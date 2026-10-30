"""UI 돌판 재질: 신전 3D 모델 그림(art/boulder/temple.png)의 크림색 돌 면을 잘라 9-patch 판을 굽는다.
python build_ui_tex.py -> games/speed_tofu/art/boulder/ui/{slab,card,btn,btn_dn}.png
판은 색이 빠진 밝은 돌결이고, 게임에서 modulate 로 색(STONE·금·빨강)을 입힌다. 테두리와 아래 두께는 그림에 구워 둔다.
"""
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

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
    # 결을 조금 누그러뜨린다: 글자가 잘 보이게
    g = 1.0 + (g - 1.0) * 0.85
    return np.clip(g * 0.86, 0, 1)


def rounded(size, r, inset=0):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).rounded_rectangle((inset, inset, size[0] - 1 - inset, size[1] - 1 - inset), r, fill=255)
    return m


def make(name, r, bw, depth, frame, W=W, H=H):
    g = grain(W, H)
    rgb = (g * 255).astype(np.uint8)
    img = Image.fromarray(rgb, "RGB").convert("RGBA")
    ink = (70, 52, 34, 255)  # 진한 갈색 테 (modulate 를 받아도 어두운 테로 남는다)
    outer = rounded((W, H), r)
    body = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    # 테: 바깥 둥근 판 전체를 잉크로, 그 안쪽(위·옆 bw, 아래 depth)을 돌결로
    border = Image.new("RGBA", (W, H), ink)
    body.paste(border, (0, 0), outer)
    inner = Image.new("L", (W, H), 0)
    ImageDraw.Draw(inner).rounded_rectangle((bw, bw, W - 1 - bw, H - 1 - depth), max(2, r - bw), fill=255)
    body.paste(img, (0, 0), inner)
    d = ImageDraw.Draw(body)
    # 아래 두께: 테 바로 위에 살짝 어두운 띠 (돌판 옆면)
    d.rounded_rectangle((bw, H - depth - 6, W - 1 - bw, H - 1 - depth), 4, fill=None)
    if frame:
        # 안쪽에 파인 테두리
        d.rounded_rectangle((bw + 10, bw + 10, W - 1 - bw - 10, H - 1 - depth - 10), 8, outline=(150, 128, 98, 255), width=3)
    # 윗빛: 위 테 안쪽에 밝은 줄
    d.line((r, bw + 2, W - r, bw + 2), fill=(255, 255, 255, 120), width=2)
    OUT.mkdir(parents=True, exist_ok=True)
    body.save(OUT / f"{name}.png")


make("slab", 22, 5, 14, True)
make("card", 26, 6, 14, False)
# 버튼은 작게 구워 여백(모서리)이 작다: 70px 짜리 작은 버튼에도 들어간다
make("btn", 16, 4, 8, False, 256, 160)
make("btn_dn", 16, 4, 4, False, 256, 160)
print("ok", sorted(p.name for p in OUT.glob("*.png")))
