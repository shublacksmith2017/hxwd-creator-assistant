"""Build credential-free release from tracked source and tested frontend output."""
from pathlib import Path
import hashlib,json,subprocess,zipfile
root=Path(__file__).resolve().parents[1]
version=json.loads((root/'distribution/version.json').read_text())['version']
out=root/'release-artifacts';out.mkdir(exist_ok=True)
name=f'HXWD-Creator-Assistant-Windows-{version}'
files=[root/p for p in subprocess.check_output(['git','ls-files','-z'],cwd=root).decode().split('\0') if p]
files += [p for p in (root/'web/frontend/dist').rglob('*') if p.is_file()]
assert any(p.name=='index.html' and 'dist' in p.parts for p in files),'Build frontend first'
for p in files:
 assert p.name not in ['.env','activation.json'], 'Secret file in release'
with zipfile.ZipFile(out/(name+'.zip'),'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p in files:z.write(p,name+'/'+p.relative_to(root).as_posix())
archive=out/(name+'.zip');digest=hashlib.sha256(archive.read_bytes()).hexdigest()
(out/'SHA256SUMS.txt').write_text(digest+'  '+archive.name+'\n')
print(json.dumps({'file':str(archive),'bytes':archive.stat().st_size,'sha256':digest}))
