"""Equivalent run_codex_texture flow with all writable outputs inside this project.
Original hwapongstuy tools are read only. Run one asset at a time.
"""
from pathlib import Path
import sys
import runpy

HERE = Path(__file__).parent.resolve()
SOURCE = Path('C:/projects/hwapongstuy/texture3d')
sys.path.insert(0, str(SOURCE.parent / 'tools'))
code = (SOURCE / 'tools/run_codex_texture.py').read_text(encoding='utf-8')
code = code.replace('HERE = Path(__file__).resolve().parents[1]', 'HERE = Path(' + repr(str(HERE / 'work')) + ')')
ns = {'__name__': 'texture_flow', '__file__': __file__}
exec(code, ns)
sys.stdout.reconfigure(encoding='utf-8')
raise SystemExit(ns['main']([*sys.argv[1:], '--work', str(HERE / 'work' / 'cleanroom')]))
