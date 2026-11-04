# 구글, 안드로이드 TV 박스 130만 대 봇넷 'XCPE' 해체…"제조사가 직접 심었다"

- 출처: BleepingComputer, Krebs on Security, CyberScoop, Ars Technica
- 원문: https://www.bleepingcomputer.com/news/security/google-disrupts-million-device-xcpe-android-malware-botnet-bans-tv-box-maker/
- 함께 본 보도: https://krebsonsecurity.com/2026/11/tech-firms-dismantle-botnet-that-turned-1-3m-tv-boxes-into-proxies/ , https://cyberscoop.com/google-disrupts-xcpe-botnet-videostrong-android-devices/
- 관련 보도: https://arstechnica.com/google/2026/11/google-dismantles-botnet-secretly-running-on-1-3-million-android-tv-boxes/
- 공식 보고서(구글 GTIG): https://cloud.google.com/blog/topics/threat-intelligence/shutting-the-door-on-the-xcpe-botnet
- 발행일: 2026-11-02

## 상세 요약

구글과 협력사들이 안드로이드 TV 스트리밍 박스 130만 대 이상으로 이뤄진 봇넷 'XCPE'를 해체했다. 구글은 명령제어 서버를 막으면서 다른 방식으로 감염된 기기 최소 1000만 대에 대한 공격자 접근도 함께 끊었다고 밝혔다. 여기에는 셋톱박스 외에 노래방 기기, 원격진료 장비, 디지털 사이니지 등이 포함된다.

이번 사건의 핵심은 감염 경로다. 악성코드는 취약점 공격이나 이용자 속임수가 아니라 제조 단계에서 펌웨어에 들어갔다. 구글은 중국 제조사 비디오스트롱 테크놀로지를 높은 신뢰도로 배후에 지목했고, 회사가 백도어를 고의로 넣어 범죄 협력자에게 접근권을 팔았다고 판단했다. 구글 연구진은 "We believe this campaign wasn't an isolated rogue insider or a development oversight."라고 적었다.

백도어는 시스템 권한으로 실행되며 앱 몰래 설치, Play Protect 비활성화, 셸 명령 실행, 정보 수집 등을 할 수 있었다. 수익은 외부 범죄 조직의 모듈을 설치해 주는 방식으로 냈다. 광고 사기 모듈과 함께 감염 기기의 인터넷 회선을 제3자에게 빌려주는 레지던셜 프록시 모듈이 쓰였다. 크렙스 온 시큐리티에 따르면 이 IP는 계정 탈취, 광고 사기, AI 학습용 대량 수집 등에 악용됐다.

구글은 비디오스트롱과 관계를 끊고 사전 설치 라이선스를 취소했으며, 이 회사와 향후 계열사가 인증 안드로이드 기기를 만들지 못하게 했다. 도메인과 서버를 폐쇄하는 법적 조치도 취했다. 일본 경찰청과 루멘, 휴먼 시큐리티, 플룸, 신시언트, 트렌드AI가 협력했다.

규모 추정은 더 커질 수 있다. 신시언트의 벤 브런디지는 130만 대가 "highly conservative"한 수치라고 평가했다. 트렌드AI 연구진은 감염 기기가 170개국 이상에 퍼졌고 말레이시아, 브라질, 이라크, 멕시코, 대만에 가장 많다고 집계했다.

해체가 곧 치료는 아니다. 악성코드는 기기에 그대로 남고 `/oem/` 파티션에서 자동 재설치되므로, 없애려면 깨끗한 펌웨어를 설치해야 한다. 임시로는 기기를 인터넷에서 분리할 수 있다. 구글도 이번 조치가 십수 개 악성 행위자에 타격을 줬지만 백도어·광고 사기·프록시 시장의 공급망은 이어질 수 있다고 경고했다. 비디오스트롱의 입장은 확인된 기사에 실리지 않았다.

## 핵심 포인트

- 안드로이드 TV 박스 130만 대 이상, 추가로 다른 기기 최소 1000만 대의 공격자 접근 차단
- 악성코드는 제조 단계 펌웨어에 내장, 구글은 비디오스트롱을 높은 신뢰도로 지목
- 구글, 비디오스트롱과 관계 종료 및 인증 기기 생산 금지
- 프록시 재판매와 광고 사기로 수익화, 170개국 이상에 분포
- 악성코드는 기기에 남으므로 깨끗한 펌웨어 설치 또는 인터넷 분리 필요
