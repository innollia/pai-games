"""Blender: export physical metre sizes, bottom/hub origins, separate UV paint."""
from pathlib import Path
import json
import bpy
from mathutils import Vector
HERE=Path(__file__).parent
ART=HERE.parents[1]/'art/tinyplanet'
ART.mkdir(parents=True,exist_ok=True)
HEIGHTS={'traveler':1.6,'villager':1.6,'windmill_tower':9,'windmill_blades':7.2,'chimney_house':2.6,'rock':1,'red_rock':5.6,'tower':2.5,'rose':1.4,'glass_flower':.6,'glass_dome':.8,'parcel':.55,'meteor':1.2,'tree':2.4,'wall':1}
checks=[]
for name,target in HEIGHTS.items():
    source=HERE/'work/out'/('tp_'+name)
    assert (source/'texture.png').is_file(),name
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(source/'model.glb'))
    obj=next(o for o in bpy.context.scene.objects if o.type=='MESH')
    positions=[obj.matrix_world@v.co for v in obj.data.vertices]
    lo=Vector([min(p[i] for p in positions) for i in range(3)])
    hi=Vector([max(p[i] for p in positions) for i in range(3)])
    center=(hi+lo)*.5; span=hi-lo
    obj.parent=None; obj.matrix_world.identity()
    for vertex,p in zip(obj.data.vertices,positions):
        # Rotate 180 degrees around Blender Z: -Y front becomes glTF -Z.
        v=Vector((-(p.x-center.x),-(p.y-center.y),p.z-(center.z if name in ['meteor','windmill_blades'] else lo.z)))
        if name=='wall':
            v=Vector((v.x/span.x,v.y*.5/span.y,v.z/span.z))
        else:
            v*=target/span.z
        vertex.co=v
    obj.data.materials.clear()
    bpy.context.view_layer.objects.active=obj
    for o in bpy.context.scene.objects: o.select_set(o is obj)
    bpy.ops.export_scene.gltf(filepath=str(ART/(name+'.glb')),export_format='GLB',use_selection=True,export_materials='NONE',export_yup=True)
    checks.append({'name':name,'triangles':sum(len(p.vertices)-2 for p in obj.data.polygons),'height':target,'origin':'center' if name=='meteor' else 'hub' if name=='windmill_blades' else 'bottom center','up':'+Y','front':'-Z'})
(HERE/'work/mesh_checks.json').write_text(json.dumps(checks,indent=2))
