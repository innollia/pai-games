"""Verify shipped GLB buffers and pixels; no Godot or game screenshots."""
from pathlib import Path
import json,struct
from PIL import Image
HERE=Path(__file__).parent
ART=HERE.parents[1]/'art/tinyplanet'
HEIGHTS={'traveler':1.6,'villager':1.6,'windmill_tower':9,'windmill_blades':7.2,'chimney_house':2.6,'rock':1,'red_rock':5.6,'tower':2.5,'rose':1.4,'glass_flower':.6,'glass_dome':.8,'parcel':.55,'meteor':1.2,'tree':2.4,'wall':1}
expected={name+ext for name in HEIGHTS for ext in ['.glb','.png']}
assert {p.name for p in ART.iterdir() if p.suffix in ['.glb','.png']}==expected
assert not list(ART.rglob('.gdignore'))
manifest=json.loads((HERE/'ASSET_MANIFEST.json').read_text())
assert {r['path'] for r in manifest}==expected
for row in manifest: assert (ART/row['path']).stat().st_size==row['bytes']
records=[]
for name,height in HEIGHTS.items():
    with Image.open(ART/(name+'.png')) as im:
        assert im.size==(512,512) and im.mode=='P',(name,im.size,im.mode)
    data=(ART/(name+'.glb')).read_bytes()
    magic,version,length,chunk,kind=struct.unpack_from('<5I',data)
    assert (magic,version,length,kind)==(0x46546c67,2,len(data),0x4e4f534a)
    doc=json.loads(data[20:20+chunk])
    assert not doc.get('images') and not doc.get('textures') and not doc.get('materials'),name
    assert len(doc['meshes'])==1,name
    assert all(not n.get('translation') and not n.get('rotation') and not n.get('scale') and not n.get('matrix') for n in doc['nodes']),name
    primitives=doc['meshes'][0]['primitives']; assert len(primitives)==1
    p=primitives[0]; attrs=p['attributes']; assert 'TEXCOORD_0' in attrs
    pos=doc['accessors'][attrs['POSITION']]; lo=pos['min']; hi=pos['max']; span=[hi[i]-lo[i] for i in range(3)]
    tris=doc['accessors'][p['indices']]['count']//3
    assert 40<=tris<=300,(name,tris)
    assert abs(span[1]-height)<.001,(name,span,height)
    assert abs(lo[0]+hi[0])<.001 and abs(lo[2]+hi[2])<.001,(name,lo,hi)
    if name in ['meteor','windmill_blades']: assert abs(lo[1]+hi[1])<.001,(name,lo,hi)
    else: assert abs(lo[1])<.001,(name,lo)
    if name=='wall': assert abs(span[0]-1)<.001 and abs(span[2]-.5)<.001
    if name=='windmill_blades': assert abs(span[0]-7.2)<.001 and span[2]<.5,(name,span)
    # Decode UVs: finite, in 0..1, not collapsed.
    uv=doc['accessors'][attrs['TEXCOORD_0']]; view=doc['bufferViews'][uv['bufferView']]
    start=20+chunk+8+view.get('byteOffset',0)+uv.get('byteOffset',0)
    values=[struct.unpack_from('<2f',data,start+i*view.get('byteStride',8)) for i in range(uv['count'])]
    assert all(0<=u<=1 and 0<=v<=1 for u,v in values),name
    assert len(set(values))>10,name
    records.append({'name':name,'triangles':tris,'bounds_min':lo,'bounds_max':hi,'size_xyz':span,'origin':'center' if name=='meteor' else 'hub' if name=='windmill_blades' else 'bottom center','glb_bytes':(ART/(name+'.glb')).stat().st_size,'png_bytes':(ART/(name+'.png')).stat().st_size})
size=sum(p.stat().st_size for p in ART.rglob('*') if p.is_file())
assert size<=4_000_000,size
assert (HERE/'.gdignore').read_bytes()==b''
assert (HERE/'.gitignore').read_text().strip()=='work/'
(HERE/'work/verification.json').write_text(json.dumps(records,indent=2))
print('PASS: 15 pairs, UV buffers, 512-square quantized PNGs, no embedded images/materials, physical bounds and origins, directory bytes:',size)
