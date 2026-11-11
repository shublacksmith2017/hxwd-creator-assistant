# 华新创作助手 v0.3.0.01 验收记录

## 本版已验证

- 上游源码固定 52806b36f5785e8f585c86ff8cf3021ac8dad34b；1195 个入包文件下载时逐项通过 Git blob SHA-1 校验。保留许可证、NOTICE、原版文档和运行所需技能资产。
- Windows 完整核心安装通过：实际安装依赖、启动独立 OpenClaw 网关、真实调用 Apilio，`easel ping` 网关和 Agent PONG 均通过。[Windows 安装记录](https://github.com/shublacksmith2017/hxwd-creator-assistant/actions/runs/43081665494)（安装修复提交 56c170f）。
- Windows 实际下载官方 EgoLite 安装包，Authenticode 为 Valid。[签名检查](https://github.com/shublacksmith2017/hxwd-creator-assistant/actions/runs/43079080425)。此项不代表已完成 Windows 图形安装向导及本人首次引导。
- 内置官方 EgoLite Skill v2.2.0 的24个文件及 MIT 许可；下载 SHA-256 与官方摘要一致，复制到隔离 Agent 工作区后逐文件校验一致。
- 本机 Haiku 实际调用文件工具写入并读回 agent-proof.txt，结果 HXWD_AGENT_FILE_OK。此项本机 OpenClaw 为现有2026.8.1，Windows安装固定2026.11.3。
- 图片由原版 ai_image.py 调用 gpt-image-2-all 真实生成，保存并查看 PNG，1254×1254，959986字节；SHA-256 ff6838520321dfcb8464088490bb130bada0a1a384dc41602a034658fd9991ed。
- EgoLite 页面检查：6个主入口可访问，技能库118项，账号页10个平台；产品名称、版本、网关已连接状态正确。账号页显示 EgoLite 操作及结果保存位置。
- 15项 Ego 路由回归覆盖10个平台登录转交、手动检查、后台请求不误启动浏览器、发布内容保留并要求确认、退出不误删全局浏览器数据。前端 TypeScript 与 Vite 构建通过。
- Windows PowerShell 5.1语法、进程退出码、Ego安装分支、缺失激活文件拒绝及配置检查在 Actions 中运行。最终打包提交对应结果见仓库 Actions。

- 本机网页对话实测：Haiku 经 EgoLite 打开本机关于页，读取真实标题/版本，写入 ego-proof.txt 并读回，结束专属浏览器空间，最终回复含可打开的产物链接。首轮模型返回空回复导致网关报错，界面点击重试后完成；不得把这种临时失败静默标为成功。

## 交付边界

- 这是 Windows 10/11 x64 联网安装包，需 GitHub/npm/PyPI/官方 EgoLite 下载可达；不是完全离线 EXE。真实员工电脑首次 EgoLite 引导、UAC和平台扫码由本人完成。
- 账号登录、账号检查和图文发布交给 EgoLite AI 对话。原版 Playwright 脚本保留供兼容参考，不会自动降级调用；后台自动拉取账号增长图表未接通 EgoLite，结果先在对话呈现。
- 未逐项实号验证全部118项技能及10个平台；未对外发布、点赞、评论、发送私信。各平台权限及页面变化需在使用时确认。
- 本版仅配置图文模型；语音、配音、视频生成、音乐不配置。
- 公共 GitHub 包没有密钥。私有内部包单独携带有限额、限模型、有效期受控的 activation.json，禁止公开上传。
