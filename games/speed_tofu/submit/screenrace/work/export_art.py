import bpy,bmesh,json,math,sys
from pathlib import Path
from mathutils import Vector
W=Path(__file__).resolve().parent
OUT=W.parents[2]/'art/screenrace'
OUT.mkdir(parents=True,exist_ok=True)
stats={}

def chunk(source,name,start,end,mat,bevel=.035):
    mesh=bpy.data.meshes.new(name)
    verts=[]; polys=[]; uvs=[]
    for p in list(source.data.polygons)[start:end]:
        base=len(verts)
        verts.extend(source.data.vertices[i].co.copy() for i in p.vertices)
        polys.append(list(range(base,len(verts))))
        uvs.extend(source.data.uv_layers.active.data[i].uv.copy() for i in p.loop_indices)
    mesh.from_pydata(verts,[],polys); mesh.update()
    layer=mesh.uv_layers.new(name='UVMap')
    for loop,uv in zip(layer.data,uvs): loop.uv=uv
    if name.startswith('trouser_'):
        for v in mesh.vertices: v.co.z=.18+(v.co.z-.34)*(.64/.48)
    if name=='market_stall':
        # Slope the canopy toward the camera without moving posts or counter.
        for v in mesh.vertices:
            if v.co.z>1.85: v.co.z+=(v.co.y+.7)*.22
    if name=='train':
        for v in mesh.vertices:
            if v.co.x < -2.8 and v.co.z>.7: v.co.x+=(v.co.z-.7)*.20
    obj=bpy.data.objects.new(name,mesh); bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat)
    bm=bmesh.new(); bm.from_mesh(mesh)
    bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.00001)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces)); bm.to_mesh(mesh); bm.free()
    bpy.context.view_layer.objects.active=obj
    mod=obj.modifiers.new('Paper soft corners','BEVEL'); mod.width=bevel; mod.segments=2; mod.affect='EDGES'
    obj.select_set(True)
    bpy.ops.object.modifier_apply(modifier=mod.name)
    obj.select_set(False)
    return obj

def material(path):
    mat=bpy.data.materials.new('Painted paper'); mat.use_nodes=True
    tex=mat.node_tree.nodes.new('ShaderNodeTexImage'); tex.image=bpy.data.images.load(str(path))
    mat.node_tree.links.new(tex.outputs['Color'],mat.node_tree.nodes.get('Principled BSDF').inputs['Base Color'])
    mat.node_tree.nodes.get('Principled BSDF').inputs['Roughness'].default_value=1
    return mat

def empty(name,parent=None,pivot=(0,0,0)):
    obj=bpy.data.objects.new(name,None); bpy.context.collection.objects.link(obj); obj.location=pivot; obj.parent=parent
    return obj

def parent_keep(obj,parent):
    bpy.context.view_layer.update()
    matrix=obj.matrix_world.copy(); obj.parent=parent; obj.matrix_world=matrix

def emit(name,objects):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects: o.select_set(True)
    bpy.context.view_layer.update()
    meshes=[o for o in objects if o.type=='MESH']
    coords=[o.matrix_world@v.co for o in meshes for v in o.data.vertices]
    lo=[min(v[i] for v in coords) for i in range(3)]; hi=[max(v[i] for v in coords) for i in range(3)]
    stats[name]={'blender_min':lo,'blender_max':hi,'godot_size':[hi[0]-lo[0],hi[2]-lo[2],hi[1]-lo[1]],'triangles':sum(len(p.vertices)-2 for o in meshes for p in o.data.polygons)}
    bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True,export_animations=True,export_frame_range=True,export_yup=True)
    sc=bpy.context.scene; sc.render.engine='BLENDER_WORKBENCH'
    sc.display.shading.light='FLAT'; sc.display.shading.color_type='TEXTURE'; sc.display.shading.show_shadows=False
    if sc.world is None: sc.world=bpy.data.worlds.new('QA_world')
    sc.world.color=(.65,.71,.77); sc.render.resolution_x=768; sc.render.resolution_y=512; sc.render.resolution_percentage=100
    for o in sc.objects: o.hide_render=o not in objects
    center=Vector([(lo[i]+hi[i])/2 for i in range(3)])
    cam=bpy.data.objects.new('QA_camera',bpy.data.cameras.new('QA_camera')); sc.collection.objects.link(cam)
    direction=Vector((.10,-1,.10)).normalized(); cam.location=center+direction*30
    cam.rotation_euler=(-direction).to_track_quat('-Z','Y').to_euler(); cam.data.type='ORTHO'
    cam.data.ortho_scale=max((hi[0]-lo[0])*1.25,(hi[2]-lo[2])*1.25*1.5)
    sc.camera=cam; sc.render.filepath=str(W/(name+'_preview.png')); bpy.ops.render.render(write_still=True)
    bpy.data.objects.remove(cam,do_unlink=True)

for variant in ['coral','blue','mint','gold']:
    d=W/'pipeline/out/screenrace_courier'
    bpy.ops.wm.open_mainfile(filepath=str(d/'source.blend'))
    bpy.context.preferences.filepaths.save_version=0
    src=next(o for o in bpy.context.scene.objects if o.type=='MESH')
    groups=json.loads(src['island_groups']); mat=material(W/('courier_'+variant+'.jpg'))
    root=empty('Courier'); objects=[root]; chunks={}
    for name,(a,b) in groups.items():
        obj=chunk(src,name,a,b,mat,.075 if name=='head' else .04 if name in ['cap','jacket','nose'] else .025)
        obj.parent=root; chunks[name]=obj; objects.append(obj)
    for i in [0,1]:
        leg=empty('leg_'+str(i),root,(0,-.19 if i==0 else .19,.82)); objects.append(leg)
        arm=empty('arm_'+str(i),root,(.02,-.285 if i==0 else .285,1.40)); objects.append(arm)
        for key in ['trouser_','shoe_']: parent_keep(chunks[key+str(i)],leg)
        for key in ['sleeve_','mitten_']: parent_keep(chunks[key+str(i)],arm)
        for node,sign in [(leg,1),(arm,-1)]:
            for frame,amount in [(1,0),(5,1),(9,0),(13,-1),(17,0)]:
                node.rotation_euler.y=amount*.65*sign*(1 if i==0 else -1)
                node.keyframe_insert(data_path='rotation_euler',frame=frame,group='run')
            node.animation_data.action.name='run'
    bpy.context.scene.frame_start=1; bpy.context.scene.frame_end=17; bpy.context.scene.render.fps=24
    bpy.context.scene.frame_set(1)
    bpy.data.objects.remove(src,do_unlink=True)
    coords=[v.co for o in chunks.values() for v in o.data.vertices]
    root.scale.x=.8/(max(v.x for v in coords)-min(v.x for v in coords))
    root.scale.z=2.4/(max(v.z for v in coords)-min(v.z for v in coords))
    emit('courier_'+variant,objects)

d=W/'pipeline/out/screenrace_props'
for name,(a,b) in ([] if '--courier-only' in sys.argv else json.loads((W/'groups.json').read_text()).items()):
    bpy.ops.wm.open_mainfile(filepath=str(d/'source.blend'))
    src=next(o for o in bpy.context.scene.objects if o.type=='MESH')
    obj=chunk(src,name,a,b,material(W/'props_atlas.jpg'),.035 if name!='bridge_board' else .018)
    root=empty(name.title()); obj.parent=root
    bpy.data.objects.remove(src,do_unlink=True)
    emit(name,[root,obj])
(W/'model_stats.json').write_text(json.dumps(stats,indent=2),encoding='utf-8')
