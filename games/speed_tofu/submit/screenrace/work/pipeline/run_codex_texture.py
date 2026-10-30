"""Codex로 텍스처 시험 한 장 (tools/run_codex_test.py의 텍스처판). 선 그림을 참고 이미지로 넘긴다.

    python texture3d/tools/run_codex_texture.py <model> [--force]
    예) python texture3d/tools/run_codex_texture.py 01_crate

작업 폴더(레포 밖)에 message.md, guide_lines.png, out/ 만 둔다.
결과: out/prompt.txt, out/texture.png → texture3d/out/<model>/texture.png 로 복사(1024로 맞춤).
"""
import argparse
import shutil
import subprocess
import sys
import time
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
sys.path.insert(0, r"C:/projects/hwapongstuy/tools")
from run_codex_test import find_codex  # noqa: E402

TASK = """이 작업 폴더에는 message.md, guide_lines.png, 빈 out/ 폴더가 있다. 이미지 생성 파이프라인 시험 한 건이다. 2단계로 진행하고, 단계를 섞지 마.

## 1단계 — 프롬프트 쓰기 (네가 한다)
1. message.md 전체를 읽고 guide_lines.png를 본다. message.md는 사용자가 guide_lines.png를 첨부해 새 채팅에 보낸 "메시지 1" 전문이다. 그 안의 지시를 그대로 따르는 작가가 되어 영어 이미지 프롬프트를 쓴다. 이미지는 생성하지 않는다.
2. 코드 블록 안에 들어갈 프롬프트 본문만 out/prompt.txt에 UTF-8로 저장한다. 앞뒤 설명, 코드 펜스(```)는 저장하지 않는다.

## 2단계 — 이미지 생성 (클린룸 서브에이전트가 한다)
1. 서브에이전트를 새로 띄운다. 서브에이전트가 받는 것은 다음 세 가지뿐이다.
   - out/prompt.txt의 영어 프롬프트 본문 전체(글자 그대로)
   - 참고 이미지 guide_lines.png (이미지 생성 도구에 참고/편집 입력 이미지로 넘긴다)
   - "위 프롬프트를 한 글자도 바꾸지 말고 그대로 사용해서, 첨부한 선 그림과 같은 배치로 이미지를 생성해."
   이 밖의 것(message.md, 메타 프롬프트, 이 작업의 목적, 네 과정)은 알려 주지 않는다.
2. 서브에이전트는 이미지 생성 도구를 정확히 한 번만 호출한다. 결과가 마음에 들지 않아도, 오류가 나도 다시 호출하지 않는다.
3. 만들어진 이미지를 out/texture.png로 복사한다.
4. 서브에이전트를 띄울 수 없으면 직접 그리지 말고 "서브에이전트를 쓸 수 없음"이라고 보고하고 끝낸다.

## 보고 (이 형식만)
- 서브에이전트 사용 여부: 예/아니오
- 참고 이미지를 생성 도구에 넘겼는지: 예/아니오
- 이미지 생성 도구 호출 횟수
- 이미지 파일 경로, 크기
- 서브에이전트가 받은 지시문 전문
- 막힌 점이 있으면 한 줄
"""


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("model")
    ap.add_argument("--work", default=r"C:\projects\_codex_runs")
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--timeout", type=int, default=1500)
    ap.add_argument("--codex-model", default="gpt-6-luna")
    ap.add_argument("--effort", default="high")
    args = ap.parse_args(argv)

    src = HERE / "out" / args.model
    work = Path(args.work) / f"texture3d_{args.model}"
    if work.exists():
        if not args.force:
            print(f"작업 폴더가 이미 있다: {work} (--force)")
            return 2
        shutil.rmtree(work)
    (work / "out").mkdir(parents=True)
    shutil.copy(src / "message.md", work / "message.md")
    shutil.copy(src / "guide_lines.png", work / "guide_lines.png")
    cmd = [find_codex(), "exec", "-m", args.codex_model, "-c", f'model_reasoning_effort="{args.effort}"',
           "-C", str(work), "--skip-git-repo-check", "-s", "workspace-write",
           "--ephemeral", "--color", "never", "-o", str(work / "out" / "last.txt")]
    started = time.time()
    # 출력은 파이프 대신 파일로 바로 쓴다: 파이프면 손자 프로세스가 잡고 있어 시간 제한 뒤에도 안 끝난다(05_hut T2에서 2시간 멈춤).
    with open(work / "run.log", "w", encoding="utf-8") as log:
        proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=log, stderr=subprocess.STDOUT,
                                text=True, encoding="utf-8")
        proc.stdin.write(TASK)
        proc.stdin.close()
        try:
            proc.wait(timeout=args.timeout)
        except subprocess.TimeoutExpired:
            subprocess.run(["taskkill", "/PID", str(proc.pid), "/T", "/F"], capture_output=True)
            proc.wait()
            print("시간 초과로 종료")
    res = proc
    last = work / "out" / "last.txt"
    if last.is_file():
        print(last.read_text(encoding="utf-8"))
    png = work / "out" / "texture.png"
    if not png.is_file():
        # 서브에이전트가 파일 경로를 못 받으면 Codex 기본 저장 폴더에만 남는다(05_hut T2).
        gen = [p for p in (Path.home() / ".codex" / "generated_images").glob("*/*.png") if p.stat().st_mtime >= started]
        if gen:
            png = max(gen, key=lambda p: p.stat().st_mtime)
            print("생성 폴더에서 찾음:", png)
    if png.is_file():
        Image.open(png).convert("RGB").resize((1024, 1024), Image.LANCZOS).save(src / "texture.png")
        shutil.copy(work / "out" / "prompt.txt", src / "prompt.txt")
        print("복사:", src / "texture.png")
    print("종료 코드:", res.returncode)
    return res.returncode


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    raise SystemExit(main(sys.argv[1:]))
