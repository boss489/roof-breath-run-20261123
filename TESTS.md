# 검증

- Godot 4.7.2: `godot --headless --editor --path . --quit`; `godot --headless --path . --script res://tests/logic.gd` → **PASS 16 checks**, 전 레벨 결정론적 재생 43틱, 기록 43.
- `python3 tests/check_glyphs.py` → `Missing non-ASCII glyphs: []`; 번들 Noto Sans KR 글리프 검사 통과.
- `godot --headless --path . --export-release Web docs/index.html` → Godot Web HTML/JS/PCK/WASM 생성.
- `python3 -m http.server 8765 --bind 127.0.0.1` (`docs/`에서), `node tests/browser.cjs` → 로컬 Chrome에서 960×640 및 320×640 캔버스 렌더. 제목→설명→플레이, 3회 추락 실패→재시작→3단계 휴식→성공, 320px 버튼 홀드와 CDP 동시 두 손가락 방향+질주 확인. 스크린샷은 `evidence/` (960/320 제목·설명·플레이, 960 실패·휴식·성공, 320 홀드·멀티터치).
- 시각 확인: 네이비 도시/달/배달원/패턴이 있는 취약 발판과 연속 안전 발판, HUD, 모든 상태의 한국어 글자 표시. 320px 물리 화면은 작은 글자가 확대 없이도 읽히나 큰 터치 영역 대비 밀도가 높다.
- 로컬 데스크톱 첫 방문에 favicon 404 콘솔 기록 1건; 게임 자산과 실행에는 영향 없고 320px 재실행 시 오류 0건. 외부 실제 기기·Safari/Firefox는 미검증.
- 공개 Pages URL에서 `BASE_URL=https://boss489.github.io/roof-breath-run-20261123/ node tests/browser.cjs` 재실행: 960/320 캔버스가 열리고 콘솔 오류 0건. `evidence/public/`의 실제 공개 사이트 화면에서 제목·튜토리얼·플레이·실패·3단계 휴식·성공(47틱 최고 기록), 320px 단일 버튼과 동시 멀티터치 질주를 시각 확인. 성공 직후 동일 브라우저 페이지를 새로고침한 `960-reloaded-record.png`에 최고 기록 47틱 유지 확인.
- 헤드리스 게임 로직은 저장이 불가능한 모드에서도 기록을 메모리에 유지하는 분기를 테스트한다. 공개 사이트 Chrome의 같은 브라우저 프로필에서 새로고침 후 최고 기록 47틱을 확인했다. 다른 기기·브라우저 간 기록 동기화는 제공하지 않는다.

## 320px 가독성 보정 재검증 (2026-11-23 KST)

- `godot --headless --editor --path . --quit` 성공; `godot --headless --path . --script res://tests/logic.gd` → **PASS 16 checks; replay 43 ticks; best 43**; `python3 tests/check_glyphs.py` → 누락 글리프 `[]`; Web export 성공.
- `node tests/browser.cjs` 로컬 Chrome 960×640/320×640: 제목→튜토리얼→플레이→실패→재도전→성공 스크린샷 재생성, 320에서 단일 홀드 및 방향+질주 멀티터치도 유지. 320 성공/실패 추가 캡처(`evidence/320-success.png`, `320-failure.png`). 960 첫 접속 favicon 404만 관찰, 320 콘솔 오류 없음.
- `evidence/320-play.png` 실사 확인: HUD·메뉴·음소거·하단 버튼의 좁은 화면 글자를 확대하고 좁은 화면 글꼴을 살짝 두껍게 렌더; 안전 지붕 도움말은 밝은 2줄로 변경. 세 터치 버튼은 여전히 각 약 90×52 CSS px, 서로 겹치지 않고 도움말과 분리됨. 데스크톱 글꼴/레이아웃은 그대로. 실제 휴대폰 및 다른 엔진은 미검증.
