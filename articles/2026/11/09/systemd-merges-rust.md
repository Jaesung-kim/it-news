# systemd, Rust 지원 병합…개별 바이너리는 Rust로, 핵심 공유 라이브러리는 C 유지

- 분야: IT 뉴스
- 출처: Amutable 블로그(Christian Brauner·Lennart Poettering), GeekNews
- 원문: https://amutable.com/blog/systemd-loves-rust
- 발행일: 2026-11-03 (GeekNews 소개 2026-11-09)

## 상세 요약

리눅스 시스템·서비스 관리자 systemd가 Rust 지원을 병합했다. systemd 개발자 크리스티안 브라우너와 레나르트 푀테링은 블로그 글에서 GitHub PR 44324가 병합되면서 개별 바이너리를 C뿐 아니라 Rust로도 작성할 수 있게 됐다고 밝혔다.

도입 범위는 두 갈래로 나뉜다. 개별 도구에 해당하는 말단 바이너리에는 Rust를 쓸 수 있지만, 여러 바이너리가 함께 쓰는 핵심 공유 라이브러리 libsystemd-shared.so에는 당분간 허용하지 않는다. Rust에 안정적인 ABI가 없어 공유 라이브러리에 Rust 코드를 넣으면 많은 바이너리에 같은 코드가 중복돼 크기가 불어나기 때문이다. systemd는 180개가 넘는 바이너리로 나뉘어 있어 정적 링크도 현실적이지 않다고 설명했다.

그래서 공유 코드는 C로 유지하고 이를 Rust 크레이트로 감싸 Rust 바이너리에서 쓰는 방식을 택했다. 경로 탐색 같은 핵심 기능은 Rust 표준 라이브러리 대신 systemd의 기존 fd 기반 chase 계열 함수를 그대로 쓰며, C와 Rust 바이너리가 옵션 처리, 도움말, 오류 메시지에서 똑같이 동작하도록 맞춘다.

빌드와 의존성 정책은 보수적이다. 빌드 시스템은 기존 meson을 유지하고 cargo는 쓰지 않는다. 현재 직접 링크하는 라이브러리는 libc뿐이고 나머지는 dlopen()으로 불러오는데, 외부 크레이트도 Rust 생태계 경험이 쌓일 때까지 받지 않는다. Rust 코드는 no_std로 작성하고 메모리 할당 실패를 처리하는 자체 크레이트를 둔다.

개발자들은 안정적으로 동작하는 C 코드를 이유 없이 Rust로 다시 쓰지는 않겠다고 밝혔다. Rust는 당분간 선택 사항이며 Rust 없이 빌드하는 경로도 계속 지원한다. 글에서는 Rust 1.100에서 systemd의 Rust 지원을 깨뜨릴 수 있었던 변경을 Rust 커뮤니티가 빠르게 되돌린 일도 소개했다.

## 핵심 포인트

- systemd가 PR 44324로 Rust 지원 병합, 개별 바이너리를 Rust로 작성 가능
- 핵심 공유 라이브러리는 Rust의 ABI 한계로 당분간 C 유지
- C 공통 코드를 Rust 크레이트로 감싸 동작을 통일
- meson 유지, cargo·외부 크레이트 미사용, no_std 적용
- Rust는 선택 사항이며 Rust 없는 빌드도 계속 지원
