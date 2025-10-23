//
//  APIClient.swift
//  WAVI
//
//  Created by 박현빈 on 9/5/25.
//

import Foundation
import Combine

// MARK: - API Client
class APIClient: ObservableObject {
    static let shared = APIClient()
    
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Generic Request Method
    func request<T: Codable>(_ endpoint: WAVIEndpointProtocol, responseType: T.Type) -> AnyPublisher<T, HTTPError> {
        guard let url = buildURL(from: endpoint) else {
            return Fail(error: HTTPError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        
        // 📤 요청 바디 로그 찍기
        if let httpBody = request.httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8) {
            print("📤 요청 바디: \(bodyString)")
        }
        
        // Add headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
            print("📤 keyvalue: \(key): \(value)")
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .handleEvents(receiveOutput: { data in
                // 🔍 서버 응답 로그 찍기
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 서버 응답: \(jsonString)")
                }
            })
            .tryMap { data -> T in
                do {
                return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    print("❌ 디코딩 실패: \(error.localizedDescription)")
                    throw HTTPError.decodingError
                }
            }
            .mapError { error in
                if let httpError = error as? HTTPError {
                    return httpError
                } else if error is DecodingError {
                    print("❌ 디코딩 에러: \(error)")
                    return HTTPError.decodingError
                } else {
                    return HTTPError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Request without Response Body
    func request(_ endpoint: WAVIEndpointProtocol) -> AnyPublisher<Void, HTTPError> {
        guard let url = buildURL(from: endpoint) else {
            return Fail(error: HTTPError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        // 📤 요청 바디 로그 찍기
        if let httpBody = request.httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8) {
            print("📤 요청 바디 (Void): \(bodyString)")
        }
        
        // Add headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return session.dataTaskPublisher(for: request)
            .map { _ in () }
            .mapError { error in
                HTTPError.networkError(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    private func buildURL(from endpoint: WAVIEndpointProtocol) -> URL? {
        var components = URLComponents(string: endpoint.baseURL + endpoint.path)
        components?.queryItems = endpoint.queryItems
        return components?.url
    }
}

// MARK: - Response Models
struct HabitResponse: Codable {
    let status: Int?
    let message: String?
    let timestamp: String?
    let error: String?
    let path: String?
}

struct HabitDetailResponse: Codable {
    let status: Int
    let message: String
    let data: HabitData?
}


//ㅊㄱ
struct TodayHabitsResponse: Codable {
    let status: Int
    let message: String
    let data: [HabitData]?
}


struct HabitStatusResponse: Codable {
    let habitId: String
    let status: String
    let completedAt: String?
    let streak: Int // 연속 달성 일수
}

// MARK: - API Service (기존 HabitService.swift에서 정의됨)