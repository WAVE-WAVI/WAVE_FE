//
//  HabitLogModels.swift
//  WAVI
//
//  Created by 박현빈 on 10/12/25.
//

import Foundation

// MARK: - 성공 기록 요청
struct HabitSuccessRequest: Codable {
    let habitId: Int
}

// MARK: - 성공 기록 응답
struct HabitSuccessResponse: Codable {
    let status: Int
    let message: String
}

// MARK: - 실패 기록 요청
struct HabitFailureRequest: Codable {
    let failureReasonIds: [Int]
    let customReason: String?
}

// MARK: - 실패 기록 응답
struct HabitFailureResponse: Codable {
    let status: Int
    let message: String
}

// MARK: - 공통 응답 (호환성 유지)
struct HabitLogResponse: Codable {
    let status: Int
    let message: String
    let data: [HabitLogData]?
}

// MARK: - 습관 로그 데이터
struct HabitLogData: Codable {
    let id: Int
    let habitId: Int
    let name: String
    let date: String // YYYY-MM-DD 형식
    let completed: Bool
    let failureReasons: [FailureReasonData]?
}

// MARK: - 서버에서 오는 실패 이유 데이터
struct FailureReasonData: Codable {
    let id: Int
    let reason: String
}

// MARK: - 실패 이유 모델
enum FailureReason: Int, CaseIterable, Codable {
    case lackOfWill = 0        // 의지 부족
    case healthProblem = 1     // 건강 문제
    case overambitiousGoal = 2 // 과도한 목표 설정
    case lackOfTime = 3        // 시간 부족
    case scheduleConflict = 4  // 일정 충돌
    case other = 5             // 기타 (직접 입력)
    
    var displayName: String {
        switch self {
        case .lackOfWill: return "의지 부족"
        case .healthProblem: return "건강 문제"
        case .overambitiousGoal: return "과도한 목표 설정"
        case .lackOfTime: return "시간 부족"
        case .scheduleConflict: return "일정 충돌"
        case .other: return "기타 (직접 입력)"
        }
    }
    
    var emoji: String {
        switch self {
        case .lackOfWill: return "😭"
        case .healthProblem: return "💊"
        case .overambitiousGoal: return "🤕"
        case .lackOfTime: return "⏳"
        case .scheduleConflict: return "🤯"
        case .other: return "🤔"
        }
    }
}
