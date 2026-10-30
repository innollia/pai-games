"""Production payload checks, without launching Godot or driving game input."""
from pathlib import Path
import json
import struct
from PIL import Image

HERE = Path(__file__).parent
ART = HERE.parents[1] / 'art' / 'boulder'
NAMES = {'stone','pillar','valley','snow','coast','crystal','plank','temple','pot'}
expected = {name + ext for name in NAMES for ext in ['.glb','.png']}
payload = {p.name for p in ART.iterdir() if p.suffix in ['.glb','.png']}
assert payload == expected, payload ^ expected
assert not list(ART.parent.rglob('.gdignore'))
manifest = json.loads((HERE / 'ASSET_MANIFEST.json').read_text())
assert {r['path'] for r in manifest} == expected
for row in manifest:
    assert (ART / row['path']).stat().st_size == row['bytes']
for name in NAMES:
    with Image.open(ART / (name+'.png')) as image:
        assert image.size == (512,512), name
    data = (ART / (name+'.glb')).read_bytes()
    magic, version, length, chunk_len, kind = struct.unpack_from('<5I', data)
    assert magic == 0x46546C67 and version == 2 and length == len(data)
    assert kind == 0x4E4F534A
    model = json.loads(data[20:20+chunk_len])
    assert len(model['meshes']) == 1, name
    assert not model.get('images'), name
    for primitive in model['meshes'][0]['primitives']:
        assert 'TEXCOORD_0' in primitive['attributes'], name
        bounds = model['accessors'][primitive['attributes']['POSITION']]
        assert all(abs(v+.5)<.001 for v in bounds['min']), (name,bounds)
        assert all(abs(v-.5)<.001 for v in bounds['max']), (name,bounds)
size = sum(p.stat().st_size for p in ART.iterdir() if p.is_file())
assert size <= 4_000_000, size
print('art OK: 9 pairs, all PNGs 512x512, normalized UV meshes; directory bytes:', size)
