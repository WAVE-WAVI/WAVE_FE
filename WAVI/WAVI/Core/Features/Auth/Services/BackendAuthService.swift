//
//  BackendAuthService.swift
//  WAVI
//
//  Created by 박현빈 on 9/23/25.
//

import Foundation

class BackendAuthService: AuthService {
    private let apiClient = LegacyAPIClient()
    
    func login(email: String, password: String) async throws -> LoginResult {
        let request = BackendLoginRequest(email: email, password: password)
        
        print("🔍 BackendAuthService: 로그인 시도 - email: \(email), password: \(password)")
        print("🔍 BackendAuthService: 요청 데이터: \(request)")
        print("🔍 BackendAuthService: API 클라이언트 baseURL: \(apiClient.baseURL)")
        print("🔍 BackendAuthService: 엔드포인트: \(Endpoint.login.path)")
        
        do {
            let response: LoginResponse = try await apiClient.request(.login, body: request)
            print("🔍 BackendAuthService: 백엔드 응답 - status: \(response.status), message: \(response.message)")
            
            // 백엔드 응답 확인
            if response.status == 200, let tokenString = response.data {
                // Bearer 토큰에서 실제 토큰 추출 (Bearer 제거)
                let accessToken = tokenString.replacingOccurrences(of: "Bearer ", with: "")
                
                // 토큰 저장 (accessToken과 refreshToken을 동일하게 설정)
                await TokenStore.shared.saveTokens(
                    accessToken: accessToken,
                    refreshToken: accessToken
                )
                
                return .success(LoginSuccessResponse(
                    code: 200,
                    message: "로그인 성공",
                    data: LoginSuccessResponse.Tokens(
                        accessToken: accessToken,
                        refreshToken: accessToken
                    )
                ))
            } else {
                return .failure(AuthError.invalidCredentials)
            }
        } catch let error as HTTPError {
            print("🔍 BackendAuthService: HTTPError 발생 - \(error)")
            return .failure(error)
        } catch {
            print("🔍 BackendAuthService: 일반 오류 발생 - \(error)")
            print("🔍 BackendAuthService: 오류 타입: \(type(of: error))")
            return .failure(error)
        }
    }
    
    func signup(email: String, password: String, nickname: String, birthYear: Int, gender: String, job: String, profileImage: Int = 1) async throws -> SignUpResult {
        let request = BackendSignUpRequest(
            email: email,
            password: password,
            loginType: "NORMAL",
            nickname: nickname,
            birthYear: birthYear,
            gender: gender,
            job: job,
            profileImage: profileImage
        )
        
        do {
            let response: APISignUpResponse = try await apiClient.request(.completeSignup, body: request)
            return .success
        } catch let error as HTTPError {
            return .failure(error)
        } catch {
            return .failure(error)
        }
    }
    
    func sendVerificationCode(email: String) async throws -> VerificationResult {
        let request = SendVerificationCodeRequest(email: email)
        
        do {
            let response: APISignUpResponse = try await apiClient.request(.initiateSignup, body: request)
            return .success
        } catch let error as HTTPError {
            return .failure(error)
        } catch {
            return .failure(error)
        }
    }
    
    func verifyCode(email: String, code: String) async throws -> VerificationResult {
        let request = VerifyCodeRequest(email: email, code: code)
        
        do {
            let response: APISignUpResponse = try await apiClient.request(.completeSignup, body: request)
            return .success
        } catch let error as HTTPError {
            return .failure(error)
        } catch {
            return .failure(error)
        }
    }
    
    func checkEmailAvailability(email: String) async throws -> EmailCheckResult {
        let request = EmailCheckRequest(email: email)
        
        do {
            let response: EmailCheckResponse = try await apiClient.request(.checkEmail, body: request)
            return response.available ? .available : .unavailable
        } catch let error as HTTPError {
            return .failure(error)
        } catch {
            return .failure(error)
        }
    }
    
    func resetPassword(email: String, newPassword: String, verificationCode: String) async throws -> PasswordResetResult {
        let request = PasswordResetRequest(
            email: email,
            newPassword: newPassword,
            verificationCode: verificationCode
        )
        
        do {
            let response: VerificationCodeResponse = try await apiClient.request(.resetPassword, body: request)
            return .success
        } catch let error as HTTPError {
            return .failure(error)
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - Request Models
struct BackendLoginRequest: Codable {
    let email: String
    let password: String
}

struct BackendSignUpRequest: Codable {
    let email: String
    let password: String
    let loginType: String
    let nickname: String
    let birthYear: Int
    let gender: String
    let job: String
    let profileImage: Int
}

struct SendVerificationCodeRequest: Codable {
    let email: String
}

struct VerifyCodeRequest: Codable {
    let email: String
    let code: String
}

struct EmailCheckRequest: Codable {
    let email: String
}

struct PasswordResetRequest: Codable {
    let email: String
    let newPassword: String
    let verificationCode: String
}
