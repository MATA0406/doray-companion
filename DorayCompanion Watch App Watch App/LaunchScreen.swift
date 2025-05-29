import SwiftUI

struct WatchLaunchScreen: View {
    var body: some View {
        ZStack {
            // 배경
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                // 앱 로고 (첨부 이미지와 동일한 디자인, 워치용)
                ZStack {
                    // 오렌지색 원형 배경
                    Circle()
                        .fill(Color(red: 1.0, green: 0.4, blue: 0.0))  // 순수 오렌지색
                        .frame(width: 60, height: 60)
                        .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    // 검은색 "M" 글자 중앙 배치 (워치용 작은 크기)
                    Text("M")
                        .font(.system(size: 24, weight: .black, design: .default))
                        .foregroundColor(.black)
                }
                
                // 앱 이름 (워치용 간소화)
                Text("Doray")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                Text("출퇴근")
                    .font(.system(size: 10))
                    .foregroundColor(.black)
            }
        }
    }
} 