import json,re
from pathlib import Path
w=Path(__file__).resolve().parent
meta=Path('C:/projects/hwapongstuy/texture3d/TEXTURE_META.md').read_text(encoding='utf-8')
negative=meta.split('## ANTI-SLOP (')[1].split('```')[1].strip()
for name in ['screenrace_courier','screenrace_props']:
    d=w/'pipeline/out'/name
    layout=json.loads((d/'layout.json').read_text(encoding='utf-8'))
    surfaces=[]
    for isl in layout['islands']:
        x0,y0,x1,y1=isl['rect_px']
        surfaces.append(f"{isl['key']}: x={x0}..{x1}, y={y0}..{y1} pixels. Paint {isl['hint']}. Shared copies: {isl['used_by']}.")
        if len(isl['labels'])==len(isl['faces']):
            for label,poly in zip(isl['labels'],isl['faces']):
                xs,ys=zip(*poly)
                surfaces.append(f"  {label[0]}: x={min(xs):.1f}..{max(xs):.1f}, y={min(ys):.1f}..{max(ys):.1f} pixels.")
    prompt='''[IMAGE]
Square 1024 by 1024 game texture atlas for a low-poly 3D model, painted onto the attached UV layout. Pocket Parcel Town: matte gouache on folded paper toys, large confident colour shapes and sparse hand-painted seams.
[LAYOUT]
The attached line image is the exact layout. Keep every polygon in exactly its original position, size and orientation. Coordinates below use pixel origin at top left. Do not move, rotate or stretch islands.
Outside the polygons use only flat middle grey #808080. Fill each polygon to its edges. The thin black guide lines are folding boundaries, not part of the final paint. All sides are flat surface paintings, image top is world up. No perspective views or miniature objects inside polygons. Box nets: FRONT in middle, LEFT to its left, RIGHT to its right, BACK beyond RIGHT, TOP above FRONT, BOTTOM below. Avoid doubled corner decorations.
[SURFACES]
'''+ '\n'.join(surfaces)+'''
[LIGHT]
Paint light from above: top faces lightest, side lower edges cooler and darker, narrow warm cream highlights at upper edges. Use stepped broad brush shapes rather than smooth gradients. Eye and clothing details must read at small mobile scale. Paint only requested faces, no extra faces on blank skin sides.
[PALETTE]
Warm paper #FFF0D5, ink navy #34334B, coral #E86758, cardboard #DDA56A, butter tape #F8D58A, peach skin #F2C098, sage #62AD91, slate blue #508CC8. Keep skin and coral clothing clearly separate.
[NEGATIVE]
'''+negative+'''
No perspective, no shading that implies a 3D view inside a face.
No text or labels.
'''
    (d/'prompt.txt').write_text(prompt,encoding='utf-8')
