"""text_export.py / text_import.py 가 같이 쓰는 것: g/tinyplanet_text.gd 의 TEXT 표 줄을 읽고 쓴다."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]  # games/speed_tofu
TEXT_GD = ROOT / "g" / "tinyplanet_text.gd"
SUBMIT = ROOT / "submit" / "tinyplanet"
TSV = SUBMIT / "TEXT_KO.tsv"
CHANGED = SUBMIT / "TEXT_CHANGED.tsv"
HEADER = ["key", "언제 나오나", "누가", "한국어", "English", "한국어(수정)"]

_S = r'"((?:[^"\\]|\\.)*)"'
LINE = re.compile(r'^(\t"(?P<key>[^"]+)": \[)' + _S + r'(, )' + _S + r'(\],)(?:(\s*#\s*)(?P<note>.*))?$')
SECTION = re.compile(r'^\t# ---- (?P<name>.+?) ----')
HOLE = re.compile(r"\{[a-z_]+\}")


def unesc(s: str) -> str:
    out, i = [], 0
    while i < len(s):
        c = s[i]
        if c == "\\" and i + 1 < len(s):
            n = s[i + 1]
            out.append({"n": "\n", "t": "\t", '"': '"', "\\": "\\"}.get(n, n))
            i += 2
            continue
        out.append(c)
        i += 1
    return "".join(out)


def esc(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\t", "\\t")


def read_lines() -> list[str]:
    return TEXT_GD.read_text(encoding="utf-8").split("\n")


def entries(lines: list[str]):
    """(줄 번호, key, ko, en, 언제, 누가, 묶음 이름) 를 표 순서대로"""
    sec = ""
    for i, ln in enumerate(lines):
        m = SECTION.match(ln)
        if m:
            sec = m.group("name").split(" (")[0]
            continue
        m = LINE.match(ln.rstrip("\r"))
        if not m:
            continue
        note = m.group("note") or ""
        when, _, who = note.rpartition(" | ")
        if not _:
            when, who = note, ""
        yield i, m.group("key"), unesc(m.group(3)), unesc(m.group(5)), when.strip(), who.strip(), sec


def set_ko(line: str, ko: str) -> str:
    m = LINE.match(line.rstrip("\r"))
    assert m
    return line[: m.start(3) - 1] + '"' + esc(ko) + '"' + line[m.end(3) + 1 :]
