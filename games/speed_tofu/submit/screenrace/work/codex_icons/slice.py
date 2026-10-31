# Codex 4x4 아이콘 판(sheet.png)을 잘라 ui/cx_*.png (160x160, 둘레 크림 바탕은 투명)로
import sys
from PIL import Image, ImageDraw
NAMES = ["mailbox", "gold", "wall", "gap", "crate", "river", "train", "bridge",
         "scale", "shutter", "trapdoor", "roof", "longgap", "edge", "parcel", "book"]
im = Image.open("sheet.png").convert("RGB")
W = im.width // 4
out = sys.argv[1]
for i, n in enumerate(NAMES):
    c = im.crop(((i % 4) * W, (i // 4) * W, (i % 4 + 1) * W, (i // 4 + 1) * W))
    # 둘레에서 이어진 밝은 바탕만 지운다 (안쪽 크림 종이는 남게)
    m = c.copy()
    for p in [(0, 0), (W - 1, 0), (0, W - 1), (W - 1, W - 1), (W // 2, 0), (W // 2, W - 1), (0, W // 2), (W - 1, W // 2)]:
        ImageDraw.floodfill(m, p, (255, 0, 255), thresh=28)
    a = Image.new("L", c.size, 255)
    pm, pa = m.load(), a.load()
    for y in range(W):
        for x in range(W):
            if pm[x, y] == (255, 0, 255):
                pa[x, y] = 0
    rgba = c.convert("RGBA")
    rgba.putalpha(a)
    bb = a.getbbox()
    rgba = rgba.crop(bb)
    s = max(rgba.size)
    sq = Image.new("RGBA", (int(s * 1.12), int(s * 1.12)), (0, 0, 0, 0))
    sq.paste(rgba, ((sq.width - rgba.width) // 2, (sq.height - rgba.height) // 2))
    sq.resize((160, 160), Image.LANCZOS).save(f"{out}/cx_{n}.png", optimize=True)
print("ok")
