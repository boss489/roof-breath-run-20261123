# 배포

- 대상: 새 공개 저장소 `boss489/roof-breath-run-20261123`, GitHub Pages `main/docs`, URL `https://boss489.github.io/roof-breath-run-20261123/`.
- 산출물: `docs/index.html`, `index.js`, `index.pck`, `index.wasm`, `index.png`, 오디오 워클릿 JS 2개, `.nojekyll`. HTML/JS만 올리는 대체 페이지가 아니라 실제 Godot Web export이다.
- 빌드: `godot --headless --editor --path . --quit && godot --headless --path . --export-release Web docs/index.html`. 테스트 명령은 `TESTS.md` 참고.
- 배포 순서: 추적 파일·비밀/라이선스 검사 → main 커밋 → 새 공개 repo 생성·push → Pages source를 main/docs로 지정 → 빌드 상태 확인 → 공개 HTTP에서 HTML·PCK·WASM 응답과 브라우저 캔버스 확인.
- 롤백: Pages를 비활성화하거나 `main`을 이전 정상 커밋으로 되돌린 뒤 Pages 빌드가 완료되었는지 확인한다.
- 실제 배포 결과와 커밋 SHA는 `PROGRESS.md`에 기록한다.
