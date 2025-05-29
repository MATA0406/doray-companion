import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            // 배경 - 간소화
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // 앱 로고 (첨부 이미지와 동일한 디자인)
                VStack(spacing: 12) {
                    ZStack {
                        // 오렌지색 원형 배경
                        Circle()
                            .fill(Color(red: 1.0, green: 0.4, blue: 0.0))  // 순수 오렌지색
                            .frame(width: 120, height: 120)
                            .shadow(color: .orange.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        // 검은색 "M" 글자 중앙 배치d
                        Text("M")
                            .font(.system(size: 48, weight: .black, design: .default))
                            .foregroundColor(.black)
                    }
                    
                    // 앱 이름
                    Text("DorayCompanion")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("출퇴근 관리")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // 하단 로딩 표시
                VStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.orange)
                    
                    Text("로딩 중...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 50)
            }
        }
    }
} 