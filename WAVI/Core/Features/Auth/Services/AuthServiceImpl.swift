//
//  AuthServiceImpl.swift
//  WAVI
//
//  Created by 박현빈 on 9/5/25.
//

final class AuthServiceImpl: AuthService {
    private let api: LegacyAPIClient
    init(api: LegacyAPIClient = LegacyAPIClient()) { self.api = api }

    func login(email: String, password: String) async throws -> LoginResult {
        let response: LoginResponse = try await api.request(.login, body: LoginRequest(email: email, password: password))
        
        // 토큰 저장
        if let tokenString = response.data {
            let accessToken = tokenString.replacingOccurrences(of: "Bearer ", with: "")
            
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
            return .failure(AuthError.noLoginData)
        }
    }
    
    func signup(email: String, password: String, nickname: String, birthYear: Int, gender: String, job: String, profileImage: Int) async throws -> SignUpResult {
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
            let response: APISignUpResponse = try await api.request(.completeSignup, body: request)
            return .success
        } catch let error as HTTPError {
            return .failure(error)
        } catch {
            return .failure(error)
        }
    }
}
