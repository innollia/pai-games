"""Blender asset-only unlit previews, never screenshots of the game."""
from pathlib import Path
import bpy
from mathutils import Vector
HERE=Path(__file__).parent
ART=HERE.parents[1]/'art/tinyplanet'
for path in sorted(ART.glob('*.glb')):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc=bpy.context.scene
    sc.render.engine='CYCLES'; sc.cycles.samples=1
    sc.render.resolution_x=sc.render.resolution_y=384
    sc.render.resolution_percentage=100
    sc.world=bpy.data.worlds.new('cream'); sc.world.use_nodes=True
    sc.world.node_tree.nodes.get('Background').inputs[0].default_value=(.55,.61,.69,1)
    sc.view_settings.view_transform='Standard'
    bpy.ops.import_scene.gltf(filepath=str(path))
    obj=next(o for o in sc.objects if o.type=='MESH')
    mat=bpy.data.materials.new('paint'); mat.use_nodes=True
    nt=mat.node_tree; nt.nodes.clear()
    tex=nt.nodes.new('ShaderNodeTexImage'); tex.image=bpy.data.images.load(str(path.with_suffix('.png')))
    emit=nt.nodes.new('ShaderNodeEmission'); out=nt.nodes.new('ShaderNodeOutputMaterial')
    nt.links.new(tex.outputs['Color'],emit.inputs['Color']); nt.links.new(emit.outputs[0],out.inputs['Surface'])
    obj.data.materials.clear(); obj.data.materials.append(mat)
    corners=[obj.matrix_world@Vector(c) for c in obj.bound_box]
    lo=Vector([min(c[i] for c in corners) for i in range(3)])
    hi=Vector([max(c[i] for c in corners) for i in range(3)])
    center=(lo+hi)*.5; size=max(hi-lo)
    cam=bpy.data.objects.new('camera',bpy.data.cameras.new('camera'))
    cam.data.type='ORTHO'; cam.data.ortho_scale=size*1.35
    direction=Vector((.65,1.8,.8)).normalized()
    cam.location=center+direction*size*4
    cam.rotation_euler=(-direction).to_track_quat('-Z','Y').to_euler()
    sc.collection.objects.link(cam); sc.camera=cam
    sc.render.filepath=str(HERE/'work/out'/('tp_'+path.stem)/'preview.png')
    bpy.ops.render.render(write_still=True)
