"""사용자가 고친 TEXT_KO.tsv 의 "한국어(수정)" 칸을 g/tinyplanet_text.gd 의 한국어 자리에 넣는다.
영어는 그대로 둔다 (Claude 가 새 한국어에 맞춰 다시 옮긴다). 바뀐 키는 submit/tinyplanet/TEXT_CHANGED.tsv 에 쌓인다.
쓰는 법:  python submit/tinyplanet/tools/text_import.py [고친.tsv]   (없으면 submit/tinyplanet/TEXT_KO.tsv)
          --dry  : 파일은 안 바꾸고 무엇이 바뀔지만 보인다
"""
import csv
import io
import sys
from pathlib import Path

from text_common import CHANGED, HOLE, TEXT_GD, TSV, entries, read_lines, set_ko


def read_tsv(p: Path) -> list[dict]:
    raw = p.read_bytes()
    if raw.startswith(b"\xff\xfe") or raw.startswith(b"\xfe\xff"):
        txt = raw.decode("utf-16")  # 엑셀 "유니코드 텍스트"로 저장한 것
    else:
        try:
            txt = raw.decode("utf-8-sig")
        except UnicodeDecodeError:
            txt = raw.decode("cp949")  # 엑셀 "텍스트(탭으로 분리)" 옛 저장
    rd = csv.reader(io.StringIO(txt), delimiter="\t")
    rows = list(rd)
    if not rows:
        return []
    head = [h.strip() for h in rows[0]]
    ki = head.index("key")
    ni = next(i for i, h in enumerate(head) if h.startswith("한국어(수정)"))
    out = []
    for r in rows[1:]:
        if len(r) > max(ki, ni):
            out.append({"key": r[ki].strip(), "new": r[ni].strip()})
    return out


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    dry = "--dry" in sys.argv
    src = Path(args[0]) if args else TSV
    edits = {r["key"]: r["new"] for r in read_tsv(src) if r["key"] and r["new"]}
    lines = read_lines()
    have = {key: (i, ko) for i, key, ko, _en, _w, _who, _s in entries(lines)}
    changed, skipped = [], []
    for key, new in edits.items():
        if key not in have:
            skipped.append(f"{key}: 표에 없는 키")
            continue
        i, old = have[key]
        if new == old:
            continue
        if key.startswith("tofu."):
            skipped.append(f"{key}: tofu 공통 글이라 한국어는 못 바꿈 (tofu.gd 가 직접 씀)")
            continue
        if sorted(HOLE.findall(new)) != sorted(HOLE.findall(old)):
            skipped.append(f"{key}: {{...}} 자리가 달라짐 ({' '.join(HOLE.findall(old)) or '없음'} 이어야 함) -> 건너뜀")
            continue
        lines[i] = set_ko(lines[i], new)
        changed.append((key, old, new))
    for k, o, n in changed:
        print(f"바뀜 {k}\n  전: {o}\n  후: {n}")
    for s in skipped:
        print("건너뜀", s)
    print(f"바뀐 줄 {len(changed)}, 건너뛴 줄 {len(skipped)}")
    if dry or not changed:
        return 0
    TEXT_GD.write_text("\n".join(lines), encoding="utf-8", newline="")
    # 영어를 다시 옮겨야 할 키 목록 (이전 것에 더한다; 같은 키는 새 한국어로)
    prev = {}
    if CHANGED.exists():
        for ln in CHANGED.read_text(encoding="utf-8-sig").splitlines()[1:]:
            p = ln.split("\t")
            if len(p) >= 3:
                prev[p[0]] = (p[1], p[2])
    for k, o, n in changed:
        prev[k] = (prev[k][0] if k in prev else o, n)
    with open(CHANGED, "w", encoding="utf-8-sig", newline="") as f:
        f.write("key\t옛 한국어\t새 한국어 (영어 다시 옮길 것)\r\n")
        for k, (o, n) in prev.items():
            f.write(f"{k}\t{o}\t{n}\r\n")
    print(f"{TEXT_GD} 고침, 바뀐 키 목록: {CHANGED}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
