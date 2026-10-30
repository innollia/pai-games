from pathlib import Path
from PIL import Image,ImageDraw
import json,colorsys
W=Path(__file__).resolve().parent
d=W/'pipeline/out/screenrace_courier'
im=Image.open(d/'texture.png').convert('RGB').resize((1024,1024),Image.Resampling.LANCZOS)
layout=json.loads((d/'layout.json').read_text(encoding='utf-8'))
mask=Image.new('L',im.size); draw=ImageDraw.Draw(mask)
for isl in layout['islands']:
    if isl['name'] in ['jacket','cap','brim','sleeve_0','sleeve_1']:
        for poly in isl['faces']: draw.polygon([tuple(p) for p in poly],fill=255)
for variant,hue in [('coral',.015),('blue',.59),('mint',.43),('gold',.115)]:
    result=im.copy(); pixels=result.load(); active=mask.load()
    if variant!='coral':
        for y in range(1024):
            for x in range(1024):
                if not active[x,y]: continue
                r,g,b=pixels[x,y]; h,s,v=colorsys.rgb_to_hsv(r/255,g/255,b/255)
                if (h<.055 or h>.95) and s>.30:
                    nr,ng,nb=colorsys.hsv_to_rgb(hue,s*.88,v*.95)
                    pixels[x,y]=(round(nr*255),round(ng*255),round(nb*255))
    result.save(W/('courier_'+variant+'.jpg'),quality=90,subsampling=0,optimize=True)
props=W/'pipeline/out/screenrace_props/texture.png'
if props.exists(): Image.open(props).convert('RGB').resize((1024,1024),Image.Resampling.LANCZOS).save(W/'props_atlas.jpg',quality=91,subsampling=0,optimize=True)
