"""Python/Pillow: production resolutions and reproducible size manifest (no repainting)."""
from pathlib import Path
from PIL import Image
import json

HERE = Path(__file__).parent
ART = HERE.parents[1] / 'art' / 'tinyplanet'
manifest = []
for source in sorted((HERE / 'work' / 'out').glob('tp_*/texture.png')):
    name = source.parent.name.removeprefix('tp_')
    size = 512
    # Quantization preserves generated paint and makes the mobile download predictable.
    image = Image.open(source).convert('RGB').resize((size, size), Image.Resampling.LANCZOS)
    image.quantize(colors=192).save(ART / (name + '.png'), optimize=True)
    for extension in ['glb', 'png']:
        file = ART / (name + '.' + extension)
        assert file.stat().st_size < 1_500_000, file
        manifest.append({'path': file.name, 'bytes': file.stat().st_size})
assert len(manifest) == 30
assert sum(p['bytes'] for p in manifest) <= 4_000_000
(HERE / 'ASSET_MANIFEST.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
print('assets:', len(manifest), 'bytes:', sum(p['bytes'] for p in manifest))
