# v26: 코스 상자에 입힐 이어 붙는 무늬 4칸 (hwapongstuy build_models.py 의 box 로 정사각 판 4장)
# 실행: blender --background --python build_tiles.py -- <out_dir>
from pathlib import Path
import bpy
SOURCE = Path('C:/projects/hwapongstuy/texture3d/tools/build_models.py')
ns = {'__name__': 'tiles', '__file__': str(SOURCE)}
exec(SOURCE.read_text(encoding='utf-8').split('bpy.ops.wm.read_factory_settings(use_empty=True)')[0], ns)
Model, box, T, export = [ns[k] for k in ['Model', 'box', 'T', 'export']]
bpy.ops.wm.read_factory_settings(use_empty=True)
ONLY_FRONT = ('top', 'bottom', 'left', 'right', 'back')
SEAM = ' Seamless tile: the left edge continues into the right edge and the top edge into the bottom edge. Pale warm grey-white paint only (the game multiplies a colour over it), contrast from a few broad darker marks.'
m = Model('screenrace_tiles', 'four flat square tiling panels for a paper-craft race course; each panel is one repeating surface')
box(m, 'ground', 'packed street ground: a few broad soft patches and two or three small pebbles, very low contrast.' + SEAM, (1.0, 0.01, 1.0), T(x=0.0), omit=ONLY_FRONT)
box(m, 'paving', 'street paving stones: one row of wide rounded flat stones with thin darker joints.' + SEAM, (1.0, 0.01, 1.0), T(x=1.3), omit=ONLY_FRONT)
box(m, 'plaster', 'plaster wall: soft mottled plaster with a few faint brick outlines showing through in one corner.' + SEAM, (1.0, 0.01, 1.0), T(x=2.6), omit=ONLY_FRONT)
box(m, 'planks', 'wooden planks running left to right: three broad planks with thin dark gaps, two grain strokes and one knot.' + SEAM, (1.0, 0.01, 1.0), T(x=3.9), omit=ONLY_FRONT)
export(m)
