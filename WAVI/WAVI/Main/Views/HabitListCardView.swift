import SwiftUI

struct HabitListCardView: View {
    // MARK: - Properties
    let habitName: String
    let timeRange: String
    let icon: String // 이모티콘
    let cardColor: CardColor
    let dayOfWeek: [Int] // 요일 배열 (1=월, 2=화, ..., 7=일)
    
    // 시간 분리
    var startTime: String {
        let components = timeRange.components(separatedBy: " - ")
        return components.first ?? ""
    }
    
    var endTime: String {
        let components = timeRange.components(separatedBy: " - ")
        return components.count > 1 ? components[1] : ""
    }
    
    // 요일 표시 문자열
    var dayOfWeekString: String {
        let weekDays = ["월", "화", "수", "목", "금", "토", "일"]
        let dayStrings = dayOfWeek.map { weekDays[$0 - 1] }
        return dayStrings.joined(separator: "·")
    }
    
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
        
        var textColor: String {
            switch self {
            case .card1: return "#4281B6"
            case .card2: return "#E9F5FF"
            case .card3: return "#715232"
            case .card4: return "#FFE9CE"
            case .card5: return "#6F8200"
            case .card6: return "#F7FFCB"
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
            
            
            
            
            
            // Center Section: Habit Details
            VStack(alignment: .leading, spacing: 0) {
                // 습관 이름을 위한 Spacer 추가
                Spacer()
                    .frame(height: 20)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(habitName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(hex: "#040415"))
                        .tracking(-0.5)
                        .lineSpacing(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        //.offset(y:10)
                    
                    Text(dayOfWeekString)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(hex: "#040415"))
                        .tracking(-0.5)
                        .lineSpacing(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, 14)
                .padding(.leading, 16)
                //.padding(.bottom, 1)
                HStack{
                    Text(icon)
                        .font(.system(size: 18))
                        .padding(.leading, 18)
                        //.padding(.trailing, 20)
                        .padding(.bottom,10)
                     
                    Spacer()
                    
                    // 시간 표시 (시작시간 + 종료시간)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        // 시작시간
                        Text(startTime)
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundColor(Color(hex: cardColor.textColor))
                            .lineLimit(1)
                        
                        // 종료시간
                        Text("-\(endTime)")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: cardColor.textColor))
                            .lineLimit(1)
                            .padding(.leading, 4)
                    }
                    .padding(.trailing, 16) // 카드 끝에서 16픽셀 차이
                    .padding(.bottom, 21) // 카드 하단에서 21픽셀 차이
                }
            }
        }
        .frame(width: 351, height: 122)

    }
    
}


#Preview {
    VStack(spacing: 16) {
        ForEach(HabitListCardView.CardColor.allCases, id: \.self) { color in
            HabitListCardView(
                habitName: "따뜻한 물 1L 마시기",
                timeRange: "09:30 - 10:00",
                icon: "💧",
                cardColor: color,
                dayOfWeek: [1, 3, 5] // 월, 수, 금
            )
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

