# 华新创作助手 · Windows

为华新同事准备的本机内容创作工具。基于 Easel 完整应用源码，保留原版账号、技能、Agent、创作和发布界面。日常模型预设 **Apilio / claude-haiku-5-5**。

## 下载与安装

1. 打开 [Releases](https://github.com/shublacksmith2017/hxwd-creator-assistant/releases)，下载 `HXWD-Creator-Assistant-Windows-0.3.0.01.zip`。
2. 解压到普通本地目录，不要在 ZIP 内直接双击。向舒老师领取内部 `activation.json`，放在 `安装.cmd` 同目录。内部完整包已包含该文件时不需再放。
3. 双击 `安装.cmd`，允许必要的系统软件安装。首次需要联网，自动安装 Python、Node、Git、FFmpeg、Agent 和 Chromium 并构建前端。
4. 安装通过后，从桌面「华新创作助手」启动，地址 `http://127.0.0.1:17860`。
5. 在账号页面本人扫码登录平台。不需要填写 API 地址和模型，不需要把密码、Key 或登录状态发送给 AI。

这是联网安装包，尚不是离线 EXE。支持目标为 Windows 10/11 x64；旧系统需可用的 winget（Microsoft App Installer）。GitHub、npm、PyPI、Chromium 下载须可达。遇到网络失败修复网络后重跑，不要跳过缺失功能。

## 给同事的 AI

复制 [AI 安装执行说明](docs/AI-INSTALL.md) 全文给同事的 AI，AI 可完成下载、解压、安装、检查和交接。扫码由本人完成。安装不自动发布内容、评论或私信。

## 功能范围与边界

- 保留全部上游 Python、React、技能和浏览器执行代码，版本固定为 `52806b36f5785e8f585c86ff8cf3021ac8dad34b`。
- OpenClaw 固定 `2026.11.3`，保留文件、浏览器及技能执行能力，未降级为仅聊天。
- 预设 Haiku 5.5 文字模型；图片、视频等独立收费服务仍需在技能设置接入相应供应商。界面和功能代码保留，不宣称仅一个文字 Key 就能运行所有媒体生成。
- 上游约 400MB 的说明书/示例视频不重复打入包，演示媒体保留上游链接；不影响用户自己的素材保存及处理。字体和技能执行资产保留。
- 账号、作品、会话、密钥保存本机。程序位于 `%LOCALAPPDATA%\HuaxinCreatorAssistant\app`；Agent 沿用独立 `.openclaw-easel` profile，检测到非本发行版已有配置会停止，避免覆盖。
- 本机服务仅绑定 `127.0.0.1`；不要对公网开放或转发端口。

## 凭证与费用

GitHub 源码和 Release 均不含真实 API Key。内部激活文件独立交付，安装器会写入本机私有配置。当前试用令牌限定 Haiku 5.5、有配额和有效期；多人使用时共享这个试用额度，不等同于每人独立额度。正式按人发放时可使用相同安装包搭配不同激活文件。

配额不足或到期需要管理员更新激活文件；软件不会偷偷切换其他模型。禁止上传 `.env`、`activation.json`、浏览器数据、日志或作品到公开仓库。

## 故障与更新

运行 `诊断.cmd`：检查依赖、Chromium、本机 Agent 和模型真实调用。只有检查通过才创建桌面快捷方式并显示安装完成。

升级前备份本机 `.env`、data、outputs、profiles 和 `.openclaw-easel`。安装器保留本机数据目录；当前版本不提供无人值守自动更新或数据库迁移。退出旧程序后再手动安装，失败恢复备份，不删除用户资料。

## 开源来源

修改说明见 [NOTICE](NOTICE)，原版文档见 [README.upstream.md](README.upstream.md)，许可证见 [LICENSE](LICENSE)。内部模块名仍用 easel，以减少对上游兼容性的影响。

## 验证

见 [验收记录](docs/ACCEPTANCE.md)。自动化检查与真实办公电脑、平台扫码、发布操作分别记录；未验证项目不会标为已通过。
