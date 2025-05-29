import SwiftUI

@main
struct DorayCompanionApp: App {
    @State private var showLaunchScreen = true
    
    // 앱 시작 시 WatchConnectivity 세션을 활성화합니다.
    init() {
        WatchSessionManager.shared.activateSession()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    LaunchScreen()
                        .transition(.opacity)
                        .onAppear {
                            // 2.5초 후 메인 화면으로 전환
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    showLaunchScreen = false
                                }
                            }
                        }
                } else {
                    ContentView()  // iOS UI (있어도 되고 없어도 무방)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.8), value: showLaunchScreen)
        }
    }
}
