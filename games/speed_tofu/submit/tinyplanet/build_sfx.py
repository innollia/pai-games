"""작은 행성 효과음. 굴러라 신전석(boulder) 방식: nkido(MIT)가 원재료(한 주기 파형·잡음)만 렌더하고,
numpy·scipy 가 층을 쌓는다(음높이 스윕, 감쇠, 필터, 짧은 울림·우주 메아리). 외부 샘플 없음, 항상 --no-default-bank.
결: 장난감 삑 대신 손에 잡히는 질감 + 부드럽고 밝은 우주 공기.

    PYTHONUTF8=1 python build_sfx.py   ->  games/speed_tofu/art/tinyplanet_sfx/<이름>.wav (24 kHz 모노 16bit)
"""
from pathlib import Path
import json, os, subprocess, wave

import numpy as np
from scipy.signal import butter, lfilter

HERE = Path(__file__).resolve().parent
OUT = HERE.parent.parent / "art/tinyplanet_sfx"
WORK = HERE / "work/sfx"
NKIDO = Path(os.environ.get("NKIDO", r"C:\projects\_tools\nkido\build-clang\bin\nkido.exe"))
RATE = 48000
BASE_HZ = 100.0
rng = np.random.default_rng(47)
SRC: dict = {}


def render(name: str, expr: str, seconds: int) -> np.ndarray:
    patch = WORK / f"{name}.akkado"
    patch.write_text(f"// tinyplanet sfx 원재료, nkido MIT, 샘플 없음\n{expr} |> out(%)\n", encoding="utf-8")
    wav = WORK / f"{name}.wav"
    subprocess.run([str(NKIDO), "render", str(patch), "-o", str(wav), "--seconds", str(seconds), "--rate", str(RATE), "--no-default-bank"],
                   check=True, capture_output=True, timeout=60)
    with wave.open(str(wav), "rb") as h:
        pcm = np.frombuffer(h.readframes(h.getnframes()), "<i2").astype(float).reshape(-1, h.getnchannels()).mean(axis=1) / 32768.0
    pcm -= pcm.mean()
    return pcm / max(np.abs(pcm).max(), 1e-9)


# ---- 다듬기 도구 (boulder 와 같음 + echo) ----
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


def swell(s, p=1.0):  # 0 -> 1 -> 0 둥근 모양
    return np.sin(np.clip(T(s) / s, 0, 1) * np.pi) ** p


def sweep(s, a, b, k):
    return b + (a - b) * np.exp(-T(s) * k)


def glide(s, a, b, p=1.0):  # a 에서 b 로 시간 내내 (p>1 이면 끝에서 빨라짐)
    return a + (b - a) * np.clip(T(s) / s, 0, 1) ** p


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


def space(x, amount, gap=0.13, n=4, fb=0.45):  # 우주 메아리: 점점 어두워지는 반복
    out = np.concatenate([x, np.zeros(int(gap * n * RATE))])
    y = x.copy()
    for i in range(1, n + 1):
        y = filt(y, "lowpass", 5200 - 700 * i) * fb
        out[int(gap * i * RATE):int(gap * i * RATE) + len(y)] += y * amount
    return out


def bell(s, f, d, g=1.0, a=0.002):  # 부드러운 종: 기음 + 비조화 배음 약간
    return (osc("sine", flat(s, f)) * env(s, a, d)
            + osc("sine", flat(s, f * 2.0)) * env(s, a, d * 1.6) * 0.28
            + osc("sine", flat(s, f * 2.76)) * env(s, a, d * 2.4) * 0.12) * g


def thud(s, f0, f1, k, d, body=1.0, dust=0.6, click=0.25, dust_cut=1600):
    t1 = osc("sine", sweep(s, f0, f1, k)) * env(s, 0.0008, d) * body
    t2 = filt(noise(s), "lowpass", dust_cut) * env(s, 0.0008, d * 1.4) * dust
    t3 = filt(noise(s), "highpass", 3200) * env(s, 0.0004, 90) * click
    return mix(t1, t2, t3)


N = {"C5": 523.25, "D5": 587.33, "E5": 659.25, "G5": 783.99, "A5": 880.0, "C6": 1046.5, "D6": 1174.7, "E6": 1318.5, "G6": 1568.0,
     "C4": 261.63, "E4": 329.63, "G4": 392.0, "A4": 440.0, "F4": 349.23, "B4": 493.88}


# ---- 소리들: 작은 행성 위의 발걸음, 중력 비행, 유리·바람·별 ----
def step():  # 작은 행성 위 부드러운 발걸음 (자주, 빠르게)
    s = 0.09
    pad = osc("sine", sweep(s, 210, 120, 45)) * env(s, 0.0015, 55) * 0.8
    grit = filt(noise(s), "bandpass", [900, 3800]) * env(s, 0.001, 70) * 0.55
    soft = filt(noise(s), "lowpass", 600) * env(s, 0.002, 60) * 0.5
    return np.tanh(mix(pad, grit, soft) * 1.3)


def liftoff():  # 발이 땅을 떠남: 짧게 위로 휙
    s = 0.36
    push = osc("sine", sweep(s, 150, 70, 30)) * env(s, 0.001, 30) * 0.7
    cut = glide(s, 700, 3800, 1.3)
    air = np.zeros(int(s * RATE))
    raw = noise(s)
    # 움직이는 대역: 구간별 필터를 이어 붙여 위로 올라가는 바람
    seg = 8
    L = len(raw) // seg
    for i in range(seg):
        lo = cut[i * L]
        air[i * L:(i + 1) * L] = filt(raw, "bandpass", [lo, lo * 2.4])[i * L:(i + 1) * L]
    air *= swell(s, 1.6) * 0.9
    lift = osc("sine", glide(s, 520, 880, 1.0)) * swell(s, 2) * 0.08
    return mix(push, air, lift)


def _rising_air(s, f0, f1, seg=16, width=2.2):
    raw = noise(s)
    out = np.zeros(len(raw))
    L = len(raw) // seg
    cut = glide(s, f0, f1, 1.4)
    for i in range(seg):
        lo = cut[min(i * L, len(cut) - 1)]
        part = filt(raw, "bandpass", [lo, min(lo * width, 11000)])
        out[i * L:(i + 1) * L] = part[i * L:(i + 1) * L]
    return filt(out, "lowpass", 9000)


def escape():  # 탈출선을 넘는 큰 도약: 크게 솟구치는 바람 + 밝은 상승음
    s = 1.3
    t = T(s)
    kick = osc("sine", sweep(s, 120, 42, 12)) * env(s, 0.001, 8) * 1.0
    shape = np.minimum(t / 0.75, 1) ** 1.5 * np.exp(-np.maximum(t - 0.75, 0) * 6)
    air = _rising_air(s, 300, 6000) * shape * 1.1
    tone = (osc("tri", glide(s, 260, 1046, 1.3)) * 0.35 + osc("sine", glide(s, 392, 1568, 1.3)) * 0.25) * shape * 0.35
    sparkle = filt(noise(s), "highpass", 7000) * shape ** 2 * 0.15
    return space(room(np.tanh(mix(kick, air, tone, sparkle) * 1.4), 0.3), 0.35, 0.12, 3)


def atmo():  # 다른 행성 대기권 진입: 낮고 공기 섞인 쉬익
    s = 1.0
    t = T(s)
    shape = np.minimum(t / 0.25, 1) * np.exp(-t * 2.8)
    hiss = filt(noise(s), "bandpass", [350, 1600]) * shape
    hi = filt(noise(s), "bandpass", [2500, 6000]) * shape * 0.25
    hum = osc("sine", glide(s, 90, 70)) * shape * 0.35
    flutter = 0.8 + 0.2 * np.sin(t * 2 * np.pi * 11)
    return room(mix(hiss * flutter, hi, hum), 0.3, 1.3)


def slingshot():  # 새총 성공: 밝은 퉁 + 차임
    s = 0.7
    t = T(s)
    f = sweep(s, 330, 220, 30) * (1 + 0.012 * np.sin(t * 2 * np.pi * 14) * np.exp(-t * 6))
    twang = filt(osc("saw", f), "lowpass", 2600) * env(s, 0.001, 9) * 0.55
    snap = filt(noise(s), "bandpass", [1500, 5000]) * env(s, 0.0004, 80) * 0.5
    chime = mix(bell(s, N["E6"], 6, 0.35), delay(bell(s - 0.07, N["G6"], 6, 0.3), 0.07))
    return space(room(mix(np.tanh(twang * 1.6), snap, chime), 0.3), 0.3, 0.11, 3)


def land():  # 부드러운 착지
    s = 0.32
    return room(np.tanh(thud(s, 140, 60, 26, 18, 1.0, 0.55, 0.15, 1200) * 1.5), 0.15, 0.5)


def land_hard():  # 세게 착지: 묵직한 쿵 + 흙먼지
    s = 0.7
    boom = thud(s, 120, 34, 13, 7.5, 1.4, 0.9, 0.5, 1900)
    crunch = filt(noise(s), "bandpass", [400, 1800]) * env(s, 0.001, 16) * 0.5
    return room(np.tanh(mix(boom, crunch) * 1.9), 0.3)


def sail():  # 돛 방향 바꿈: 천이 탁 펴짐
    s = 0.28
    t = T(s)
    flap1 = filt(noise(s), "bandpass", [600, 3200]) * env(s, 0.0005, 45)
    flap2 = delay(filt(noise(0.15), "bandpass", [900, 4200]) * env(0.15, 0.0005, 55) * 0.7, 0.045)
    body = osc("sine", sweep(s, 180, 110, 30)) * env(s, 0.001, 30) * 0.35
    rustle = filt(noise(s), "highpass", 2500) * swell(s, 2) * 0.12 * (0.5 + 0.5 * np.sin(t * 2 * np.pi * 40))
    return np.tanh(mix(flap1, flap2, body, rustle) * 1.5)


def drift_warn():  # 허공으로 떠내려감: 부드럽게 두 번 울리는 경고
    s = 0.6
    one = osc("sine", sweep(0.25, 520, 440, 8)) * env(0.25, 0.02, 11) + osc("tri", flat(0.25, 220)) * env(0.25, 0.02, 12) * 0.25
    one = filt(one, "lowpass", 2400)
    return room(mix(one, delay(one * 0.75, 0.24)), 0.25, 0.8)


def die():  # 부드럽게 떨어져 퐁 하고 사라짐
    s = 1.0
    t = T(s)
    fallw = osc("sine", glide(s * 0.7, 700, 180, 0.8)) * swell(s * 0.7, 0.6) * 0.3
    air = filt(noise(s * 0.7), "bandpass", [400, 1600]) * swell(s * 0.7, 1.2) * 0.5
    poof_s = 0.5
    poof = delay(filt(noise(poof_s), "lowpass", 1400) * env(poof_s, 0.004, 10) * 0.9
                 + osc("sine", sweep(poof_s, 220, 90, 14)) * env(poof_s, 0.003, 10) * 0.6, 0.55)
    sparkle = delay(mix(bell(0.5, N["C6"], 9, 0.12), delay(bell(0.4, N["G5"], 9, 0.1), 0.08)), 0.6)
    return room(mix(fallw, air, poof, sparkle), 0.35, 1.2)


def meteor_warn():  # 다가오는 운석 휘파람
    s = 1.1
    t = T(s)
    whistle = osc("sine", glide(s, 1900, 700, 1.4)) * np.minimum(t / 0.6, 1) ** 2 * np.exp(-np.maximum(t - 0.9, 0) * 20) * 0.45
    whistle2 = osc("sine", glide(s, 1900 * 1.5, 700 * 1.5, 1.4)) * np.minimum(t / 0.6, 1) ** 2 * np.exp(-np.maximum(t - 0.9, 0) * 20) * 0.1
    roar = filt(noise(s), "bandpass", [500, 2500]) * np.minimum(t / 0.9, 1) ** 2 * np.exp(-np.maximum(t - 0.9, 0) * 20) * 0.6
    return mix(whistle, whistle2, roar)


def meteor_hit():  # 운석 충돌: 바위 부서짐
    s = 1.0
    boom = thud(s, 130, 30, 11, 5.5, 1.3, 1.0, 0.8, 2200)
    crunch = filt(noise(s), "bandpass", [300, 2200]) * env(s, 0.001, 9) * (0.7 + 0.3 * np.sin(T(s) * 2 * np.pi * 23))
    debris = mix(*[delay(filt(noise(0.07), "bandpass", [800, 3500]) * env(0.07, 0.0005, 60) * 0.35, dt) for dt in (0.1, 0.17, 0.26, 0.38)])
    return room(np.tanh(mix(boom, crunch, debris) * 1.9), 0.4, 1.3)


def pickup():  # 물건 집기: 톡 + 위로 작은 반짝
    s = 0.3
    tap = osc("sine", sweep(s, 300, 180, 40)) * env(s, 0.001, 40) * 0.6
    grab = filt(noise(s), "bandpass", [1200, 4000]) * env(s, 0.0005, 70) * 0.4
    up = mix(bell(s, N["G5"], 18, 0.22), delay(bell(s - 0.05, N["C6"], 16, 0.2), 0.05))
    return room(mix(np.tanh(tap * 1.4), grab, up), 0.2, 0.6)


def drop():  # 물건 놓기: 아래로 톡
    s = 0.3
    tap = osc("sine", sweep(s, 240, 110, 30)) * env(s, 0.001, 30) * 0.7
    soft = filt(noise(s), "lowpass", 1500) * env(s, 0.001, 40) * 0.4
    down = mix(bell(s, N["E5"], 20, 0.15), delay(bell(s - 0.05, N["C5"], 18, 0.13), 0.05))
    return room(mix(np.tanh(tap * 1.4), soft, down), 0.15, 0.6)


def deliver():  # 일 해결: 따뜻한 세 음 차임 (C-E-G 위로, 부드러운 종)
    s = 1.3
    notes = [(0.0, N["C5"]), (0.11, N["E5"]), (0.22, N["G5"])]
    chimes = mix(*[delay(bell(s - dt, f, 4.0, 0.5, 0.004) + osc("tri", flat(s - dt, f / 2)) * env(s - dt, 0.006, 5) * 0.1, dt) for dt, f in notes])
    glow = osc("sine", flat(s, N["C6"])) * np.minimum(T(s) / 0.3, 1) * np.exp(-T(s) * 3) * 0.06
    return space(room(mix(chimes, glow), 0.35, 1.0), 0.25, 0.15, 3)


def crack():  # 유리 금 감
    s = 0.35
    tick = filt(noise(s), "highpass", 3500) * env(s, 0.0002, 110)
    tick2 = delay(filt(noise(0.1), "highpass", 4500) * env(0.1, 0.0002, 140) * 0.6, 0.035)
    ping = osc("sine", flat(s, 3150)) * env(s, 0.0005, 30) * 0.25 + osc("sine", flat(s, 4720)) * env(s, 0.0005, 40) * 0.12
    creak = filt(osc("saw", sweep(s, 900, 600, 20)), "bandpass", [1500, 4000]) * env(s, 0.001, 45) * 0.15
    return room(mix(tick, tick2, ping, creak), 0.2, 0.5)


def shatter():  # 유리 깨짐
    s = 1.0
    burst = filt(noise(s), "highpass", 2800) * env(s, 0.0003, 14) * 0.9
    body = filt(noise(s), "bandpass", [1000, 3500]) * env(s, 0.0005, 22) * 0.5
    ring = sum(osc("sine", flat(s, f)) * env(s, 0.0005, d) * g for f, d, g in [(2240, 7, 0.32), (3310, 9, 0.24), (4680, 12, 0.18), (6200, 15, 0.12)])
    tinkles = mix(*[delay(osc("sine", flat(0.25, f)) * env(0.25, 0.0005, 25) * 0.16 + filt(noise(0.25), "highpass", 5000) * env(0.25, 0.0003, 70) * 0.2, dt)
                    for dt, f in [(0.12, 3900), (0.2, 5100), (0.29, 4400), (0.41, 5800), (0.55, 4900)]])
    return room(mix(burst, body, ring, tinkles), 0.35)


def wind():  # 풍차 바람 한 줄기 (~1.5s, 반복 가능: 양 끝이 조용하고 모양이 같다)
    s = 1.5
    t = T(s)
    shape = np.sin(np.pi * t / s) ** 2  # 시작·끝 0 -> 이어 붙여도 매끈
    gust = 0.75 + 0.25 * np.sin(2 * np.pi * t / s * 3)  # 정수 주기라 이어짐
    low = filt(noise(s), "bandpass", [250, 1000]) * shape * gust
    high = filt(noise(s), "bandpass", [1500, 4200]) * shape ** 1.5 * gust * 0.3
    whistle = osc("sine", 640 + 60 * np.sin(2 * np.pi * t / s * 2)) * shape ** 2 * 0.05
    return mix(low, high, whistle)


def windmill_wake():  # 풍차가 깨어남: 나무 삐걱 + 밝은 차임
    s = 1.5
    t = T(s)
    cs = 0.55
    tc = T(cs)
    f = 120 + 50 * np.sin(tc * 2 * np.pi * 2.2)
    rasp = filt(np.tanh(osc("saw", f) * 2.2), "bandpass", [400, 1700]) * (0.45 + 0.55 * (np.sin(tc * 2 * np.pi * 26) > 0)) * env(cs, 0.03, 4.5) * 0.7
    knock = osc("sine", sweep(0.2, 200, 100, 30)) * env(0.2, 0.001, 30) * 0.5
    turn = filt(noise(s), "bandpass", [400, 1500]) * np.minimum(t / 0.6, 1) * np.exp(-t * 1.5) * 0.25 * (0.6 + 0.4 * np.sin(t * 2 * np.pi * 5))
    chimes = mix(*[delay(bell(0.9, f, 5, 0.3), dt) for dt, f in [(0.45, N["G5"]), (0.58, N["D6"]), (0.71, N["G6"])]])
    return room(mix(rasp, delay(knock, 0.4), turn, chimes), 0.35, 1.1)


def talk():  # NPC 말 소리: 부드러운 '뽀' (pitch_scale 로 높낮이)
    s = 0.12
    t = T(s)
    f = 330 * (1 + 0.12 * np.exp(-t * 40))
    v = osc("tri", f) * 0.6 + osc("sine", f * 2) * 0.25
    vowel = filt(v, "bandpass", [500, 1800]) * 1.4 + osc("sine", f) * 0.4
    breath = filt(noise(s), "bandpass", [1200, 3500]) * env(s, 0.001, 60) * 0.12
    return mix(vowel * env(s, 0.006, 26), breath)


def ui_tap():  # 버튼 톡
    s = 0.08
    knock = osc("sine", sweep(s, 1100, 700, 60)) * env(s, 0.0008, 70) * 0.5
    click = filt(noise(s), "bandpass", [2000, 6000]) * env(s, 0.0004, 120) * 0.5
    body = osc("sine", flat(s, 350)) * env(s, 0.001, 60) * 0.3
    return mix(knock, click, body)


def win():  # 엔딩: 따뜻한 화음 (C 장조 9, 펼쳐 울림)
    s = 3.2
    t = T(s)
    pad_env = np.minimum(t / 0.35, 1) * np.exp(-t * 0.9)
    pad = sum(filt(osc("saw", flat(s, f)) + osc("saw", flat(s, f * 1.004)), "lowpass", 1400) * g for f, g in
              [(N["C4"], 0.22), (N["E4"], 0.18), (N["G4"], 0.18), (N["D5"], 0.1)]) * pad_env * 0.6
    bass = osc("sine", flat(s, 130.81)) * pad_env * 0.5
    arp = mix(*[delay(bell(s - dt, f, 2.2, 0.32, 0.003), dt) for dt, f in
                [(0.0, N["C5"]), (0.12, N["E5"]), (0.24, N["G5"]), (0.36, N["C6"]), (0.55, N["E6"]), (0.75, N["G6"])]])
    air = filt(noise(s), "bandpass", [4000, 9000]) * np.minimum(t / 1.0, 1) * np.exp(-t * 1.2) * 0.05
    return space(room(mix(pad, bass, arp, air), 0.45, 1.5), 0.25, 0.18, 3)


SOUNDS = [step, liftoff, escape, atmo, slingshot, land, land_hard, sail, drift_warn, die, meteor_warn, meteor_hit,
          pickup, drop, deliver, crack, shatter, wind, windmill_wake, talk, ui_tap, win]
NOTE = {
    "step": "작은 행성 위 부드러운 발걸음(짧은 저음 톡 + 자갈 사각), 빠르게 연타용",
    "liftoff": "발이 땅을 떠남: 짧은 밀기 + 위로 올라가는 바람",
    "escape": "탈출선 넘는 도약: 큰 북 + 크게 솟구치는 바람 + 밝은 상승음 + 우주 메아리",
    "atmo": "다른 행성 대기권 진입: 낮고 펄럭이는 공기 쉬익",
    "slingshot": "새총 성공: 줄 퉁 + 밝은 두 음 차임",
    "land": "부드러운 착지 쿵",
    "land_hard": "세게 착지: 묵직한 쿵 + 흙먼지",
    "sail": "돛 방향 바꿈: 천이 두 번 탁 펴짐",
    "drift_warn": "허공 표류 경고: 부드러운 두 번 울림(반복 재생용)",
    "die": "떨어지는 바람 + 퐁 사라짐 + 작은 반짝",
    "meteor_warn": "다가오는 운석 휘파람(내려가는 음 + 커지는 굉음)",
    "meteor_hit": "운석 충돌: 깊은 쿵 + 바위 부서짐 + 파편",
    "pickup": "물건 집기: 톡 + 위로 두 음 반짝",
    "drop": "물건 놓기: 톡 + 아래로 두 음",
    "deliver": "일 해결: 따뜻한 도-미-솔 종 차임 + 메아리",
    "crack": "유리 금 감: 날카로운 틱 두 번 + 가는 울림",
    "shatter": "유리 깨짐: 파삭 + 유리 울림 + 조각 짤랑",
    "wind": "풍차 바람 한 줄기, 양끝 0이라 이어 붙여 반복 가능",
    "windmill_wake": "풍차 깨어남: 나무 삐걱 + 돌아가는 바람 + 솔-레-솔 차임",
    "talk": "NPC 말 소리: 짧고 부드러운 모음 '뽀'(pitch_scale로 높낮이)",
    "ui_tap": "버튼 톡",
    "win": "엔딩: 따뜻한 C장조 화음 패드 + 올라가는 종 아르페지오",
}


def save(name, x, loop=False):
    x = x - x.mean()
    x = x / max(np.abs(x).max(), 1e-9) * 0.89
    if not loop:
        fade = min(int(0.012 * RATE), len(x) // 3)
        x[-fade:] *= np.linspace(1, 0, fade)
    x = filt(x, "lowpass", 11000)[::2]  # 24 kHz
    peak, rms = np.abs(x).max(), np.sqrt(np.mean(x ** 2))
    assert peak < 0.99 and rms > 0.01, (name, peak, rms)
    pcm = (x * 32767).astype("<i2")
    with wave.open(str(OUT / f"{name}.wav"), "wb") as h:
        h.setnchannels(1)
        h.setsampwidth(2)
        h.setframerate(24000)
        h.writeframes(pcm.tobytes())
    return {"file": f"{name}.wav", "seconds": round(len(x) / 24000, 3), "peak": round(float(peak), 3), "rms": round(float(rms), 3), "note": NOTE[name]}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    WORK.mkdir(parents=True, exist_ok=True)
    period = int(RATE / BASE_HZ)
    for kind in ("sine", "tri", "saw"):
        SRC[kind] = render(kind, f"{kind}({BASE_HZ:g})", 2)[RATE // 2: RATE // 2 + period]
    SRC["noise"] = render("noise", "noise(0, 0, 211)", 6)
    recs = [save(f.__name__, f(), loop=(f is wind)) for f in SOUNDS]
    (HERE / "SFX_MANIFEST.json").write_text(json.dumps({"tool": "nkido (MIT) 원재료 + numpy/scipy 다듬기, --no-default-bank", "samples": "none", "rate": 24000,
                                                        "dir": "art/tinyplanet_sfx", "sounds": recs}, ensure_ascii=False, indent=1), encoding="utf-8")
    for r in recs:
        print(r["file"], r["seconds"], r["peak"], r["rms"])
    print("ok", len(recs))


if __name__ == "__main__":
    main()
