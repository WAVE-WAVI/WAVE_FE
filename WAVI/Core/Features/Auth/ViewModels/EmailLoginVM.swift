//
//  EmailLoginVM.swift
//  WAVI
//
//  Created by 박현빈 on 9/5/25.
//

import SwiftUI

final class EmailLoginVM: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: AuthService
    private let tokens = TokenStore.shared
    private let authManager: AuthManager
    @Published var loginSucceeded = false

    init(service: AuthService = BackendAuthService(), authManager: AuthManager) {
        self.service = service
        self.authManager = authManager
    }

    @MainActor
    func login() async {
        print("🚀 EmailLoginVM: login() 함수 호출됨")
        print("🚀 EmailLoginVM: 사용 중인 서비스: \(type(of: service))")
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "이메일과 비밀번호를 입력해주세요."
            print("❌ 입력 누락")
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            print("🚀 EmailLoginVM: service.login() 호출 시작")
            let result = try await service.login(email: email, password: password)
            print("🚀 EmailLoginVM: service.login() 완료")
            
            switch result {
            case .success(let response):
                loginSucceeded = true
                authManager.login() // AuthManager의 로그인 상태 업데이트
                print("✅ 로그인 성공")
            case .failure(let error):
                errorMessage = error.localizedDescription
                print("❌ 로그인 실패: \(error.localizedDescription)")
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "로그인 실패"
            print("❌ 로그인 실패: \(error.localizedDescription)")
        }
    }
}
