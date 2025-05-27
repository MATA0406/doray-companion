# DorayCompanion

DorayCompanion은 두레이(Dooray) 출퇴근 관리를 위한 iOS/Apple Watch 앱입니다. Apple Watch에서 간편하게 출퇴근을 기록하고, 실제 두레이에 등록된 시간을 확인할 수 있습니다.

## 🚀 주요 기능

- **Apple Watch 출퇴근 기록**: 워치에서 간편하게 출근/퇴근 버튼 클릭
- **iPhone 앱 지원**: iOS 앱에서도 동일한 기능 제공
- **실시간 동기화**: Watch ↔ iPhone 간 WatchConnectivity를 통한 실시간 통신
- **실제 시간 조회**: 두레이 서버에서 실제 등록된 출퇴근 시간을 가져와 표시
- **스마트 UI**: 퇴근 버튼은 오후 6시 이후에만 활성화

## 📋 시스템 요구사항

- **iOS**: 18.2+
- **watchOS**: 11.2+
- **Xcode**: 16.0+
- **Apple Watch**: Series 4 이상 권장
- **네트워크**: 두레이 서버에 접속 가능한 인터넷 연결

## 🛠 설치 및 설정

### 1. 프로젝트 클론

```bash
git clone <repository-url>
cd DorayCompanion
```

### 2. 서버 URL 설정

`DorayCompanion/Config.swift` 파일에서 서버 URL을 수정하세요:

```swift
struct Config {
    static let serverURL = "https://your-doray-server.com"
    // ...
}
```

### 3. Xcode에서 빌드

1. `DorayCompanion.xcodeproj` 파일을 Xcode로 열기
2. Apple ID로 로그인 (개발자 계정 필요)
3. Bundle Identifier 변경:
   - iOS 앱: `com.yourname.doraycompanion`
   - Watch 앱: `com.yourname.doraycompanion.watchkitapp`
4. 실제 기기 선택 후 빌드 및 실행

### 4. Apple Watch 페어링

- iPhone과 Apple Watch가 페어링되어 있어야 함
- Watch 앱은 자동으로 설치됨

## 📱 사용법

### Apple Watch 앱

1. Watch에서 DorayCompanion 앱 실행
2. **출근** 버튼 터치로 출근 기록
3. **퇴근** 버튼 터치로 퇴근 기록 (오후 6시 이후 활성화)
4. **상태** 버튼으로 실제 두레이 등록 시간 확인

### iPhone 앱

1. iPhone에서 DorayCompanion 앱 실행
2. 현재 시간과 출퇴근 상태 확인
3. 출근/퇴근 버튼으로 직접 기록
4. **실제 시간 조회** 버튼으로 두레이 서버 시간 확인

## 🏗 프로젝트 구조

```
DorayCompanion/
├── DorayCompanion/                 # iOS 앱
│   ├── DorayCompanionApp.swift    # 앱 진입점
│   ├── ContentView.swift          # iPhone UI
│   ├── WatchSessionManager.swift  # Watch-iPhone 통신 매니저
│   └── Config.swift               # 서버 설정
├── DorayCompanion Watch App/       # Apple Watch 앱
│   ├── DorayCompanionApp.swift    # Watch 앱 진입점
│   ├── ContentView.swift          # Watch UI
│   └── WatchSessionManager.swift  # Watch 통신 매니저
└── DorayCompanion.xcodeproj       # Xcode 프로젝트
```

## 🔧 주요 컴포넌트

### WatchSessionManager

- Watch ↔ iPhone 간 통신 담당
- 두레이 서버 API 호출
- UI 상태 관리

### Config

- 서버 URL 및 엔드포인트 관리
- 환경별 설정 분리

### ContentView

- SwiftUI 기반 사용자 인터페이스
- 실시간 시간 표시 및 버튼 상태 관리

## 🌐 API 연동

앱은 다음 API 엔드포인트를 사용합니다:

- `POST /check-in`: 출근 기록
- `POST /check-out`: 퇴근 기록
- `GET /actual-times`: 실제 두레이 등록 시간 조회

자세한 API 문서는 [doray-server README](../doray-server/README.md)를 참조하세요.

## 🔍 문제 해결

### Watch 앱이 설치되지 않는 경우

1. iPhone과 Watch가 정상적으로 페어링되어 있는지 확인
2. Watch에서 "자동 앱 설치" 활성화
3. iPhone Watch 앱에서 수동으로 DorayCompanion 설치

### 서버 연결 실패

1. `Config.swift`의 서버 URL 확인
2. 네트워크 연결 상태 확인
3. 서버가 정상적으로 실행 중인지 확인

### JSON 파싱 에러 (503 - Tunnel Unavailable)

iPhone 앱에서 "JSON text did not start with array or object" 에러가 발생하는 경우:

1. **원인**: localtunnel이 죽어서 503 HTML 에러 페이지가 반환됨
2. **해결**: localtunnel을 PM2로 백그라운드에서 안정적으로 실행

```bash
# localtunnel을 PM2로 백그라운드 실행
pm2 start lt --name "localtunnel" -- --port 3001 --subdomain bright-cloths-raise

# 상태 확인
pm2 status

# 로그 확인
pm2 logs localtunnel

# 재시작 (필요한 경우)
pm2 restart localtunnel

# 자동 시작 설정 (부팅 시)
pm2 save
pm2 startup
```

3. **테스트**: `curl https://bright-cloths-raise.loca.lt/health`로 정상 응답 확인

### Watch-iPhone 통신 문제

1. 두 기기가 같은 Wi-Fi 네트워크에 연결되어 있는지 확인
2. 앱을 완전히 종료 후 재실행
3. Watch와 iPhone 재부팅

### 개발자 모드 활성화 필요

iPhone에서 개발자 모드를 활성화해야 할 수 있습니다:

1. 설정 → 개인정보 보호 및 보안 → 개발자 모드
2. 개발자 모드 활성화 후 재부팅

## 📝 라이선스

이 프로젝트는 개인 사용을 위한 프로젝트입니다.

## 🤝 기여

버그 리포트나 기능 제안은 이슈로 등록해 주세요.
