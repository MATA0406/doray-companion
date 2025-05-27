import Foundation
import WatchConnectivity
import Combine

/// Watch Extension ↔ iOS Companion 통신 매니저
class WatchAppSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchAppSessionManager()
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
            print("⚠️ [Watch] WCSession not supported")
            return 
        }
        session.delegate = self
        session.activate()
    }

    /// iOS Companion에 컨텍스트 전송
    func send(action: String) {
        guard isSessionActivated else {
            DispatchQueue.main.async {
                self.statusMessage = "세션이 활성화되지 않음"
            }
            return
        }
        
        guard session.isReachable else {
            DispatchQueue.main.async {
                self.statusMessage = "iPhone과 연결되지 않음"
            }
            return
        }
        
        do {
            try session.updateApplicationContext(["action": action])
            DispatchQueue.main.async {
                self.statusMessage = "요청 전송 중..."
            }
        } catch {
            DispatchQueue.main.async {
                self.statusMessage = "통신 오류: \(error.localizedDescription)"
            }
        }
    }

    // MARK: — WCSessionDelegate

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        DispatchQueue.main.async {
            self.isSessionActivated = (activationState == .activated)
        }
        
        print("▶︎ [Watch] WCSession activated, state:", activationState.rawValue)
        if let error = error {
            print("❌ [Watch] Session activation error:", error)
            DispatchQueue.main.async {
                self.statusMessage = "세션 활성화 실패"
            }
        }
    }

    func session(_ session: WCSession,
                 didReceiveApplicationContext context: [String: Any]) {
        print("▶︎ [Watch] received context from iOS:", context)
        
        DispatchQueue.main.async {
            self.handleResponse(context)
        }
    }
    
    /// iOS로부터 받은 응답 처리
    private func handleResponse(_ context: [String: Any]) {
        guard let type = context["type"] as? String else {
            print("⚠️ [Watch] No type in response")
            return
        }
        
        let message = context["message"] as? String ?? ""
        let success = context["success"] as? Bool ?? false
        
        switch type {
        case "checkInResult":
            if success, let time = context["checkInTime"] as? String {
                self.checkInTime = time
                self.statusMessage = "✅ \(message)"
            } else {
                self.statusMessage = "❌ \(message)"
            }
            
        case "checkOutResult":
            if success, let time = context["checkOutTime"] as? String {
                self.checkOutTime = time
                self.statusMessage = "✅ \(message)"
            } else {
                self.statusMessage = "❌ \(message)"
            }
            
        case "statusResult":
            if let checkIn = context["checkInTime"] as? String {
                self.checkInTime = checkIn
            }
            if let checkOut = context["checkOutTime"] as? String {
                self.checkOutTime = checkOut
            }
            self.statusMessage = "📊 \(message)"
            
        default:
            print("⚠️ [Watch] Unknown response type:", type)
            self.statusMessage = "알 수 없는 응답"
        }
        
        // 3초 후 상태 메시지 초기화
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.statusMessage.contains("✅") || self.statusMessage.contains("❌") || self.statusMessage.contains("📊") {
                self.statusMessage = ""
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        print("▶︎ [Watch] Session reachability changed:", session.isReachable)
        DispatchQueue.main.async {
            if !session.isReachable {
                self.statusMessage = "iPhone 연결 끊어짐"
            }
        }
    }
}
