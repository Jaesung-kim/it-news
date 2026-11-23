# GitHub Actions, YAML 규격 어긋난 워크플로도 그대로 실행…zizmor·tree-sitter 등 도구와 호환성 문제

- 분야: IT 뉴스
- 출처: yossarian.net, GeekNews
- 원문: https://yossarian.net/til/post/github-actions-accepts-invalid-yaml/
- 관련 글: https://news.hada.io/topic?id=37696
- 발행일: 2026-11-22

## 상세 요약

GitHub Actions가 YAML 표준상 유효하지 않은 구문도 받아들여, 실제로 쓰이는 일부 워크플로와 액션 정의를 표준을 지키는 YAML 파서로는 읽을 수 없다는 분석이 나왔다. GitHub Actions 보안 정적 분석 도구 zizmor 관련 작업을 해 온 개발자가 블로그 'yossarian.net'에 정리한 글이다.

발단은 zizmor 이슈 #1116이다. 한 사용자가 zizmor가 특정 워크플로를 거부한다고 신고했는데, 문제의 단계는 `jsdaniell/create-json` 액션에 여러 줄짜리 작은따옴표 문자열로 JSON을 넘기는 부분이었다. 내용이 아니라 마지막 닫는 줄의 들여쓰기가 4칸이었던 것이 원인이다. 한 칸을 더해 5칸으로 만들면 유효한 YAML이 된다.

근거는 YAML 1.2.2 규격 8.2.3절이다. 글은 이 조항을 "Flow nodes must be indented by at least one more space than the parent block collection."이라고 인용한다. 블록 컬렉션 안의 흐름 노드는 부모보다 최소 한 칸 더 들여써야 한다는 뜻이다. 결국 이 파일을 거부한 zizmor가 규격상 옳고, 실행해 준 GitHub Actions가 규격에서 벗어나 있다.

저자는 처음에 이 구문이 잘못됐다는 사실을 알아채지 못해 tree-sitter-yaml에 이를 허용하는 수정(#36)을 올렸다가, 나중에 되돌리는 변경(#51)을 냈다고 털어놨다. YAML이 그만큼 복잡하다는 방증이라는 설명이다.

GitHub Actions 내부 코드는 대부분 비공개지만, 공개된 러너 코드로 보면 2018년 나온 YamlDotNet 5.3.0을 쓰는 것으로 보인다. 최신 18.1.0에도 같은 동작이 남아 있어 업그레이드만으로는 해결되지 않는다. 저자는 2020년 패치가 큰따옴표 문자열만 고쳤고, 공식 YAML 테스트 모음이 이 규칙을 큰따옴표로만 검사해 작은따옴표 사례가 빠졌을 가능성을 추정으로 제시했다.

저자는 GitHub가 규격 준수로 옮겨 갈 깔끔한 방법이 있는지는 확신하지 못한다고 했다. 이미 이 구문에 기대는 워크플로가 있는 만큼, 파서를 고치면 기존 워크플로가 깨질 수 있기 때문이다.

## 핵심 포인트

- GitHub Actions는 YAML 1.2.2 들여쓰기 규칙을 어긴 여러 줄 작은따옴표 문자열을 허용한다
- 표준을 따르는 zizmor는 같은 워크플로를 거부하며, 공백 한 칸 차이로 유효성이 갈린다
- 저자는 tree-sitter-yaml에 넣었던 잘못된 허용 수정을 되돌렸다
- 원인은 GitHub가 쓰는 것으로 보이는 YamlDotNet의 동작으로, 최신 버전에도 남아 있다
- 기존 워크플로 호환성 때문에 GitHub가 규격 준수로 전환하기는 쉽지 않을 전망이다
