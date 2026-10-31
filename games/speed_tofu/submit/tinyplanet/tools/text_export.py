"""g/tinyplanet_text.gd 의 글을 submit/tinyplanet/TEXT_KO.tsv 로 내보낸다 (엑셀·구글 시트에서 열어 "한국어(수정)" 칸을 채운다).
쓰는 법:  python submit/tinyplanet/tools/text_export.py
"""
import csv
import sys

from text_common import HEADER, TSV, entries, read_lines


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    rows = []
    for _i, key, ko, en, when, who, sec in entries(read_lines()):
        if key.startswith("tofu."):
            when = when + " (tofu 공통 글: 한국어는 여기서 고쳐도 안 바뀜, 영어만)"
        rows.append([key, f"[{sec}] {when}" if sec else when, who if who != "-" else "", ko, en, ""])
    # 엑셀이 한글을 바로 읽게 BOM 을 붙인다
    with open(TSV, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.writer(f, delimiter="\t", lineterminator="\r\n")
        w.writerow(HEADER)
        w.writerows(rows)
    print(f"{TSV} : {len(rows)}줄")
    return 0


if __name__ == "__main__":
    sys.exit(main())
