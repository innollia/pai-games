# 제출 리허설 (10/29 24시 전, 약 10분)

목적: 마감 뒤에는 고칠 수 없으니, 빈 뼈대를 먼저 실제 itch.io에 올려 폰에서 열어 본다. 게임 내용이 아니라 **올리는 과정과 폰에서 도는지**를 확인한다.

사전: itch.io 계정(만 13세 이상, 게시자는 성인이거나 보호자 동의 — 미성년이면 오늘 동의를 받아 둔다), 실제 스마트폰 1대(가능하면 iPhone 11급 이하), 같은 폰으로 itch.io에 로그인.

## 1. ZIP 만들기 (1분)

```bash
node jam_kits/slapjam2/tools/smoke_test.js
```

```bash
powershell -ExecutionPolicy Bypass -File jam_kits/slapjam2/tools/build.ps1
```

"검사 통과"가 나오고 `jam_kits/slapjam2/dist/slapjam2.zip`이 생기면 된다. 실패하면 출력된 오류를 고친다.

## 2. 비공개로 올리기 (4분)

1. itch.io → Dashboard → Create new project.
2. Title은 임시(`rehearsal`). Kind of project: **HTML**.
3. Uploads에 `slapjam2.zip` 업로드 → **This file will be played in the browser** 체크.
4. Embed options: **Viewport 720 × 1280**, **Mobile friendly** 체크, **Orientation: Portrait**. 전체화면 버튼은 켜 둬도 된다.
5. Visibility는 **Draft** 또는 **Restricted(비공개)** 로 저장 → Save.

## 3. 폰에서 확인 (3분) — 해당 항목이 안 되면 실패

| 확인 | 기준 |
| --- | --- |
| 프로젝트 페이지의 게임이 세로 화면에 맞게 뜬다 | 잘림·가로 스크롤 없음 |
| "탭해서 시작"이 보이고, 탭하면 사라진다 | 첫 탭 한 번에 시작 |
| 동그라미를 탭하면 소리가 난다 | **무음 스위치 끄고** 확인. 소리 없으면 실패 |
| 화면을 문질러도 페이지가 스크롤·확대되지 않는다 | 핀치 확대 안 됨 |
| 한 판(30초) 동안 끊기지 않는다 | 주소 끝에 `?debug` 없이 눈으로. 의심되면 게임 URL에 `?debug` |
| 홈 버튼/탭 전환 후 돌아와도 계속된다 | 멈췄다가 이어짐, 소리 복구 |
| 점수가 새로고침 뒤에도 남는지 | iframe이라 안 남을 수 있음. 안 남아도 정상이다(게임이 저장에 의존하면 안 됨) |

## 4. 실제 제출 때 (마감 11/1 00:00 KST) 체크리스트

- [ ] 마감 **최소 1시간 전**에 최종 ZIP 업로드 (11/1 00:00 에 몰리면 업로더 지연에 대응 못 한다. 서두르면 못 고친다.)
- [ ] 프로젝트 **Public**, Mobile friendly, Portrait 다시 확인 (리허설 때 Draft였다면 반드시 바꿈)
- [ ] 잼 페이지에서 **Submit your project** 로 이 프로젝트를 연결 (업로드만으로는 제출이 안 된다)
- [ ] 제출 후 시크릿 창/다른 폰으로 공개 URL을 열어 다시 실행
- [ ] 마지막 4가지(느림·조작 불편·어두운 화면·소리 없음)를 실제 폰에서 확인
- [ ] 마감 뒤에는 진행 불가 버그도 수정할 수 없다 — 마지막 몇 시간은 새 기능보다 이미 통과한 빌드를 지킨다. 새 빌드를 올릴 때마다 위 3번 표를 다시 돈다.

## 문제 생겼을 때

- 게임이 안 뜬다/흰 화면: ZIP 최상위에 `index.html`이 있는지(폴더째 압축하면 한 단계 아래로 들어간다). `build.ps1`이 만든 ZIP만 쓴다.
- 이미지·소리가 안 나온다: 파일명 대소문자(`Star.png` ≠ `star.png`). 빌드 검사가 잡아 준다.
- 소리가 없다: 폰 무음 스위치, 첫 탭을 했는지, 코드에서 `Kit.sfx`를 부르는지.
- 느리다: `README.md`의 "가볍게" 항목. 이미지 크기, `shadowBlur`, 동시 스프라이트 수부터 본다.
