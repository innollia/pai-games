from pathlib import Path
from PIL import Image,ImageDraw
root=Path(__file__).parent/'work'
files=sorted((root/'out').glob('*/preview.png'))
out=Image.new('RGB',(1280,840),'#f5eedf'); d=ImageDraw.Draw(out)
for i,f in enumerate(files):
    x=(i%5)*256;y=(i//5)*280
    out.paste(Image.open(f).convert('RGB').resize((256,256)),(x,y))
    d.text((x+8,y+260),f.parent.name,fill='#2b2d42')
out.save(root/'contact_sheet.png')
