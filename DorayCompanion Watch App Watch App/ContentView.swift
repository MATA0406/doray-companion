import SwiftUI

struct ContentView: View {
  @ObservedObject private var session = WatchAppSessionManager.shared
  
  // 현재 시간이 오후 6시 이후인지 체크
  private var isAfter6PM: Bool {
    let calendar = Calendar.current
    let currentHour = calendar.component(.hour, from: Date())
    return currentHour >= 18
  }
  
  // 현재 시간이 출근 시간(8:00-9:30)인지 체크
  private var isWorkTime: Bool {
    let now = Date()
    let hour = Calendar.current.component(.hour, from: now)
    let minute = Calendar.current.component(.minute, from: now)
    return hour == 8 || (hour == 9 && minute <= 30)
  }

  private var statusMessage: String {
    let checkInTime = session.checkInTime
    let checkOutTime = session.checkOutTime
    
    if checkInTime != "--:--" {
      if checkOutTime != "--:--" {
        return "출근: \(checkInTime)\n퇴근: \(checkOutTime)"
      } else {
        return "출근: \(checkInTime)"
      }
    } else {
      return "출근 기록 없음"
    }
  }

  var body: some View {
    VStack(spacing: 10) {
      // 상태 표시
      VStack(spacing: 5) {
        Text("출퇴근 상태")
          .font(.headline)

        Text(statusMessage)
          .font(.caption)
          .multilineTextAlignment(.center)
          .lineLimit(3)
      }
      .padding(.horizontal)

      Spacer()

      VStack(spacing: 8) {
        // 출근 버튼
        Button(action: {
          session.send(action: "checkIn")
        }) {
          HStack {
            Image(systemName: "clock.arrow.circlepath")
            Text("출근")
          }
          .font(.caption)
          .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(.blue)

        // 퇴근 버튼
        Button(action: {
          session.send(action: "checkOut")
        }) {
          HStack {
            Image(systemName: "clock.arrow.circlepath")
            Text("퇴근")
          }
          .font(.caption)
          .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(isAfter6PM ? .red : .gray)
        .disabled(!isAfter6PM)

        // 서버 상태 표시
        Button(action: {
          session.send(action: "ping")
        }) {
          HStack {
            Image(systemName: "wifi")
            Text("서버 확인")
          }
          .font(.caption)
          .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(.green)
      }
      .padding(.horizontal)

      Spacer()

      // 알림 메시지
      if !session.statusMessage.isEmpty {
        Text(session.statusMessage)
          .font(.caption)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
      }
    }
    .padding(.vertical)
    .onAppear {
      // Watch 앱이 시작될 때 자동으로 두레이 상태 조회
      session.send(action: "fetchStatus")
    }
  }
}

#Preview {
    ContentView()
}
