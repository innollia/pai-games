"""Align 2D GPT paint to the existing UV polygons; never repaint source assets.

The generator preserved net topology but shifted/scaled islands. Measured crop
boxes refer to the preserved 1254px generated.png originals in work/out/b6_*.
"""
from pathlib import Path
import json
from PIL import Image, ImageDraw

ROOT = Path(__file__).parent / 'work' / 'out'
CROPS = {
    'coast': [[(318,535,625,840), (625,535,930,840), (930,535,1234,840),
               (20,535,318,840), (318,235,625,535), (318,840,625,1150)]],
    'plank': [[(317,440,624,774), (624,440,932,774), (932,440,1241,774),
               (13,440,317,774), (317,130,624,440), (317,774,624,1088)]],
    'temple': [
        [(230,907,510,982), (510,907,717,982), (717,907,1017,982),
         (28,907,230,982), (230,734,510,907), (230,982,510,1154)],
        [(128,418,172,598), (172,418,274,598), (274,418,315,598),
         (28,418,128,598), (128,299,172,418), (128,598,172,718)],
        [(505,492,779,546), (779,492,945,546), (945,492,1228,546),
         (340,492,505,546), (505,359,779,492), (505,546,779,693)],
        [(28,154,320,266)], [(329,184,510,266)],
    ],
}


def align(name):
    folder = ROOT / ('b6_' + name)
    source = Image.open(folder / 'generated.png').convert('RGB')
    assert source.size == (1254, 1254), source.size
    layout = json.loads((folder / 'layout.json').read_text())
    output = Image.new('RGB', (1024, 1024), '#808080')
    if name == 'crystal':
        xs = [21,263,505,747,989,1230]
        crops = [[(xs[i],342,xs[i+1],1145) for i in range(5)] +
                 [(xs[i],110,xs[i+1],342) for i in range(5)]]
    elif name == 'pot':
        # Side faces are listed bottom row first, eight columns per row.
        crops = [[(round(16+i*1223/8), y0, round(16+(i+1)*1223/8), y1)
                  for y0,y1 in [(1080,1167),(806,1080),(708,806),(550,708)]
                  for i in range(8)], [(136,14,664,542)], [(711,117,1113,535)]]
    else:
        crops = CROPS[name]
    for island, boxes in zip(layout['islands'], crops, strict=True):
        for face, box in zip(island['faces'], boxes, strict=True):
            x0, y0 = [round(min(v[i] for v in face)) for i in range(2)]
            x1, y1 = [round(max(v[i] for v in face)) for i in range(2)]
            mask = Image.new('L', (x1-x0, y1-y0))
            ImageDraw.Draw(mask).polygon([(round(x-x0),round(y-y0)) for x,y in face],fill=255)
            paint = source.crop(box).resize(mask.size, Image.Resampling.LANCZOS)
            output.paste(paint, (x0,y0), mask)
    output.save(folder / 'texture.png')
    print('aligned GPT paint:', name)


if __name__ == '__main__':
    import sys
    for name in sys.argv[1:]:
        align(name)
