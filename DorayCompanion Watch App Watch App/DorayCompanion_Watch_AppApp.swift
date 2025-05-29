import SwiftUI

@main
struct DorayCompanion_Watch_App_Watch_AppApp: App {
    @State private var showLaunchScreen = true
    
    // 워치 앱 독립 실행 초기화
    init() {
        print("🚀 [Watch] 독립 워치앱 시작")
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    WatchLaunchScreen()
                        .transition(.opacity)
                        .onAppear {
                            // 2초 후 메인 화면으로 전환 (워치는 조금 더 빠르게)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeInOut(duration: 0.6)) {
                                    showLaunchScreen = false
                                }
                            }
                        }
                } else {
                    ContentView()  // Watch용 UI
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: showLaunchScreen)
        }
    }
}
