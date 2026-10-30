import struct,json,io,sys
from pathlib import Path
from PIL import Image
W=Path(__file__).resolve().parent
OUT=W.parents[2]/'art/screenrace'
def read(path):
    data=path.read_bytes(); magic,version,size=struct.unpack_from('<4sII',data)
    assert magic==b'glTF' and version==2 and size==len(data)
    n,kind=struct.unpack_from('<II',data,12); assert kind==0x4e4f534a
    doc=json.loads(data[20:20+n]); bn,bkind=struct.unpack_from('<II',data,20+n)
    assert bkind==0x004e4942
    return doc,data[28+n:28+n+bn]

reports={}
remodel='--remodel' in sys.argv
names=['courier_coral','courier_blue','courier_mint','courier_gold','parcel','train','bridge_board']
paths=[OUT/(name+'.glb') for name in names] if remodel else sorted(OUT.glob('*.glb'))
for path in paths:
    doc,blob=read(path)
    for mat in doc.get('materials',[]):
        mat.setdefault('extensions',{})['KHR_materials_unlit']={}
    doc['extensionsUsed']=sorted(set(doc.get('extensionsUsed',[])+['KHR_materials_unlit']))
    animations=doc.get('animations',[])
    if animations:
        combined={'name':'run_loop','samplers':[],'channels':[]}
        for animation in animations:
            offset=len(combined['samplers']); combined['samplers']+=animation['samplers']
            for channel in animation['channels']:
                channel['sampler']+=offset; combined['channels'].append(channel)
        doc['animations']=[combined]
    encoded=json.dumps(doc,separators=(',',':')).encode(); encoded+=b' '*((-len(encoded))%4)
    blob+=b'\0'*((-len(blob))%4)
    size=12+8+len(encoded)+8+len(blob)
    path.write_bytes(struct.pack('<4sII',b'glTF',2,size)+struct.pack('<II',len(encoded),0x4e4f534a)+encoded+struct.pack('<II',len(blob),0x004e4942)+blob)
    images=[]
    for image in doc.get('images',[]):
        bv=doc['bufferViews'][image['bufferView']]; start=bv.get('byteOffset',0)
        im=Image.open(io.BytesIO(blob[start:start+bv['byteLength']]))
        assert max(im.size)<=1024
        images.append({'px':list(im.size),'mime':image['mimeType'],'bytes':bv['byteLength']})
    for view in doc['bufferViews']:
        assert view.get('byteOffset',0)+view['byteLength']<=len(blob)
    for accessor in doc['accessors']:
        assert accessor['count']>0
    tri=sum(doc['accessors'][p['indices']]['count']//3 for m in doc['meshes'] for p in m['primitives'])
    reports[path.name]={'bytes':size,'triangles':tri,'embedded_images':images,'animations':[a['name'] for a in doc.get('animations',[])],'nodes':[n.get('name') for n in doc['nodes']]}
(W/('remodel_validation.json' if remodel else 'glb_validation.json')).write_text(json.dumps(reports,indent=2),encoding='utf-8')
print(json.dumps({k:{'bytes':v['bytes'],'triangles':v['triangles'],'animations':v['animations']} for k,v in reports.items()},indent=2))
