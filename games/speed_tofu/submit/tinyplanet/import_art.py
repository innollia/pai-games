"""Import all production assets once inside an isolated project (write boundary)."""
from pathlib import Path
import os,json,shutil,subprocess
HERE=Path(__file__).parent.resolve()
WORK=HERE/'work'
ART=HERE.parents[1]/'art/tinyplanet'
# Query running engines immediately before launching; no install preflight.
r=subprocess.run(['powershell','-NoProfile','-Command',"@(Get-Process -Name '*Godot_v4.7.2*' -ErrorAction SilentlyContinue).Count"],capture_output=True,text=True)
if r.stdout.strip()!='0':
    (WORK/'import_status.json').write_text(json.dumps({'status':'skipped','reason':'another Godot_v4.7.2 process is running','query':r.stdout.strip()}))
    print('Import skipped: running Godot process.')
    raise SystemExit(0)
root=WORK/'import_project'
(root/'art/tinyplanet').mkdir(parents=True,exist_ok=True)
(root/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Tinyplanet asset validation"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
for path in ART.iterdir():
    if path.suffix in ['.glb','.png']: shutil.copy2(path,root/'art/tinyplanet'/path.name)
exe=Path(os.environ['LOCALAPPDATA'])/'Temp/opencode/godot/Godot_v4.7.2-stable_win64_console.exe'
env=os.environ.copy()
for key in ['APPDATA','LOCALAPPDATA','TEMP','TMP']:
    dest=WORK/'import_environment'/key
    dest.mkdir(parents=True,exist_ok=True)
    env[key]=str(dest)
with (WORK/'import.log').open('w',encoding='utf-8') as log:
    result=subprocess.run([str(exe),'--headless','--path','.','--import','--log-file',str(WORK/'godot.log')],cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=180)
sidecars=list((root/'art/tinyplanet').glob('*.import'))
status={'status':'passed' if len(sidecars)==30 else 'failed','exit_code':result.returncode,'sidecars':len(sidecars),'project':str(root),'scope':'isolated import of exact production asset copies; game project untouched'}
(WORK/'import_status.json').write_text(json.dumps(status,indent=2))
print(status)
assert len(sidecars)==30,status
