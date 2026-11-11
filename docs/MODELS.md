# 本版模型配置

仅解决图文创作，按用户确认配置：

| 能力 | 服务 | 模型 | 自动写入配置 |
| --- | --- | --- | --- |
| 策划、文案、Agent 工具调用 | Apilio | claude-haiku-5-5 | OPENAI_BASE_URL / OPENAI_MODEL / OPENAI_API_KEY |
| AI 配图 | Apilio | gpt-image-2-all | IMG_BASE_URL / IMG_MODEL / IMG_API_KEY |

两项接口根地址为 https://api.apilio.ai/v1。安装器从内部 activation.json 取得调用令牌。凭证只写本机，不进入仓库或公开下载包。

配音、语音转写、视频和音乐均不配置。相关代码和界面保留，使用时仍需另行授权配置；本版不自动选替代服务。

管理员试用令牌限定上述两个模型、设置有效期和调用额度。到期或额度不足时应更新内部激活配置，不能用后台管理 Access Token 代替调用 Key，也不能未经授权改用个人密钥。

检查命令（在已安装目录，由 AI 或管理员执行）：

```powershell
.venv\Scripts\python.exe skills\shared\scripts\ai_image.py check
```

真实图文测试会消费额度。日常安装诊断只发最小文字请求并检查浏览器，不自动生成图片；首次业务验收可生成一张图片确认本机保存。
