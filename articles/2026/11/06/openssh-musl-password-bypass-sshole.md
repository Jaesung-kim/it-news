# OpenSSH, musl 환경 비밀번호 인증 우회 긴급 조치…알파인 "지금 업데이트하고 sshd 재시작"

- 분야: IT 뉴스
- 출처: Alpine Linux 보안 권고, OpenSSH 릴리스 노트, sshhole.com(발견자 공개 글), GeekNews, Hacker News
- 원문: https://alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/
- 공식 출처: https://alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/ , https://www.openssh.org/releasenotes.html#10.6p2
- 발행일: 2026-11-05

## 상세 요약

musl libc를 쓰고 PAM 없이 동작하는 리눅스 시스템의 sshd에서 비밀번호를 몰라도 로그인할 수 있는 결함이 공개됐다. OpenSSH 프로젝트는 11월 5일 치명적 보안 우회 조치를 담은 10.6p2를 내놓았고, Alpine Linux는 같은 날 보안 권고를 냈다. 발견자는 Wakefield 소속 외즈귄 퀼테킨(Özgün Kültekin)이다. 권고 작성 시점에 CVE 번호는 배정되지 않았다.

공격이 성립하려면 여러 조건이 함께 맞아야 한다. 공격자가 SSH 포트에 닿을 수 있고, sshd가 PAM 없이 빌드됐거나 `UsePAM no`로 돌아가야 한다. `PasswordAuthentication`은 켜져 있어야 하는데 이것이 기본값이다. 여기에 비밀번호 필드가 `*`인 계정과 `$5$` 또는 `$6$` 해시를 가진 다른 로컬 계정이 하나씩 있어야 한다. 이때 257~1024바이트 길이의 비밀번호를 보내면 로그인이 성공한다.

원인은 두 동작이 맞물린 데 있다. PAM이 없는 sshd는 `crypt()`로 비밀번호를 검사하고, 저장된 값이 솔트를 담기에 너무 짧으면 다른 계정의 솔트를 빌린다. musl의 `crypt()`는 키가 256바이트를 넘으면 오류 표시로 문자열 `*`를 돌려주는데, 이 값이 비밀번호 없는 계정의 저장 필드와 일치해 비교가 통과된다. OpenSSH 측은 근본 원인이 sshd 바깥에 있다고 보면서도 sshd를 통해 악용되고 sshd에서 막을 수 있어 우회 조치를 넣었다고 밝혔다.

알파인 권고는 위험을 강하게 표현했다. 비밀번호를 가진 사용자가 한 명만 있어도 비밀번호 없는 모든 계정에 닿을 수 있고, 한 번의 연결로 매번 재현되며 재시도도 필요 없다는 설명이다. 대상 계정의 예로는 `root`(`PermitRootLogin yes`일 때만), 비밀번호 없이 만든 키 전용 사용자, nslcd·winbind·sssd 사용자, tiny-cloud 이미지의 `alpine` 사용자를 들었다. 지원 중인 3.21~3.24와 edge는 물론 지원이 끝난 3.16~3.20도 영향을 받으며, 수정 패키지는 3.16까지 거슬러 배포됐다.

조치는 패키지 업데이트에서 끝나지 않는다. 알파인은 `apk upgrade -U -a` 후 sshd를 재시작하라고 안내했다. 패키지만 올려서는 실행 중인 데몬이 바뀌지 않기 때문이다. 수정 버전은 3.24용 10.3_p1-r2, 3.23용 10.2_p1-r1, 3.22용 10.0_p1-r11, 3.21용 9.9_p2-r1, edge용 10.6_p2-r0 등이다. 즉시 업데이트가 어렵다면 `PasswordAuthentication no`로 바꾸고 재시작하면 된다. `/var/log/messages`에서 비밀번호 없는 계정의 `Accepted password for` 기록을 찾아야 하며, 알파인은 로그인을 배제할 수 없으면 침해된 것으로 보라고 권고했다.

영향 범위 밖의 환경도 명확하다. PAM을 쓰는 `openssh-server-pam`(`UsePAM yes`), `PasswordAuthentication no` 설정, 잠긴 계정(`!`)은 해당하지 않는다고 알파인은 밝혔다. OpenSSH 공지도 대상을 musl을 쓰고 PAM을 끈 리눅스로 한정했다. 발견자 글은 glibc, Dropbear, OpenBSD는 무관하고 OpenWRT, Buildroot, Yocto의 musl 빌드는 해당한다고 적었는데, 이 부분은 발견자 측 주장이다.

이번 릴리스는 개발 절차의 변화도 함께 알렸다. OpenSSH 팀은 AI가 찾아낸 버그 보고가 늘어난 점을 들어 앞으로 릴리스를 더 자주 내겠다고 밝혔다.

## 핵심 포인트

- PAM 없는 musl 리눅스의 sshd에서 `*` 계정에 257~1024바이트 비밀번호를 보내면 인증이 우회됨
- musl `crypt()`의 오류 반환값 `*`가 비밀번호 없는 계정의 저장 필드와 일치하는 것이 원인
- OpenSSH 10.6p2와 알파인 3.16~edge 수정 패키지가 배포됐고, 작성 시점에 CVE 번호는 없음
- 패키지 업데이트 후 sshd 재시작이 필수이며, 대안은 `PasswordAuthentication no`
- 로그에서 비밀번호 없는 계정의 로그인 기록을 점검해야 함

> 배경(편집자 설명): 알파인 같은 musl 기반 배포판은 컨테이너 베이스 이미지로도 널리 쓰인다. sshd를 직접 띄우는 이미지가 있다면 함께 점검하는 편이 좋다.
