import json,sys,urllib.request
from pathlib import Path
from playwright.sync_api import sync_playwright
root=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(root))
from easel.direct_api import read_settings
try:
    c=read_settings(root/".env")
    assert c.get("OPENAI_MODEL")=="claude-haiku-5-5"
    assert c.get("OPENAI_BASE_URL")=="https://api.apilio.ai/v1"
    with sync_playwright() as p:
        browser=p.chromium.launch(headless=True);browser.close()
    req=urllib.request.Request(c["OPENAI_BASE_URL"]+"/chat/completions",data=json.dumps({"model":c["OPENAI_MODEL"],"messages":[{"role":"user","content":"Reply only OK"}],"max_tokens":16}).encode(),headers={"Authorization":"Bearer "+c["OPENAI_API_KEY"],"Content-Type":"application/json"})
    with urllib.request.urlopen(req,timeout=60) as response: result=json.load(response)
    assert result.get("choices")
    print("Browser and Apilio model ready")
except Exception as e:
    print("Runtime check failed: "+type(e).__name__);sys.exit(1)
