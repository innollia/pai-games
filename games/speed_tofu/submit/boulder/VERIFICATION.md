# 검증 기록 — v6 finish / 2026-10-30

- 수정 범위: g/boulder.gd, art/boulder/, submit/boulder/. Git 명령, tools/build.ps1, 웹 배포, 새 봇 및 스크린샷 촬영 없음.
- 기존 4종 GPT 원본 보존. 누락 5종은 texture_flow.py를 각각 1회+재시도 1회 실행했으나 중첩 Codex 접근 거부(os error 5)로 실패. 내장 2D GPT 이미지 fallback으로 전부 완성했으며 손그림 fallback은 사용하지 않음. 최초 참조 이미지 전송 오류는 신탁의 텍스트 전용 재시도 기록을 적용해 해결.
- 생산 자산: GLB/PNG 9쌍, PNG 전부 512×512. 자산 합계 979,163 bytes. Godot .import 메타데이터 포함 디렉터리 997,828 bytes. art 하위 .gdignore 없음.
- verify_art.py 통과: 파일명 집합, manifest 용량 일치, PNG 해상도, GLB 단일 공유 메시와 UV, 단위 정규화 경계, 임베디드 이미지 없음, 전체 디렉터리 4 MB 이하.
- verify_course.py 통과: 11구역·28조각, 조수 정원/공명 제단 각각 학습과 섞기 구간, 성장/던지기/점프 조합, 마지막 목표와 로컬 기록. 크기 2.0/3.5/5.0/7.0에서 최소 충전 도약 거리의 보수적 수치 검사 통과.
- 내용 보완: 마지막 구역을 넓은 바다 위 신전으로 정리하고 바다 도착 결과 표시. 한국어 howto에 바다 신전, 40% 충전 해제, 완주 기록 설명 추가. 첫 구역의 재도전에서도 누적 플레이 시간과 실패 횟수를 유지하고 처음부터 버튼/완주 후 재시작에서 새 기록 도전으로 초기화.
- 다른 Godot_v4.7.2 프로세스가 없는 것을 확인한 뒤, Godot 4.7.2 headless --path . --import를 **정확히 1회** 실행. 종료 코드 0, 자산 import 완료, SCRIPT ERROR/Parse Error 없음. 기록: work/import_v6.txt.
- 다시 다른 Godot_v4.7.2 프로세스가 없는 것을 확인한 뒤, --headless --path . --fixed-fps 60 -s tools/smoke.gd -- boulder를 **정확히 1회** 실행. 출력: %TEMP%/smoke_boulder.txt, 보관본 work/smoke_v6.txt.
- Smoke 종료 코드 **0**, SCRIPT ERROR **0건**, 게임 요약 **끝남 11 / 다시 10 / 무작위최고 45**, **smoke done** 확인.
- 엄격한 마지막 줄 조건은 미충족: smoke done 뒤 ObjectDB 누수 경고 **20개**와 cleanup 위치가 출력됨. 기존 실행 기록의 89개와 비교할 수 있으나 무작위 입력이므로 개선을 입증하는 수치로 해석하지 않음.
- 환경 오류: 사용자 Godot 로그 파일 쓰기/회전 실패, 루트 인증서 저장소 읽기 실패. Import 시 사용자 편집기 설정 저장 권한 오류도 있었음. 신탁에서 직접 적용할 환경 해결책은 없었고, 추가 import/smoke는 실행하지 않음.
- 검토는 결정적 정적 검사와 지정 smoke에 근거함. 독립 외부 리뷰는 수행하지 않음. 이 smoke는 초반 무작위 입력의 스크립트 안정성 검사이며 모든 구역의 수동 완주, 엔딩의 실제 입력 도달, 기록 저장의 환경별 성공, 모바일 웹 시각 품질을 보증하지 않음. 에셋 파일은 직접 열어 확인했으나 게임 스크린샷은 촬영하지 않음.
