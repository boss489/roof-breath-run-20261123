# 숨 고르는 지붕길 — 진행 기록

2026-11-23 KST. 선정 파일 `selection.json`의 id=1 규칙에 따른 독립 Godot 4.7.2 Web 게임. 0.2초 틱, 안전 지붕 정지 휴식, 취약 지붕 진입 질주·기력 차감, 3목숨·3레벨, 성공/실패/재시작, 최고 틱 기록 및 음소거 저장/메모리 폴백. 키보드·화면 마우스·320px 동시 터치 동작.

아트 정의 `ART.md`, 글꼴 라이선스 `CREDITS.md`, 테스트 `TESTS.md`, 배포 절차 `DEPLOY.md`. `evidence/`에는 실제 Godot Web을 Chrome에서 렌더한 상태별 스크린샷이 있다.

배포 완료: 새 공개 저장소 `https://github.com/boss489/roof-breath-run-20261123`의 main/docs Pages 소스. 게임 바이너리 최초 배포 커밋 `1e61f537f0eea6aa6ae1be24077c71a31ad6999d`; Pages 빌드 `built` (2026-11-22T20:34:14Z = 2026-11-23 05:34:14 KST). 공개 URL `https://boss489.github.io/roof-breath-run-20261123/`. HTML/JS/PCK/WASM HTTP 206 Range 응답 및 Chrome에서 실제 공개 게임의 데스크톱·320px 플레이/성공 확인; `evidence/public/`. 최종 문서·증거 업데이트 후 원격 main SHA는 별도로 검증한다.

한계: 실제 휴대폰/Safari/Firefox 미확인; 로컬 첫 접속 favicon 404(공개 사이트 재검증에서는 콘솔 오류 없음). 공개 사이트의 동일 Chrome 브라우저에서 새로고침 시 최고 기록 47틱 보존 확인; 다른 기기 간 동기화는 제공하지 않는다.

2026-11-23 KST 접근성 보정: 320×640에서 HUD·도움말의 글꼴 크기/획/밝기를 높이고 긴 도움말을 두 줄로 나눔. 기존 3개 터치 버튼의 위치·히트 영역과 게임 로직은 불변. Godot import/16개 로직 체크/한글 글리프/Web export와 로컬 Chrome 960·320의 제목→튜토리얼→플레이→실패→성공 및 320 멀티터치를 재검증함(`TESTS.md`). 게임/바이너리 보정 커밋 `6685ff4b370fd781115e0136dadcab133f009ec7`의 Pages 빌드 `built`(2026-11-22T20:50:57Z), 공개 HTML/JS/PCK/WASM 로컬 바이트 SHA-256 일치, 공개 Chrome 960·320 각 화면/터치 실제 확인(`evidence/public/`). 후속 증거·문서 전용 커밋의 원격 SHA와 Pages 상태는 최종 인계에서 확인.
