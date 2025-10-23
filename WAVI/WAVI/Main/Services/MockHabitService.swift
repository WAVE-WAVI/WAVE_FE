//
//  MockHabitService.swift
//  WAVI
//
//  Created by 박현빈 on 7/28/25.
//

import Foundation

// MARK: - Habit Service Protocol
protocol HabitServiceProtocol {
    func fetchMainScreenData() async -> Result<MainScreenData, Error>
    func fetchAllHabits() async -> Result<[Habit], Error>
}

// MARK: - Mock Habit Service
class MockHabitService: ObservableObject, HabitServiceProtocol {
    
    // MARK: - Mock Data
    private let mockHabits: [Habit] = [
        Habit(
            id: 1,
            name: "따뜻한 물 1L 마시기",
            status: "ACTIVE",
            dayOfWeek: [1, 2, 3, 4, 5], // 월~금
            icon: "💧",
            startTime: "09:30:00",
            endTime: "10:00:00"
        ),
        Habit(
            id: 2,
            name: "500m 수영하기",
            status: "ACTIVE",
            dayOfWeek: [2, 4, 6], // 화, 목, 토
            icon: "🏊",
            startTime: "12:00:00",
            endTime: "12:30:00"
        ),
        Habit(
            id: 3,
            name: "자외선 차단제 바르기",
            status: "ACTIVE",
            dayOfWeek: [1, 3, 5, 7], // 월, 수, 금, 일
            icon: "☀️",
            startTime: "09:30:00",
            endTime: "10:00:00"
        ),
        Habit(
            id: 4,
            name: "30분 운동하기",
            status: "ACTIVE",
            dayOfWeek: [1, 2, 3, 4, 5, 6, 7], // 매일
            icon: "💻",
            startTime: "14:00:00",
            endTime: "14:30:00"
        ),
        Habit(
            id: 5,
            name: "독서 1시간",
            status: "ACTIVE",
            dayOfWeek: [1, 2, 3, 4, 5, 6, 7], // 매일
            icon: "📚",
            startTime: "20:00:00",
            endTime: "21:00:00"
        ),
        Habit(
            id: 6,
            name: "명상 15분",
            status: "ACTIVE",
            dayOfWeek: [1, 3, 5], // 월, 수, 금
            icon: "🍃",
            startTime: "07:00:00",
            endTime: "07:15:00"
        )
    ]
    
    private let mockMainScreenData = MainScreenData(
        nickname: "딜로포사우르스",
        profileImage: 2,
        habits: []
    )
    
    // MARK: - Public Methods
    func fetchMainScreenData() async -> Result<MainScreenData, Error> {
        // 테스트를 위해 모든 습관을 반환 (6개 카드 모두 테스트)
        let mainScreenData = MainScreenData(
            nickname: mockMainScreenData.nickname,
            profileImage: mockMainScreenData.profileImage,
            habits: mockHabits // 6개 습관 모두 반환
        )
        
        // 실제 API 호출을 시뮬레이션하기 위한 딜레이
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초
        
        return .success(mainScreenData)
    }
    
    func fetchAllHabits() async -> Result<[Habit], Error> {
        // 실제 API 호출을 시뮬레이션하기 위한 딜레이
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3초
        
        return .success(mockHabits)
    }
    
    // MARK: - Helper Methods
    func getHabitsForToday() -> [Habit] {
        let today = Calendar.current.component(.weekday, from: Date())
        return mockHabits.filter { habit in
            habit.dayOfWeek.contains(today)
        }
    }
    
    func getHabitsByStatus(_ status: String) -> [Habit] {
        return mockHabits.filter { habit in
            habit.status == status
        }
    }
    
    func getActiveHabits() -> [Habit] {
        return getHabitsByStatus("active")
    }
    
    func getCompletedHabits() -> [Habit] {
        return getHabitsByStatus("completed")
    }
}
