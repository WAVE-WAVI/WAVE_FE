//
//  HabitLogService.swift
//  WAVI
//
//  Created by 박현빈 on 10/12/25.
//

import Foundation

// MARK: - HabitLogService Protocol
protocol HabitLogServicing {
    func logSuccess(habitId: Int) async throws
    func logFailure(habitId: Int, failureReasonIds: [Int], customReason: String?) async throws
}

// MARK: - Backend HabitLog Service
class BackendHabitLogService: HabitLogServicing {
    private let apiClient = LegacyAPIClient()
    
    func logSuccess(habitId: Int) async throws {
        print("🚀 BackendHabitLogService: 습관 성공 기록 시작 - habitId: \(habitId)")
        
        let request = HabitSuccessRequest(habitId: habitId)
        
        do {
            let response: HabitSuccessResponse = try await apiClient.request(
                .logSuccess(habitId: habitId),
                body: request
            )
            print("✅ 습관 성공 기록 완료: \(response.message)")
        } catch let error as HTTPError {
            print("❌ 습관 성공 기록 실패: \(error)")
            throw error
        } catch {
            print("❌ 알 수 없는 오류: \(error)")
            throw HTTPError.invalidRequest
        }
    }
    
    func logFailure(habitId: Int, failureReasonIds: [Int], customReason: String?) async throws {
        print("🚀 BackendHabitLogService: 습관 실패 기록 시작 - habitId: \(habitId)")
        print("📝 실패 이유: \(failureReasonIds), 커스텀 이유: \(customReason ?? "없음")")
        
        let request = HabitFailureRequest(
            failureReasonIds: failureReasonIds,
            customReason: customReason
        )
        
        do {
            let response: HabitFailureResponse = try await apiClient.request(
                .logFailure(habitId: habitId),
                body: request
            )
            print("✅ 습관 실패 기록 완료: \(response.message)")
        } catch let error as HTTPError {
            print("❌ 습관 실패 기록 실패: \(error)")
            throw error
        } catch {
            print("❌ 알 수 없는 오류: \(error)")
            throw HTTPError.invalidRequest
        }
    }
}

// MARK: - Mock HabitLog Service
class MockHabitLogService: HabitLogServicing {
    func logSuccess(habitId: Int) async throws {
        print("🎭 [Mock] 습관 성공 기록 - habitId: \(habitId)")
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 대기
        print("✅ [Mock] 습관 성공 기록 완료")
    }
    
    func logFailure(habitId: Int, failureReasonIds: [Int], customReason: String?) async throws {
        print("🎭 [Mock] 습관 실패 기록 - habitId: \(habitId)")
        print("📝 [Mock] 실패 이유: \(failureReasonIds), 커스텀 이유: \(customReason ?? "없음")")
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 대기
        print("✅ [Mock] 습관 실패 기록 완료")
    }
}
