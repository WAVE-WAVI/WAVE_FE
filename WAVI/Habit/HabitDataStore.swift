//
//  HabitDataStore.swift
//  WAVI
//
//  Created by 박현빈 on 10/14/25.
//

import SwiftUI
import Combine

// MARK: - HabitDataStore
class HabitDataStore: ObservableObject {
    @Published var habitData: ChatAnalysisData? = nil
    
    init(habitData: ChatAnalysisData? = nil) {
        self.habitData = habitData
    }
    
    func setHabitData(_ data: ChatAnalysisData) {
        habitData = data
    }
}
