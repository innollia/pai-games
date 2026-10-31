# 16:9 표지 1920x1080: cover_shots.gd 로 찍은 제목 뒤 경주 장면 + 게임 속 제목 그림(ui/logo.png) 그대로
# python work/make_cover16.py <bg16_n.png>
import sys
from PIL import Image
bg = Image.open(sys.argv[1]).convert("RGBA").resize((1920, 1080))
logo = Image.open("../../art/screenrace/ui/logo.png").convert("RGBA")
w = 820
logo = logo.resize((w, int(logo.height * w / logo.width)), Image.LANCZOS)
bg.alpha_composite(logo, (1920 - w - 60, 50))
bg.convert("RGB").save("cover_16x9.png")
