"""Blender: Postcard Planets meshes, using read-only hwapongstuy UV tools."""
from pathlib import Path
import math

HERE = Path(__file__).parent
SOURCE = Path('C:/projects/hwapongstuy/texture3d')
ns = {'__name__': 'uv_tools', '__file__': str(SOURCE / 'tools/build_models.py')}
exec((SOURCE / 'tools/build_models.py').read_text(encoding='utf-8').split('bpy.ops.wm.read_factory_settings(use_empty=True)')[0], ns)
ns['OUT'] = str(HERE / 'work/out')
bpy, Model, box, lathe, T, R = [ns[k] for k in ['bpy','Model','box','lathe','T','R']]
bpy.ops.wm.read_factory_settings(use_empty=True)
STYLE = ' Postcard Planets: matte gouache, broad flat planes, one bold mark per face, cream #fff6e6, navy #2b2d42, yellow #ffd166, mint #8fe3c2, lavender #b9a7f2, sky #9fd3ff. No gloss, gradients, tiny patterns, text or runes. Red only on danger rocks and meteor.'
def model(name, title):
    return Model('tp_' + name, title)
def roundpart(m, name, hint, rings, n=8, **kw):
    return lathe(m, name, hint + STYLE, rings, n, cap_bottom=True, **kw)
def block(m, name, hint, size, **kw):
    return box(m, name, hint + STYLE, size, **kw)
def done(m):
    ns['export'](m)

for name in ['traveler','villager']:
    m = model(name, 'Chubby three-head-tall ' + name + ', facing Blender -Y / exported -Z')
    for x in [-.16,.16]:
        block(m,'boots','navy small boots',(.23,.32,.18),mat=T(x,-.03,0),key='boots')
    roundpart(m,'body','cream cape, lavender lower shadow' if name=='traveler' else 'cream overalls, two broad straps',[(.16,.28),(.6,.32),(1.02,.23)],8)
    roundpart(m,'head','warm cream face; exactly TWO navy dot eyes on front-facing side columns 5 and 6 (zero based); all other panels blank cream',[(1,.19),(1.14,.28),(1.43,.27),(1.54,.13)],8,rot=math.pi/8)
    if name=='traveler':
        roundpart(m,'scarf','warm yellow scarf with ochre underside',[(.94,.27),(1.04,.27)],8)
        block(m,'scarf tail','yellow cloth single ochre fold',(.14,.07,.36),mat=T(.15,-.29,.64))
        block(m,'folded sail','folded cream sail with one yellow seam and navy mast',(.22,.16,.78),mat=T(0,.32,.45))
    else:
        roundpart(m,'hat','plain cream hat, lavender underside',[(1.43,.34),(1.49,.34),(1.5,.23),(1.6,.19)],8)
    done(m)

m=model('windmill_tower','Tall tapered cream windmill tower with cap and small front door')
roundpart(m,'tower','white cream plaster; ONE small navy door on front column 6 at bottom; other panels empty; lavender footing',[(0,1.3),(6.8,.85),(7.5,.8)],8)
roundpart(m,'cap','warm yellow cap, ochre lower edge',[(7.5,1.05),(9,0)],8)
done(m)
m=model('windmill_blades','Four canvas blades in Blender XZ plane, exported XY plane, origin hub')
for angle in [0,90,180,270]:
    mat=R(angle,'Y')
    block(m,'spar','brown wood with cream edge',(.12,.16,3.55),mat=mat,key='spar')
    block(m,'canvas','yellow cream canvas, one ochre seam',(.68,.08,2.65),mat=mat @ T(.22,-.1,.9),key='canvas')
roundpart(m,'hub','ochre wood round hub', [(-.2,.3),(.2,.3)],8,mat=R(90,'X'))
done(m)
m=model('chimney_house','Round cream cottage, pink coral roof, tall dark chimney')
roundpart(m,'walls','cream plaster; ONE navy rounded door on front column 6; a single yellow window on column 0',[(0,.9),(1.5,.9)],8)
roundpart(m,'roof','warm pink coral #ff8a80 roof, muted rose shadow, NO danger red',[(1.5,1.1),(2.35,0)],8)
block(m,'chimney','dark navy chimney, lavender top opening',(.3,.3,1.05),mat=T(.45,.25,1.55))
done(m)
for name,h,r,hint in [('rock',1,.65,'grey lilac boulder, broad cream upper facet and lavender underside'),('red_rock',5.6,1.25,'DANGER crimson #e8453c rock; dark red shadows, sharp scarlet upper edges'),('meteor',1.2,.65,'DANGER dark navy rock with crimson #e8453c broad angular cracks')]:
    m=model(name,hint)
    roundpart(m,name,hint,[(0,r*.75),(h*.25,r),(h*.66,r*.8),(h,r*.18)],7,noise=.13,seed=11)
    if name=='red_rock':
        roundpart(m,'spike','DANGER crimson sharp side spike, dark red base',[(0,.6),(3.6,.5),(4.9,0)],5,mat=T(.9,0,0))
    done(m)
m=model('tower','Short stone lookout tower, yellow flat top')
roundpart(m,'stone','cream stone, two broad lavender mortar seams, navy doorway on front column 6',[(0,.75),(.2,.85),(.35,.66),(2.2,.66)],8)
roundpart(m,'top','yellow flat stone platform, ochre rim',[(2.2,.88),(2.5,.88)],8)
done(m)
for name,height,hint in [('rose',1.4,'warm pink coral #ff8a80 rose bloom; a few broad overlapping petal arcs; NO danger red'),('glass_flower',.6,'pale mint glass flower, cream edges, broad flat sky blue shadow, matte')]:
    m=model(name,hint)
    roundpart(m,'stem','mint green stem',[(0,.035),(height*.75,.035)],5)
    for x,ang in [(-.12,-45),(.12,45)]:
        roundpart(m,'leaf','mint leaf one dark green center seam',[(0,.03),(.14,.12),(.3,0)],5,mat=T(x,0,height*.3) @ R(ang,'Y'),key='leaf')
    roundpart(m,'bloom',hint,[(height*.63,.12),(height*.8,height*.23),(height*.96,height*.18),(height,height*.09)],7)
    done(m)
m=model('glass_dome','Clear-blue glass bell with white rim')
roundpart(m,'rim','cream white thick rim',[(0,.46),(.08,.46)],10)
roundpart(m,'glass','clear pale sky blue glass; single broad cream edge reflection; pale blue flat planes, no gloss',[(.08,.42),(.53,.42),(.72,.27),(.8,.08)],10)
done(m)
m=model('parcel','Kraft brown parcel with cream string cross')
block(m,'parcel','kraft brown paper, cream string crosses through center of FRONT TOP BACK BOTTOM; single crease',(.75,.55,.5))
block(m,'knot','cream string knot',(.12,.12,.05),mat=T(z=.5))
roundpart(m,'seal','plain cream wax knot center, no symbol',[(.5,.045),(.55,.045)],6)
done(m)
m=model('tree','Lollipop tree with round low-poly mint crown and brown trunk')
roundpart(m,'trunk','warm brown trunk, one cream notch',[(0,.16),(1.3,.13)],7)
roundpart(m,'crown','mint green crown, broad pale mint top and dark green lower facets, no individual leaves',[(.95,.35),(1.2,.8),(1.8,.9),(2.25,.56),(2.4,.12)],9)
done(m)
m=model('wall','Cream stone garden wall unit, lavender shadows')
for z in [0,.33,.66]:
    block(m,'course','cream stone, lavender lower shadow, one broad chip', (1,.5,.34),mat=T(z=z),key='course')
block(m,'cap','cream stone top slab pale yellow edge',(1,.5,.12),mat=T(z=.88))
done(m)
