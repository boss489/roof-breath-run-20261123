# 검증

- Godot 4.7.2: `godot --headless --editor --path . --quit`; `godot --headless --path . --script res://tests/logic.gd` → **PASS 16 checks**, 전 레벨 결정론적 재생 43틱, 기록 43.
- `python3 tests/check_glyphs.py` → `Missing non-ASCII glyphs: []`; 번들 Noto Sans KR 글리프 검사 통과.
- `godot --headless --path . --export-release Web docs/index.html` → Godot Web HTML/JS/PCK/WASM 생성.
- `python3 -m http.server 8765 --bind 127.0.0.1` (`docs/`에서), `node tests/browser.cjs` → 로컬 Chrome에서 960×640 및 320×640 캔버스 렌더. 제목→설명→플레이, 3회 추락 실패→재시작→3단계 휴식→성공, 320px 버튼 홀드와 CDP 동시 두 손가락 방향+질주 확인. 스크린샷은 `evidence/` (960/320 제목·설명·플레이, 960 실패·휴식·성공, 320 홀드·멀티터치).
- 시각 확인: 네이비 도시/달/배달원/패턴이 있는 취약 발판과 연속 안전 발판, HUD, 모든 상태의 한국어 글자 표시. 320px 물리 화면은 작은 글자가 확대 없이도 읽히나 큰 터치 영역 대비 밀도가 높다.
- 데스크톱 첫 방문에 favicon 404 콘솔 기록 1건; 게임 자산과 실행에는 영향 없고 320px 재실행 시 오류 0건. 외부 실제 기기·Safari/Firefox는 미검증.
- 헤드리스 게임 로직은 저장이 불가능한 모드에서도 기록을 메모리에 유지하는 분기를 테스트한다. 브라우저 재방문 기록 지속 여부는 자동 검증 범위 밖이다.
