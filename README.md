# 🕰️ DorayCompanion

> **Smart Attendance Tracking System for iOS & Apple Watch**  
> Swift/SwiftUI 기반의 Dooray 출퇴근 관리 솔루션 - iPhone과 Apple Watch의 원활한 동기화를 통한 스마트 근태 관리

[![iOS](https://img.shields.io/badge/iOS-18.2+-007AFF?style=flat&logo=ios&logoColor=white)](https://developer.apple.com/ios/)
[![watchOS](https://img.shields.io/badge/watchOS-11.2+-007AFF?style=flat&logo=apple&logoColor=white)](https://developer.apple.com/watchos/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-FA7343?style=flat&logo=swift&logoColor=white)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0+-007AFF?style=flat&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)

## 📖 프로젝트 개요

DorayCompanion은 **Dooray 근태 관리 시스템과의 API 연동**을 통해 iPhone과 Apple Watch에서 **실시간 출퇴근 기록**을 제공하는 네이티브 앱입니다. WatchConnectivity 프레임워크를 활용한 기기 간 **무결절 동기화**와 **독립적인 서버 통신** 기능을 구현했습니다.

### 🎯 핵심 특징

- **🔄 실시간 양방향 동기화**: iPhone ↔ Apple Watch 간 WatchConnectivity 기반 실시간 데이터 동기화
- **🌐 RESTful API 연동**: Dooray 서버와의 완전한 API 통합 (출근/퇴근/상태조회)
- **⌚ Watch 독립 실행**: Apple Watch만으로도 완전한 출퇴근 관리 가능
- **🎨 네이티브 SwiftUI**: 최신 SwiftUI 기반의 직관적이고 반응형 UI
- **🛡️ 스마트 검증**: 퇴근 시간 제한(오후 6시 이후), 실시간 상태 검증
- **📱 Universal Design**: iPhone 및 Apple Watch 최적화 UI/UX

---

## 🛠 기술 스택 & 아키텍처

### **Core Technologies**

```
• Language: Swift 5.9+
• UI Framework: SwiftUI 4.0+
• Connectivity: WatchConnectivity
• Networking: URLSession + Async/Await
• Architecture: MVVM + ObservableObject
• State Management: Combine Framework
```

### **Platform Support**

```
• iOS: 18.2+ (iPhone)
• watchOS: 11.2+ (Apple Watch Series 4+)
• Xcode: 16.0+
• Deployment Target: iOS 18.2, watchOS 11.2
```

### **시스템 아키텍처**

```
┌─────────────────┐    WatchConnectivity    ┌──────────────────┐
│   Apple Watch   │ ◄────────────────────► │   iPhone App     │
│   (독립 실행)    │                         │   (Session Hub)  │
└─────────────────┘                         └──────────────────┘
         │                                            │
         │ RESTful API                               │ RESTful API
         ▼                                            ▼
┌────────────────────────────────────────────────────────────────┐
│                    Dooray Server                               │
│                (출퇴근 API & 상태 관리)                          │
└────────────────────────────────────────────────────────────────┘
```

---

## 🚀 주요 기능

### 💼 **출퇴근 관리**

- **스마트 출근/퇴근 기록**: 터치 한 번으로 Dooray 서버에 즉시 등록
- **실시간 상태 동기화**: iPhone ↔ Watch 간 실시간 상태 업데이트
- **시간 기반 제어**: 퇴근은 오후 6시 이후에만 활성화
- **실제 시간 조회**: Dooray 서버에서 실제 등록된 출퇴근 시간 확인

### 📱 **멀티플랫폼 지원**

- **iPhone App**: 메인 허브 역할, 상세한 정보 표시 및 관리
- **Apple Watch App**: 독립 실행 가능, 빠른 출퇴근 기록
- **Universal Sync**: 어느 기기에서 기록해도 즉시 동기화

### 🔧 **개발자 친화적 구조**

- **Modular Architecture**: Config, Session Manager, UI 분리
- **Environment Configuration**: 개발/배포 환경별 설정 관리
- **Error Handling**: 종합적인 에러 처리 및 사용자 피드백
- **Logging System**: 디버깅을 위한 상세한 로깅

---

## 📋 시스템 요구사항

### **최소 요구사항**

- **iOS**: 18.2+ (iPhone)
- **watchOS**: 11.2+ (Apple Watch Series 4+)
- **Xcode**: 16.0+ (개발 시)
- **Network**: Dooray 서버 접근 가능한 인터넷 연결

### **권장 환경**

- **Device**: iPhone 14+ & Apple Watch Series 7+
- **iOS**: 최신 버전
- **Developer Account**: Apple Developer Program 가입 (실제 기기 테스트용)

---

## 🏗 프로젝트 구조

```
DorayCompanion/
├── 📱 DorayCompanion/                    # iOS App Target
│   ├── DorayCompanionApp.swift          # App 진입점 & 초기화
│   ├── ContentView.swift                # iPhone UI (SwiftUI)
│   ├── LaunchScreen.swift               # 스플래시 화면
│   ├── WatchSessionManager.swift        # Watch-iPhone 통신 매니저
│   ├── Config.swift                     # 서버 설정 & 환경 관리
│   └── Assets.xcassets/                 # iPhone 앱 아이콘 & 리소스
│       └── AppIcon.appiconset/          # 8가지 크기 아이콘
├── ⌚ DorayCompanion Watch App/          # watchOS App Target
│   ├── DorayCompanion_Watch_AppApp.swift # Watch App 진입점
│   ├── ContentView.swift                # Watch UI (SwiftUI)
│   ├── LaunchScreen.swift               # Watch 스플래시 화면
│   ├── WatchSessionManager.swift        # Watch 독립 통신 매니저
│   ├── Config.swift                     # Watch 전용 서버 설정
│   └── Assets.xcassets/                 # Watch 앱 아이콘 & 리소스
│       └── WatchAppIcon.appiconset/     # 11가지 크기 아이콘
└── 🛠 DorayCompanion.xcodeproj          # Xcode 프로젝트 파일
```

---

## 🔧 핵심 컴포넌트

### **📡 WatchSessionManager**

```swift
// iPhone & Watch 간 양방향 통신 및 서버 API 처리
class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    // WatchConnectivity 세션 관리
    // RESTful API 호출 (URLSession)
    // 실시간 상태 동기화 (@Published)
    // 에러 핸들링 및 사용자 피드백
}
```

### **⚙️ Config**

```swift
// 환경별 설정 관리 및 API 엔드포인트 정의
struct Config {
    static let serverURL = "https://your-dooray-server.com"
    // 또는 개발용: "https://your-tunnel.loca.lt"
}
```

### **🎨 SwiftUI Views**

```swift
// 반응형 UI 및 상태 기반 인터페이스
struct ContentView: View {
    @StateObject private var session = WatchSessionManager.shared
    // 실시간 시간 표시
    // 조건부 버튼 활성화
    // 상태 메시지 표시
}
```

---

## 🌐 API 연동

### **RESTful API Endpoints**

| Method | Endpoint        | Description         | Request | Response                             |
| ------ | --------------- | ------------------- | ------- | ------------------------------------ |
| `POST` | `/check-in`     | 출근 기록           | `{}`    | `{"success": true, "time": "09:00"}` |
| `POST` | `/check-out`    | 퇴근 기록           | `{}`    | `{"success": true, "time": "18:00"}` |
| `GET`  | `/actual-times` | 실제 등록 시간 조회 | -       | `{"success": true, "data": {...}}`   |
| `GET`  | `/health`       | 서버 상태 확인      | -       | `{"status": "ok"}`                   |

### **응답 데이터 구조**

```json
{
  "success": true,
  "data": {
    "checkInTime": "09:00:00",
    "checkOutTime": "18:30:00",
    "status": "active"
  },
  "timestamp": "2025-01-XX 18:30:00"
}
```

---

## 🚀 설치 및 실행

### **1. 환경 설정**

```bash
# 프로젝트 클론
git clone <repository-url>
cd DorayCompanion

# Xcode에서 프로젝트 열기
open DorayCompanion.xcodeproj
```

### **2. 서버 설정**

`DorayCompanion/Config.swift` 및 `DorayCompanion Watch App/Config.swift`에서 서버 URL을 설정:

```swift
struct Config {
    static let serverURL = "https://your-dooray-server.com"
    // 또는 개발용: "https://your-tunnel.loca.lt"
}
```

### **3. 프로젝트 설정**

1. **Apple Developer Account** 연결
2. **Bundle Identifier** 수정:
   - iOS: `com.yourname.doraycompanion`
   - Watch: `com.yourname.doraycompanion.watchkitapp`
3. **Signing & Capabilities** 설정
4. **Target Device** 선택 (실제 iPhone + Watch 권장)

### **4. 빌드 & 실행**

```bash
# Xcode에서 빌드 (⌘+B)
# 실제 기기에 설치 후 테스트 권장
```

---

## 📱 사용법

### **iPhone App**

1. 📱 앱 실행 → 현재 상태 자동 조회
2. 🔵 **출근** 버튼 → 즉시 Dooray 서버에 출근 기록
3. 🔴 **퇴근** 버튼 → 오후 6시 이후 활성화, 퇴근 기록
4. 🔄 **새로고침** → Dooray 서버에서 실제 등록 시간 조회

### **Apple Watch App**

1. ⌚ Watch에서 DorayCompanion 앱 실행
2. 🔵 **출근** / 🔴 **퇴근** → 터치 한 번으로 즉시 기록
3. 📊 **상태** → 현재 출퇴근 상태 및 시간 확인
4. 📱 iPhone과 자동 동기화

---

## 🔧 고급 기능

### **🔄 실시간 동기화**

- **WatchConnectivity**: `updateApplicationContext()` 사용
- **Bidirectional Sync**: iPhone ↔ Watch 양방향 데이터 동기화
- **State Management**: Combine + @Published를 통한 반응형 상태 관리

### **⚡ 독립 실행**

- **Watch Independent**: Apple Watch만으로도 완전한 기능 수행
- **Direct API Call**: Watch에서 직접 서버 API 호출
- **Fallback Mechanism**: iPhone 연결 없이도 정상 동작

### **🛡️ 에러 핸들링**

- **Network Retry**: 네트워크 오류 시 자동 재시도
- **User Feedback**: 실시간 상태 메시지 및 에러 알림
- **Graceful Degradation**: 서버 연결 실패 시에도 UI 정상 동작

---

## 🔍 문제 해결

### **일반적인 문제들**

<details>
<summary><strong>🔴 JSON 파싱 에러 (503 - Tunnel Unavailable)</strong></summary>

**증상**: "JSON text did not start with array or object" 에러

**원인**: localtunnel 서비스 중단으로 HTML 에러 페이지 반환

**해결책**:

```bash
# PM2로 localtunnel 안정적 실행
pm2 start lt --name "localtunnel" -- --port 3001 --subdomain bright-cloths-raise
pm2 save
pm2 startup

# 상태 확인
curl https://bright-cloths-raise.loca.lt/health
```

</details>

<details>
<summary><strong>⌚ Watch 앱 설치 안됨</strong></summary>

**해결책**:

1. iPhone-Watch 페어링 확인
2. Watch 앱에서 "자동 앱 설치" 활성화
3. Watch에서 수동 설치: 앱 스토어 → DorayCompanion 검색
</details>

<details>
<summary><strong>🔗 Watch-iPhone 통신 안됨</strong></summary>

**해결책**:

1. 같은 Wi-Fi 네트워크 연결 확인
2. 두 앱 모두 완전 종료 후 재실행
3. 필요시 기기 재부팅
</details>

<details>
<summary><strong>🔧 개발자 모드 활성화</strong></summary>

iPhone에서 개발자 모드 활성화 필요:

```
설정 → 개인정보 보호 및 보안 → 개발자 모드 → 활성화 → 재부팅
```

</details>

---

## 🎯 기술적 하이라이트

### **아키텍처 패턴**

- **MVVM Architecture**: Model-View-ViewModel 분리로 테스트 가능한 코드
- **Dependency Injection**: 싱글톤 패턴을 통한 효율적인 리소스 관리
- **Observer Pattern**: Combine을 활용한 반응형 프로그래밍

### **성능 최적화**

- **Async/Await**: 최신 Swift Concurrency로 비동기 처리
- **Memory Management**: ARC 기반 자동 메모리 관리
- **State Optimization**: @StateObject와 @ObservableObject를 통한 효율적인 상태 관리

### **보안 & 안정성**

- **HTTPS 통신**: 모든 API 호출 시 SSL/TLS 암호화
- **Input Validation**: 서버 응답 검증 및 안전한 파싱
- **Error Recovery**: 네트워크 실패 시 사용자 친화적인 에러 처리

---

## 📊 프로젝트 통계

```
• Total Lines of Code: ~1,000+ lines
• Swift Files: 10개 (iOS 5개 + Watch 5개)
• UI Components: 4개 (ContentView, LaunchScreen × 2)
• API Endpoints: 4개 (출근/퇴근/조회/헬스체크)
• Icon Assets: 19개 (iPhone 8개 + Watch 11개)
• Supported Platforms: 2개 (iOS, watchOS)
```

---

## 🏆 개발 성과

### **기술적 도전과 해결**

- ✅ **Cross-Platform Sync**: WatchConnectivity를 통한 실시간 동기화 구현
- ✅ **Independent Architecture**: Watch 독립 실행을 위한 이중 통신 구조
- ✅ **Modern UI**: SwiftUI 기반 반응형 인터페이스 설계
- ✅ **API Integration**: RESTful API 완전 연동 및 에러 핸들링
- ✅ **Production Ready**: 앱 아이콘, 스플래시 화면 등 출시 준비 완료

### **학습한 기술들**

- **WatchConnectivity Framework**: Watch-iPhone 간 통신
- **SwiftUI Advanced**: @StateObject, @Published, Combine
- **URLSession & Async/Await**: 모던 네트워킹
- **Multi-Target Project**: iOS + watchOS 동시 개발
- **Asset Management**: 멀티플랫폼 아이콘 및 리소스 관리

---

## 📝 향후 개선 계획

- [ ] **푸시 알림**: 출퇴근 리마인더 및 상태 알림
- [ ] **위젯 지원**: iOS 위젯을 통한 빠른 상태 확인
- [ ] **다크 모드**: 시스템 테마 대응
- [ ] **로컬 데이터**: Core Data를 통한 오프라인 캐싱
- [ ] **통계 기능**: 주간/월간 출퇴근 통계 및 차트

---

## 📄 라이선스

이 프로젝트는 **개인 포트폴리오용**으로 제작되었습니다.

---

**기술 스택 전문성**: Swift, SwiftUI, WatchConnectivity, RESTful API, iOS/watchOS 개발  
**프로젝트 특징**: 실무 레벨의 멀티플랫폼 앱 개발, 실시간 동기화, 독립적인 Watch 앱 구현
