#!/usr/bin/env python3
"""Firestore 에 쌓인 평가(tofu_ratings)·아이디어(tofu_ideas)를 받아 FEEDBACK.md 를 만든다.
표준 라이브러리만 쓴다. 읽기는 규칙상 공개라 키 없이 REST 로 받는다.

  python tools/feedback.py            -> FEEDBACK.md (이 폴더 루트)
  python tools/feedback.py --json     -> 원본 문서도 feedback_raw.json 으로 저장

다음 세대 유전 알고리즘(어느 게임을 남기고 섞을지)의 입력이다.
"""
import json
import re
import os
import sys
import urllib.parse
import urllib.request
from collections import defaultdict
from datetime import datetime, timezone, timedelta

PROJECT = "innollia-blog"
BASE = f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KST = timezone(timedelta(hours=9))


def fetch_all(collection):
    """컬렉션의 문서를 전부 받아 [dict] 로 돌려준다 (pageToken 으로 이어 받는다)."""
    out = []
    token = None
    while True:
        q = {"pageSize": "300"}
        if token:
            q["pageToken"] = token
        url = f"{BASE}/{collection}?{urllib.parse.urlencode(q)}"
        req = urllib.request.Request(url, headers={"Accept": "application/json"})
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                data = json.loads(r.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            body = e.read().decode("utf-8", "replace")[:300]
            print(f"[{collection}] HTTP {e.code}: {body}", file=sys.stderr)
            break
        except Exception as e:  # 네트워크 등
            print(f"[{collection}] 실패: {e}", file=sys.stderr)
            break
        for d in data.get("documents", []):
            out.append(_flat(d))
        token = data.get("nextPageToken")
        if not token:
            break
    return out


def _val(v):
    """Firestore REST 값 {"stringValue": ..} -> 파이썬 값"""
    if "stringValue" in v:
        return v["stringValue"]
    if "integerValue" in v:
        return int(v["integerValue"])
    if "doubleValue" in v:
        return float(v["doubleValue"])
    if "booleanValue" in v:
        return v["booleanValue"]
    if "timestampValue" in v:
        return v["timestampValue"]
    if "nullValue" in v:
        return None
    if "mapValue" in v:
        return {k: _val(x) for k, x in v["mapValue"].get("fields", {}).items()}
    if "arrayValue" in v:
        return [_val(x) for x in v["arrayValue"].get("values", [])]
    return None


def _flat(doc):
    d = {k: _val(v) for k, v in doc.get("fields", {}).items()}
    d["_id"] = doc["name"].rsplit("/", 1)[-1]
    d["_created"] = doc.get("createTime", "")
    return d


def _when(d):
    s = d.get("ts") or d.get("_created") or ""
    try:
        t = datetime.fromisoformat(s.replace("Z", "+00:00"))
        return t.astimezone(KST).strftime("%Y-%m-%d %H:%M")
    except Exception:
        return s[:16]


def _sort_key(d):
    return d.get("ts") or d.get("_created") or ""


def _stars_bar(avg):
    n = int(round(avg))
    return "★" * n + "☆" * (5 - n)


def build_md(ratings, ideas):
    L = []
    now = datetime.now(KST).strftime("%Y-%m-%d %H:%M")
    L.append(f"# 평가·아이디어 모음\n")
    L.append(f"받은 때 {now} KST · 평가 {len(ratings)}건 · 아이디어 {len(ideas)}건. `python tools/feedback.py` 로 다시 만든다.\n")

    by_game = defaultdict(list)
    for r in ratings:
        g = str(r.get("game") or "?")
        if g.startswith("_"):  # _test 같은 확인용 기록은 집계에서 뺀다
            continue
        s = r.get("stars")
        if isinstance(s, int) and 1 <= s <= 5:
            by_game[g].append(r)

    L.append("## 게임별 별점\n")
    if not by_game:
        L.append("(아직 없음)\n")
    else:
        L.append("| 게임 | 평균 | 개수 | 분포 1·2·3·4·5 | 최근 버전 |")
        L.append("|---|---|---|---|---|")
        rows = []
        for g, rs in by_game.items():
            avg = sum(r["stars"] for r in rs) / len(rs)
            dist = [sum(1 for r in rs if r["stars"] == k) for k in range(1, 6)]
            latest = max(rs, key=_sort_key).get("ver") or "?"
            rows.append((avg, len(rs), g, dist, latest))
        rows.sort(key=lambda x: (-x[0], -x[1], x[2]))
        for avg, n, g, dist, latest in rows:
            L.append(f"| {g} | {avg:.2f} {_stars_bar(avg)} | {n} | {'·'.join(map(str, dist))} | {latest} |")
        L.append("")

        L.append("## 게임별 상세 (버전별 분포 · 한마디)\n")
        for avg, n, g, dist, latest in rows:
            rs = by_game[g]
            L.append(f"### {g} — 평균 {avg:.2f} ({n}건)\n")
            by_ver = defaultdict(list)
            for r in rs:
                by_ver[str(r.get("ver") or "?")].append(r)
            L.append("| 게임 버전·빌드 | 평균 | 개수 | 분포 1·2·3·4·5 | 평균 점수 |")
            L.append("|---|---|---|---|---|")
            for ver in sorted(by_ver, reverse=True):
                vs = by_ver[ver]
                va = sum(r["stars"] for r in vs) / len(vs)
                vd = [sum(1 for r in vs if r["stars"] == k) for k in range(1, 6)]
                scores = [r.get("score") for r in vs if isinstance(r.get("score"), (int, float))]
                sa = f"{sum(scores) / len(scores):.0f}" if scores else "-"
                L.append(f"| {ver} | {va:.2f} | {len(vs)} | {'·'.join(map(str, vd))} | {sa} |")
            words = [r for r in rs if str(r.get("text") or "").strip()]
            if words:
                L.append("\n한마디:\n")
                for r in sorted(words, key=_sort_key, reverse=True):
                    txt = str(r["text"]).strip().replace("\n", " ")
                    L.append(f"- ★{r['stars']} ({_when(r)}, {r.get('ver') or '?'}, 점수 {r.get('score', '-')}) {txt}")
            L.append("")

    # 별 없이 남긴 한마디(tofu_ideas 에 game 이 붙은 것)는 게임별로 따로 모은다
    notes = defaultdict(list)
    for d in ideas:
        g = str(d.get("game") or "")
        if g and not g.startswith("_") and not g.endswith("_stage"):
            notes[g].append(d)
    ideas = [d for d in ideas if not d.get("game")]
    L.append("## 별 없는 한마디 (게임별)\n")
    if not notes:
        L.append("(아직 없음)\n")
    else:
        for g in sorted(notes):
            L.append(f"### {g}\n")
            for d in sorted(notes[g], key=_sort_key, reverse=True):
                txt = str(d.get("text") or "").strip().replace("\n", " ")
                L.append(f"- ({_when(d)}, {d.get('ver') or '?'}) {txt}")
            L.append("")

    L.append("## 아이디어 (최신순)\n")
    if not ideas:
        L.append("(아직 없음)\n")
    else:
        for d in sorted(ideas, key=_sort_key, reverse=True):
            txt = str(d.get("text") or "").strip().replace("\r", "")
            body = "\n  ".join(txt.split("\n"))
            L.append(f"- ({_when(d)}, {d.get('ver') or '?'}) {body}")
        L.append("")
    return "\n".join(L)


def save_stages(ideas):
    """스테이지 제작 툴의 제출(game 이 <id>_stage)을 stages/<id>/<시각>_<이름>.json 으로 꺼낸다."""
    out = []
    for d in sorted(ideas, key=_sort_key):
        g = str(d.get("game") or "")
        if not g.endswith("_stage"):
            continue
        try:
            room = json.loads(str(d.get("text") or ""))
        except ValueError:
            continue
        name = re.sub(r"[^0-9A-Za-z가-힣_-]+", "_", str(room.get("name") or "room"))[:30]
        when = re.sub(r"[^0-9]", "", _when(d))[:12]
        folder = os.path.join(ROOT, "stages", g[:-len("_stage")])
        os.makedirs(folder, exist_ok=True)
        path = os.path.join(folder, f"{when}_{name}.json")
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            json.dump(room, f, ensure_ascii=False, indent=1)
        out.append(os.path.relpath(path, ROOT).replace("\\", "/"))
    return out


def main():
    ratings = fetch_all("tofu_ratings")
    ideas = fetch_all("tofu_ideas")
    stages = save_stages(ideas)
    md = build_md(ratings, [d for d in ideas if not str(d.get("game") or "").endswith("_stage")])
    if stages:
        md += "\n## 제출된 스테이지\n\n" + "\n".join(f"- {s}" for s in stages) + "\n"
    out = os.path.join(ROOT, "FEEDBACK.md")
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        f.write(md)
    print(f"{out}: 평가 {len(ratings)}건, 아이디어 {len(ideas)}건")
    if "--json" in sys.argv:
        raw = os.path.join(ROOT, "feedback_raw.json")
        with open(raw, "w", encoding="utf-8") as f:
            json.dump({"ratings": ratings, "ideas": ideas}, f, ensure_ascii=False, indent=1)
        print(raw)


if __name__ == "__main__":
    main()
