import SwiftUI

@main
struct DorayCompanionApp: App {
    // 앱 시작 시 WatchConnectivity 세션을 활성화합니다.
    init() {
        WatchSessionManager.shared.activateSession()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()  // iOS UI (있어도 되고 없어도 무방)
        }
    }
}
