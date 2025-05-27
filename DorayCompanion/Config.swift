import Foundation

/// 앱 설정 관리
struct Config {
    /// 서버 URL 설정
    /// 개발/배포 환경에 따라 변경
    static let serverURL = "https://bright-cloths-raise.loca.lt"
    
    /// API 엔드포인트들
    enum Endpoint {
        static let checkIn = "/check-in"
        static let checkOut = "/check-out" 
        static let status = "/status"
        static let actualTimes = "/actual-times"
        static let health = "/health"
    }
    
    /// 전체 URL 생성 헬퍼
    static func url(for endpoint: String) -> String {
        return serverURL + endpoint
    }
} 