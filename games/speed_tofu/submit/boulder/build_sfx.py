"""굴러라 신전석 효과음. TINProject pixel_arena 방식: nkido(MIT)가 원재료(한 주기 파형·잡음)를 렌더하고,
numpy·scipy 가 층을 쌓는다(음높이 스윕, 감쇠, 필터, 짧은 울림). 외부 샘플 없음, 항상 --no-default-bank.

    python build_sfx.py   ->  games/speed_tofu/art/boulder/sfx/<이름>.wav (24 kHz 모노 16bit)
"""
from pathlib import Path
import json, os, subprocess, wave

import numpy as np
from scipy.signal import butter, lfilter

HERE = Path(__file__).resolve().parent
OUT = HERE.parent.parent / "art/boulder/sfx"
WORK = HERE / "work/sfx"
NKIDO = Path(os.environ.get("NKIDO", r"C:\projects\_tools\nkido\build-clang\bin\nkido.exe"))
RATE = 48000
BASE_HZ = 100.0
rng = np.random.default_rng(31)
SRC: dict = {}


def render(name: str, expr: str, seconds: int) -> np.ndarray:
    patch = WORK / f"{name}.akkado"
    patch.write_text(f"// boulder sfx 원재료, nkido MIT, 샘플 없음\n{expr} |> out(%)\n", encoding="utf-8")
    wav = WORK / f"{name}.wav"
    subprocess.run([str(NKIDO), "render", str(patch), "-o", str(wav), "--seconds", str(seconds), "--rate", str(RATE), "--no-default-bank"],
                   check=True, capture_output=True, timeout=60)
    with wave.open(str(wav), "rb") as h:
        pcm = np.frombuffer(h.readframes(h.getnframes()), "<i2").astype(float).reshape(-1, h.getnchannels()).mean(axis=1) / 32768.0
    pcm -= pcm.mean()
    return pcm / max(np.abs(pcm).max(), 1e-9)


def osc(kind, freq):
    table = SRC[kind]
    phase = np.cumsum(np.asarray(freq, float) / RATE) * len(table)
    return np.interp(phase % len(table), np.arange(len(table)), table)


def T(s):
    return np.arange(int(s * RATE)) / RATE


def noise(s):
    bed = SRC["noise"]
    n = int(s * RATE)
    i = int(rng.integers(0, len(bed) - n - 1))
    return bed[i:i + n].copy()


def env(s, a, d):
    t = T(s)
    return np.minimum(t / max(a, 1e-4), 1.0) * np.exp(-t * d)


def sweep(s, a, b, k):
    return b + (a - b) * np.exp(-T(s) * k)


def flat(s, f):
    return np.full(int(s * RATE), float(f))


def filt(x, kind, cut, order=2):
    b, a = butter(order, np.asarray(cut) / (RATE / 2), kind)
    return lfilter(b, a, x)


def mix(*parts):
    out = np.zeros(max(len(p) for p in parts))
    for p in parts:
        out[:len(p)] += p
    return out


def delay(x, sec):
    return np.concatenate([np.zeros(int(sec * RATE)), x])


def room(x, amount, size=1.0):
    tail = np.concatenate([x, np.zeros(int(0.6 * size * RATE))])
    wet = np.zeros_like(tail)
    for d, g in [(0.031, 0.5), (0.041, 0.42), (0.053, 0.35), (0.071, 0.27), (0.097, 0.2)]:
        k = int(d * size * RATE)
        wet[k:] += tail[:-k] * g
    return tail + filt(wet, "lowpass", 3800) * amount


# ---- 소리들: 돌·바위가 주인공. 장난감 삑 소리 대신 질감 있는 타격 ----
def roll():  # 구르는 돌이 바닥을 한 번 누르는 묵직한 톡 (자주 울린다)
    s = 0.13
    thud = osc("sine", sweep(s, 95, 48, 30)) * env(s, 0.002, 34)
    grit = filt(noise(s), "bandpass", [180, 700]) * env(s, 0.001, 45) * 0.7
    return np.tanh(mix(thud, grit) * 1.4)


def jump():  # 바위가 땅을 박차고 뜬다
    s = 0.4
    push = osc("sine", sweep(s, 130, 45, 22)) * env(s, 0.001, 16)
    dirt = filt(noise(s), "lowpass", 1400) * env(s, 0.001, 24) * 0.7
    t = T(s)
    air = filt(noise(s), "bandpass", [700, 3400]) * np.sin(np.clip(t / s, 0, 1) * np.pi) ** 2 * 0.45
    return np.tanh(mix(push * 1.2, dirt, air) * 1.4)


def crush_s():  # 항아리: 도자기 깨짐 + 조각 짤랑
    s = 0.4
    snap = filt(noise(s), "highpass", 3200) * env(s, 0.0004, 80)
    body = filt(noise(s), "bandpass", [700, 2400]) * env(s, 0.001, 26) * 0.8
    ring = sum(osc("sine", flat(s, f)) * env(s, 0.001, d) * g for f, d, g in [(1240, 30, 0.25), (1810, 38, 0.18), (2650, 45, 0.12)])
    shards = mix(*[delay(filt(noise(0.05), "highpass", 4000) * env(0.05, 0.0003, 120) * 0.35, dt) for dt in (0.05, 0.09, 0.14)])
    return room(np.tanh(mix(snap, body, ring, shards) * 1.5), 0.15, 0.6)


def crush_m():  # 집·석상: 돌과 나무가 무너진다
    s = 0.7
    boom = osc("sine", sweep(s, 150, 46, 16)) * env(s, 0.001, 9) * 1.1
    crunch = filt(noise(s), "bandpass", [250, 1600]) * env(s, 0.001, 11)
    crack = filt(noise(s), "highpass", 3000) * env(s, 0.0005, 70) * 0.7
    debris = mix(*[delay(filt(noise(0.08), "bandpass", [600, 2500]) * env(0.08, 0.001, 50) * 0.4, dt) for dt in (0.12, 0.2, 0.31)])
    return room(np.tanh(mix(boom, crunch, crack, debris) * 1.7), 0.25)


def crush_big():  # 탑·황금 신상: 깊은 붕괴 + 잔해가 쏟아진다
    s = 1.6
    sub = osc("sine", sweep(s, 120, 28, 5)) * env(s, 0.002, 3.4) * 1.4
    blast = filt(noise(s), "lowpass", 2200) * env(s, 0.001, 5)
    crack = filt(noise(s), "highpass", 3200) * env(s, 0.0004, 45) * 0.9
    rubble = filt(noise(s), "bandpass", [400, 2200]) * env(s, 0.12, 3.5) * (0.6 + 0.4 * np.sin(T(s) * 2 * np.pi * 7)) * 0.5
    return room(np.tanh(mix(sub, blast, crack, rubble) * 1.9), 0.5, 1.5)


def land():  # 쾅 착지
    s = 0.7
    boom = osc("sine", sweep(s, 90, 34, 12)) * env(s, 0.001, 7) * 1.4
    dust = filt(noise(s), "lowpass", 1800) * env(s, 0.001, 9)
    tick = filt(noise(s), "highpass", 3500) * env(s, 0.0004, 90) * 0.6
    return room(np.tanh(mix(boom, dust, tick) * 2.0), 0.3)


def bonk():  # 단단한 것에 막힘
    s = 0.3
    knock = osc("sine", sweep(s, 260, 110, 30)) * env(s, 0.001, 24)
    wood = filt(noise(s), "bandpass", [400, 1300]) * env(s, 0.001, 35) * 0.8
    return np.tanh(mix(knock, wood) * 1.8)


def split():  # 돌이 쩍 갈라지고 앞으로 튀어 나간다
    s = 0.6
    crack = filt(noise(s), "highpass", 2600) * env(s, 0.0003, 60)
    chunk = osc("sine", sweep(s, 200, 70, 25)) * env(s, 0.001, 18) * 0.9
    t = T(s)
    shape = np.clip(t / 0.45, 0, 1)
    air = (filt(noise(s), "bandpass", [600, 1800]) * (1 - shape) + filt(noise(s), "bandpass", [2200, 6500]) * shape) * np.sin(shape * np.pi) ** 1.5 * 0.9
    return np.tanh(mix(crack, chunk, air) * 1.6)


def throw():  # 몸 한 덩이를 휙
    s = 0.32
    t = T(s)
    shape = np.sin(np.clip(t / s, 0, 1) * np.pi)
    whoosh = filt(noise(s), "bandpass", [500, 2600]) * shape ** 2 * 1.2
    grunt = osc("sine", sweep(s, 140, 70, 20)) * env(s, 0.001, 25) * 0.5
    return mix(whoosh, grunt)


def glass():  # 보라 수정 깨짐
    s = 0.9
    ring = sum(osc("sine", flat(s, f)) * env(s, 0.0005, d) * g for f, d, g in [(1980, 6, 0.5), (2870, 8, 0.38), (4210, 11, 0.28), (6120, 15, 0.18)])
    shatter = filt(noise(s), "highpass", 3500) * env(s, 0.0003, 22) * 0.9
    return room(mix(ring, shatter), 0.35)


def gem():  # 동굴 보석
    s = 0.35
    a = osc("sine", flat(s, 1760)) * env(s, 0.001, 14)
    b = delay(osc("sine", flat(s - 0.06, 2637)) * env(s - 0.06, 0.001, 16), 0.06)
    sparkle = filt(noise(s), "highpass", 7000) * env(s, 0.001, 30) * 0.15
    return room(mix(a, b * 0.8, sparkle) * 0.8, 0.45, 0.8)


def cave():  # 수정 동굴로 떨어짐: 깊은 울림 + 반짝이는 공기
    s = 2.4
    t = T(s)
    sub = osc("sine", sweep(s, 80, 36, 6)) * env(s, 0.002, 2.2) * 1.2
    drone = filt(osc("saw", flat(s, 55)) + osc("saw", flat(s, 55.3)), "lowpass", 420) * np.minimum(t / 0.6, 1) * np.exp(-t * 0.9) * 0.35
    bells = mix(*[delay(osc("sine", flat(s - dt, f)) * env(s - dt, 0.002, 3.0) * 0.14, dt) for dt, f in [(0.25, 1318.5), (0.55, 1975.5), (0.85, 2637.0), (1.1, 1760.0)]])
    air = filt(noise(s), "bandpass", [3000, 8000]) * np.minimum(t / 0.8, 1) * np.exp(-t * 1.2) * 0.12
    return room(mix(sub, drone, bells, air), 0.6, 1.8)


def warn():  # 느려: 돌이 긁히는 둔탁한 경고
    s = 0.18
    return np.tanh(filt(osc("saw", flat(s, 92)), "lowpass", 700) * env(s, 0.002, 18) * 2.0) * 0.8


def snow():  # 눈 밟는 뽀득
    s = 0.12
    return filt(noise(s), "bandpass", [1800, 6000]) * env(s, 0.002, 40) + filt(noise(s), "bandpass", [300, 900]) * env(s, 0.003, 50) * 0.5


def melt():  # 칙 녹는 소리
    s = 0.3
    t = T(s)
    return filt(noise(s), "highpass", 4500) * np.sin(np.clip(t / s, 0, 1) * np.pi) * 0.7


def charge():  # 황금 발판 힘 참: 금속성 울림
    s = 0.7
    ring = sum(osc("sine", flat(s, f)) * env(s, 0.002, d) * g for f, d, g in [(523, 4, 0.5), (1046, 5, 0.3), (1568, 7, 0.2)])
    hit = filt(noise(s), "bandpass", [1500, 5000]) * env(s, 0.0005, 50) * 0.4
    return room(mix(ring, hit), 0.4)


def launch():  # 공명 도약: 깊은 북 + 솟구치는 바람
    s = 0.9
    t = T(s)
    drum = osc("sine", sweep(s, 110, 40, 10)) * env(s, 0.001, 6) * 1.3
    shape = np.clip(t / 0.7, 0, 1)
    rise = (filt(noise(s), "bandpass", [500, 1500]) * (1 - shape) + filt(noise(s), "bandpass", [2500, 7000]) * shape) * np.sin(shape * np.pi) * 0.8
    return room(np.tanh(mix(drum, rise) * 1.6), 0.3)


def creak():  # 흔들다리 삐걱
    s = 0.35
    t = T(s)
    f = 140 + 40 * np.sin(t * 2 * np.pi * 3)
    rasp = filt(np.tanh(osc("saw", f) * 2), "bandpass", [500, 1800]) * (0.5 + 0.5 * (np.sin(t * 2 * np.pi * 34) > 0)) * env(s, 0.02, 7)
    return rasp * 0.8


def fall():  # 아래로 떨어짐
    s = 1.1
    t = T(s)
    whistle = osc("sine", sweep(s, 700, 140, 2.2)) * np.minimum(t / 0.05, 1) * np.exp(-t * 1.6) * 0.4
    wind = filt(noise(s), "bandpass", [300, 1400]) * np.minimum(t / 0.3, 1) * np.exp(-t * 1.5) * 0.7
    return mix(whistle, wind)


def rumble():  # 뒤에서 굴러오는 바위: 울퉁불퉁 저음
    s = 0.9
    t = T(s)
    lump = 0.55 + 0.45 * np.sin(t * 2 * np.pi * 6.5)
    bed = filt(noise(s), "lowpass", 600) * lump * np.minimum(t / 0.25, 1) * np.exp(-t * 2.2)
    sub = osc("sine", flat(s, 42)) * lump * np.minimum(t / 0.25, 1) * np.exp(-t * 2.2) * 0.6
    return np.tanh(mix(bed, sub) * 1.8)


def catch():  # 노란 돌을 받아 합쳐짐
    s = 0.45
    thud = osc("sine", sweep(s, 160, 60, 18)) * env(s, 0.001, 12)
    chime = osc("sine", flat(s, 880)) * env(s, 0.002, 10) * 0.25 + osc("sine", flat(s, 1320)) * env(s, 0.002, 12) * 0.15
    return room(np.tanh(mix(thud, chime) * 1.5), 0.2)


def tick():  # 갈림길 선택
    s = 0.09
    return filt(noise(s), "bandpass", [1500, 4000]) * env(s, 0.0005, 70) + osc("sine", flat(s, 660)) * env(s, 0.001, 50) * 0.3


SOUNDS = [roll, jump, crush_s, crush_m, crush_big, land, bonk, split, throw, glass, gem, cave, warn, snow, melt, charge, launch, creak, fall, rumble, catch, tick]


def save(name, x):
    x = x - x.mean()
    x = x / max(np.abs(x).max(), 1e-9) * 0.89
    fade = min(int(0.012 * RATE), len(x) // 3)
    x[-fade:] *= np.linspace(1, 0, fade)
    x = filt(x, "lowpass", 11000)[::2]  # 24 kHz
    assert np.abs(x).max() < 0.99 and np.sqrt(np.mean(x ** 2)) > 0.01, name
    pcm = (x * 32767).astype("<i2")
    with wave.open(str(OUT / f"{name}.wav"), "wb") as h:
        h.setnchannels(1)
        h.setsampwidth(2)
        h.setframerate(24000)
        h.writeframes(pcm.tobytes())
    return {"file": f"{name}.wav", "seconds": round(len(x) / 24000, 3)}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    WORK.mkdir(parents=True, exist_ok=True)
    period = int(RATE / BASE_HZ)
    for kind in ("sine", "tri", "saw"):
        SRC[kind] = render(kind, f"{kind}({BASE_HZ:g})", 2)[RATE // 2: RATE // 2 + period]
    SRC["noise"] = render("noise", "noise(0, 0, 211)", 6)
    recs = [save(f.__name__, f()) for f in SOUNDS]
    (HERE / "SFX_MANIFEST.json").write_text(json.dumps({"tool": "nkido (MIT) 원재료 + numpy/scipy 다듬기, --no-default-bank", "samples": "none", "rate": 24000, "sounds": recs}, ensure_ascii=False, indent=1), encoding="utf-8")
    print("ok", len(recs))


if __name__ == "__main__":
    main()
