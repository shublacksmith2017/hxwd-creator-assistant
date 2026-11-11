"""Ego UI routes must not spawn old browsers or treat background checks as user actions."""
import asyncio
import sys
from pathlib import Path
import pytest
from fastapi import HTTPException
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'web'))
import app

@pytest.fixture(autouse=True)
def ego(monkeypatch):
    monkeypatch.setattr(app, 'read_settings', lambda *a: {'EASEL_BROWSER_PROVIDER': 'egolite', 'EASEL_PUBLISH_MODE': 'automated'})
    def forbidden(*a, **kw):
        raise AssertionError('Legacy browser subprocess was launched')
    monkeypatch.setattr(app.subprocess, 'Popen', forbidden)
    monkeypatch.setattr(app.subprocess, 'run', forbidden)

@pytest.mark.parametrize('platform', list(app.LOGIN_RUNNERS))
def test_login_goes_to_explicit_ego_chat(platform):
    with pytest.raises(HTTPException) as exc:
        asyncio.run(app.api_login_start(platform))
    assert exc.value.status_code == 409
    assert exc.value.detail['code'] == 'ego_required'
    assert app.LOGIN_RUNNERS[platform]['name'] in exc.value.detail['prompt']


def test_background_whoami_does_not_start_ai_or_browser():
    with pytest.raises(HTTPException) as exc:
        asyncio.run(app.api_account_whoami('xiaohongshu', False))
    assert isinstance(exc.value.detail, str)


def test_manual_whoami_routes_to_ego():
    with pytest.raises(HTTPException) as exc:
        asyncio.run(app.api_account_whoami('xiaohongshu', True))
    assert exc.value.detail['code'] == 'ego_required'


def test_publish_keeps_exact_content_and_requires_review():
    request = app.PublishRequest(title='内部验收标题', body='仅用于测试，不得发送', media=[])
    with pytest.raises(HTTPException) as exc:
        asyncio.run(app.api_publish('zhihu', request))
    detail = exc.value.detail
    assert detail['code'] == 'ego_required'
    assert '内部验收标题' in detail['prompt']
    assert '最终确认' in detail['prompt']


def test_logout_does_not_delete_other_browser_data():
    with pytest.raises(HTTPException) as exc:
        asyncio.run(app.api_logout('xiaohongshu'))
    assert exc.value.detail['code'] == 'ego_required'
    assert '不删除其他平台' in exc.value.detail['prompt']


def test_accounts_never_reuse_legacy_login_marker(monkeypatch):
    monkeypatch.setattr(app, '_wechat_has_credentials', lambda: True)
    rows = asyncio.run(app.api_accounts())
    assert all(r['browserProvider']=='egolite' and not r['loggedIn'] for r in rows)
