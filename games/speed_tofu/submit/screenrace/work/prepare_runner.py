from pathlib import Path
w=Path(__file__).resolve().parent
s=Path('C:/projects/hwapongstuy/texture3d/tools/run_codex_texture.py').read_text(encoding='utf-8')
s=s.replace('HERE = Path(__file__).resolve().parents[1]', 'HERE = Path(__file__).resolve().parent')
s=s.replace('str(HERE.parent / "tools")', 'r"C:/projects/hwapongstuy/tools"')
(w/'pipeline/run_codex_texture.py').write_text(s,encoding='utf-8')
(w/'.gdignore').touch()
