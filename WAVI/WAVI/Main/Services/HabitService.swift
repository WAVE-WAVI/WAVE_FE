//
//  HabitService.swift
//  WAVI
//
//  Created by 박현빈 on 10/12/25.
//

import Foundation
import Combine

// MARK: - Empty Request for GET endpoints
struct EmptyRequest: Codable {}

// MARK: - Habit Service Protocol (기존 호환성 유지)
protocol HabitService {
    func fetchAllHabits() async -> Result<[Habit], Error>
}

// MARK: - Backend Habit Service (기존 호환성 유지)
class BackendHabitService: HabitService {
    private let apiClient: LegacyAPIClient
    
    init(apiClient: LegacyAPIClient = LegacyAPIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchAllHabits() async -> Result<[Habit], Error> {
        print("🌐 BackendHabitService: 모든 습관 목록 요청")
        
        do {
            let response: HabitListResponse = try await apiClient.request(
                .allHabits,
                body: EmptyRequest()
            )
            
            print("✅ BackendHabitService: 습관 목록 로드 성공")
            print("   습관 개수: \(response.data.count)")
            
            // 각 습관의 아이콘 확인
            for habit in response.data {
                print("   습관 ID: \(habit.id), 이름: \(habit.name), 아이콘: \(habit.icon)")
            }
            
            return .success(response.data)
            
        } catch let error as HTTPError {
            print("❌ BackendHabitService: HTTPError - \(error)")
            return .failure(error)
        } catch {
            print("❌ BackendHabitService: 일반 오류 - \(error)")
            return .failure(error)
        }
    }
    
}

// MARK: - New Habit Service for AddingHabitsMainView and HabitsConfirmView
class NewHabitService: ObservableObject {
    private let apiClient = APIClient.shared
    
    // MARK: - Habit Formation Methods
    func analyzeUserMessage(_ request: ChatAnalysisRequest) -> AnyPublisher<ChatAnalysisResponse, HTTPError> {
        return apiClient.request(WAVIEndpoint.analyzeUserMessage(request), responseType: ChatAnalysisResponse.self)
    }
    
    func createHabit(_ request: HabitRequest) -> AnyPublisher<HabitResponse, HTTPError> {
        return apiClient.request(WAVIEndpoint.createHabit(request), responseType: HabitResponse.self)
    }
    
    func updateHabit(id: String, request: HabitRequest) -> AnyPublisher<HabitResponse, HTTPError> {
        return apiClient.request(WAVIEndpoint.updateHabit(id: id, request), responseType: HabitResponse.self)
    }
    
    func deleteHabit(id: String) -> AnyPublisher<HabitResponse, HTTPError> {
        return apiClient.request(WAVIEndpoint.deleteHabit(id: id), responseType: HabitResponse.self)
    }
    
    func getHabit(id: String) -> AnyPublisher<HabitDetailResponse, HTTPError> {
        return apiClient.request(WAVIEndpoint.getHabit(id: id), responseType: HabitDetailResponse.self)
    }
    
    func getAllHabits() -> AnyPublisher<AllHabitsResponse, HTTPError> {
        return apiClient.request(WAVIEndpoint.getAllHabits, responseType: AllHabitsResponse.self)
    }
    
    func getTodayHabits() -> AnyPublisher<TodayHabitsResponse, HTTPError> {
        return apiClient.request(WAVIEndpoint.getTodayHabits, responseType: TodayHabitsResponse.self)
    }
    
    func updateHabitStatus(_ request: HabitStatusRequest) -> AnyPublisher<HabitResponse, HTTPError> {
        return apiClient.request(WAVIEndpoint.updateHabitStatus(request), responseType: HabitResponse.self)
    }
    
    func getHabitLogs(habitId: Int? = nil, startDate: String? = nil, endDate: String? = nil, completed: Bool? = nil) -> AnyPublisher<HabitLogResponse, HTTPError> {
        return apiClient.request(WAVIEndpoint.getHabitLogs(habitId: habitId, startDate: startDate, endDate: endDate, completed: completed), responseType: HabitLogResponse.self)
    }
    
    // MARK: - Report Methods
    func getReports(type: String, startDate: String, endDate: String) -> AnyPublisher<ReportResponse, HTTPError> {
        return apiClient.request(WAVIEndpoint.getReports(type: type, startDate: startDate, endDate: endDate), responseType: ReportResponse.self)
    }
}

