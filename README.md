# GSBOX 앱

https://gsbox.kr 을 앱 화면으로 보여주는 안드로이드 앱(Flutter 웹뷰)입니다.

## 파일 구성
- `lib/main.dart` — 앱 코드 (주소는 맨 위 `kHomeUrl`에서 바꿈)
- `pubspec.yaml` — 앱 이름·버전·사용 패키지
- `.github/workflows/build-apk.yml` — main에 올리면 APK 자동 빌드

## APK 받는 법
GitHub → Actions → 최신 "Build APK" 실행 → 아래 Artifacts의 `gsbox-apk` 다운로드

## GSBOX 앱 (build-apk-mobile.yml)
창고예약·주차이용 신청과 창고/주차 시스템 로그인이 있는 `gsbox.kr/m` 을 여는 별도 앱입니다.
기존 GSBOX 앱과 따로 설치됩니다 (패키지 `kr.gsbox.mobile`).
- `.github/workflows/build-apk-mobile.yml` — PR·main 에 올라오면 자동 빌드 (Actions 에서 버튼으로도 실행 가능)
- APK 받기(고정 주소): https://github.com/it7993it-alt/gsbox/releases/download/mobile-apk/GSBOX.apk
  main 에 반영될 때마다 최신 APK 로 바뀝니다. gsbox.kr/m 의 앱 설치 버튼이 이 주소를 씁니다.
