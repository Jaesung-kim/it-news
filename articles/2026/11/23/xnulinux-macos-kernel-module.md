# 'XNU Linux' 공개…macOS 커널 XNU를 리눅스 커널 모듈로 올려 하이퍼바이저 없이 macOS 데스크톱 구동

- 분야: IT 뉴스
- 출처: GitHub(AFK-surf/xnulinux), GeekNews
- 원문: https://github.com/AFK-surf/xnulinux
- 관련 글: https://news.hada.io/topic?id=37700
- 발행일: 2026-11-23 (GeekNews 소개 기준)

## 상세 요약

macOS의 커널인 XNU를 리눅스 커널 안에 모듈로 적재해 macOS 사용자 공간을 통째로 실행하는 오픈소스 프로젝트 'xnulinux'가 공개돼 개발자 커뮤니티에서 화제가 됐다. 저장소 소개 문구는 "Run macOS userspace on Linux by loading the macOS kernel into it."이다. 저작권 표기는 Heyang Zhou와 기여자들로 돼 있다.

방식은 이렇다. 애플이 공개한 소스로 XNU를 빌드해 `xnu.ko` 모듈로 만들고, 수정하지 않은 arm64 우분투 커널에 `insmod`로 올리면 macOS 27 시스템 디스크가 데스크톱까지 부팅된다. 하이퍼바이저를 두지 않고 XNU가 CPU와 MMU를 직접 다루기 때문에 macOS 프로세스와 리눅스 프로세스가 같은 CPU에서 네이티브로 돈다. 리눅스는 FKI라는 얇은 인터페이스 모듈을 통해 메모리, 타이머, 파일, 네트워크, GPU를 제공한다.

GPU는 macOS의 Metal 호출을 metal2vulkan으로 Vulkan으로 바꾼 뒤 DRM 브리지를 거쳐 호스트 GPU를 쓴다. GPU가 없으면 Mesa lavapipe 기반 CPU 렌더링으로 전환한다. 로그인 화면, WindowServer, Dock, Finder, Safari, Chrome, Spotlight, 파일 시스템이 동작하는 것으로 나와 있다.

성능 수치도 공개됐다. 애플 실리콘 Mac 위의 arm64 리눅스 VM에서 macOS 27.2.1 데스크톱 부팅에 호스팅 CPU 1~6개 기준 31~48초가 걸렸다. 같은 Mac에서 애플 가상화 프레임워크 기반 macOS VM은 49초였다. Safari, 메모, 계산기 등 앱 실행과 디스크 순회를 40회 반복한 30분 스트레스 테스트에서는 패닉이나 크래시가 없었다. 다만 4K 페이지를 쓰는 탓에 메모리 접근은 16K 페이지를 쓰는 네이티브 VM보다 느리다.

제약도 분명하다. 지금은 애플 실리콘 Mac 위의 krunkit·tart VM에서만 검증됐고, RAM 16GB(이 중 8GB는 호스팅 커널 예약)와 사용자가 직접 준비한 macOS 27 설치본, Xcode가 있는 Mac이 필요하다. AMFI 패치와 SIP 완화 같은 임시 조치도 남아 있다.

라이선스는 리눅스 쪽(GPL-2.0)과 XNU 쪽(APSL-2.0)을 분리하고 FKI로만 연결하는 구조다. 저장소는 애플 바이너리를 포함하거나 배포하지 않으며, 애플과 제휴하거나 승인받은 프로젝트가 아니라고 밝혔다.

## 핵심 포인트

- XNU를 리눅스 커널 모듈로 적재해 하이퍼바이저 없이 macOS 데스크톱과 앱을 실행한다
- 리눅스는 FKI 인터페이스로 메모리·파일·네트워크·GPU를 제공하고, Metal은 Vulkan으로 변환된다
- macOS 27.2.1 부팅은 31~48초로, 애플 가상화 VM(49초)보다 빨랐다
- 30분 스트레스 테스트에서 크래시는 없었지만 4K 페이지 탓에 메모리 접근은 느리다
- 현재는 애플 실리콘 Mac의 리눅스 VM에서만 검증됐고, 애플 바이너리는 사용자가 직접 준비해야 한다
