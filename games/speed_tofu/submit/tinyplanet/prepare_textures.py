"""Preserve source meta, full face lists, and the exact image-generation prompts."""
from pathlib import Path
import json
import subprocess
HERE=Path(__file__).parent
SOURCE=Path('C:/projects/hwapongstuy/texture3d')
meta=(SOURCE/'TEXTURE_META.md').read_text(encoding='utf-8')
negative=meta.split('```')[3].strip()
style='Postcard Planets: matte gouache, broad flat brush planes, one bold mark per face. Cream #fff6e6, navy #2b2d42, yellow #ffd166, pink coral #ff8a80, mint #8fe3c2, lavender #b9a7f2, sky #9fd3ff. Red #e8453c exclusively for danger red_rock and meteor. No gloss, smooth gradients, speckles, tiny patterns, letters or runes.'
for folder in sorted((HERE/'work/out').glob('tp_*')):
    subprocess.run(['python',str(SOURCE/'tools/build_message.py'),str(HERE/'work/out'),folder.name],check=True)
    message=folder/'message.md'
    message.write_text(message.read_text(encoding='utf-8')+'\n'+style,encoding='utf-8')
    data=json.loads((folder/'layout.json').read_text(encoding='utf-8'))
    lines=[]
    for island in data['islands']:
        lines.append(f"{island['key']}: {island['hint']}\nExact polygons in 1024 pixel coordinates: "+json.dumps(island['faces'],separators=(',',':')))
    prompt='[IMAGE] Square 1024x1024 game texture atlas for a low-poly '+data['title']+'.\n[LAYOUT] Text-only exact UV layout below replaces the attached line image. All coordinates are pixels from upper left on a 1024 square. Keep each polygon at these coordinates. Fill polygons edge to edge. Outside polygons flat #808080. Side panel image up equals world up. Flat surfaces only. No model preview.\n[SURFACES]\n'+'\n'.join(lines)+'\n[LIGHT] Broad flat painted light from above: top cream, lower edge muted shadow; thin pale edge.\n[PALETTE] '+style+'\n[NEGATIVE]\n'+negative+'\nNo perspective, no shading that implies a 3D view inside a face.\nNo text or labels.'
    (folder/'prompt.txt').write_text(prompt,encoding='utf-8')
print('Prepared 15 prompts with verbatim TEXTURE_META anti-slop.')
