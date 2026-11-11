import json,sys,urllib.request
from pathlib import Path
import argparse, shutil, subprocess
root=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(root))
from easel.direct_api import read_settings
parser=argparse.ArgumentParser()
parser.add_argument('--model-only', action='store_true', help='CI core check; does not validate EgoLite or full installation')
args=parser.parse_args()
try:
    c=read_settings(root/".env")
    assert c.get("OPENAI_MODEL")=="claude-haiku-5-5"
    assert c.get("OPENAI_BASE_URL")=="https://api.apilio.ai/v1"
    if not args.model_only:
        command=shutil.which('ego-browser')
        assert command, 'EgoLite onboarding required'
        check=subprocess.run([command,'nodejs','-e',"console.log('HXWD_EGO_READY')"],capture_output=True,text=True,timeout=60)
        assert check.returncode == 0 and 'HXWD_EGO_READY' in check.stdout
    req=urllib.request.Request(c["OPENAI_BASE_URL"]+"/chat/completions",data=json.dumps({"model":c["OPENAI_MODEL"],"messages":[{"role":"user","content":"Reply only OK"}],"max_tokens":16}).encode(),headers={"Authorization":"Bearer "+c["OPENAI_API_KEY"],"Content-Type":"application/json"})
    with urllib.request.urlopen(req,timeout=60) as response: result=json.load(response)
    assert result.get("choices")
    print("Apilio model ready; EgoLite not checked" if args.model_only else "EgoLite and Apilio model ready")
except Exception as e:
    print("Runtime check failed: "+type(e).__name__);sys.exit(1)
