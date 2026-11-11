"""Validate internal activation and merge known settings without printing secrets."""
import json, os, sys
from pathlib import Path

def configure(root, activation):
    root, activation = Path(root), Path(activation)
    c = json.loads(activation.read_text(encoding="utf-8-sig"))
    key = c.get("apiKey", "")
    if not isinstance(key, str) or len(key) < 16 or any(x.isspace() for x in key):
        raise ValueError("Invalid activation credential")
    if c.get("baseUrl") != "https://api.apilio.ai/v1" or c.get("model") != "claude-haiku-5-5":
        raise ValueError("Unexpected activation endpoint/model")
    values = {"OPENAI_API_KEY":key, "OPENAI_BASE_URL":c["baseUrl"], "OPENAI_MODEL":c["model"],
              "CLAUDE_MODEL":"openai/claude-haiku-5-5", "EASEL_CHAT_TRANSPORT":"http", "EASEL_BROWSER_PROVIDER":"egolite", "IMG_API_KEY":key, "IMG_BASE_URL":"https://api.apilio.ai/v1", "IMG_MODEL":"gpt-image-2-all"}
    p = root / ".env"
    lines = p.read_text(encoding="utf-8-sig").splitlines() if p.exists() else ["EASEL_PUBLISH_MODE=automated"]
    lines = [l for l in lines if l.split("=",1)[0].strip() not in values]
    lines += [k+"="+v for k,v in values.items()]
    tmp=p.with_suffix(".env.tmp")
    fd=os.open(tmp,os.O_WRONLY|os.O_CREAT|os.O_TRUNC,0o600)
    with os.fdopen(fd,"w",encoding="utf-8") as f: f.write("\n".join(lines)+"\n")
    os.replace(tmp,p)
    return p

if __name__ == "__main__":
    try:
        configure(sys.argv[1],sys.argv[2]); print("Apilio Haiku 5.5 configured; credential hidden")
    except Exception as e:
        print("Activation failed: "+type(e).__name__,file=sys.stderr);sys.exit(1)
