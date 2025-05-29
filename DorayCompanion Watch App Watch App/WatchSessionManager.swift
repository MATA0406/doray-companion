import Foundation
import WatchConnectivity
import Combine

/// Watch Extension 독립 통신 매니저 (서버 직접 통신)
class WatchAppSessionManager: NSObject, ObservableObject {
    static let shared = WatchAppSessionManager()
    
    @Published var checkInTime = "--:--"
    @Published var checkOutTime = "--:--"
    @Published var statusMessage = ""

    private override init() {
        super.init()
        print("📱 [Watch] Independent session manager initialized")
    }

    /// 워치에서 서버로 직접 통신
    func send(action: String) {
        print("🔄 [Watch] Sending direct action: \(action)")
        
        DispatchQueue.main.async {
            self.statusMessage = "워치에서 직접 요청 중..."
        }
        
        switch action {
        case "checkIn":
            performDirectCheckIn()
        case "checkOut":
            performDirectCheckOut()
        case "fetchStatus":
            performDirectStatus()
        default:
            DispatchQueue.main.async {
                self.statusMessage = "❌ 알 수 없는 액션: \(action)"
            }
        }
    }
    
    /// 워치에서 직접 출근 처리
    private func performDirectCheckIn() {
        guard let url = URL(string: Config.url(for: Config.Endpoint.checkIn)) else {
            updateStatusMessage("❌ 잘못된 서버 URL")
            return
        }
        
        performDirectServerRequest(
            url: url,
            method: "POST",
            successMessage: "출근 완료 (워치 직접)",
            failureMessage: "출근 실패",
            updateCheckInTime: true
        )
    }
    
    /// 워치에서 직접 퇴근 처리
    private func performDirectCheckOut() {
        guard let url = URL(string: Config.url(for: Config.Endpoint.checkOut)) else {
            updateStatusMessage("❌ 잘못된 서버 URL")
            return
        }
        
        performDirectServerRequest(
            url: url,
            method: "POST",
            successMessage: "퇴근 완료 (워치 직접)",
            failureMessage: "퇴근 실패",
            updateCheckInTime: false
        )
    }
    
    /// 워치에서 직접 상태 조회
    private func performDirectStatus() {
        guard let url = URL(string: Config.url(for: Config.Endpoint.actualTimes)) else {
            updateStatusMessage("❌ 잘못된 서버 URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ [Watch] Direct status request failed:", error)
                self?.updateStatusMessage("❌ 서버 연결 실패 (워치 직접)")
                return
            }
            
            guard let data = data else {
                self?.updateStatusMessage("❌ 서버 응답 없음")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                print("✅ [Watch] Direct status response:", json ?? "nil")
                
                if let success = json?["success"] as? Bool, success {
                    let statusData = json?["data"] as? [String: Any]
                    let checkInTime = statusData?["checkInTime"] as? String ?? "--:--"
                    let checkOutTime = statusData?["checkOutTime"] as? String ?? "--:--"
                    
                    DispatchQueue.main.async {
                        self?.checkInTime = checkInTime == "미등록" ? "--:--" : checkInTime
                        self?.checkOutTime = (checkOutTime == "미등록" || checkOutTime == "-") ? "--:--" : checkOutTime
                        self?.statusMessage = "✅ 상태 조회 완료 (워치 직접)"
                        
                        // 3초 후 메시지 초기화
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self?.statusMessage = ""
                        }
                    }
                } else {
                    let errorMsg = json?["error"] as? String ?? "알 수 없는 오류"
                    self?.updateStatusMessage("❌ 서버 오류: \(errorMsg)")
                }
            } catch {
                print("❌ [Watch] JSON parsing failed:", error)
                self?.updateStatusMessage("❌ 응답 파싱 실패")
            }
        }.resume()
    }
    
    /// 직접 서버 요청 수행 (출근/퇴근용)
    private func performDirectServerRequest(
        url: URL,
        method: String,
        successMessage: String,
        failureMessage: String,
        updateCheckInTime: Bool
    ) {
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 요청 본문
        let body = ["timestamp": Date().timeIntervalSince1970]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("🚀 [Watch] Direct server request: \(method) \(url)")
        
        URLSession.shared.dataTask(with: req) { [weak self] data, response, error in
            if let error = error {
                print("❌ [Watch] Direct request failed:", error)
                self?.updateStatusMessage("❌ 서버 연결 실패")
                return
            }
            
            // HTTP 상태 코드 확인
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [Watch] HTTP Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    self?.updateStatusMessage("❌ 서버 오류 (HTTP \(httpResponse.statusCode))")
                    return
                }
            }
            
            guard let data = data else {
                self?.updateStatusMessage("❌ 서버 응답 없음")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                print("✅ [Watch] Direct request response:", json ?? "nil")
                
                if let success = json?["success"] as? Bool, success {
                    // 성공 후 실제 시간 조회
                    self?.fetchActualTimesAfterDirectAction(
                        successMessage: successMessage,
                        updateCheckInTime: updateCheckInTime
                    )
                } else {
                    // 서버에서 실패 응답 - 에러 메시지 분석해서 친근한 메시지로 변환
                    let errorMsg = json?["error"] as? String ?? "알 수 없는 오류"
                    let friendlyMessage = self?.convertToFriendlyMessage(errorMsg, isCheckIn: updateCheckInTime) ?? errorMsg
                    self?.updateStatusMessage("ℹ️ \(friendlyMessage)")
                }
            } catch {
                print("❌ [Watch] JSON parsing failed:", error)
                self?.updateStatusMessage("❌ 응답 처리 실패")
            }
        }.resume()
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
    
    /// 직접 액션 후 실제 시간 조회
    private func fetchActualTimesAfterDirectAction(successMessage: String, updateCheckInTime: Bool) {
        guard let url = URL(string: Config.url(for: Config.Endpoint.actualTimes)) else {
            updateStatusMessage("❌ 실제 시간 조회 URL 오류")
            return
        }
        
        // 2초 대기 후 조회 (서버 반영 시간)
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    print("❌ [Watch] Actual times fetch failed:", error)
                    self?.updateStatusMessage("✅ \(successMessage) (시간 조회 실패)")
                    return
                }
                
                guard let data = data else {
                    self?.updateStatusMessage("✅ \(successMessage) (시간 조회 실패)")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    print("✅ [Watch] Actual times after direct action:", json ?? "nil")
                    
                    if let success = json?["success"] as? Bool, success {
                        let statusData = json?["data"] as? [String: Any]
                        let checkInTime = statusData?["checkInTime"] as? String ?? "--:--"
                        let checkOutTime = statusData?["checkOutTime"] as? String ?? "--:--"
                        
                        DispatchQueue.main.async {
                            self?.checkInTime = checkInTime == "미등록" ? "--:--" : checkInTime
                            self?.checkOutTime = (checkOutTime == "미등록" || checkOutTime == "-") ? "--:--" : checkOutTime
                            self?.statusMessage = "✅ \(successMessage) (실제 시간 반영)"
                            
                            // 3초 후 메시지 초기화
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self?.statusMessage = ""
                            }
                        }
                    } else {
                        self?.updateStatusMessage("✅ \(successMessage) (시간 조회 실패)")
                    }
                } catch {
                    print("❌ [Watch] Actual times JSON parsing failed:", error)
                    self?.updateStatusMessage("✅ \(successMessage) (시간 조회 실패)")
                }
            }.resume()
        }
    }
    
    /// 상태 메시지 업데이트 헬퍼
    private func updateStatusMessage(_ message: String) {
        DispatchQueue.main.async {
            self.statusMessage = message
            
            // 5초 후 메시지 초기화 (에러 메시지의 경우)
            if message.contains("❌") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.statusMessage = ""
                }
            }
        }
    }
}
