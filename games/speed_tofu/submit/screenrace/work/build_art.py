import sys, json
from pathlib import Path
import bpy
from mathutils import Matrix

WORK=Path(__file__).resolve().parent
SOURCE=Path('C:/projects/hwapongstuy/texture3d/tools/build_models.py')
ns={'__name__':'pipeline','__file__':str(SOURCE)}
sys.argv=['build_models.py','--',str(WORK/'pipeline/out')]
exec(SOURCE.read_text(encoding='utf-8').split('bpy.ops.wm.read_factory_settings(use_empty=True)')[0],ns)
export_source=SOURCE.read_text(encoding='utf-8').split('def export(m):')[1].split('bpy.ops.wm.read_factory_settings(use_empty=True)')[0]
export_source=export_source.replace('    m.bm.free()', '''    obj_groups={}
    cursor=0
    for island in m.islands:
        obj_groups[island.name]=[cursor,cursor+len(island.faces)]
        cursor+=len(island.faces)
    m.bm.free()''')
export_source=export_source.replace('    bpy.data.objects.remove(obj)', '''    obj["island_groups"]=json.dumps(obj_groups)
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(d,"source.blend"))
    bpy.data.objects.remove(obj)''')
exec('def export(m):'+export_source,ns)
Model,box,lathe,T,R,export=[ns[k] for k in ['Model','box','lathe','T','R','export']]
bpy.ops.wm.read_factory_settings(use_empty=True)

m=Model('screenrace_courier','Pocket Parcel Town courier: coral cap and jacket, peach face, ink boots; cute chunky side-view +X runner')
def b(name,hint,size,pos=(0,0,0),rot=0):
    return box(m,name,hint,size,T(*pos)@R(rot,'Y'))
b('jacket','coral red delivery jacket, cream zipper and shoulder straps, two broad cloth folds',(.55,.43,.65),(0,0,.83))
b('head','peach skin, FRONT face (camera-facing) has a single dark eye near RIGHT edge and small cheek, BACK face matching eye near LEFT; other faces plain skin',(.58,.47,.57),(.04,0,1.61))
b('nose','warm peach small round nose, no eyes',(.16,.26,.15),(.34,0,1.77))
b('cap','coral courier cap, cream badge on FRONT, one painted stitched seam',(.68,.55,.20),(.03,0,2.18))
b('brim','coral cap brim with pale upper edge and dark burgundy underside',(.30,.57,.07),(.25,0,2.16))
for i,y in enumerate([-.19,.19]):
    b('trouser_'+str(i),'ink navy trousers, one broad pale blue fold',(.22,.19,.48),(-.09 if i else .09,y,.34))
    b('shoe_'+str(i),'ink navy sneaker, cream sole and single coral patch',(.37,.23,.23),(.12 if i else -.10,y,0))
    b('sleeve_'+str(i),'coral jacket sleeve, cream cuff',(.23,.22,.42),(.12,y*1.5,1.02),-23 if i else 24)
    b('mitten_'+str(i),'peach mitten with a single thumb crease, no separated fingers',(.22,.22,.22),(.28 if i else -.08,y*1.5,.88))
b('scarf','butter yellow neckerchief with one ochre fold',(.42,.51,.13),(0,0,1.49))
export(m)

m=Model('screenrace_props','Pocket Parcel Town delivery race prop kit; all pieces share one hand-painted atlas')
groups={}
def section(name,fn):
    start=len(m.bm.faces); fn(); groups[name]=[start,len(m.bm.faces)]
def parcel():
    b('parcel','golden cardboard, broad cream packing tape cross, small blank cream shipping label on FRONT, one coral arrow pictogram, creased corners',(.65,.48,.52))
def crate():
    b('crate','honey wood crate: three broad planks, diagonal brace on FRONT and BACK; two dark nail heads only, no corner brackets',(.95,.80,.95))
def board():
    b('board','warm honey timber plank, two broad grain strokes and one knot, end grain on LEFT and RIGHT, no cracks yet',(1.0,.95,.16))
def lantern():
    b('lantern_panes','warm butter amber glass, dark teal iron framing along edges only, pale central flame silhouette, no bloom',(.40,.32,.48),(0,0,.12))
    b('lantern_base','dark teal painted iron with cream edge highlights',(.48,.39,.12))
    lathe(m,'lantern_roof','dark teal iron cap with warm cream edge',[(.60,.34),(.78,.08)],4,rot=.785)
    b('lantern_handle','dark teal iron handle with warm edge',(.08,.10,.20),(0,0,.77))
def stall():
    for x in [-1.3,1.3]: b('stall_post','warm timber post, one grain stroke',(.14,.16,2.40),(x,.32,0),0)
    b('stall_counter','sage market counter with cream wood edging and a few broad brush marks',(2.8,.75,.65),(0,0,0))
    b('awning','coral and cream broad striped canvas, scallop motifs only on FRONT lower edge, fold shadow under lip',(3.0,1.20,.20),(0,-.1,2.1),0)
    b('awning_lip','coral and cream broad striped hanging canvas valance, curved scallop painted along bottom',(3.0,.10,.28),(0,-.70,1.88))
def train():
    b('train_body','butter cream commuter train SIDE: three large slate blue windows separated by coral door, coral stripe along lower third; FRONT and BACK are side views too',(6.4,1.3,1.45),(.25,0,.40))
    b('train_nose','LEFT face is arriving train front: two amber round headlamps and slate windshield; FRONT and BACK cream and coral cheek panels',(.60,1.3,1.25),(-3.10,0,.40))
    b('train_roof','slate blue train roof, broad pale blue upper panel',(6.6,1.35,.15),(.10,0,1.85))
    for x in [-2.15,2.15]:
        lathe(m,'train_wheel','dark indigo rubber wheel with single slate hub on caps, no spokes',[(0,.32),(.16,.32)],8,mat=T(x,-.73,.32)@R(90,'X'),cap_bottom=True,key='wheel_rim',cap_key='wheel_hub')
for name,fn in [('parcel',parcel),('crate',crate),('bridge_board',board),('lantern',lantern),('market_stall',stall),('train',train)]: section(name,fn)
export(m)
(WORK/'groups.json').write_text(json.dumps(groups),encoding='utf-8')
