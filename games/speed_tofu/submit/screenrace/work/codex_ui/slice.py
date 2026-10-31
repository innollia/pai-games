# Codex UI 그림 -> art/screenrace/ui/cxui_*.png. kit.png 의 조각은 크림 바탕에서 떨어진 덩어리로 찾아(위->아래, 왼->오른)
# card, banner, tab_on, tab_off, close, frame 로 저장. 둘레 바탕은 투명. page.png 는 줄여서 그대로.
import sys
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage
out = sys.argv[1]
Image.open("page.png").convert("RGB").resize((720, 1080), Image.LANCZOS).save(f"{out}/cxui_page.png", optimize=True)
im = Image.open("kit.png").convert("RGB")
a = np.asarray(im).astype(int)
bg = np.median(a[:8, :, :].reshape(-1, 3), axis=0)
fg = np.abs(a - bg).sum(axis=2) > 40
fg = ndimage.binary_closing(fg, iterations=6)
lab, n = ndimage.label(fg)
objs = [(s, (lab[s] > 0).sum()) for s in ndimage.find_objects(lab)]
objs = [s for s, area in objs if area > 4000]
rows = sorted(objs, key=lambda s: (s[0].start // 120, s[1].start))
names = ["card", "banner", "tab_on", "tab_off", "close", "frame"]
print(len(rows), [(s[1].start, s[0].start, s[1].stop - s[1].start, s[0].stop - s[0].start) for s in rows])
for name, s in zip(names, rows):
    pad = 6
    box = (max(s[1].start - pad, 0), max(s[0].start - pad, 0), min(s[1].stop + pad, im.width), min(s[0].stop + pad, im.height))
    c = im.crop(box)
    m = c.copy()
    W, H = c.size
    for p in [(0, 0), (W - 1, 0), (0, H - 1), (W - 1, H - 1)]:
        ImageDraw.floodfill(m, p, (255, 0, 255), thresh=30)
    alpha = Image.fromarray(np.where(np.all(np.asarray(m) == [255, 0, 255], axis=2), 0, 255).astype("uint8"))
    rgba = c.convert("RGBA")
    rgba.putalpha(alpha)
    if name in ("card", "banner"):
        rgba = rgba.resize((int(rgba.width * 0.6), int(rgba.height * 0.6)), Image.LANCZOS)  # 화면 크기쯤 (나인 슬라이스 모서리가 너무 크지 않게)
    rgba.save(f"{out}/cxui_{name}.png", optimize=True)
    print(name, rgba.size)
