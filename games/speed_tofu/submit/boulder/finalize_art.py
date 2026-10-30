"""Blender: normalize production meshes, keep generated paint separate, enforce web budgets.
Run after preview approval. Source images and prompts stay in work/out (Godot-ignored).
"""
from pathlib import Path
import bpy
from mathutils import Vector

HERE = Path(__file__).parent
ART = HERE.parents[1] / 'art' / 'boulder'
ART.mkdir(parents=True, exist_ok=True)
names = ['stone', 'pillar', 'valley', 'snow', 'coast', 'crystal', 'plank', 'temple', 'pot']
for name in names:
    source = HERE / 'work' / 'out' / ('b6_' + name)
    if not (source / 'texture.png').is_file():
        raise RuntimeError('No GPT texture: ' + name)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(source / 'model.glb'))
    meshes = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    for node in bpy.context.scene.objects:
        node.select_set(node in meshes)
    obj = meshes[0]
    bpy.context.view_layer.objects.active = obj
    if len(meshes) > 1:
        bpy.ops.object.join()
    world = obj.matrix_world.copy()
    positions = [world @ v.co for v in obj.data.vertices]
    lo = Vector([min(v[i] for v in positions) for i in range(3)])
    hi = Vector([max(v[i] for v in positions) for i in range(3)])
    center = (lo + hi) * .5
    span = hi - lo
    obj.parent = None
    obj.matrix_world.identity()
    for vert, position in zip(obj.data.vertices, positions):
        vert.co = Vector([(position[i] - center[i]) / max(span[i], .0001) for i in range(3)])
    obj.data.materials.clear()
    bpy.ops.export_scene.gltf(filepath=str(ART / (name + '.glb')), export_format='GLB',
                              use_selection=True, export_materials='NONE')
    # Blender's bundled Python lacks Pillow: exact resize/compression is the separate pack step.
    print('[production mesh]', name, len(obj.data.polygons))
