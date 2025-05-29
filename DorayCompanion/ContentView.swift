//
//  ContentView.swift
//  DorayCompanion
//
//  Created by monthlykitchen on 5/23/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var session = WatchSessionManager.shared
    
    // 현재 시간이 오후 6시 이후인지 체크
    private var isAfter6PM: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 18
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("먼키")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("출퇴근 관리")
                .font(.title2)
                .foregroundColor(.secondary)
            
            // 출근/퇴근 시간 표시
            HStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("출근")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(session.checkInTime)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 8) {
                    Text("퇴근")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(session.checkOutTime)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // 상태 메시지
            if !session.statusMessage.isEmpty {
                Text(session.statusMessage)
                    .font(.body)
                    .foregroundColor(session.statusMessage.contains("❌") ? .red : .green)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // 버튼들
            VStack(spacing: 16) {
                Button(action: {
                    session.performCheckIn()
                }) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("출근")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    session.performCheckOut()
                }) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("퇴근")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isAfter6PM ? Color.red : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!isAfter6PM)
                
                Button(action: {
                    session.sendStatus()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("새로고침")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .onAppear {
            // 앱이 시작될 때 자동으로 두레이 상태 조회
            session.sendStatus()
        }
    }
}

#Preview {
    ContentView()
}
