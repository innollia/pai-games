"""Static course checks and flight-envelope math. No game input, no bot, no Godot launch."""
from pathlib import Path
import json
import math
import re

code = (Path(__file__).parents[2] / 'g' / 'boulder.gd').read_text(encoding='utf-8')
legs = [json.loads(text) for text in re.findall(r'"legs": (\[\[.*?\]\])', code, re.S)]
assert len(legs) >= 25
for item in legs:
    for leg in item:
        assert int(leg[0]) > 0 and float(leg[2]) >= 2.0, leg
        assert len(leg) < 5 or leg[4] in ['ramp', 'gap', 'bridge', 'aq', 'drop', 'plaza', 'gate', 'rope', 'drum']
for size in [2.0, 3.5, 5.0, 7.0]:
    # Earliest valid release, slowest carried speed, conservative drag integration.
    charge_time = .4 / (.8 + size * .1)
    release_offset = 12.0 * charge_time
    forward = 45.0 + 9.0 * .4
    vertical = (36.0 + .4 * 8.0) / (size / 2.0) ** .22
    height = 0.0
    traveled = 0.0
    while vertical > 0 or height > 0:
        dt = 1 / 600
        forward -= .0014 * .3 * forward * forward * dt
        traveled += forward * dt
        vertical -= 32 * dt
        height += vertical * dt
    # Longest bed 50m + 38m gap; all landings descend, so level return is conservative.
    assert traveled > 88 - release_offset, (size, traveled, release_offset)
assert '"goal": 326' in code
assert code.count('"goal":') == 1
assert 'if cur_k == 1 and not underground' in code
assert 'user://boulder_v6.cfg' in code
assert code.count('"msg":') == 11
for zone_name, verb in [('조수 정원', '"flow":'), ('공명 제단', '"drum":')]:
    zone = code.split('{"msg": "' + zone_name, 1)[1].split('{"msg":', 1)[0]
    assert zone.count(verb) >= 2, zone_name
    assert '섞기:' in zone and '"row":' in zone and '"snow":' in zone, zone_name
assert 'if fresh_run:' in code and 'var fresh_run := true' in code
assert 'finish_time = run_elapsed' in code and 'config.save(RECORD)' in code
assert '바다 도착' in code and '"floor": WATER' in code
print(f'course static OK: {len(legs)} authored pieces, all four stone sizes clear the new launch envelope')
