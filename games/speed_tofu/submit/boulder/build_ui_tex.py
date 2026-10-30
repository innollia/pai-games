"""UI 돌판 재질: 신전 3D 모델 그림(art/boulder/temple.png)의 크림색 돌 면을 잘라 9-patch 판을 굽는다.
python build_ui_tex.py -> games/speed_tofu/art/boulder/ui/{slab,card,btn,btn_dn}.png
판은 색이 빠진 밝은 돌결이고, 게임에서 modulate 로 색(STONE·금·빨강)을 입힌다. 테두리와 아래 두께는 그림에 구워 둔다.
모서리는 둥글지 않고 깎은 돌처럼 비스듬히 자른다.
"""
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
ART = HERE.parent.parent / "art/boulder"
OUT = ART / "ui"
W, H = 384, 288


def grain(W=W, H=H) -> np.ndarray:
    # 신전 벽 크림 돌 면(파란 띠 아래 깨끗한 곳)
    src = Image.open(ART / "temple.png").convert("RGB").crop((214, 240, 316, 296))
    a = np.asarray(src).astype(float) / 255.0
    a = a / a.reshape(-1, 3).mean(axis=0)  # 색을 빼고 밝기 결만 (평균 1)
    img = Image.fromarray((np.clip(a * 0.5, 0, 1) * 255).astype(np.uint8)).resize((W, H), Image.BICUBIC)
    g = np.asarray(img).astype(float) / 255.0 * 2.0
    g = 1.0 + (g - 1.0) * 0.85
    return np.clip(g * 0.86, 0, 1)


def cut(x0, y0, x1, y1, c):
    """모서리를 c 만큼 비스듬히 깎은 팔각 판"""
    return [(x0 + c, y0), (x1 - c, y0), (x1, y0 + c), (x1, y1 - c), (x1 - c, y1), (x0 + c, y1), (x0, y1 - c), (x0, y0 + c)]


def make(name, c, bw, depth, frame, W=W, H=H):
    g = grain(W, H)
    img = Image.fromarray((g * 255).astype(np.uint8), "RGB").convert("RGBA")
    ink = (70, 52, 34, 255)  # 진한 갈색 테 (modulate 를 받아도 어두운 테로 남는다)
    outer = Image.new("L", (W, H), 0)
    ImageDraw.Draw(outer).polygon(cut(0, 0, W - 1, H - 1, c), fill=255)
    body = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    body.paste(Image.new("RGBA", (W, H), ink), (0, 0), outer)
    inner = Image.new("L", (W, H), 0)
    ImageDraw.Draw(inner).polygon(cut(bw, bw, W - 1 - bw, H - 1 - depth, max(2, c - bw // 2)), fill=255)
    body.paste(img, (0, 0), inner)
    d = ImageDraw.Draw(body)
    if frame:
        # 안쪽에 파인 테두리 (모서리도 깎음)
        f = bw + 10
        d.polygon(cut(f, f, W - 1 - f, H - 1 - depth - 10, 5), outline=(150, 128, 98, 255), width=3)
    # 윗빛: 위 테 안쪽에 밝은 줄
    d.line((c + 2, bw + 2, W - c - 2, bw + 2), fill=(255, 255, 255, 120), width=2)
    OUT.mkdir(parents=True, exist_ok=True)
    body.save(OUT / f"{name}.png")


make("slab", 14, 5, 14, True)
make("card", 16, 6, 14, False)
# 버튼은 작게 구워 여백(모서리)이 작다: 70px 짜리 작은 버튼에도 들어간다
make("btn", 9, 4, 8, False, 256, 160)
make("btn_dn", 9, 4, 4, False, 256, 160)
print("ok", sorted(p.name for p in OUT.glob("*.png")))
