import SwiftUI

@main
struct DorayCompanion_Watch_App_Watch_AppApp: App {
    // 워치 앱 시작 시 WCSession 활성화
    init() {
        WatchAppSessionManager.shared.activateSession()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()  // Watch용 UI
        }
    }
}
