# 배포

- 대상: 새 공개 저장소 `boss489/roof-breath-run-20261123`, GitHub Pages `main/docs`, URL `https://boss489.github.io/roof-breath-run-20261123/`.
- 산출물: `docs/index.html`, `index.js`, `index.pck`, `index.wasm`, `index.png`, 오디오 워클릿 JS 2개, `.nojekyll`. HTML/JS만 올리는 대체 페이지가 아니라 실제 Godot Web export이다.
- 빌드: `godot --headless --editor --path . --quit && godot --headless --path . --export-release Web docs/index.html`. 테스트 명령은 `TESTS.md` 참고.
- 배포 순서: 추적 파일·비밀/라이선스 검사 → main 커밋 → 새 공개 repo 생성·push → Pages source를 main/docs로 지정 → 빌드 상태 확인 → 공개 HTTP에서 HTML·PCK·WASM 응답과 브라우저 캔버스 확인.
- 롤백: Pages를 비활성화하거나 `main`을 이전 정상 커밋으로 되돌린 뒤 Pages 빌드가 완료되었는지 확인한다.
- 실제 배포 결과와 커밋 SHA는 `PROGRESS.md`에 기록한다.

## 320px 보정 갱신

- 기존 `main/docs` Pages만 업데이트한다. 게임 소스 `Main.gd`를 다시 Web export한 `docs/index.pck`와 상태별 Chrome 캡처를 함께 검증한다.
- 새 커밋 push 후 원격 main SHA와 Pages `builds/latest`의 `commit`·`status=built`를 일치시킨다. 공개 URL의 `index.html`, `index.js`, `index.pck`, `index.wasm`을 캐시 무효화 URL로 내려받아 로컬 `docs/`와 SHA-256을 비교하고 실제 공개 게임을 960/320 Chrome에서 다시 플레이한다. 검증 명령과 결과는 `TESTS.md` 및 최종 인계에 기록한다.
