//
//  HabitListViewModel.swift
//  WAVI
//
//  Created by 박현빈 on 10/12/25.
//

import Foundation
import SwiftUI

@MainActor
class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let habitService: HabitService
    
    init(habitService: HabitService = BackendHabitService()) {
        self.habitService = habitService
    }
    
    func loadAllHabits() async {
        isLoading = true
        errorMessage = nil
        
        let result = await habitService.fetchAllHabits()
        
        isLoading = false
        
        switch result {
        case .success(let habits):
            self.habits = habits
            print("✅ HabitListViewModel: 습관 목록 로드 성공 - \(habits.count)개 습관")
            
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            print("❌ HabitListViewModel: 습관 목록 로드 실패 - \(error)")
        }
    }
}


