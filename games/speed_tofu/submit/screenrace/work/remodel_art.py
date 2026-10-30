"""Cover-match rebuild. Blender --background --python remodel_art.py.

Uses texture3d's primitive constructors, atlas coordinates and existing GLB pipeline.
Only the seven requested GLBs and work previews are written.
"""
import bpy, bmesh, sys, json, math
from pathlib import Path
from mathutils import Vector, Matrix

W = Path(__file__).resolve().parent
OUT = W.parents[2] / 'art/screenrace'
SOURCE = Path('C:/projects/hwapongstuy/texture3d/tools/build_models.py')
ns = {'__name__': 'pipeline', '__file__': str(SOURCE)}
sys.argv = ['build_models.py', '--', str(W/'pipeline/out/remodel')]
exec(SOURCE.read_text(encoding='utf-8').split('# ---------------------------------------------------------------- 모델 10개')[0], ns)
Model, box, lathe, T, R = [ns[k] for k in ('Model','box','lathe','T','R')]
STATS = {}
TILES = dict(coral=0, skin=1, navy=2, brown=3, kraft=4, cream=5,
             ink=6, tape=7, wood=8, rope=9, teal=10, amber=11,
             blue=12, mint=13, gold=14, glass=15)

def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    mat = bpy.data.materials.new('Pocket Parcel Town painted paper')
    mat.use_nodes = True
    tex = mat.node_tree.nodes.new('ShaderNodeTexImage')
    tex.image = bpy.data.images.load(str(W/'pipeline/out/remodel/atlas.jpg'))
    tex.interpolation = 'Linear'
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    mat.node_tree.links.new(tex.outputs['Color'], bsdf.inputs['Base Color'])
    bsdf.inputs['Roughness'].default_value = 1
    return mat

def empty(name, parent=None, pivot=(0,0,0)):
    o = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(o)
    o.location = pivot
    o.parent = parent
    return o

def meshpart(name, tile, mat, size=None, center=(0,0,0), rotation=0,
             bevel=.008, cylinder=None, compact=False):
    m = Model(name, 'Cover-match folded paper')
    if cylinder:
        radius, depth, axis, sides = cylinder
        rot = R(90,'X') if axis == 'Y' else R(90,'Y') if axis == 'X' else Matrix.Identity(4)
        pos = Vector(center) - rot @ Vector((0,0,depth/2))
        lathe(m, name, tile, [(0,radius),(depth,radius)], sides,
              mat=T(*pos)@rot, cap_bottom=True)
    else:
        box(m, name, tile, size, T(*center)@R(rotation,'Y')@T(0,0,-size[2]/2))
    # Map axis-aligned primitive faces onto the same painted material swatch.
    col, row = TILES[tile]%4, TILES[tile]//4
    layer = m.bm.loops.layers.uv.new('UVMap')
    for island in m.islands:
        for face, coords in island.faces:
            us, vs = zip(*coords)
            du, dv = max(us)-min(us), max(vs)-min(vs)
            for loop,(u,v) in zip(face.loops,coords):
                fu = (u-min(us))/max(du,.00001)
                fv = (v-min(vs))/max(dv,.00001)
                pad, span = (100,56) if compact else (24,208)
                loop[layer].uv = ((col*256+pad+fu*span)/1024,
                                 1-(row*256+pad+(1-fv)*span)/1024)
    bmesh.ops.remove_doubles(m.bm, verts=list(m.bm.verts), dist=.000001)
    bmesh.ops.recalc_face_normals(m.bm, faces=list(m.bm.faces))
    mesh = bpy.data.meshes.new(name)
    m.bm.to_mesh(mesh); m.bm.free(); mesh.update()
    o = bpy.data.objects.new(name,mesh); bpy.context.collection.objects.link(o)
    o.data.materials.append(mat)
    if bevel:
        bpy.context.view_layer.objects.active=o; o.select_set(True)
        mod=o.modifiers.new('Folded paper corners','BEVEL')
        mod.width=bevel; mod.segments=1
        bpy.ops.object.modifier_apply(modifier=mod.name); o.select_set(False)
    return o

def segment(name, tile, mat, a, b, width, depth, bevel=.008):
    a,b=Vector(a),Vector(b)
    o=meshpart(name,tile,mat,(width,depth,(b-a).length),bevel=bevel)
    o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler()
    o.location=(a+b)/2
    bpy.context.view_layer.objects.active=o; o.select_set(True)
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    o.select_set(False)
    return o

def parent_keep(o,p):
    bpy.context.view_layer.update()
    matrix=o.matrix_world.copy(); o.parent=p; o.matrix_world=matrix

def emit(name,objects):
    bpy.context.view_layer.update()
    meshes=[o for o in objects if o.type=='MESH']
    coords=[o.matrix_world@v.co for o in meshes for v in o.data.vertices]
    lo=Vector([min(v[i] for v in coords) for i in range(3)])
    hi=Vector([max(v[i] for v in coords) for i in range(3)])
    tris=sum(len(p.vertices)-2 for o in meshes for p in o.data.polygons)
    if name.startswith('courier'): assert tris<=2500, (name,tris)
    assert abs(lo.z)<.0001, (name,lo)
    # Soft face lighting survives the game's unlit mobile renderer.
    light=Vector((-.25,-.55,.80)).normalized()
    for o in meshes:
        colors=o.data.color_attributes.new(name='Paper light',type='BYTE_COLOR',domain='CORNER')
        for face in o.data.polygons:
            normal=o.matrix_world.to_3x3()@face.normal
            factor=.72+.28*max(0,normal.normalized().dot(light))
            for index in face.loop_indices: colors.data[index].color=(factor,factor,factor,1)
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects: o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',
        use_selection=True,export_yup=True,export_animations=True,export_frame_range=True,
        export_vertex_color='ACTIVE',export_all_vertex_colors=False)
    STATS[name]={'triangles':tris,'godot_min':[lo.x,lo.z,-hi.y],
        'godot_max':[hi.x,hi.z,-lo.y],'height':hi.z-lo.z,
        'material_count':1,'bytes':(OUT/(name+'.glb')).stat().st_size}
    # Preview the exact unlit atlas times vertex color that Godot will display.
    sc=bpy.context.scene; sc.render.engine='CYCLES'; sc.cycles.samples=8
    mat=meshes[0].data.materials[0]; nodes=mat.node_tree.nodes; links=mat.node_tree.links
    tex=next(n for n in nodes if n.type=='TEX_IMAGE')
    attr=nodes.new('ShaderNodeVertexColor'); attr.layer_name='Paper light'
    multiply=nodes.new('ShaderNodeMixRGB'); multiply.blend_type='MULTIPLY'; multiply.inputs[0].default_value=1
    links.new(tex.outputs['Color'],multiply.inputs[1]); links.new(attr.outputs['Color'],multiply.inputs[2])
    emission=nodes.new('ShaderNodeEmission'); links.new(multiply.outputs[0],emission.inputs[0])
    links.new(emission.outputs[0],nodes.get('Material Output').inputs['Surface'])
    sc.world=bpy.data.worlds.new('QA cream'); sc.world.use_nodes=True
    sc.world.node_tree.nodes.get('Background').inputs[0].default_value=(.88,.855,.77,1)
    sc.render.resolution_x=768; sc.render.resolution_y=640; sc.render.resolution_percentage=100
    sc.view_settings.view_transform='Standard'
    center=(lo+hi)/2
    camera=bpy.data.objects.new('QA_camera',bpy.data.cameras.new('QA_camera'))
    sc.collection.objects.link(camera)
    direction=Vector((.12,-1,.08)).normalized()
    camera.location=center+direction*20
    camera.rotation_euler=(-direction).to_track_quat('-Z','Y').to_euler()
    camera.data.type='ORTHO'; camera.data.ortho_scale=max((hi.x-lo.x)*1.2,(hi.z-lo.z)*1.45)
    sc.camera=camera
    sc.render.filepath=str(W/(name+'_preview.png')); bpy.ops.render.render(write_still=True)

def ground_center(objects, native_height=None):
    bpy.context.view_layer.update()
    coords=[o.matrix_world@v.co for o in objects if o.type=='MESH' for v in o.data.vertices]
    lo=Vector([min(v[i] for v in coords) for i in range(3)])
    hi=Vector([max(v[i] for v in coords) for i in range(3)])
    root=empty('Courier' if native_height else 'Prop')
    for o in objects:
        if o.parent is None: parent_keep(o,root)
    scale=native_height/(hi.z-lo.z) if native_height else 1
    root.scale=(scale,scale,scale)
    root.location=(-.5*(lo.x+hi.x)*scale,-.5*(lo.y+hi.y)*scale,-lo.z*scale)
    return [root]+objects

def courier(team):
    mat=reset(); parts=[]
    def p(name,tile,size,center,rot=0,bevel=.008,compact=False):
        o=meshpart(name,tile,mat,size,center,rot,bevel,compact=compact); parts.append(o); return o
    def seg(name,tile,a,b,width,depth):
        o=segment(name,tile,mat,a,b,width,depth); parts.append(o); return o
    p('jacket',team,(.31,.285,.265),(.0,0,.585),10,.014)
    p('collar','cream',(.19,.27,.035),(.04,0,.724),10,.004)
    # Head plus oversized cap occupies 40% of native height.
    p('head','skin',(.375,.335,.325),(.105,0,.877),0,.027)
    p('cap',team,(.43,.385,.115),(.075,0,1.073),-3,.012)
    p('brim',team,(.235,.38,.030),(.326,0,1.028),-5,.006)
    p('cap_band',team,(.405,.353,.028),(.082,0,1.018),0,.004)
    # Camera is Blender -Y = Godot +Z. Both profiles and +X front are readable.
    for side in [-1,1]:
        p('ear_'+str(side),'skin',(.082,.054,.093),(-.062,side*.175,.86),0,.02)
        o=meshpart('eye_'+str(side),'ink',mat,center=(.202,side*.171,.901),
            bevel=0,cylinder=(.024,.008,'Y',10),compact=True)
        for v in o.data.vertices: v.co.z=.901+(v.co.z-.901)*1.25
        parts.append(o)
        # Four short segments create a small upturned smile, on the visible cheek plane.
        points=[(.205,side*.174,.818),(.220,side*.174,.810),(.235,side*.174,.812),(.246,side*.174,.822)]
        for j in range(3): seg('smile_'+str(side)+'_'+str(j),'ink',points[j],points[j+1],.007,.004)
    p('nose','skin',(.052,.088,.065),(.306,0,.852),0,.014)
    # Cream cargo straps stay in the courier; actual countable parcels are game-owned.
    for side in [-1,1]:
        p('cargo_strap_'+str(side),'cream',(.032,.012,.24),(-.055,side*.149,.6),12,.002)
    p('back_harness','brown',(.038,.25,.185),(-.162,0,.588),10,.006)
    pivots=[]
    # Wide mid-stride legs, sturdy brown shoes with thick paper soles.
    for i,(side,knee,ankle,shoe_rot) in enumerate([
        (-.087,(.17,-.087,.27),(.30,-.087,.11),-18),
        (.087,(-.21,.087,.28),(-.32,.087,.20),30)]):
        pivot=empty('leg_'+str(i),pivot=(0,side,.475)); pivots.append(pivot)
        legparts=[seg('thigh_'+str(i),'navy',(-.025,side,.48),knee,.147,.162),
                  seg('shin_'+str(i),'navy',knee,ankle,.142,.162),
                  p('shoe_'+str(i),'brown',(.24,.19,.112),(ankle[0]+.025,side,ankle[2]-.037),shoe_rot,.012),
                  p('sole_'+str(i),'cream',(.249,.196,.027),(ankle[0]+.034,side,ankle[2]-.095),shoe_rot,.003)]
        for o in legparts: parent_keep(o,pivot)
    # Near arm swept back, far arm pumping forwards; no crossed forearms.
    for i,(side,elbow,hand) in enumerate([
        (-.205,(-.205,-.205,.605),(-.294,-.205,.679)),
        (.205,(.215,.205,.59),(.315,.205,.72))]):
        pivot=empty('arm_'+str(i),pivot=(.005,side,.704)); pivots.append(pivot)
        arm_parts=[seg('sleeve_'+str(i),team,(.005,side,.69),elbow,.145,.16),
                   seg('forearm_'+str(i),team,elbow,hand,.112,.127),
                   p('mitten_'+str(i),'skin',(.117,.137,.126),hand,-15 if i else 20,.025)]
        for o in arm_parts: parent_keep(o,pivot)
    objects=ground_center(parts+pivots,1.0)
    sc=bpy.context.scene; sc.frame_start=1; sc.frame_end=17; sc.render.fps=24
    # Preserve existing named limb hooks and run_loop export pipeline.
    for i,pivot in enumerate(pivots):
        for frame,delta in [(1,0),(5,.18),(9,0),(13,-.18),(17,0)]:
            pivot.rotation_euler.y=delta*(1 if i%2 else -1)
            pivot.keyframe_insert(data_path='rotation_euler',frame=frame,group='run')
        pivot.animation_data.action.name='run'
    sc.frame_set(1); emit('courier_'+team,objects)

def parcel():
    mat=reset(); objs=[]
    def b(name,tile,size,center,bevel=.003):
        o=meshpart(name,tile,mat,size,center,bevel=bevel); objs.append(o)
    b('kraft_box','kraft',(.65,.48,.52),(0,0,.26),.008)
    # Continuous red packing-tape cross, with sharp geometric edges on every face.
    for z in [.001,.521]:
        b('tape_top_x','tape',(.65,.072,.002),(0,0,z),0)
        b('tape_top_y','tape',(.072,.48,.002),(0,0,z+.0002),0)
    for y in [-.241,.241]:
        b('tape_side_vertical','tape',(.073,.002,.52),(0,y,.26),0)
        b('tape_side_horizontal','tape',(.65,.002,.066),(0,y,.26),0)
        b('shipping_label','cream',(.165,.003,.096),(.174,y*1.008,.389),.001)
        b('label_address','ink',(.092,.003,.007),(.174,y*1.018,.402),0)
        b('label_address_short','ink',(.06,.003,.007),(.158,y*1.018,.379),0)
    for x in [-.326,.326]:
        b('tape_end_vertical','tape',(.002,.072,.52),(x,0,.26),0)
        b('tape_end_horizontal','tape',(.002,.48,.066),(x,0,.26),0)
    emit('parcel',ground_center(objs))

def train():
    mat=reset(); objs=[]
    def b(name,tile,size,center,bevel=.02,rotation=0):
        o=meshpart(name,tile,mat,size,center,rotation,bevel); objs.append(o); return o
    def cyl(name,tile,center,radius,depth,axis='Y',sides=12):
        o=meshpart(name,tile,mat,center=center,bevel=.009,cylinder=(radius,depth,axis,sides)); objs.append(o)
    b('chassis','coral',(2.9,.91,.16),(0,0,.39))
    cyl('round_boiler','teal',(-.48,0,.88),.41,1.49,'X')
    cyl('front_smokebox','ink',(-1.25,0,.88),.36,.055,'X')
    cyl('headlamp','amber',(-1.295,0,1.00),.105,.06,'X',10)
    cyl('headlamp_center','cream',(-1.331,0,1.0),.072,.012,'X',10)
    cyl('smokestack','ink',(-.86,0,1.43),.125,.52,'Z',8)
    cyl('chimney_rim','coral',(-.86,0,1.70),.18,.095,'Z',8)
    cyl('steam_dome','amber',(-.10,0,1.32),.135,.18,'Z',8)
    b('cab','gold',(.83,.88,.98),(.85,0,1.03))
    b('overhanging_cab_roof','coral',(1.02,1.08,.13),(.83,0,1.59))
    for y in [-.449,.449]:
        b('window_frame','cream',(.49,.015,.45),(.82,y,1.24),.008)
        b('cab_window','glass',(.40,.018,.36),(.82,y*1.02,1.24),.008)
        b('cab_door_seam','teal',(.014,.012,.77),(1.16,y,.99),.001)
    b('front_cab_window','glass',(.018,.5,.36),(.423,0,1.26),.006)
    # Six exposed large locomotive wheels, hubs, and connecting rods.
    for side in [-1,1]:
        for i,x in enumerate([-.97,-.17,.79]):
            cyl('driving_wheel_'+str(side)+'_'+str(i),'ink',(x,side*.52,.29),.29,.13)
            cyl('painted_wheel_'+str(side)+'_'+str(i),'coral',(x,side*.595,.29),.216,.02)
            cyl('wheel_hub_'+str(side)+'_'+str(i),'cream',(x,side*.615,.29),.072,.025)
        b('connecting_rod_'+str(side),'cream',(1.83,.033,.052),(-.10,side*.641,.27),.012)
    # Sloped cowcatcher wedge at the -X nose.
    b('cowcatcher','coral',(.31,.98,.18),(-1.48,0,.29),.012,30)
    for y in [-.3,0,.3]:
        b('cowcatcher_bar','cream',(.02,.032,.19),(-1.646,y,.29),.003,30)
    b('rear_buffer','ink',(.14,.97,.12),(1.47,0,.38))
    emit('train',ground_center(objs))

def board():
    mat=reset(); objs=[]
    objs.append(meshpart('wooden_plank','wood',mat,(1.65,.70,.105),(0,0,.075),bevel=.012))
    # Closed rope wraps at both ends, including the edge and underside.
    for end in [-1,1]:
        for j in [-1,0,1]:
            x=end*.63+j*.038
            for z in [.014,.139]:
                objs.append(meshpart('rope_wrap','rope',mat,(.029,.75,.025),(x,0,z),bevel=.009))
            for y in [-.363,.363]:
                objs.append(meshpart('rope_edge','rope',mat,(.029,.025,.128),(x,y,.076),bevel=.009))
        objs.append(meshpart('binding_knot','rope',mat,(.12,.10,.065),(end*.63,-.32,.159),bevel=.018))
    emit('bridge_board',ground_center(objs))

for team in ['coral','blue','mint','gold']: courier(team)
parcel(); train(); board()
(W/'remodel_stats.json').write_text(json.dumps(STATS,indent=2),encoding='utf-8')
print('REMODEL_STATS',json.dumps(STATS))
