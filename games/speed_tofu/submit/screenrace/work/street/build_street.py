# v25: 우체통·가로등 저폴리 모델 (hwapongstuy texture3d 의 build_models.py 를 그대로 빌려 씀)
# 실행: blender --background --python build_street.py -- <out_dir>
import sys
from pathlib import Path
import bpy
SOURCE = Path('C:/projects/hwapongstuy/texture3d/tools/build_models.py')
ns = {'__name__': 'street', '__file__': str(SOURCE)}
exec(SOURCE.read_text(encoding='utf-8').split('bpy.ops.wm.read_factory_settings(use_empty=True)')[0], ns)
Model, box, lathe, T, R, export = [ns[k] for k in ['Model', 'box', 'lathe', 'T', 'R', 'export']]
bpy.ops.wm.read_factory_settings(use_empty=True)

# 우체통: 게임이 상태 색(빨강·금·찬 것)을 곱해 입힌다 -> 그림은 밝은 종이색 바탕 + 남색 선
m = Model('screenrace_mailbox', 'paper-craft street mailbox; the game multiplies a state colour over it, so the paint is pale')
box(m, 'post', 'pale grey-white painted post, one darker band near the bottom, cream highlight on upper edge', (0.16, 0.16, 1.0))
box(m, 'body', 'pale warm white mailbox body: FRONT has a dark navy horizontal mail slot near the top and a small blank cream address label below it; other faces plain pale paint with one folded paper seam', (1.1, 0.7, 0.86), T(z=0.99))
box(m, 'roof', 'pale warm white rounded lid, lighter top face, thin darker lip along the lower edge', (1.18, 0.76, 0.16), T(z=1.85))
export(m)

# 가로등: 화면 맨 앞에서 빨리 지나가는 기둥 (빠르기가 보이게)
m = Model('screenrace_lamp', 'paper-craft street lamp seen from the side in the foreground')
box(m, 'base', 'dark navy painted iron base, cream edge highlight', (0.34, 0.34, 0.3))
lathe(m, 'pole', 'cream painted pole with one navy band near the top', [(0.3, 0.09), (3.9, 0.07)], 6, cap_top=False)
box(m, 'arm', 'navy iron arm, cream highlight along the top edge', (0.95, 0.14, 0.12), T(x=0.4, z=3.85))
box(m, 'lamp', 'butter yellow glass lamp panes with navy frame along the edges only, no glow', (0.3, 0.3, 0.34), T(x=0.78, z=3.52))
lathe(m, 'cap', 'navy iron lamp cap with a cream rim', [(3.86, 0.24), (4.08, 0.0)], 4, mat=T(x=0.78), rot=0.785, cap_bottom=True)
export(m)
