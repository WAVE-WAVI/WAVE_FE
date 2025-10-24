//
//  ProgressRingView.swift
//  WAVI
//
//  Created by 박현빈 on 7/28/25.
//

import SwiftUI

struct ProgressRingView: View {
    @State private var currentTime = Date()
    let habits: [Habit]
    let currentCenterIndex: Int
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // 남은 목표 개수 계산 (ACTIVE 상태이면서 아직 시간이 남은 습관만)
    var remainingGoalsCount: Int {
        let remaining = habits.filter { habit in
            // ACTIVE 상태이면서
            guard habit.status == "ACTIVE" else { return false }
            
            // 남은 시간이 00:00이 아닌 습관만 (즉, 아직 수행할 시간이 있는 습관)
            return habit.remainingTime != "00:00"
        }.count
        
        return remaining
    }
    
    // 당일 목표가 있는지 확인 (오늘 요일에 해당하는 습관이 있는지)
    var hasTodayGoals: Bool {
        return !habits.isEmpty
    }
    
    // 모든 목표를 달성했는지 확인 (목표는 있지만 남은 것이 없는 경우)
    var allGoalsCompleted: Bool {
        return hasTodayGoals && remainingGoalsCount == 0
    }
    
    // 표시할 메시지 결정
    var displayMessage: String {
        if !hasTodayGoals {
            // 당일 목표가 아예 없는 경우 - 메시지 표시 안함
            return ""
        } else if remainingGoalsCount > 0 {
            // 목표가 있고 아직 달성할 것이 남은 경우
            return "앞으로 달성할 목표가 \(remainingGoalsCount)개 남았어요!"
        } else {
            // 목표는 있지만 모두 달성한 경우
            return "오늘의 목표를 모두 달성했어요!"
        }
    }
    
    // 현재 중앙 카드의 primaryColor
    var currentCenterCardPrimaryColor: String {
        guard currentCenterIndex < habits.count else {
            return "#DCA061" // 기본값
        }
        let currentHabit = habits[currentCenterIndex]
        return currentHabit.cardColor.primaryColor
    }
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            ZStack {
                // 배경 반원 (387x387)
                SemiCircle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(hex: "#F5F5F5"), location: 0.0),
                                .init(color: Color(hex: "#EAEAEA"), location: 0.5013)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 387, height: 387/2)
                
                // 진행률 바 위에 점들 배치 (아래 레이어)
                ProgressDots()
                    .fill(Color(hex: "#CDCDD0"))
                    .frame(width: 421, height: 421/2)
                
                // 진행률 반원 (421x421) (위 레이어)
                SemiCircle()
                    .trim(from: 0, to: calculateProgress())
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(hex: "#9B9BA1"), location: 0.0087),
                                .init(color: Color(hex: currentCenterCardPrimaryColor), location: 0.7778)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 421, height: 421/2)
                
                // 중앙 텍스트
                VStack(spacing: 8) {
                    Text("현재 시각")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#999999"))
                    
                    Text(formatTime(currentTime))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(hex: "#333333"))
                    
                    Text(displayMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#666666"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .offset(y: 30)
            }
            .frame(height: 250)
            .onReceive(timer) { _ in
                currentTime = Date()
            }
        }
    }
    
    // 현재 시간을 기반으로 진행률 계산 (0.0 ~ 1.0)
    private func calculateProgress() -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        let minute = calendar.component(.minute, from: currentTime)
        let second = calendar.component(.second, from: currentTime)
        
        // 12시간 단위로 계산 (0~11시 또는 12~23시)
        let hour12 = hour % 12
        
        // 시간을 초 단위로 변환 (0 ~ 43200초 = 12시간)
        let totalSeconds = Double(hour12 * 3600 + minute * 60 + second)
        
        // 12시간(43200초)을 1.0으로 정규화
        let progress = totalSeconds / 43200.0
        
        return progress
    }
    
    // 시간 포맷 (09:30)
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// 반원 Shape (똑바로 선 반원)
struct SemiCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = rect.width / 2
        
        // 반원 그리기 (왼쪽에서 시작해서 오른쪽으로, 위쪽 반원)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(180), // 왼쪽 시작
            endAngle: .degrees(0),      // 오른쪽 끝
            clockwise: false
        )
        
        return path
    }
}

// 진행률 바 위에 점들을 배치하는 Shape
struct ProgressDots: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = rect.width / 2
        
        // 반원의 가장 위쪽 지점(90도)을 기준으로 좌우로 6도씩 점들을 배치할 각도들을 생성합니다.
        // 예를 들어, 90도, 90-6=84도, 90+6=96도, 90-12=78도, 90+12=102도 ...
        // 0도(오른쪽 끝)와 180도(왼쪽 끝)까지 포함합니다.
        let angles: [Double] = {
            var result: [Double] = []
            // 가장 위쪽 점 (90도) 추가
            result.append(90.0)

            // 90도를 기준으로 좌우 대칭으로 6도씩 각도 추가
            for angleOffset in stride(from: 6.0, through: 90.0, by: 6.0) {
                result.append(90.0 - angleOffset) // 오른쪽으로 이동하는 각도 (예: 84, 78, ..., 0)
                result.append(90.0 + angleOffset) // 왼쪽으로 이동하는 각도 (예: 96, 102, ..., 180)
            }
            return result.sorted() // 각도를 오름차순으로 정렬 (필수는 아니지만 일관성을 위해)
        }()
        
        // 점들 그리기
        for angle in angles {
            // 반원의 호 위에 점의 위치 계산
            // center.y (rect.maxY)를 기준으로 위로 그려지는 반원이므로, y 좌표는 감소해야 합니다.
            // angle은 표준 극좌표계 각도 (0도=오른쪽, 90도=위쪽, 180도=왼쪽)
            let x = center.x + radius * cos(angle * .pi / 180)
            let y = center.y - radius * sin(angle * .pi / 180) // 위쪽으로 그려지도록 y 계산 수정
            
            path.addEllipse(in: CGRect(x: x - 2, y: y - 2, width: 8, height: 8))
        }
        
        return path
    }
}

#Preview {
    let sampleHabits = [
        Habit(id: 1, name: "물 마시기", status: "ACTIVE", dayOfWeek: [1,2,3], icon: "💧", startTime: "09:00:00", endTime: "10:00:00"),
        Habit(id: 2, name: "독서하기", status: "COMPLETED", dayOfWeek: [1,2,3], icon: "📚", startTime: "14:00:00", endTime: "15:00:00"),
        Habit(id: 3, name: "운동하기", status: "ACTIVE", dayOfWeek: [1,2,3], icon: "🏃", startTime: "18:00:00", endTime: "19:00:00")
    ]
    
    return ProgressRingView(habits: sampleHabits, currentCenterIndex: 0)
        .previewLayout(.sizeThatFits)
        .padding()
  
}


