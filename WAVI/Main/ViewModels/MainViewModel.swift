//
//  MainViewModel.swift
//  WAVI
//
//  Created by 박현빈 on 10/12/25.
//

import Foundation
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var profileImage: Int = 0
    @Published var habits: [Habit] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let mainService: MainService
    private var lastLoadedDate: Date?
    private var todayHabitStates: [Int: String] = [:]  // habitId: status
    private var timer: Timer?
    
    init(mainService: MainService = BackendMainService()) {
        self.mainService = mainService
        startExpirationTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // 시간 만료 체크 타이머 시작 (1분마다 체크)
    private func startExpirationTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkAndUpdateExpiredHabits()
            }
        }
    }
    
    // 만료된 습관들을 체크하고 자동으로 DEACTIVE로 변경
    private func checkAndUpdateExpiredHabits() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        
        for (index, habit) in habits.enumerated() {
            // ACTIVE 상태인 습관만 체크
            guard habit.status == "ACTIVE" else { continue }
            
            // 종료 시간이 현재 시간을 지났는지 확인
            guard let endTime = formatter.date(from: habit.endTime) else { continue }
            
            let calendar = Calendar.current
            let todayEndTime = calendar.date(bySettingHour: calendar.component(.hour, from: endTime),
                                           minute: calendar.component(.minute, from: endTime),
                                           second: 0,
                                           of: now) ?? now
            
            // 종료 시간이 지났으면 자동으로 DEACTIVE로 변경
            if now > todayEndTime {
                print("⏰ 습관 시간 만료 감지 - habitId: \(habit.id), name: \(habit.name)")
                markHabitAsDeactive(habitId: habit.id)
            }
        }
    }
    
    // 앱 시작 시 이미 만료된 습관들을 DEACTIVE로 변경
    private func checkExpiredHabitsOnStart() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        
        for (index, habit) in habits.enumerated() {
            // ACTIVE 상태인 습관만 체크
            guard habit.status == "ACTIVE" else { continue }
            
            // 종료 시간이 현재 시간을 지났는지 확인
            guard let endTime = formatter.date(from: habit.endTime) else { continue }
            
            let calendar = Calendar.current
            let todayEndTime = calendar.date(bySettingHour: calendar.component(.hour, from: endTime),
                                           minute: calendar.component(.minute, from: endTime),
                                           second: 0,
                                           of: now) ?? now
            
            // 종료 시간이 지났으면 자동으로 DEACTIVE로 변경
            if now > todayEndTime {
                print("⏰ 앱 시작 시 만료된 습관 감지 - habitId: \(habit.id), name: \(habit.name)")
                markHabitAsDeactive(habitId: habit.id)
            }
        }
    }
    
    // 날짜가 바뀌었는지 확인
    private func isNewDay() -> Bool {
        guard let lastDate = lastLoadedDate else {
            return true // 첫 로드
        }
        
        let calendar = Calendar.current
        let today = Date()
        
        return !calendar.isDate(lastDate, inSameDayAs: today)
    }
    
    func loadMainData() async {
        isLoading = true
        errorMessage = nil
        
        let result = await mainService.fetchMainScreenData()
        
        isLoading = false
        
        switch result {
        case .success(let data):
            self.nickname = data.nickname
            self.profileImage = data.profileImage
            
            let newDay = isNewDay()
            
            // 날짜가 바뀌면 상태 딕셔너리 초기화
            if newDay {
                todayHabitStates.removeAll()
            }
            
            // 오늘 요일에 해당하는 습관만 필터링
            self.habits = data.habits
                .filter { $0.isTodayHabit }
                .map { habit in
                    // 오늘 저장된 상태가 있으면 그것을 사용, 없으면 ACTIVE
                    let status = todayHabitStates[habit.id] ?? "ACTIVE"
                    
                    return Habit(
                        id: habit.id,
                        name: habit.name,
                        status: status,
                        dayOfWeek: habit.dayOfWeek,
                        icon: habit.icon,
                        startTime: habit.startTime,
                        endTime: habit.endTime
                    )
                }
                .sorted { habit1, habit2 in
                    return habit1.startTime < habit2.startTime
                }
            
            // 날짜 업데이트
            lastLoadedDate = Date()
            
            // 앱 시작 시 이미 만료된 습관들을 DEACTIVE로 변경
            checkExpiredHabitsOnStart()
            
            print("✅ MainViewModel: 메인 데이터 로드 성공")
            print("   전체 습관: \(data.habits.count)개")
            print("   오늘의 습관: \(self.habits.count)개")
            print("   날짜 변경: \(newDay ? "YES" : "NO")")
            print("   저장된 상태: \(todayHabitStates)")
            
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            print("❌ MainViewModel: 메인 데이터 로드 실패 - \(error)")
        }
    }
    
    // 습관 상태를 COMPLETED로 변경 (성공 시)
    func markHabitAsCompleted(habitId: Int) {
        // 오늘의 상태 딕셔너리에 저장
        todayHabitStates[habitId] = "COMPLETED"
        
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            var updatedHabit = habits[index]
            let completedHabit = Habit(
                id: updatedHabit.id,
                name: updatedHabit.name,
                status: "COMPLETED",
                dayOfWeek: updatedHabit.dayOfWeek,
                icon: updatedHabit.icon,
                startTime: updatedHabit.startTime,
                endTime: updatedHabit.endTime
            )
            habits[index] = completedHabit
            print("✅ 로컬 상태 업데이트: habitId \(habitId) -> COMPLETED")
        }
    }
    
    // 습관 상태를 DEACTIVE로 변경 (실패 시)
    func markHabitAsDeactive(habitId: Int) {
        // 오늘의 상태 딕셔너리에 저장
        todayHabitStates[habitId] = "DEACTIVE"
        
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            var updatedHabit = habits[index]
            let deactiveHabit = Habit(
                id: updatedHabit.id,
                name: updatedHabit.name,
                status: "DEACTIVE",
                dayOfWeek: updatedHabit.dayOfWeek,
                icon: updatedHabit.icon,
                startTime: updatedHabit.startTime,
                endTime: updatedHabit.endTime
            )
            habits[index] = deactiveHabit
            print("✅ 로컬 상태 업데이트: habitId \(habitId) -> DEACTIVE")
        }
    }
}

