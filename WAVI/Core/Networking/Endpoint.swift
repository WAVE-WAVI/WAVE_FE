//
//  Endpoint.swift
//  WAVI
//
//  Created by 박현빈 on 9/5/25.
//

import Foundation

// MARK: - Legacy Endpoint (기존 호환성 유지)
enum Endpoint {
    case login
    case signup
    case initiateSignup  // 이메일 인증 시작
    case completeSignup  // 회원가입 완료
    case checkEmail
    case resetPassword
    case main
    case allHabits
    case logSuccess(habitId: Int)
    case logFailure(habitId: Int)

    var baseURL: String {
        return "http://43.202.29.58:8080"
    }

    var path: String {
        switch self {
        case .login: return "/api/v1/user/login"
        case .signup: return "/api/v1/user/signup"
        case .initiateSignup: return "/api/v1/user/signup/initiate"
        case .completeSignup: return "/api/v1/user/signup/complete"
        case .checkEmail: return "/api/v1/user/check-email"
        case .resetPassword: return "/api/v1/auth/reset-password"
        case .main: return "/api/v1/main"
        case .allHabits: return "/api/v1/habit"
        case .logSuccess(let habitId): return "/api/v1/log/success/\(habitId)"
        case .logFailure(let habitId): return "/api/v1/log/failure/\(habitId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .signup, .initiateSignup, .completeSignup, .checkEmail, .resetPassword, .logSuccess, .logFailure:
            return .POST
        case .main, .allHabits:
            return .GET
        }
    }

    var headers: [String:String]? {
        var headers = ["Content-Type": "application/json"]
        
        // 인증이 필요한 엔드포인트에 JWT 토큰 추가
        switch self {
        case .main, .allHabits, .logSuccess, .logFailure:
            if let token = TokenStore.shared.loadAccess() {
                headers["Authorization"] = "Bearer \(token)"
            }
        default:
            break
        }
        
        return headers
    }
    
    var body: Data? {
        return nil
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
}

