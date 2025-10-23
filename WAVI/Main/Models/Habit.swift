//
//  Habit.swift
//  WAVI
//
//  Created by 박현빈 on 7/28/25.
//

import Foundation

// MARK: - Habit Model
struct Habit: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let status: String // "ACTIVE", "COMPLETED", "DEACTIVE"
    let dayOfWeek: [Int] // 요일 배열 (0:일~6:토)
    let icon: String // 이모티콘 (API에서는 문자열)
    let startTime: String // 시작 시간 (예: "12:00:00")
    let endTime: String // 종료 시간 (예: "12:30:00")
    
    // Coding Keys for API mapping
    enum CodingKeys: String, CodingKey {
        case id, name, status, icon, startTime, endTime, dayOfWeek
    }
    
    // Hashable 구현
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable 구현 (Hashable이 Equatable을 상속받음)
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Computed Properties
    var timeRange: String {
        // "12:00:00" -> "12:00" 형태로 변환
        let start = String(startTime.prefix(5))
        let end = String(endTime.prefix(5))
        return "\(start) - \(end)"
    }
    
    // 오늘 요일에 해당하는지 확인
    var isTodayHabit: Bool {
        let calendar = Calendar.current
        let today = Date()
        let todayWeekday = calendar.component(.weekday, from: today)
        
        // Swift의 weekday: 1=일, 2=월, 3=화, 4=수, 5=목, 6=금, 7=토
        // 서버의 dayOfWeek: 1=월, 2=화, 3=수, 4=목, 5=금, 6=토, 7=일
        
        // Swift weekday를 서버 형식으로 변환
        let serverWeekday = todayWeekday == 1 ? 7 : todayWeekday - 1
        
        return dayOfWeek.contains(serverWeekday)
    }
    
    var remainingTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        
        guard let start = formatter.date(from: startTime) else {
            return "00:00"
        }
        
        let now = Date()
        let calendar = Calendar.current
        
        // 오늘 날짜로 시작 시간 설정
        let todayStart = calendar.date(bySettingHour: calendar.component(.hour, from: start),
                                      minute: calendar.component(.minute, from: start),
                                      second: 0,
                                      of: now) ?? now
        
        // 수행해야하는 시간 - 현재시간 = 남은시간
        if now < todayStart {
            // 아직 수행 시간 전
            let interval = todayStart.timeIntervalSince(now)
            let hours = Int(interval) / 3600
            let minutes = Int(interval) % 3600 / 60
            return String(format: "%02d:%02d", hours, minutes)
        } else {
            // 수행 시간이 지났거나 진행 중
            return "00:00"
        }
    }
    
    var isActive: Bool {
        return status == "ACTIVE"
    }
    
    var isCompleted: Bool {
        return status == "COMPLETED"
    }
    
    var isFailed: Bool {
        return status == "FAILED" || status == "DEACTIVE"
    }
    
    var isDeactive: Bool {
        return status == "DEACTIVE"
    }
    
    // 표시할 텍스트 (성공/실패 상태에 따라)
    var displayText: String {
        if isCompleted {
            return "100%"
        } else if isFailed || isDeactive {
            return "0%"
        } else {
            return remainingTime
        }
    }
    
    // 텍스트 색상
    var displayTextColor: String {
        if isCompleted {
            return "#EAECF0" // Light Gray (성공)
        } else if isFailed || isDeactive {
            return "#EAECF0" // Light Gray (실패)
        } else {
            return "#FFFFFF" // White
        }
    }
    
    // MARK: - Card Color Assignment
    var cardColor: MainHabitCardView.CardColor {
        // 습관 ID를 기반으로 색상 결정 (각 습관마다 다른 색상)
        let colors = MainHabitCardView.CardColor.allCases
        return colors[id % colors.count]
    }
    
    var listCardColor: HabitListCardView.CardColor {
        // 습관 ID를 기반으로 색상 결정 (각 습관마다 다른 색상)
        let colors = HabitListCardView.CardColor.allCases
        return colors[id % colors.count]
    }
}

// MARK: - Main Screen Response Model
struct MainScreenResponse: Codable {
    let status: Int
    let message: String
    let data: MainScreenData
}

struct MainScreenData: Codable {
    let nickname: String
    let profileImage: Int
    let habits: [Habit]
}

// MARK: - Habit List Response Model
struct HabitListResponse: Codable {
    let status: Int
    let message: String
    let data: [Habit]  // API는 배열을 직접 반환
}
