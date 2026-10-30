"""Align preserved GPT paint crops to hwapongstuy faces; no hand painting.
All crop coordinates refer to the unmodified 1254-square generated.png files.
"""
from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageChops
ROOT=Path(__file__).parent/'work/out'
def grid(x0,x1,ys,n):
    return [(round(x0+i*(x1-x0)/n)+2,ys[r]+2,round(x0+(i+1)*(x1-x0)/n)-2,ys[r+1]-2) for r in reversed(range(len(ys)-1)) for i in range(n)]
def net(front,right,back,left,top,bottom):
    return [front,right,back,left,top,bottom]
def repeated(box,n): return [box]*n
S={
 'traveler':{
  'boots':net((145,518,235,590),(239,518,323,590),(326,518,431,590),(37,518,139,590),(147,419,229,507),(148,599,230,703)),
  'body':grid(350,1015,[790,988,1192],8), 'body top':[(700,234,852,371)], 'body bottom':[(1072,532,1195,655)],
  'head':grid(468,1014,[469,534,649,707],8), 'head top':[(1072,327,1146,382)], 'head bottom':[(910,292,1018,385)],
  'scarf':grid(30,648,[121,167],8),'scarf top':[(58,216,201,353)],'scarf bottom':[(277,216,425,352)],
  'scarf tail':repeated((518,241,559,357),6),
  'folded sail':net((94,798,154,1118),(180,798,203,1118),(210,798,303,1118),(38,798,84,1118),(95,744,154,778),(97,1133,155,1177)),
 },
 'villager':{
  'boots':net((891,995,969,1100),(986,995,1075,1100),(1081,995,1216,1100),(762,995,875,1100),(891,876,964,979),(891,1114,966,1203)),
  'body':grid(30,729,[827,1032,1210],8),'body top':[(53,319,189,441)],'body bottom':[(960,587,1156,764)],
  'head':grid(350,905,[515,590,723,790],8),'head top':[(445,346,552,445)],'head bottom':[(258,345,379,443)],
  'hat':grid(32,740,[130,180,231,256],8),'hat top':[(786,159,872,244)],'hat bottom':[(62,535,267,718)],
 },
 'windmill_tower':{'tower':grid(34,710,[377,449,1179],8),'tower top':[(1069,178,1203,295)],'tower bottom':[(790,921,1013,1139)],'cap':grid(248,1009,[137,344],8),'cap bottom':[(49,160,209,293)]},
 'windmill_blades':{'spar':repeated((80,252,112,1146),6),'canvas':repeated((508,550,576,645),6),'hub':grid(32,590,[53,173],8),'hub top':[(694,1041,809,1152)],'hub bottom':[(880,1041,999,1152)]},
 'chimney_house':{'walls':grid(246,1221,[543,815],8),'walls top':[(488,942,665,1127)],'walls bottom':[(818,943,1019,1125)],'roof':grid(33,1190,[258,477],8),'roof bottom':[(100,900,331,1117)],'chimney':net((80,580,122,769),(129,580,168,769),(177,580,213,769),(39,580,72,769),(84,512,113,531),(83,784,120,810))},
 'rock':{'rock':repeated((161,341,295,479),21),'rock top':[(156,226,264,284)],'rock bottom':[(140,485,260,541)]},
 'red_rock':{'red_rock':grid(35,736,[397,701,1004,1212],7),'red_rock top':[(101,130,217,245)],'red_rock bottom':[(96,217,218,307)],'spike':grid(769,1227,[506,710,1210],5),'spike bottom':[(328,247,404,334)]},
 'tower':{'stone':grid(36,944,[718,1137,1180,1217],8),'stone top':[(91,158,248,300)],'stone bottom':[(864,497,1040,662)],'top':grid(39,1091,[39,95],8),'top top':[(110,445,324,635)],'top bottom':[(479,445,691,635)]},
 'rose':{'stem':grid(30,189,[397,1214],5),'stem top':[(911,318,950,353)],'stem bottom':[(995,323,1033,354)],'leaf':grid(30,401,[87,215,365],5),'leaf bottom':[(1080,324,1110,353)],'bloom':grid(213,1225,[604,728,923,1213],7),'bloom top':[(473,208,602,325)],'bloom bottom':[(716,215,838,325)]},
 'glass_flower':{'stem':grid(30,300,[623,1160],5),'stem top':[(191,148,239,199)],'stem bottom':[(315,150,364,199)],'leaf':grid(358,949,[714,925,1161],5),'leaf bottom':[(424,153,466,199)],'bloom':grid(31,867,[235,318,448,593],7),'bloom top':[(937,337,1178,548)],'bloom bottom':[(43,101,145,188)]},
 'glass_dome':{'rim':repeated((171,471,241,493),10),'rim top':[(174,471,233,490)],'rim bottom':[(174,471,233,490)],'glass':grid(34,793,[824,911,1016,1214],10),'glass top':[(811,731,873,783)],'glass bottom':[(480,541,729,739)]},
 'parcel':{'parcel':net((283,634,630,931),(638,634,875,931),(886,634,1224,931),(31,634,273,931),(286,394,627,625),(285,942,627,1167)),'knot':repeated((91,239,146,276),6),'seal':grid(526,757,[263,294],6),'seal top':[(316,248,359,293)],'seal bottom':[(409,258,455,299)]},
 'meteor':{'meteor':grid(33,1219,[578,808,1027,1215],7),'meteor top':[(469,463,543,534)],'meteor bottom':[(112,202,321,407)]},
 'tree':{'trunk':grid(33,361,[65,478],7),'trunk top':[(687,401,743,454)],'trunk bottom':[(823,412,865,454)],'crown':grid(35,1219,[503,668,887,1042,1221],9),'crown top':[(960,403,1004,434)],'crown bottom':[(424,306,559,430)]},
 'wall':{'course':net((235,877,620,1010),(636,877,822,1010),(838,877,1218,1010),(38,877,222,1010),(239,695,615,865),(239,1026,615,1182)),'cap':net((234,394,620,445),(636,394,821,445),(838,394,1218,445),(38,394,220,445),(240,195,615,382),(240,458,615,633))},
}
def align(name):
    folder=ROOT/('tp_'+name)
    source=Image.open(folder/'generated.png').convert('RGB')
    assert source.size==(1254,1254),source.size
    layout=json.loads((folder/'layout.json').read_text())
    out=Image.new('RGB',(1024,1024),'#808080')
    coverage=Image.new('L',out.size)
    for island in layout['islands']:
        boxes=S[name][island['key']]
        assert len(boxes)==len(island['faces']),(name,island['key'])
        # Move generated eye panels onto the two forward facets, never redraw eyes.
        if island['key']=='head':
            order=[0,1,2,3,6,4,5,7]
            boxes=[boxes[r*8+order[c]] for r in range(3) for c in range(8)]
        for face,crop in zip(island['faces'],boxes,strict=True):
            x0,y0=[round(min(v[i] for v in face)) for i in range(2)]
            x1,y1=[round(max(v[i] for v in face)) for i in range(2)]
            mask=Image.new('L',(max(1,x1-x0),max(1,y1-y0)))
            ImageDraw.Draw(mask).polygon([(round(x-x0),round(y-y0)) for x,y in face],fill=255)
            paint=source.crop(crop).resize(mask.size,Image.Resampling.LANCZOS)
            out.paste(paint,(x0,y0),mask)
            coverage.paste(255,(x0,y0),mask)
    # Extrude painted edge pixels into a 3px gutter to keep gray out of mip edges.
    for _ in range(3):
        # Nearest paint is extended by masked neighbor copies, no new colors.
        grown=out.copy()
        grownmask=coverage.copy()
        for dx,dy in [(-1,0),(1,0),(0,-1),(0,1)]:
            shifted=Image.new('RGB',out.size)
            shifted.paste(out,(dx,dy))
            sm=Image.new('L',out.size); sm.paste(coverage,(dx,dy))
            take=ImageChops.subtract(sm,grownmask)
            grown.paste(shifted,(0,0),take)
            grownmask=ImageChops.lighter(grownmask,sm)
        out,coverage=grown,grownmask
    out.save(folder/'texture.png')
    (folder/'alignment.json').write_text(json.dumps(S[name],indent=2))
    print('aligned GPT paint:',name)
if __name__=='__main__':
    import sys
    for name in sys.argv[1:] or S: align(name)
