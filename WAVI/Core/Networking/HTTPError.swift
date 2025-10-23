//
//  HTTPError.swift
//  WAVI
//
//  Created by 박현빈 on 9/5/25.
//

import Foundation

// RawValue(예: : String) 쓰지 말고, Error/LocalizedError 채택만!
enum HTTPError: Error, LocalizedError {
    case invalidRequest
    case unauthorized
    case forbidden
    case notFound
    case server
    case message(String)   // ← 연관값 OK (RawValue 없을 때만)
    case network
    case unknown
    case invalidURL
    case decodingError
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidRequest: return "잘못된 요청입니다."
        case .unauthorized:   return "인증 실패 에러"
        case .forbidden:      return "접근 권한이 없습니다."
        case .notFound:       return "리소스를 찾을 수 없습니다."
        case .server:         return "서버 에러"
        case .message(let m): return m
        case .network:        return "네트워크 오류가 발생했습니다."
        case .unknown:        return "알 수 없는 오류가 발생했습니다."
        case .invalidURL:     return "잘못된 URL입니다."
        case .decodingError:  return "데이터 디코딩 오류가 발생했습니다."
        case .networkError(let error): return "네트워크 오류: \(error.localizedDescription)"
        }
    }
}
