# v38: 노란 점프 발판 모델 + 빨간 길·물 무늬 2칸 (hwapongstuy build_models.py 그대로)
# 실행: blender --background --python build_v38.py -- <out_dir>
from pathlib import Path
import bpy
SOURCE = Path('C:/projects/hwapongstuy/texture3d/tools/build_models.py')
ns = {'__name__': 'v38', '__file__': str(SOURCE)}
exec(SOURCE.read_text(encoding='utf-8').split('bpy.ops.wm.read_factory_settings(use_empty=True)')[0], ns)
Model, box, T, export = [ns[k] for k in ['Model', 'box', 'T', 'export']]
bpy.ops.wm.read_factory_settings(use_empty=True)

m = Model('screenrace_spring', 'paper-craft yellow springboard that launches a runner upward')
box(m, 'base', 'dark navy painted base plate with a cream edge highlight', (1.6, 2.4, 0.1))
box(m, 'coils', 'FRONT and BACK: three big dark navy zigzag coil springs standing between the plates on a pale butter background; LEFT and RIGHT: one zigzag coil each', (1.5, 2.3, 0.2), T(z=0.1))
box(m, 'plate', 'bright butter yellow springboard top plate: TOP face has three big white up-pointing chevron arrows in a row; FRONT edge has a thin orange stripe', (1.6, 2.4, 0.1), T(z=0.3))
export(m)

ONLY_FRONT = ('top', 'bottom', 'left', 'right', 'back')
SEAM = ' Seamless tile: the left edge continues into the right edge and the top edge into the bottom edge.'
m = Model('screenrace_tiles2', 'two flat square tiling panels for a paper-craft race course')
box(m, 'redpath', 'shop awning road surface: coral red and cream wide stripes running left to right, with two big cream right-pointing chevron arrows painted on the red stripes.' + SEAM, (1.0, 0.01, 1.0), T(x=0.0), omit=ONLY_FRONT)
box(m, 'water', 'river water seen from the side: clear medium blue with a few soft wavy lighter lines and three small orange and teal fish swimming right, spread apart, plenty of plain water between them.' + SEAM, (1.0, 0.01, 1.0), T(x=1.3), omit=ONLY_FRONT)
export(m)
