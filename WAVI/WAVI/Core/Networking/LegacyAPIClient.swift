//
//  LegacyAPIClient.swift
//  WAVI
//
//  Created by 박현빈 on 9/5/25.
//

import Foundation

// MARK: - Legacy API Client for Authentication
class LegacyAPIClient {
    private let session = URLSession.shared
    let baseURL = "http://43.202.29.58:8080"
    
    init() {}
    
    // MARK: - Request Method for Legacy Endpoint (with body)
    func request<T: Codable, B: Encodable>(
        _ endpoint: Endpoint,
        body: B
    ) async throws -> T {
        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            throw HTTPError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // Only add body for non-GET requests
        if endpoint.method != .GET {
            request.httpBody = try JSONEncoder().encode(body)
            
            // 📤 요청 바디 로그 찍기
            if let httpBody = request.httpBody,
               let bodyString = String(data: httpBody, encoding: .utf8) {
                print("📤 요청 바디 (Legacy): \(bodyString)")
            }
        }
        
        // Add headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (data, response) = try await session.data(for: request)
        
        // 🔍 서버 응답 로그 찍기
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🔍 서버 응답 (Legacy): \(jsonString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.network
        }
        
        if httpResponse.statusCode == 200 {
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                print("❌ 디코딩 실패: \(error.localizedDescription)")
                throw HTTPError.decodingError
            }
        } else {
            // Handle error responses
            print("❌ HTTP 에러 상태 코드: \(httpResponse.statusCode)")
            
            if let errorResponse = try? JSONDecoder().decode(APINetworkErrorResponse.self, from: data) {
                print("❌ 서버 에러 응답: \(errorResponse.message)")
                throw HTTPError.message(errorResponse.message)
            } else {
                // 서버 에러 응답을 파싱할 수 없는 경우
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ 서버 에러 응답 (파싱 실패): \(errorString)")
                }
                throw HTTPError.server
            }
        }
    }
}
