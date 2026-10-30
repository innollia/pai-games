"""Stage only finished GPT textures, then use hwapongstuy render_preview.py unchanged."""
from pathlib import Path
import shutil
import subprocess
import sys

HERE = Path(__file__).parent
stage = HERE / 'work' / 'previews'
for image in (HERE / 'work' / 'out').glob('b6_*/texture.png'):
    target = stage / image.parent.name
    target.mkdir(parents=True, exist_ok=True)
    for file in ['model.glb', 'texture.png']:
        shutil.copy2(image.parent / file, target / file)
subprocess.run(['C:/Program Files/Blender Foundation/Blender 5.2/blender.exe', '--background',
                '--python', 'C:/projects/hwapongstuy/texture3d/tools/render_preview.py', '--', str(stage)], check=True)
