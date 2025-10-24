//
//  LoginModels.swift
//  WAVI
//
//  Created by 박현빈 on 9/5/25.
//

// 요청/응답 DTO + 에러 응답
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginSuccessResponse: Decodable {
    let code: Int?
    let message: String
    let data: Tokens
    struct Tokens: Decodable {
        let accessToken: String
        let refreshToken: String
    }
}

struct APIErrorResponse: Decodable {
    let status: Int?
    let code: Int?
    let message: String
}

// 이메일 인증 시작 요청
struct InitiateSignUpRequest: Encodable {
    let email: String
}

// 회원가입 완료 요청
struct CompleteSignUpRequest: Encodable {
    let email: String
    let code: String
    let password: String
    let nickname: String
    let birthYear: Int
    let gender: String
    let job: String
    let profileImage: Int
}

// MARK: - User Model
struct User: Codable {
    let id: Int
    let email: String
    let nickname: String
    let birthYear: Int
    let gender: String
    let job: String
    let profileImage: Int?
}

// MARK: - Login Response
struct LoginResponse: Codable {
    let status: Int
    let message: String
    let data: String?  // 서버에서 Bearer 토큰을 String으로 반환
}

// MARK: - SignUp Response
struct APISignUpResponse: Codable {
    let status: Int
    let message: String
    let data: String?
}

// MARK: - Network Error Response
struct APINetworkErrorResponse: Codable {
    let status: Int?
    let code: Int?
    let message: String
}

// MARK: - Email Check Response
struct EmailCheckResponse: Codable {
    let available: Bool
    let message: String
}

// MARK: - Verification Code Response
struct VerificationCodeResponse: Codable {
    let status: Int
    let message: String
}

// MARK: - Auth Error
enum AuthError: Error {
    case noLoginData
    case invalidCredentials
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .noLoginData:
            return "로그인 데이터가 없습니다."
        case .invalidCredentials:
            return "이메일 또는 비밀번호가 올바르지 않습니다."
        case .networkError:
            return "네트워크 오류가 발생했습니다."
        }
    }
}

// MARK: - Result Types
enum LoginResult {
    case success(LoginSuccessResponse)
    case failure(Error)
}

enum SignUpResult {
    case success
    case failure(Error)
}

enum VerificationResult {
    case success
    case failure(Error)
}

enum EmailCheckResult {
    case available
    case unavailable
    case failure(Error)
}

enum PasswordResetResult {
    case success
    case failure(Error)
}
