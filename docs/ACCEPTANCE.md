# 验收记录

- 2026-11-12：上游 1195 个入包文件下载时逐项通过 Git blob SHA-1 校验；上游源码 commit 52806b36f5785e8f585c86ff8cf3021ac8dad34b。
- Apilio 独立有限额模型令牌：claude-haiku-5-5 工具调用测试通过，返回 report_ready({"status":"OK"})。未复用 CRM 密钥，密钥未入库。
- Windows 自动化与前端构建结果：以仓库 Actions 最近执行结果及后续本记录为准。
- 尚需真实员工 Windows 电脑完成首次安装、本人扫码和业务操作验收。未执行对外发布、评论或私信。
- 图文范围：gpt-image-2-all 已由原版 ai_image.py 发起真实请求，成功保存并人工查看 PNG。配音、语音转写、视频、音乐按用户要求不配置。

- 前端 npm audit fix 后 0 漏洞，生产构建通过；46 项相关 Python 回归测试通过。
- EgoLite 实际检查：6 个主入口可访问，技能库显示 118 项、账号页显示 10 个平台，品牌和版本显示正确。这里只证明入口及代码保留，未逐项跑完 118 个技能。
- GitHub Windows PowerShell 5.1 语法、缺失激活文件拒绝、配置回归及 Linux 前端构建已通过。完整 Windows 安装测试另行记录。

- EgoLite 集成：官方 Windows 下载入口已确认；Windows 安装向导新增复用、签名校验、本人初始化、CLI 检查，启动器改用 EgoLite。缺失初始化不算通过，平台脚本适配仍待完成。
- Windows 第二轮完整安装：依赖和实际模型调用通过；Agent 原生入口解析失败（npm 全局目录与 Node 不同目录），已增加修复及回归，待 Windows 重跑。
