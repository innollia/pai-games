"""Read-only GLB checks plus requested contact sheet and audit report."""
from pathlib import Path
import struct, json, io, math
from PIL import Image, ImageDraw, ImageFont

W=Path(__file__).resolve().parent
OUT=W.parents[2]/'art/screenrace'
NAMES=['courier_coral','courier_blue','courier_mint','courier_gold','parcel','train','bridge_board']

def multiply(a,b):
    return [[sum(a[i][k]*b[k][j] for k in range(4)) for j in range(4)] for i in range(4)]

def transform(node):
    if 'matrix' in node:
        return [[node['matrix'][j*4+i] for j in range(4)] for i in range(4)]
    x,y,z,w=node.get('rotation',[0,0,0,1]); s=node.get('scale',[1,1,1]); t=node.get('translation',[0,0,0])
    r=[[1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)],
       [2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)],
       [2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)]]
    return [[r[i][j]*s[j] for j in range(3)]+[t[i]] for i in range(3)]+[[0,0,0,1]]

def inspect(path):
    data=path.read_bytes(); magic,version,size=struct.unpack_from('<4sII',data)
    assert (magic,version,size)==(b'glTF',2,len(data))
    n,kind=struct.unpack_from('<II',data,12); assert kind==0x4e4f534a
    doc=json.loads(data[20:20+n]); bn,bkind=struct.unpack_from('<II',data,20+n)
    assert bkind==0x004e4942; blob=data[28+n:28+n+bn]
    def accessor(index):
        a=doc['accessors'][index]; v=doc['bufferViews'][a['bufferView']]
        fmt={5121:'B',5123:'H',5125:'I',5126:'f'}[a['componentType']]
        count={'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4}[a['type']]
        item=struct.Struct('<'+fmt*count); stride=v.get('byteStride',item.size)
        offset=v.get('byteOffset',0)+a.get('byteOffset',0)
        values=[item.unpack_from(blob,offset+i*stride) for i in range(a['count'])]
        if a.get('normalized'):
            divisor={5121:255,5123:65535}[a['componentType']]
            values=[tuple(v/divisor for v in row) for row in values]
        return values
    assert len(doc['materials'])==len(doc['images'])==1
    assert 'KHR_materials_unlit' in doc['materials'][0]['extensions']
    assert all('uri' not in i for i in doc['images'])
    image=doc['images'][0]; view=doc['bufferViews'][image['bufferView']]
    start=view.get('byteOffset',0)
    atlas=Image.open(io.BytesIO(blob[start:start+view['byteLength']]))
    assert atlas.size==(512,512)
    triangles=0
    for mesh in doc['meshes']:
        for p in mesh['primitives']:
            assert p.get('mode',4)==4 and p['material']==0
            attrs=p['attributes']; assert {'POSITION','NORMAL','TEXCOORD_0','COLOR_0'}<=set(attrs)
            indices=accessor(p['indices']); positions=accessor(attrs['POSITION'])
            assert len(indices)%3==0 and max(v[0] for v in indices)<len(positions)
            assert all(math.isfinite(v) for row in positions for v in row)
            assert all(0<=u<=1 and 0<=v<=1 for u,v in accessor(attrs['TEXCOORD_0']))
            colors=accessor(attrs['COLOR_0']); assert min(c[0] for c in colors)<1
            triangles+=len(indices)//3
    coords=[]; named={n.get('name'):i for i,n in enumerate(doc['nodes'])}; worlds={}; node_points={}
    identity=[[int(i==j) for j in range(4)] for i in range(4)]
    def visit(index,parent):
        node=doc['nodes'][index]; matrix=multiply(parent,transform(node)); worlds[index]=matrix
        if 'mesh' in node:
            node_points[index]=[]
            for p in doc['meshes'][node['mesh']]['primitives']:
                for position in accessor(p['attributes']['POSITION']):
                    v=list(position)+[1]
                    point=[sum(matrix[i][j]*v[j] for j in range(4)) for i in range(3)]
                    coords.append(point); node_points[index].append(point)
        for child in node.get('children',[]): visit(child,matrix)
    for root in doc['scenes'][doc.get('scene',0)]['nodes']: visit(root,identity)
    lo=[min(p[i] for p in coords) for i in range(3)]; hi=[max(p[i] for p in coords) for i in range(3)]
    assert abs(lo[1])<.0001
    assert abs(lo[0]+hi[0])<.0001 and abs(lo[2]+hi[2])<.0001
    if path.stem.startswith('courier'):
        assert triangles<=2500 and abs(hi[1]-1)<.0001
        assert all(n in named for n in ['arm_0','arm_1','leg_0','leg_1'])
        assert [a['name'] for a in doc['animations']]==['run_loop']
        assert len(doc['animations'][0]['channels'])==4
        for channel in doc['animations'][0]['channels']:
            assert channel['target']['path']=='rotation'
        # Head+cap remains about 40 percent of native total height.
        head_bottom=min(p[1] for p in node_points[named['head']])
        assert .34 < hi[1]-head_bottom < .42
    if path.stem=='train':
        assert 'smokestack' in named and 'round_boiler' in named
        assert max(p[0] for p in node_points[named['headlamp']]) < min(p[0] for p in node_points[named['cab']])
    return {'bytes':len(data),'triangles':triangles,'materials':1,'atlas_px':list(atlas.size),
            'min_xyz':lo,'max_xyz':hi,'animation':[a['name'] for a in doc.get('animations',[])]}

report={name:inspect(OUT/(name+'.glb')) for name in NAMES}
total=sum(p.stat().st_size for p in OUT.rglob('*') if p.is_file() and
          not {'ui','sfx'}.intersection(p.relative_to(OUT).parts))
assert total<=5_000_000,total
report['total_art_bytes_excluding_ui_sfx']=total
(W/'remodel_check.json').write_text(json.dumps(report,indent=2),encoding='utf-8')

# A comparison contact sheet, not a modification of the cover or source previews.
canvas=Image.new('RGB',(2110,610),'#fff0d5'); draw=ImageDraw.Draw(canvas)
font=ImageFont.truetype('C:/Windows/Fonts/arialbd.ttf',24)
small=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',18)
cover=Image.open(W.parent/'cover.png').convert('RGB'); cover.thumbnail((630,500))
canvas.paste(cover,(18,60)); draw.text((20,20),'COVER — identity reference',font=font,fill='#34334b')
for i,team in enumerate(['coral','blue','mint','gold']):
    x=660+i*360
    im=Image.open(W/('courier_'+team+'_preview.png')).convert('RGB')
    im=im.crop((130,35,650,610)); im.thumbnail((350,470))
    canvas.paste(im,(x+(350-im.width)//2,65))
    draw.text((x+12,22),team.upper()+(' / PLAYER' if i==0 else ''),font=font,fill='#34334b')
    draw.text((x+12,550),f"{report['courier_'+team]['triangles']:,} tris / 1 material / 1 unit",font=small,fill='#34334b')
draw.text((20,582),'Cargo is assembled separately by gameplay; the courier GLBs retain the countable parcel system.',font=small,fill='#34334b')
canvas.save(W/'cover_match.png')
print(json.dumps(report,indent=2))
