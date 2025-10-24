//
//  WAVIEndpoint.swift
//  WAVI
//
//  Created by 박현빈 on 9/5/25.
//

import Foundation

// MARK: - API Endpoint Protocol
protocol WAVIEndpointProtocol {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var queryItems: [URLQueryItem]? { get }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - API Endpoints
enum WAVIEndpoint: WAVIEndpointProtocol {
    // Base URL
    var baseURL: String {
        return "http://43.202.29.58:8080" // 실제 API 서버 URL
    }
    
    // MARK: - Habit Formation Endpoints
    case analyzeUserMessage(ChatAnalysisRequest) // 사용자 메시지 분석 챗봇
    case createHabit(HabitRequest) // 습관 등록
    case updateHabit(id: String, HabitRequest) // 습관 수정
    case deleteHabit(id: String) // 습관 삭제
    case getHabit(id: String) // 단일 습관 조회
    case getAllHabits // 내 모든 습관 조회
    case getTodayHabits // 오늘의 습관 조회
    case updateHabitStatus(HabitStatusRequest) // 습관 상태 갱신
    case getHabitLogs(habitId: Int?, startDate: String?, endDate: String?, completed: Bool?) // 습관 기록 조회
    case createReport(ReportRequest) // 리포트 생성
    case getReports(type: String?, startDate: String?, endDate: String?) // 리포트 조회
    
    var path: String {
        switch self {
        case .analyzeUserMessage:
            return "/api/v1/habit/chat"
        case .createHabit, .getAllHabits:
            return "/api/v1/habit"
        case .updateHabit(let id, _), .deleteHabit(let id), .getHabit(let id):
            return "/api/v1/habit/\(id)"
        case .getTodayHabits:
            return "/api/v1/habit/today"
        case .updateHabitStatus:
            return "/api/v1/habit/status"
        case .getHabitLogs:
            return "/api/v1/log"
        case .createReport:
            return "/api/v1/report"
        case .getReports:
            return "/api/v1/report"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAllHabits, .getHabit, .getTodayHabits, .getHabitLogs, .getReports:
            return .GET
        case .analyzeUserMessage, .createHabit, .updateHabitStatus, .createReport:
            return .POST
        case .updateHabit:
            return .PATCH
        case .deleteHabit:
            return .DELETE
        }
    }
    
    var headers: [String: String]? {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        // Authorization 헤더 추가
        if let token = TokenStore.shared.accessToken {
            headers["Authorization"] = "Bearer \(token)"
        } else {
            // 실제 토큰이 없을 경우에만 테스트 토큰 사용
            headers["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0ZXN0MUBnbWFpbC5jb20iLCJleHAiOjE3NjAxMTM4NzgsImlhdCI6MTc2MDExMjA3OH0.11sZKj3MBLBMQGdYcRyXXVMNtx2Of88GXqq4PJoTLKo"
        }
        
        return headers
    }
    
    var body: Data? {
        switch self {
        case .analyzeUserMessage(let request):
            return try? JSONEncoder().encode(request)
        case .createHabit(let request):
            return try? JSONEncoder().encode(request)
        case .updateHabit(_, let request):
            return try? JSONEncoder().encode(request)
        case .updateHabitStatus(let request):
            return try? JSONEncoder().encode(request)
        case .createReport(let request):
            return try? JSONEncoder().encode(request)
        default:
            return nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getHabitLogs(let habitId, let startDate, let endDate, let completed):
            var items: [URLQueryItem] = []
            
            if let habitId = habitId {
                items.append(URLQueryItem(name: "habitId", value: String(habitId)))
            }
            if let startDate = startDate {
                items.append(URLQueryItem(name: "startDate", value: startDate))
            }
            if let endDate = endDate {
                items.append(URLQueryItem(name: "endDate", value: endDate))
            }
            if let completed = completed {
                items.append(URLQueryItem(name: "completed", value: String(completed)))
            }
            
            return items.isEmpty ? nil : items
        case .getReports(let type, let startDate, let endDate):
            var items: [URLQueryItem] = []
            
            if let type = type {
                items.append(URLQueryItem(name: "type", value: type))
            }
            if let startDate = startDate {
                items.append(URLQueryItem(name: "startDate", value: startDate))
            }
            if let endDate = endDate {
                items.append(URLQueryItem(name: "endDate", value: endDate))
            }
            
            return items.isEmpty ? nil : items
        default:
            return nil
        }
    }
}

// MARK: - Request Models
struct ChatAnalysisRequest: Codable {
    let currentPrompt: String
    let history: [String]
}

struct HabitRequest: Codable {
    let name: String
    let dayOfWeek: [Int] // 0=월, 1=화, ..., 6=일 (사용자 테스트 결과)
    let icon: String
    let startTime: String
    let endTime: String
}

struct HabitStatusRequest: Codable {
    let habitId: String
    let status: String // "completed", "skipped", "pending" 등
    let completedAt: String? // 완료 시간 (ISO 8601 형식)
}



// MARK: - Response Models
// (이전 코드와 동일하며, 서버 응답 디코딩 처리를 위한 모델입니다.)
struct ErrorResponse: Codable {
    let timestamp: String
    let status: Int
    let error: String
    let path: String
}

struct ChatAnalysisData: Codable {
    let icon: String
    let name: String
    let startTime: String
    let endTime: String
    let dayOfWeek: [Int] // dayOfWeek는 [1, 2, 3, 4, 5, 6, 7]과 같은 배열
}

struct ChatAnalysisResponse: Codable {
    let status: Int?
    let message: String?
    let data: ChatAnalysisDataOrString?
    
    // 400 에러일 때 data를 String으로 가져오는 computed property
    var dataMessage: String? {
        if let data = data {
            switch data {
            case .string(let message):
                return message
            case .object(_):
                return nil
            }
        }
        return nil
    }
    
    // 200 성공일 때 data를 ChatAnalysisData로 가져오는 computed property
    var habitData: ChatAnalysisData? {
        if let data = data {
            switch data {
            case .string(_):
                return nil
            case .object(let habitData):
                return habitData
            }
        }
        return nil
    }
}

// data 필드가 String 또는 ChatAnalysisData일 수 있으므로 enum으로 처리
enum ChatAnalysisDataOrString: Codable {
    case string(String)
    case object(ChatAnalysisData)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // 먼저 String으로 시도
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        }
        // String이 실패하면 ChatAnalysisData로 시도
        else if let objectValue = try? container.decode(ChatAnalysisData.self) {
            self = .object(objectValue)
        }
        else {
            throw DecodingError.typeMismatch(ChatAnalysisDataOrString.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected String or ChatAnalysisData"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .object(let data):
            try container.encode(data)
        }
    }
}

// MARK: - All Habits Models
struct AllHabitsResponse: Codable {
    let status: Int
    let message: String
    let data: [HabitData]?
}

struct HabitData: Codable {
    let id: Int
    let name: String
    let status: String
    let dayOfWeek: [Int]
    let icon: String
    let startTime: String
    let endTime: String
}

// MARK: - Habit Log Models (기존 모델 사용)

// MARK: - Report Models
struct ReportRequest: Codable {
    let type: String // WEEKLY, MONTHLY, YEARLY
    let startDate: String
    let endDate: String
}

struct ReportResponse: Codable {
    let status: Int
    let message: String
    let data: [ReportData]?
}

struct ReportData: Codable {
    let createdAt: String
    let updatedAt: String
    let id: Int
    let type: String
    let startDate: String
    let endDate: String
    let summary: String
    let overallSuccessRate: Double?
    let topFailureReasons: [TopFailureReason]?
    let habitSuccessRates: [HabitSuccessRate]?
    let recommendation: [ReportRecommendation]?
    let consistencyIndex: ConsistencyIndex?
}

struct ConsistencyIndex: Codable {
    let id: Int
    let successRate: Double
    let displayMessage: String
}

struct HabitSuccessRate: Codable {
    let name: String
    let rate: Double
}

struct TopFailureReason: Codable {
    let id: Int
    let reason: String
    let priority: Int
}

struct ReportRecommendation: Codable {
    let id: Int
    let name: String
    let startTime: String
    let endTime: String
    let dayOfWeek: [Int]
    let currentHabitName: String?
    let currentHabitStartTime: String?
    let currentHabitEndTime: String?
    let currentHabitDayOfWeek: [Int]?
}