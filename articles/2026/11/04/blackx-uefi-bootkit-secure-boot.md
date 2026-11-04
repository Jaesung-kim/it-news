# 완전 패치된 윈도우도 뚫은 UEFI 부트킷 'BlackX'…Secure Boot 수동 조치 공백 노려

- 출처: Kaspersky Securelist, BleepingComputer, Ars Technica
- 원문: https://securelist.com/uefi-bootkit-blackx/121539/
- 함께 본 보도: https://www.bleepingcomputer.com/news/security/blackx-uefi-bootkit-exploits-baton-drop-flaw-to-bypass-secure-boot/
- 관련 보도: https://arstechnica.com/security/2026/11/uefi-bootkit-infected-fully-patched-windows-machines-is-microsoft-to-blame/
- 공식 출처: https://nvd.nist.gov/vuln/detail/CVE-2022-21894 , https://msrc.microsoft.com/update-guide/vulnerability/CVE-2022-21894
- 발행일: 2026-10-22(Kaspersky), 2026-11-03(Ars Technica)

## 상세 요약

카스퍼스키가 2026년 초 포착한 UEFI 부트킷 'BlackX'가 완전히 패치된 윈도우 기기까지 감염시킨 사실이 알려지며 논란이 커지고 있다. 표적은 타지키스탄, 우즈베키스탄, 투르크메니스탄의 외교 기관이었다. 공격자는 네트워크에 침투해 관리자 권한을 얻은 뒤 부트킷을 설치했다.

악용된 취약점은 2022년 1월 공개된 Secure Boot 우회 결함 CVE-2022-21894(Baton Drop)다. NVD에 등록된 CVSS 점수는 4.4(중간)로, 높은 권한이 있어야 하지만 CISA의 분류에는 실제 악용 상태로 올라 있다. 공격 구현은 2023년 확인된 BlackLotus와 매우 비슷하며, 공격자는 자체 MOK 키를 등록해 임의의 EFI 파일을 불러왔다.

패치된 기기가 감염된 이유가 핵심이다. 패치는 취약한 구성요소를 서명한 'Windows Production PCA 2011' 인증서를 폐기하도록 설계됐지만, 이 폐기는 자동으로 일어나지 않는다. 관리자가 레지스트리 플래그를 설정하고 예약 작업을 돌려야 한다. 카스퍼스키는 "this revocation does not happen automatically upon patch installation"이라고 지적했다. 듀얼 부팅 시스템이 깨질 수 있어 수동으로 뒀다는 설명이다.

해당 인증서는 2026년 10월 19일 만료됐지만, 차단 목록에 올리지 않으면 취약한 바이너리 로딩은 막히지 않는다. 마이크로소프트 공식 안내도 폐기 후 2011 서명 부트 매니저를 쓰는 복구·PXE·USB 매체로는 부팅할 수 없다고 경고해, 적용이 쉽지 않은 사정을 보여 준다. 카스퍼스키에 따르면 자동 폐기를 위한 '강제 적용 단계'는 보고서 시점까지 구현되지 않았다. Ars Technica는 BlackX가 마이크로소프트의 불명확한 Secure Boot 보호 안내를 파고들었다고 짚었다.

부트킷이 넣는 커널 드라이버는 보안 제품의 콜백을 끄고 ETW 데이터를 조작한다. 후속 페이로드로는 구글 드라이브, 원드라이브, 얀덱스 디스크를 명령 채널로 쓰는 원격 제어 도구와 OxiDLLRunner가 쓰였다. 카스퍼스키는 공격 주체를 APT41로 중간 신뢰도로 추정했다.

권고는 명확하다. 관리자는 Secure Boot 폐기 절차를 실제로 마쳤는지 확인해야 하고, 패치 적용 뒤 추가 조치가 필요한지도 점검해야 한다. 다만 마이크로소프트는 DB 업데이트 없이 DBX만 수동 적용하면 부팅 불능이 될 수 있다고 경고했으므로 테스트 장비에서 먼저 검증하는 것이 안전하다.

## 핵심 포인트

- BlackX가 CVE-2022-21894로 Secure Boot를 우회, 중앙아시아 외교 기관 표적
- 피해 기기는 모두 패치 상태였으나 인증서 폐기 수동 조치가 빠져 있었음
- 'Windows Production PCA 2011'은 10월 19일 만료됐지만 차단 목록 등록 전에는 로딩을 막지 못함
- 카스퍼스키는 APT41을 중간 신뢰도로 지목
- 관리자는 폐기 절차 완료 여부 확인, 적용 전 테스트 장비 검증 필요
