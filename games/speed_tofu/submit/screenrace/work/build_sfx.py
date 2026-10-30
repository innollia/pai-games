"""화면 밖 경주 효과음: nkido(MIT)로 원재료(사인·삼각·톱니 한 주기, 노이즈)만 렌더하고
numpy/scipy로 음높이 스윕·필터·감쇠를 쌓는다. 외부 샘플 없음. (TINProject pixel_arena build_sfx.py 방식)

    python submit/screenrace/work/build_sfx.py      (games/speed_tofu 에서)

결과: art/screenrace/sfx/<이름>.wav (모노 22050Hz 16bit) + art/screenrace/sfx/manifest.json
종이 공작 배달 세계라서 골판지·종이·나무·고무도장 질감으로 만든다.
"""
import hashlib
import json
import os
import subprocess
import wave
from pathlib import Path

import numpy as np
from scipy.signal import butter, lfilter

HERE = Path(__file__).resolve().parent
KIT = HERE.parents[2]  # games/speed_tofu
OUT = KIT / "art/screenrace/sfx"
BUILD = HERE / "sfx_build"  # nkido 패치·원재료 (커밋 안 함)
NKIDO = Path(os.environ.get("NKIDO", r"C:\projects\_tools\nkido\build-clang\bin\nkido.exe"))
SRC_RATE = 48000
RATE = 22050
BASE_HZ = 100.0
rng = np.random.default_rng(31)
SOURCES: dict = {}


def render(name: str, expression: str, seconds: int = 2) -> np.ndarray:
    patch = BUILD / f"{name}.akkado"
    patch.write_text(f"// Off the Screen! sfx source, nkido MIT; no samples.\n{expression} |> out(%)\n", encoding="utf-8")
    target = BUILD / f"{name}.wav"
    subprocess.run([str(NKIDO), "render", str(patch), "-o", str(target), "--seconds", str(seconds), "--rate", str(SRC_RATE), "--no-default-bank"], check=True, capture_output=True, timeout=60)
    with wave.open(str(target), "rb") as h:
        pcm = np.frombuffer(h.readframes(h.getnframes()), "<i2").astype(float)
        pcm = pcm.reshape(-1, h.getnchannels()).mean(axis=1) / 32768.0
    pcm -= pcm.mean()
    return pcm / max(np.abs(pcm).max(), 1e-9)


def cycle(src: np.ndarray) -> np.ndarray:
    period = int(SRC_RATE / BASE_HZ)
    return src[SRC_RATE // 2: SRC_RATE // 2 + period]


def osc(kind: str, freq) -> np.ndarray:
    table = SOURCES[kind]
    phase = np.cumsum(np.asarray(freq, float) / RATE) * len(table)
    return np.interp(phase % len(table), np.arange(len(table)), table)


def noise(s: float) -> np.ndarray:
    bed = SOURCES["noise"]
    n = int(s * RATE)
    start = int(rng.integers(0, len(bed) - n - 1))
    return bed[start:start + n].copy()


def t_axis(s: float) -> np.ndarray:
    return np.arange(int(s * RATE)) / RATE


def env(s: float, attack: float, decay: float) -> np.ndarray:
    t = t_axis(s)
    return np.minimum(t / max(attack, 1e-4), 1.0) * np.exp(-t * decay)


def sweep(s: float, a: float, b: float, speed: float) -> np.ndarray:
    t = t_axis(s)
    return b + (a - b) * np.exp(-t * speed)


def filt(x: np.ndarray, kind: str, cutoff, order: int = 2) -> np.ndarray:
    b, a = butter(order, np.asarray(cutoff) / (RATE / 2), kind)
    return lfilter(b, a, x)


def room(x: np.ndarray, amount: float, size: float = 1.0) -> np.ndarray:
    tail = np.concatenate([x, np.zeros(int(0.3 * size * RATE))])
    wet = np.zeros_like(tail)
    for d, g in [(0.023, 0.5), (0.031, 0.4), (0.047, 0.3), (0.067, 0.2)]:
        k = int(d * size * RATE)
        wet[k:] += tail[:-k] * g
    return tail + filt(wet, "lowpass", 3500) * amount


def mix(*parts: np.ndarray) -> np.ndarray:
    out = np.zeros(max(len(p) for p in parts))
    for p in parts:
        out[:len(p)] += p
    return out


def delay(x: np.ndarray, s: float) -> np.ndarray:
    return np.concatenate([np.zeros(int(s * RATE)), x])


def tone(f: float, s: float, decay: float, kind: str = "sine") -> np.ndarray:
    return osc(kind, np.full(int(s * RATE), f)) * env(s, 0.002, decay)


# ---- 소리들 ----

def jump() -> np.ndarray:  # 골판지 발 구르기 + 가벼운 휙
    s = 0.2
    t = t_axis(s)
    scuff = filt(noise(s), "bandpass", [600, 2400]) * env(s, 0.001, 40)
    air = filt(noise(s), "bandpass", [1500, 5000]) * np.sin(np.clip(t / s, 0, 1) * np.pi) ** 2 * 0.5
    lift = osc("tri", sweep(s, 260, 520, -8).clip(260, 520)) * env(s, 0.005, 18) * 0.35
    return mix(scuff, air, lift)


def land() -> np.ndarray:  # 상자 위에 털썩
    s = 0.18
    thud = osc("sine", sweep(s, 150, 60, 30)) * env(s, 0.001, 30)
    box = filt(noise(s), "bandpass", [200, 1100]) * env(s, 0.001, 35) * 0.8
    return np.tanh(mix(thud, box) * 1.4)


def express() -> np.ndarray:  # 짐을 던지고 튀어나감: 종이 찢김 + 앞으로 휙
    s = 0.32
    t = t_axis(s)
    rip = filt(noise(s), "bandpass", [2500, 7000]) * (np.sin(t * 2 * np.pi * 70) > 0.2) * env(s, 0.002, 18) * 0.7
    whoosh = filt(noise(s), "bandpass", [500, 2500]) * np.sin(np.clip(t / s, 0, 1) * np.pi) ** 1.5
    zip_ = osc("saw", sweep(s, 300, 900, -9).clip(300, 900)) * env(s, 0.01, 10) * 0.12
    return mix(rip, whoosh, filt(zip_, "lowpass", 2500))


def damaged() -> np.ndarray:  # 짐 하나 잃음: 상자 구겨지는 소리
    s = 0.4
    crunch = mix(*[delay(filt(noise(0.08), "bandpass", [300 + 300 * k, 2400]) * env(0.08, 0.0005, 45), 0.04 * k) for k in range(4)])
    thud = osc("sine", sweep(s, 120, 50, 18)) * env(s, 0.001, 14) * 0.8
    return room(np.tanh(mix(crunch, thud) * 1.5), 0.15)


def returned() -> np.ndarray:  # 화면 밖 탈락(반송): 내려가는 삼각파 + 도장
    s = 0.7
    fall = osc("tri", sweep(s, 660, 160, 4)) * env(s, 0.005, 4) * 0.5
    return room(mix(fall, delay(stamp() * 0.9, 0.42)), 0.2)


def stamp() -> np.ndarray:  # 고무도장 쿵: 낮은 쿵 + 짧은 종이 찰싹
    s = 0.22
    thunk = osc("sine", sweep(s, 210, 75, 32)) * env(s, 0.0008, 26)
    slap = filt(noise(s), "bandpass", [900, 3800]) * env(s, 0.0004, 80) * 0.9
    wood = tone(420, s, 40, "tri") * 0.25
    return np.tanh(mix(thunk * 1.2, slap, wood) * 1.6)


def bump() -> np.ndarray:  # 나무 상자에 부딪힘
    s = 0.25
    knock = sum(tone(f, s, d, "sine") * g for f, d, g in [(310, 28, 0.8), (720, 40, 0.4), (1240, 55, 0.2)])
    tap = filt(noise(s), "bandpass", [1200, 4000]) * env(s, 0.0004, 90) * 0.6
    return np.tanh(mix(knock, tap) * 1.5)


def spring() -> np.ndarray:  # 점프대: 용수철 보잉
    s = 0.45
    t = t_axis(s)
    f = sweep(s, 180, 620, 9) * (1 + 0.06 * np.sin(t * 2 * np.pi * 22) * np.exp(-t * 4))
    return mix(osc("tri", f) * env(s, 0.002, 6) * 0.7, land() * 0.4)


def bell() -> np.ndarray:  # 건널목 종: 땡 땡
    def ding() -> np.ndarray:
        s = 0.35
        return sum(tone(f, s, d) * g for f, d, g in [(1320, 9, 0.6), (2650, 13, 0.3), (3960, 18, 0.15)])
    return room(mix(ding(), delay(ding() * 0.85, 0.22)), 0.3)


def crack() -> np.ndarray:  # 다리 판이 부러짐
    s = 0.45
    snap = filt(noise(s), "highpass", 2200) * env(s, 0.0003, 60)
    split = mix(*[delay(filt(noise(0.06), "bandpass", [700, 3000]) * env(0.06, 0.0005, 60) * (0.8 - 0.15 * k), 0.03 + 0.05 * k) for k in range(4)])
    groan = filt(osc("saw", sweep(s, 140, 70, 5)), "lowpass", 700) * env(s, 0.01, 6) * 0.35
    return room(np.tanh(mix(snap, split, groan) * 1.5), 0.2)


def pickup() -> np.ndarray:  # 짐 줍기: 종이 바스락 + 맑은 두 음
    s = 0.3
    rustle = filt(noise(0.12), "bandpass", [2000, 6500]) * env(0.12, 0.002, 30) * 0.6
    a = tone(988, s, 18)
    b = delay(tone(1480, s - 0.06, 20), 0.06) * 0.8
    return room(mix(rustle, a * 0.6, b * 0.6), 0.2, 0.6)


def gate() -> np.ndarray:  # 짐 개수 문에 막힘: 둔한 나무 두 번
    s = 0.3
    k = tone(170, 0.15, 30, "tri") + filt(noise(0.15), "bandpass", [200, 900]) * env(0.15, 0.001, 40) * 0.6
    return np.tanh(mix(k, delay(k * 0.8, 0.12)) * 1.3)


def go() -> np.ndarray:  # 출발 호루라기
    s = 0.5
    t = t_axis(s)
    f = 2100 + 160 * np.sin(t * 2 * np.pi * 28)
    body = osc("sine", f) * np.minimum(t / 0.02, 1) * np.minimum((s - t) / 0.06, 1) * 0.6
    breath = filt(noise(s), "bandpass", [1800, 3500]) * np.minimum(t / 0.02, 1) * np.minimum((s - t) / 0.06, 1) * 0.25
    return mix(body, breath)


def chord(notes, s: float, step: float, decay: float) -> np.ndarray:
    parts = []
    for i, m in enumerate(notes):
        f = 440 * 2 ** ((m - 69) / 12)
        parts.append(delay(tone(f, s, decay, "tri") + tone(f * 2, s, decay * 1.5) * 0.3, i * step))
    return room(mix(*parts) * 0.6, 0.3)


def train() -> np.ndarray:  # 기차가 지나감: 낮은 덜컹 + 경적 두 음
    s = 0.9
    t = t_axis(s)
    rumble = filt(noise(s), "lowpass", 400) * (0.6 + 0.4 * (np.sin(t * 2 * np.pi * 7) > 0)) * env(s, 0.05, 2)
    horn = (osc("saw", np.full(len(t), 311.0)) + osc("saw", np.full(len(t), 392.0))) * np.minimum(t / 0.03, 1) * np.exp(-t * 2.5) * 0.25
    return mix(rumble, filt(horn, "lowpass", 1600))


SFX = {
    "jump": jump, "land": land, "express": express, "damaged": damaged, "returned": returned,
    "stamp": stamp, "bump": bump, "spring": spring, "bell": bell, "crack": crack,
    "pickup": pickup, "gate": gate, "go": go, "train": train,
    "delivered": lambda: chord([72, 76, 79, 84], 0.8, 0.07, 4.0),
    "lost": lambda: chord([67, 63, 60, 55], 0.9, 0.12, 3.0),
    "champion": lambda: chord([60, 64, 67, 72, 76, 79, 84], 1.5, 0.09, 2.0),
}


def write(name: str, mono: np.ndarray) -> dict:
    mono = mono - mono.mean()
    mono = mono * (0.84 / max(np.abs(mono).max(), 1e-9))
    fade = min(int(0.01 * RATE), len(mono) // 4)
    mono[-fade:] *= np.linspace(1, 0, fade)
    pcm = np.round(mono * 32767).astype("<i2")
    target = OUT / f"{name}.wav"
    with wave.open(str(target), "wb") as h:
        h.setnchannels(1)
        h.setsampwidth(2)
        h.setframerate(RATE)
        h.writeframes(pcm.tobytes())
    assert np.isfinite(mono).all(), name
    return {"file": target.name, "seconds": round(len(mono) / RATE, 3), "sha256": hashlib.sha256(target.read_bytes()).hexdigest()}


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    BUILD.mkdir(parents=True, exist_ok=True)
    for kind in ("sine", "tri", "saw"):
        src = cycle(render(kind, f"{kind}(100)"))
        SOURCES[kind] = src
    SOURCES["noise"] = render("noise", "noise(0, 0, 211)", 6)[::2]  # 48k -> 22.05k 근사 (노이즈라 상관없음)
    records = [write(n, f()) for n, f in SFX.items()]
    (OUT / "manifest.json").write_text(json.dumps({"tool": "nkido (MIT) raw sources + numpy/scipy shaping", "samples": "none", "rate": RATE, "tracks": records}, indent=2), encoding="utf-8")
    print(len(records), "sfx ->", OUT)


if __name__ == "__main__":
    main()
