# jQuery 4.1.0·3.8.0 동시 출시…3.x는 마지막 기능 업데이트, 셀렉터 ReDoS 수정

- 분야: IT 뉴스
- 출처: jQuery GitHub, jQuery 공식 블로그, Hacker News
- 원문: https://github.com/jquery/jquery/releases/tag/4.1.0
- 발행일: 2026-11-17

## 상세 요약

자바스크립트 라이브러리 jQuery가 17일 4.1.0과 3.8.0을 함께 내놨다. 릴리스는 메인테이너 티미 윌리슨이 맡았으며, 공식 블로그는 대부분의 사용자가 큰 변경 없이 업그레이드할 수 있다고 안내했다. 3.8.0은 3.x 계열의 마지막 기능 릴리스로, 앞으로 3.x에는 치명적인 보안·버그 수정만 들어간다.

4.1.0의 Ajax 기능에는 리디렉션 뒤 최종 URL을 담는 `responseURL` 속성이 jqXHR 객체에 추가됐다. 최신 브라우저의 XHR에서는 이 값을 얻을 수 있지만 IE 11이나 스크립트·JSONP 전송 방식에서는 비어 있다. 전송 계층이 완료 콜백에 위치 인자 대신 하나의 객체를 넘길 수 있게 한 변화도 들어갔다.

보안과 성능 개선도 담겼다. 셀렉터 엔진의 식별자 매칭에서 정규식 과도한 역추적으로 서비스 거부를 일으킬 수 있던 ReDoS 문제가 고쳐졌다. 잘못된 이스케이프 문자를 처리하는 방식도 정비됐고, 사파리 27의 정규식 해석기 버그를 피하는 우회 코드도 추가됐다. 내부적으로는 `getElementsByTagName`과 `getElementsByClassName` 호출을 없애고 `querySelectorAll`로 통일했다. 요소 중복 제거를 하는 `jQuery.uniqueSort`는 처리 시간이 제곱 비례에서 선형으로 줄었다.

웹 표준 대응도 늘었다. 폼과 연동되는 커스텀 엘리먼트를 `.serialize()`로 직렬화할 수 있게 됐고, XSLT 결과물 같은 XML 문서에서도 `.css()`가 작동한다. 기여 지침에는 기계가 생성한 기여물에 관한 가이드라인이 새로 들어갔다.

3.8.0에서는 `hidden="until-found"` 속성을 지원하고, jQuery 객체의 `push`·`sort`·`splice` 배열 메서드와 `jQuery.expr[":"]`, `jQuery.expr.filters`를 공식적으로 사용 중단(deprecated) 처리했다. 대체 수단은 `jQuery.expr.pseudos`다. 두 버전 모두 공식 CDN과 npm으로 받을 수 있다.

## 핵심 포인트

- jQuery 4.1.0과 3.8.0이 11월 17일 함께 출시됐다
- 3.8.0은 3.x의 마지막 기능 릴리스이며 이후에는 치명적 수정만 제공된다
- 셀렉터 식별자 매칭의 ReDoS 취약 패턴이 수정됐다
- jqXHR에 리디렉션 뒤 최종 URL을 담는 responseURL이 추가됐다
- 커스텀 폼 엘리먼트 직렬화, XML 문서의 .css() 지원 등이 들어갔다
