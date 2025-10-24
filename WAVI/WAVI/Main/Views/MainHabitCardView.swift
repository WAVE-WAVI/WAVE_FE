import SwiftUI

struct MainHabitCardView: View {
    // MARK: - Properties
    let habit: Habit
    let cardColor: CardColor
    
    // MARK: - State for animations and interactions
    @Binding var dragOffset: CGFloat
    @Binding var isShowingSuccessAnimation: Bool
    @Binding var isShowingFailureAnimation: Bool
    @Binding var successPercentage: String
    @Binding var failurePercentage: String
    
    // MARK: - Services
    private let habitLogService: HabitLogServicing = BackendHabitLogService()
    
    // MARK: - Callbacks
    let onSuccess: (Int) -> Void
    let onFailure: (Int) -> Void
    
    // MARK: - Card Colors Enum
    enum CardColor: CaseIterable {
        case card1
        case card2
        case card3
        case card4
        case card5
        case card6
        
        var imageName: String {
            switch self {
            case .card1: return "Card - 1"
            case .card2: return "Card - 2"
            case .card3: return "Card - 3"
            case .card4: return "Card - 4"
            case .card5: return "Card - 5"
            case .card6: return "Card - 6"
            }
        }
        
        // 각 카드의 고유 색상 (사용자가 수정 가능)
        
        var textColor: String {
            switch self {
            case .card1: return "#4281B6" // 진한
            case .card2: return "#E9F5FF" // 진한
            case .card3: return "#715232" // 진한
            case .card4: return "#FFE9CE" // 진한
            case .card5: return "#6F8200" // 진한
            case .card6: return "#F7FFCB" // 진한
            }
        }
        
        var primaryColor: String {
            switch self {
            case .card1: return "#9BCBF4" //
            case .card2: return "#4281B6" //
            case .card3: return "#DCA061" //
            case .card4: return "#715232" //
            case .card5: return "#A3B72D" //
            case .card6: return "#576600" // 
            }
        }
        
        var backgroundColor: String {
            switch self {
            case .card1: return "#E3F2FD" // 밝은 파란 배경
            case .card2: return "#E8F5E9" // 밝은 초록 배경
            case .card3: return "#FFF3E0" // 밝은 주황 배경
            case .card4: return "#F3E5F5" // 밝은 보라 배경
            case .card5: return "#FCE4EC" // 밝은 핑크 배경
            case .card6: return "#E0F2F1" // 밝은 청록 배경
            }
        }
        
        
        var accentColor: String {
            switch self {
            case .card1: return "#9BCBF4"
            case .card2: return "#81C784"
            case .card3: return "#FFB74D"
            case .card4: return "#BA68C8"
            case .card5: return "#F06292"
            case .card6: return "#4DB6AC"
            }
        }
        
        var iconName: String {
            switch self {
            case .card1: return "drop.fill"
            case .card2: return "figure.pool.swim"
            case .card3: return "sun.max.fill"
            case .card4: return "laptopcomputer"
            case .card5: return "book.fill"
            case .card6: return "leaf.fill"
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background Card Image
            Image(cardColor.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 351, height: 122)
                .clipped()
                .cornerRadius(20)
                .scaleEffect(isShowingSuccessAnimation ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isShowingSuccessAnimation)
            
            // Success Animation Overlay
            if isShowingSuccessAnimation {
                ZStack {
                    // Background circle
//                    Circle()
//                        .fill(Color.green)
//                        .frame(width: 120, height: 120)
//                        .scaleEffect(isShowingSuccessAnimation ? 1.0 : 0.5)
//                        .opacity(isShowingSuccessAnimation ? 1.0 : 0.0)
                    
                    // Privacy & Security Image
                    Image("Privacy & Security")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .scaleEffect(isShowingSuccessAnimation ? 1.0 : 0.5)
                        .opacity(isShowingSuccessAnimation ? 1.0 : 0.0)
                }
                .animation(.spring(response: 1.0, dampingFraction: 0.8), value: isShowingSuccessAnimation)
            }
            
            // Main Content
            HStack {
                // Left Section: Habit Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#040415"))
                        .tracking(-0.5)
                        .lineSpacing(20)
                        .frame(width: 171, alignment: .leading)
                    
                    Text(habit.timeRange)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: cardColor.textColor))
                        .tracking(-0.5)
                        .lineSpacing(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // Icon - 왼쪽 하단에 위치
                    Text(habit.icon)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: cardColor.accentColor))
                        .offset(x:1)
                }
                .padding(.leading, 20)
                .padding(.vertical, 16)
                
                Spacer()
                
                // Right Section: Remaining Time or Success/Failure Percentage
                VStack(alignment: .trailing, spacing: 5) {
                    Spacer()
                    Spacer()
                    
                    if isShowingSuccessAnimation {
                        Text("100%")
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundColor(Color(hex: cardColor.textColor))
                            .lineSpacing(0)
                    } else if isShowingFailureAnimation {
                        Text("0%")
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundColor(Color(hex: "#EAECF0"))
                            .lineSpacing(0)
                    } else {
                        // DB에 저장된 상태에 따라 표시
                        if habit.isCompleted || habit.isFailed {
                            Text(habit.displayText)
                                .font(.system(size: 48, weight: .semibold))
                                .foregroundColor(Color(hex: habit.displayTextColor))
                                .lineSpacing(0)
                        } else {
                            Text("남은시간")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#FFFFFF"))
                                .tracking(-0.5)
                                .lineSpacing(20)
                            
                            Text(habit.displayText)
                                .font(.system(size: 48, weight: .semibold))
                                .foregroundColor(Color(hex: cardColor.textColor))
                                .lineSpacing(0)
                        }
                    }
                }
                .padding(.trailing, 20)
                .padding(.vertical, 16)
            }
            .frame(width: 351, height: 122)
        }
        .frame(width: 351, height: 122)
        .offset(x: dragOffset)
    }
    
    // MARK: - Private Methods
    private func handleSuccess() {
        // 성공 애니메이션 시작
        isShowingSuccessAnimation = true
        
        // 1초 애니메이션 + 2초 유지 = 총 3초 후 애니메이션 완료
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isShowingSuccessAnimation = false
            onSuccess(habit.id)
        }
        
        // 드래그 오프셋 리셋
        withAnimation(.spring()) {
            dragOffset = 0
        }
    }
    
}

#Preview {
    @State var dragOffset: CGFloat = 0
    @State var isShowingSuccessAnimation = false
    @State var isShowingFailureAnimation = false
    @State var successPercentage = ""
    @State var failurePercentage = ""
    
    let sampleHabit = Habit(
        id: 1,
        name: "따뜻한 물 1L 마시기",
        status: "ACTIVE",
        dayOfWeek: [1, 2, 3, 4, 5],
        icon: "💧",
        startTime: "09:30:00",
        endTime: "10:00:00"
    )
    
    return VStack(spacing: 16) {
        ForEach(MainHabitCardView.CardColor.allCases, id: \.self) { color in
            MainHabitCardView(
                habit: sampleHabit,
                cardColor: color,
                dragOffset: $dragOffset,
                isShowingSuccessAnimation: $isShowingSuccessAnimation,
                isShowingFailureAnimation: $isShowingFailureAnimation,
                successPercentage: $successPercentage,
                failurePercentage: $failurePercentage,
                onSuccess: { _ in print("Success!") },
                onFailure: { _ in print("Failure!") }
            )
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

