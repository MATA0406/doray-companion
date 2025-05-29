import Foundation
import WatchConnectivity
import Combine

/// 워치 ↔ iOS Companion 간 메시지를 받아 Doray 서버에 HTTP 호출을 수행하는 매니저
class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchSessionManager()
    private let session = WCSession.default
    
    @Published var checkInTime = "--:--"
    @Published var checkOutTime = "--:--"
    @Published var statusMessage = ""
    
    private var isSessionActivated = false

    private override init() {
        super.init()
        activateSession()
    }

    /// WCSession 활성화
    func activateSession() {
        guard WCSession.isSupported() else { 
            print("⚠️ [iOS] WCSession not supported")
            return 
        }
        session.delegate = self
        session.activate()
    }

    /// 워치로 메시지 전송
    private func sendToWatch(_ message: [String: Any]) {
        guard isSessionActivated else {
            print("⚠️ [iOS] Session not activated")
            return
        }
        
        guard session.isReachable else {
            print("⚠️ [iOS] Watch is not reachable")
            return
        }
        
        do {
            try session.updateApplicationContext(message)
            print("✅ [iOS] Sent to watch:", message)
        } catch {
            print("❌ [iOS] Failed to send to watch:", error)
        }
    }

    // MARK: — WCSessionDelegate

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        isSessionActivated = (activationState == .activated)
        print("▶︎ [iOS] WCSession activated, state:", activationState.rawValue)
        
        if let error = error {
            print("❌ [iOS] Session activation error:", error)
        }
    }

    func session(_ session: WCSession,
                 didReceiveApplicationContext context: [String: Any]) {
        print("▶︎ [iOS] [Watch → iOS] received context:", context)
        guard let action = context["action"] as? String else {
            print("⚠️ [iOS] No action in context")
            return
        }
        handleAction(action)
    }

    // MARK: — Action 처리

    private func handleAction(_ action: String) {
        switch action {
        case "checkIn":
            handleWatchCheckIn()
        case "checkOut":
            handleWatchCheckOut()
        case "fetchStatus":
            handleWatchStatus()
        default:
            print("⚠️ [iOS] Unknown action:", action)
        }
    }

    // MARK: — Public Methods for iPhone UI
    
    /// iPhone UI에서 출근 버튼 클릭 시 호출
    func performCheckIn() {
        DispatchQueue.main.async {
            self.statusMessage = "출근 요청 중..."
        }
        
        print("▶︎ [iOS] performCheckIn() - 두레이 서버로 출근 요청")
        
        // 실제 두레이 서버 요청
        performServerRequest(
            endpoint: "/check-in",
            method: "POST",
            successMessage: "출근 완료",
            failureMessage: "출근 실패",
            resultType: "checkInResult",
            timeKey: "checkInTime"
        )
    }

    /// iPhone UI에서 퇴근 버튼 클릭 시 호출
    func performCheckOut() {
        DispatchQueue.main.async {
            self.statusMessage = "퇴근 요청 중..."
        }
        
        print("▶︎ [iOS] performCheckOut() - 두레이 서버로 퇴근 요청")
        
        // 실제 두레이 서버 요청
        performServerRequest(
            endpoint: "/check-out",
            method: "POST",
            successMessage: "퇴근 완료",
            failureMessage: "퇴근 실패",
            resultType: "checkOutResult",
            timeKey: "checkOutTime"
        )
    }

    /// iPhone UI에서 상태 새로고침 버튼 클릭 시 호출
    func sendStatus() {
        DispatchQueue.main.async {
            self.statusMessage = "실제 출퇴근 시간 조회 중..."
        }
        
        print("▶︎ [iOS] sendStatus() - 실제 두레이 출퇴근 시간 조회")
        
        guard let url = URL(string: Config.url(for: Config.Endpoint.actualTimes)) else { 
            updateUIWithError("잘못된 서버 URL")
            return 
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ [iOS] Actual times request failed:", error)
                self?.updateUIWithError("서버 연결 실패: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self?.updateUIWithError("서버 응답 데이터 없음")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                print("✅ [iOS] Actual times response:", json ?? "nil")
                
                if let success = json?["success"] as? Bool, success {
                    // 성공적인 응답 처리
                    let statusData = json?["data"] as? [String: Any]
                    let checkInTime = statusData?["checkInTime"] as? String ?? "--:--"
                    let checkOutTime = statusData?["checkOutTime"] as? String ?? "--:--"
                    
                    DispatchQueue.main.async {
                        // 실제 두레이 시간으로 업데이트
                        self?.checkInTime = checkInTime == "미등록" ? "--:--" : checkInTime
                        self?.checkOutTime = checkOutTime == "미등록" || checkOutTime == "-" ? "--:--" : checkOutTime
                        self?.statusMessage = "✅ 실제 출퇴근 시간 조회 완료"
                        
                        // 3초 후 메시지 초기화
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self?.statusMessage = ""
                        }
                    }
                } else {
                    // 서버에서 실패 응답
                    let errorMsg = json?["error"] as? String ?? "알 수 없는 오류"
                    self?.updateUIWithError("서버 오류: \(errorMsg)")
                }
            } catch {
                print("❌ [iOS] JSON parsing failed:", error)
                self?.updateUIWithError("응답 파싱 실패")
            }
        }.resume()
    }
    
    /// UI 에러 업데이트 헬퍼 메서드
    private func updateUIWithError(_ message: String) {
        DispatchQueue.main.async {
            self.statusMessage = "❌ \(message)"
            
            // 5초 후 메시지 초기화
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.statusMessage = ""
            }
        }
    }

    /// UI 정보 업데이트 헬퍼 메서드 (에러가 아닌 정보성 메시지용)
    private func updateUIWithInfo(_ message: String) {
        DispatchQueue.main.async {
            self.statusMessage = "ℹ️ \(message)"
            
            // 4초 후 메시지 초기화 (정보성 메시지는 조금 더 빨리)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.statusMessage = ""
            }
        }
    }
    
    /// 서버 에러 메시지를 친근한 메시지로 변환
    private func convertToFriendlyMessage(_ errorMessage: String, isCheckIn: Bool) -> String {
        let lowercaseError = errorMessage.lowercased()
        
        if isCheckIn {
            // 출근 관련 메시지
            if lowercaseError.contains("이미") && lowercaseError.contains("출근") {
                return "이미 출근 완료했어요! 😊"
            } else if lowercaseError.contains("비활성화") && lowercaseError.contains("출근") {
                return "오늘 출근은 이미 끝났어요 ✅"
            } else if lowercaseError.contains("찾을 수 없") && lowercaseError.contains("출근") {
                return "출근 버튼을 찾을 수 없어요 😅"
            } else {
                return "출근 처리 중 문제가 생겼어요"
            }
        } else {
            // 퇴근 관련 메시지
            if lowercaseError.contains("이미") && lowercaseError.contains("퇴근") {
                return "이미 퇴근 완료했어요! 😊"
            } else if lowercaseError.contains("비활성화") && lowercaseError.contains("퇴근") {
                return "오늘 퇴근은 이미 끝났어요 ✅"
            } else if lowercaseError.contains("찾을 수 없") && lowercaseError.contains("퇴근") {
                return "퇴근 버튼을 찾을 수 없어요 😅"
            } else {
                return "퇴근 처리 중 문제가 생겼어요"
            }
        }
    }

    // MARK: — Watch Communication (기존 private 메서드들)
    
    /// Watch에서 오는 액션 처리용 (기존 로직)
    private func handleWatchCheckIn() {
        print("▶︎ [iOS] handleWatchCheckIn() - Watch에서 출근 요청")
        
        // 실제 두레이 서버 요청
        performServerRequest(
            endpoint: "/check-in",
            method: "POST",
            successMessage: "출근 완료",
            failureMessage: "출근 실패",
            resultType: "checkInResult",
            timeKey: "checkInTime"
        )
    }

    private func handleWatchCheckOut() {
        print("▶︎ [iOS] handleWatchCheckOut() - Watch에서 퇴근 요청")
        
        // 실제 두레이 서버 요청
        performServerRequest(
            endpoint: "/check-out",
            method: "POST",
            successMessage: "퇴근 완료",
            failureMessage: "퇴근 실패",
            resultType: "checkOutResult",
            timeKey: "checkOutTime"
        )
    }

    private func handleWatchStatus() {
        print("▶︎ [iOS] handleWatchStatus() - Watch에서 실제 출퇴근 시간 조회 요청")
        
        guard let url = URL(string: Config.url(for: Config.Endpoint.actualTimes)) else { 
            sendErrorToWatch("잘못된 서버 URL")
            return 
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ [iOS] Actual times request failed:", error)
                self?.sendErrorToWatch("서버 연결 실패: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self?.sendErrorToWatch("서버 응답 데이터 없음")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                print("✅ [iOS] Watch actual times response:", json ?? "nil")
                
                if let success = json?["success"] as? Bool, success {
                    // 성공적인 응답 처리
                    let statusData = json?["data"] as? [String: Any]
                    let checkInTime = statusData?["checkInTime"] as? String ?? "--:--"
                    let checkOutTime = statusData?["checkOutTime"] as? String ?? "--:--"
                    
                    // 시간 포맷 정리
                    let displayCheckInTime = checkInTime == "미등록" ? "--:--" : checkInTime
                    let displayCheckOutTime = (checkOutTime == "미등록" || checkOutTime == "-") ? "--:--" : checkOutTime
                    
                    self?.sendToWatch([
                        "type": "statusResult",
                        "success": true,
                        "checkInTime": displayCheckInTime,
                        "checkOutTime": displayCheckOutTime,
                        "message": "실제 출퇴근 시간 조회 완료"
                    ])
                } else {
                    // 서버에서 실패 응답 - 에러 메시지 분석해서 친근한 메시지로 변환
                    let errorMsg = json?["error"] as? String ?? "알 수 없는 오류"
                    let friendlyMessage = self?.convertToFriendlyMessage(errorMsg, isCheckIn: false) ?? errorMsg
                    
                    // UI 업데이트 (iPhone 앱용)
                    self?.updateUIWithInfo(friendlyMessage)
                    
                    // Watch로 전송 (Watch 앱용)
                    self?.sendToWatch([
                        "type": "statusResult",
                        "success": false,
                        "message": friendlyMessage
                    ])
                }
            } catch {
                print("❌ [iOS] JSON parsing failed:", error)
                
                // 실제 시간 조회 실패 시에도 성공 메시지는 표시
                DispatchQueue.main.async {
                    self?.statusMessage = "✅ 실제 출퇴근 시간 조회 (시간 조회 실패)"
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self?.statusMessage = ""
                    }
                }
            }
        }.resume()
    }
    
    /// 서버 요청을 수행하는 공통 메서드
    private func performServerRequest(
        endpoint: String,
        method: String,
        successMessage: String,
        failureMessage: String,
        resultType: String,
        timeKey: String
    ) {
        guard let url = URL(string: Config.url(for: endpoint)) else { 
            sendErrorToWatch("잘못된 서버 URL")
            return 
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 요청 본문 (두레이 서버에서 필요한 경우)
        let body = ["timestamp": Date().timeIntervalSince1970]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("🚀 [iOS] 두레이 서버 요청: \(method) \(url)")
        
        URLSession.shared.dataTask(with: req) { [weak self] data, response, error in
            if let error = error {
                print("❌ [iOS] \(endpoint) request failed:", error)
                self?.sendToWatch([
                    "type": resultType,
                    "success": false,
                    "message": "\(failureMessage): \(error.localizedDescription)"
                ])
                
                // UI 업데이트 (iPhone 앱용)
                self?.updateUIWithError("\(failureMessage): \(error.localizedDescription)")
                return
            }
            
            // HTTP 상태 코드 확인
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [iOS] HTTP Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    self?.sendToWatch([
                        "type": resultType,
                        "success": false,
                        "message": "\(failureMessage): HTTP \(httpResponse.statusCode)"
                    ])
                    
                    // UI 업데이트 (iPhone 앱용)
                    self?.updateUIWithError("\(failureMessage): HTTP \(httpResponse.statusCode)")
                    return
                }
            }
            
            // 응답 데이터 처리
            guard let data = data else {
                self?.sendToWatch([
                    "type": resultType,
                    "success": false,
                    "message": "\(failureMessage): 응답 데이터 없음"
                ])
                
                // UI 업데이트 (iPhone 앱용)
                self?.updateUIWithError("\(failureMessage): 응답 데이터 없음")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                print("✅ [iOS] \(endpoint) response:", json ?? "nil")
                
                if let success = json?["success"] as? Bool, success {
                    // 출퇴근 처리 성공 후 실제 두레이 시간 조회
                    print("🔍 [iOS] \(successMessage) 완료, 실제 두레이 시간 조회 중...")
                    self?.fetchActualTimesAfterAction(
                        successMessage: successMessage,
                        resultType: resultType,
                        timeKey: timeKey
                    )
                } else {
                    // 서버에서 실패 응답 - 에러 메시지 분석해서 친근한 메시지로 변환
                    let errorMsg = json?["error"] as? String ?? "알 수 없는 오류"
                    let friendlyMessage = self?.convertToFriendlyMessage(errorMsg, isCheckIn: false) ?? errorMsg
                    
                    // UI 업데이트 (iPhone 앱용)
                    self?.updateUIWithInfo(friendlyMessage)
                    
                    // Watch로 전송 (Watch 앱용)
                    self?.sendToWatch([
                        "type": resultType,
                        "success": false,
                        "message": friendlyMessage
                    ])
                }
            } catch {
                print("❌ [iOS] JSON parsing failed:", error)
                
                // UI 업데이트 (iPhone 앱용)
                self?.updateUIWithError("\(failureMessage): 응답 파싱 실패")
                
                // Watch로 전송 (Watch 앱용)
                self?.sendToWatch([
                    "type": resultType,
                    "success": false,
                    "message": "\(failureMessage): 응답 파싱 실패"
                ])
            }
        }.resume()
    }
    
    /// 출퇴근 처리 후 실제 두레이 시간을 조회하는 메서드
    private func fetchActualTimesAfterAction(
        successMessage: String,
        resultType: String,
        timeKey: String
    ) {
        guard let url = URL(string: Config.url(for: Config.Endpoint.actualTimes)) else {
            updateUIWithError("실제 시간 조회 URL 오류")
            return
        }
        
        // 잠시 대기 후 조회 (두레이에 시간이 반영될 시간을 줌)
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    print("❌ [iOS] Actual times fetch failed:", error)
                    self?.updateUIWithError("실제 시간 조회 실패")
                    return
                }
                
                guard let data = data else {
                    self?.updateUIWithError("실제 시간 응답 데이터 없음")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    print("✅ [iOS] Actual times after action:", json ?? "nil")
                    
                    if let success = json?["success"] as? Bool, success {
                        let statusData = json?["data"] as? [String: Any]
                        let checkInTime = statusData?["checkInTime"] as? String ?? "--:--"
                        let checkOutTime = statusData?["checkOutTime"] as? String ?? "--:--"
                        
                        // 시간 포맷 정리
                        let displayCheckInTime = checkInTime == "미등록" ? "--:--" : checkInTime
                        let displayCheckOutTime = (checkOutTime == "미등록" || checkOutTime == "-") ? "--:--" : checkOutTime
                        
                        DispatchQueue.main.async {
                            // UI 업데이트 (iPhone 앱용) - 실제 두레이 시간으로 업데이트
                            self?.checkInTime = displayCheckInTime
                            self?.checkOutTime = displayCheckOutTime
                            self?.statusMessage = "✅ \(successMessage) (실제 시간 반영)"
                            
                            // 3초 후 메시지 초기화
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self?.statusMessage = ""
                            }
                        }
                        
                        // Watch로 전송 (Watch 앱용) - 실제 두레이 시간으로 전송
                        self?.sendToWatch([
                            "type": resultType,
                            "success": true,
                            "checkInTime": displayCheckInTime,
                            "checkOutTime": displayCheckOutTime,
                            "message": "\(successMessage) (실제 시간 반영)"
                        ])
                    } else {
                        // 실제 시간 조회 실패 시에도 성공 메시지는 표시
                        DispatchQueue.main.async {
                            self?.statusMessage = "✅ \(successMessage) (시간 조회 실패)"
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self?.statusMessage = ""
                            }
                        }
                    }
                } catch {
                    print("❌ [iOS] Actual times JSON parsing failed:", error)
                    
                    // 실제 시간 조회 실패 시에도 성공 메시지는 표시
                    DispatchQueue.main.async {
                        self?.statusMessage = "✅ \(successMessage) (시간 조회 실패)"
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self?.statusMessage = ""
                        }
                    }
                }
            }.resume()
        }
    }
    
    /// 에러 메시지를 워치로 전송하는 헬퍼 메서드
    private func sendErrorToWatch(_ message: String) {
        sendToWatch([
            "type": "error",
            "success": false,
            "message": message
        ])
    }

    // MARK: — 프로토콜 스텁

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("▶︎ [iOS] Session became inactive")
        isSessionActivated = false
    }
    
    func sessionDidDeactivate(_ session: WCSession) { 
        print("▶︎ [iOS] Session deactivated, reactivating...")
        isSessionActivated = false
        session.activate() 
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) { 
        print("▶︎ [iOS] Watch state changed")
    }
}
