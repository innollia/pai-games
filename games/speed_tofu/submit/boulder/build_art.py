"""Blender entry point. Reuse hwapongstuy UV conventions without writing there."""
from pathlib import Path
import sys

SOURCE = Path('C:/projects/hwapongstuy/texture3d')
OUT = Path(__file__).parent / 'work' / 'out'
code = (SOURCE / 'tools/build_models.py').read_text(encoding='utf-8')
ns = {'__name__': 'uv_tools', '__file__': str(SOURCE / 'tools/build_models.py')}
exec(code.split('bpy.ops.wm.read_factory_settings(use_empty=True)')[0], ns)
ns['OUT'] = str(OUT)
bpy, Model, box, lathe, T = [ns[k] for k in ['bpy', 'Model', 'box', 'lathe', 'T']]
bpy.ops.wm.read_factory_settings(use_empty=True)
STYLE = (' Painted Temple style: cream sandstone, cobalt blue, pale mint, ochre, '
         'terracotta, dark teal outlines. Broad matte gouache brush planes, sparse '
         'chips and one bold material mark per face. No random glyphs. ')

def model(name, title):
    return Model('b6_' + name, title)

m = model('stone', 'Rolling temple stone, cobalt ceramic relic with an ivory equatorial band')
lathe(m, 'stone', 'cobalt stone; continuous ivory belt across the middle row, a single ochre inset and two broad chips' + STYLE,
      [(-.5, .16), (-.36, .37), (0, .5), (.36, .37), (.5, .16)], 10, cap_bottom=True)
ns['export'](m)
m = model('pillar', 'Hexagonal temple column with broad cap and stepped base')
lathe(m, 'shaft', 'cream sandstone flutes, ochre top rim, dark teal lower edge' + STYLE,
      [(-.5,.48),(-.39,.48),(-.34,.31),(.34,.31),(.39,.48),(.5,.48)], 6, cap_bottom=True)
ns['export'](m)
for name, hint in [
    ('valley', 'TOP warm cream flagstone with a few large broken slabs and sparse mint moss; SIDES ochre cliff strata'),
    ('snow', 'TOP deep desaturated teal blue flagstone, a few pale frost cracks; SIDES dark teal rock. The road itself must remain DARK blue, no white snow cover'),
    ('coast', 'TOP pale sand stone with broad shell limestone shapes and turquoise water-worn edges; SIDES terracotta strata')]:
    m = model(name, name + ' ground tile, centered unit cube')
    box(m, 'tile', hint + STYLE, (1,1,1), mat=T(z=-.5))
    ns['export'](m)
m = model('crystal', 'Purple crystal barricade, three pointed prismatic shards')
for i, (x,h) in enumerate([(-.3,.72),(0,1),(.3,.83)]):
    lathe(m, 'shard', 'violet amethyst, broad lavender diagonal facet, dark plum base, pale sharp tip' + STYLE,
          [(0,.19),(.72,.19),(1,0)], 5, mat=T(x=x,z=-.5) @ ns['S'](h), key='shard', cap_top=False)
ns['export'](m)
m = model('plank', 'Rope bridge timber plank with painted rope lashings')
box(m, 'plank', 'ochre wood, two broad grain lines, two ivory rope ties at the short ends, deep brown end grain' + STYLE,
    (1,1,1), mat=T(z=-.5))
ns['export'](m)
m = model('temple', 'Distant stepped temple silhouette, open portico and triangular pediment')
box(m, 'steps', 'terracotta sandstone broad stair courses' + STYLE, (1,.7,.18), mat=T(z=-.5))
for x in [-.34,-.11,.11,.34]:
    box(m, 'columns', 'ivory pillar with dark teal shadow, ochre rim' + STYLE, (.11,.4,.46), mat=T(x,0,-.32), key='columns')
box(m, 'lintel', 'cream sandstone, single cobalt frieze stripe' + STYLE, (.94,.52,.12), mat=T(z=.14))
ns['roof'](m, 'pediment', 'ochre roof with terracotta edge, cream triangular gable' + STYLE, 1,.6,.23, mat=T(z=.26))
ns['export'](m)
m = model('pot', 'Breakable offering jar, terracotta belly with cobalt shoulder stripe')
lathe(m, 'pot', 'terracotta earthenware, single cobalt shoulder stripe, pale cream lip, two broad chips' + STYLE,
      [(-.5,.22),(-.36,.42),(.14,.48),(.38,.25),(.5,.28)], 8, cap_bottom=True)
ns['export'](m)
