# 16:9 표지 1920x1080: cover_shots.gd 로 찍은 경주 장면 + 게임 속 제목 그림(ui/logo.png) 그대로
# python work/make_cover16.py <bg16_n.png> [왼쪽 자를 비율]
# 표지용 카메라가 게임 카메라보다 왼쪽을 보면 배경 그림이 왼쪽 끝에서 모자란다: 그만큼 왼쪽(과 같은 비율로 아래)을 잘라 다시 늘린다.
# v43 표지는 bg16_22 (넷이 띄엄띄엄 달리고 가운데 빨간 우체통), 왼쪽 0.11
import sys
from PIL import Image
bg = Image.open(sys.argv[1]).convert("RGBA")
cut = float(sys.argv[2]) if len(sys.argv) > 2 else 0.0
W, H = bg.size
x0 = int(W * cut)
bg = bg.crop((x0, 0, W, int(H * (1.0 - cut)))).resize((1920, 1080), Image.LANCZOS)
logo = Image.open("../../art/screenrace/ui/logo.png").convert("RGBA")
w = 660  # 오른쪽 위 하늘에
logo = logo.resize((w, int(logo.height * w / logo.width)), Image.LANCZOS)
bg.alpha_composite(logo, (1920 - w - 40, 36))
bg.convert("RGB").save("cover_16x9.png")
