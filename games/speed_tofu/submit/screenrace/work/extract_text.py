import re, json, sys
from pathlib import Path
ROOT = Path(r'C:/projects/pai-games/games/speed_tofu')
S = '"([^"]*)"'
pats = [
    ('L', re.compile(r'\b_?L\(\s*' + S + r'\s*,\s*' + S + r'\s*\)', re.S)),
    ('stamp', re.compile(r'_stamp\(\s*' + S + r'\s*,\s*' + S, re.S)),
    ('stamp', re.compile(r'_stamp\(\s*' + S + r'\s*%[^,]+,\s*' + S, re.S)),
    ('ifko', re.compile(S + r'\s+if\s+ko\s+else\s+' + S, re.S)),
]
WHERE = {'_stamp': '도장(화면에 찍히는 글)', '_fill_bubble': '연습 말풍선', '_howto_text': '하는 법(?) 카드', '_show_board': '판 끝 결과판',
         'show_results': '마지막 결과 영수증', '_res': '마지막 결과 영수증', 'countdown_tick': '출발 카운트다운', '_route_advice': '길 카드 설명',
         '_gate_tick': '낮은 문 안내', '_start_round': '출발 때 큰 안내', '_pick_route': '다음 길 안내', 'refresh_text': '제목·연습 버튼',
         '_finger': '홈 버튼 안내', '_set_lang': '언어', '_record_course': '메달·기록'}
rows = []
seen = set()
def add(ko, en, where):
    ko = ko.replace('\n', ' / ').replace('\\"', '"'); en = en.replace('\n', ' / ').replace('\\"', '"')
    if not re.search('[가-힣]', ko):
        return
    k = (ko, en)
    if k in seen:
        return
    seen.add(k)
    rows.append((where, ko, en))
for fn in ['g/screenrace.gd', 'g/sr_front.gd', 'g/sr_menus.gd', 'g/sr_hud.gd', 'g/sr_theme.gd']:
    text = (ROOT / fn).read_text(encoding='utf-8')
    funcs = [(m.start(), m.group(1)) for m in re.finditer(r'^\s*(?:static\s+)?func\s+(\w+)', text, re.M)]
    def func_at(pos):
        name = ''
        for p, n in funcs:
            if p <= pos: name = n
            else: break
        return name
    hits = []
    for kind, p in pats:
        for m in p.finditer(text):
            hits.append((m.start(), kind, m.group(1), m.group(2)))
    for pos, kind, ko, en in sorted(hits):
        line = text.count('\n', 0, pos) + 1
        # skip comment lines and the unused segment sign table
        ls = text.rfind('\n', 0, pos) + 1
        if text[ls:pos].lstrip().startswith('#'):
            continue
        f = func_at(pos)
        where = '도장(화면에 찍히는 글)' if kind == 'stamp' else WHERE.get(f, f or '맨 위 표')
        add(ko, en, where)
src = (ROOT / 'g/screenrace.gd').read_text(encoding='utf-8')
def table(name):
    m = re.search(r'^const ' + name + r' := (.*?)\n(?=const |#|var |func )', src, re.S | re.M)
    return m.group(1)
# courses
ko_c = re.findall(r'\{"name": "([^"]+)", "rule": "[^"]*", "say": "([^"]+)"', src)
en_c = re.findall(r'\["([^"]+)", "([^"]+)"\]', table('COURSES_EN'))
for (kn, ks), (en_n, en_s) in zip(ko_c, en_c):
    add(kn, en_n, '동네 이름'); add(ks, en_s, '동네 설명')
for key, (kn, ks) in re.findall(r'"(\w+)": \["([^"]+)", "([^"]+)"\]', table('TWISTS')) and [(k, (a, b)) for k, a, b in re.findall(r'"(\w+)": \["([^"]+)", "([^"]+)"\]', table('TWISTS'))]:
    en = dict((k, (a, b)) for k, a, b in re.findall(r'"(\w+)": \["([^"]+)", "([^"]+)"\]', table('TWISTS_EN')))
    add(kn, en[key][0], '길 이름'); add(ks, en[key][1], '길 설명')
modes = dict(re.findall(r'"(\w+)": "([^"]+)"', table('MODES'))); modes_en = dict(re.findall(r'"(\w+)": "([^"]+)"', table('MODES_EN')))
mr = dict(re.findall(r'"(\w+)": "([^"]+)"', table('MODE_RULES'))); mr_en = dict(re.findall(r'"(\w+)": "([^"]+)"', table('MODE_RULES_EN')))
for k in modes:
    add(modes[k], modes_en[k], '모드 이름'); add(mr[k], mr_en[k], '모드 설명')
ps = dict(re.findall(r'"([^"]+)": "([^"]+)"', table('PERK_SAY')))
pe = {k: (a, b) for k, a, b in re.findall(r'"([^"]+)": \["([^"]+)", "([^"]+)"\]', table('PERK_EN'))}
for k in ps:
    add(k, pe[k][0], '특전 이름'); add(ps[k], pe[k][1], '특전 설명')
nk = re.search(r'var nicks := \[(.*?)\]', src).group(1); nke = table('NICKS_EN')
for a, b in zip(re.findall(r'"([^"]+)"', nk), re.findall(r'"([^"]+)"', nke)):
    add(a, b, '배달부 이름')
# shared rating card (standalone translates these)
sync = (ROOT.parent / 'off_screen/tools/sync.ps1').read_text(encoding='utf-8-sig')
for a, b in re.findall(r"'\"(.*?)\"' = '\"(.*?)\"'", sync):
    add(a.replace('\n', ' / '), b.replace('\n', ' / '), '별점 카드·공용 글')
json.dump(rows, open(sys.argv[1], 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
print(len(rows))
