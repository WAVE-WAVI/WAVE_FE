//
//  MockAuthService.swift
//  WAVI
//
//  Created by 박현빈 on 9/9/25.
//

import Foundation

struct MockUser {
    let email: String
    let password: String
    let accessToken: String
    let refreshToken: String
}

final class MockAuthService: AuthService {
    private let users: [MockUser] = [
        MockUser(
            email: "park",
            password: "1234",
            accessToken: "mock_access_token_1",
            refreshToken: "mock_refresh_token_1"
        ),
        MockUser(
            email: "seo",
            password: "1111",
            accessToken: "mock_access_token_2",
            refreshToken: "mock_refresh_token_2"
        )
    ]

    func login(email: String, password: String) async throws -> LoginResult {
        try await Task.sleep(nanoseconds: 300_000_000) // 지연 흉내

        guard let u = users.first(where: { $0.email == email && $0.password == password }) else {
            return .failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "이메일 또는 비밀번호가 올바르지 않습니다."]))
        }

        // 토큰 저장
        await TokenStore.shared.saveTokens(
            accessToken: u.accessToken,
            refreshToken: u.refreshToken
        )

        return .success(LoginSuccessResponse(
            code: 200,
            message: "로그인 성공",
            data: LoginSuccessResponse.Tokens(
                accessToken: u.accessToken,
                refreshToken: u.refreshToken
            )
        ))
    }
    
    func signup(email: String, password: String, nickname: String, birthYear: Int, gender: String, job: String, profileImage: Int) async throws -> SignUpResult {
        try await Task.sleep(nanoseconds: 300_000_000) // 지연 흉내
        
        // Mock 회원가입 로직
        return .success
    }
}
