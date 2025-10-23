//
//  SignUpStepVMs.swift
//  WAVI
//
//  Created by 박현빈 on 9/23/25.
//

import SwiftUI

// MARK: - STEP 1: 이메일
final class SignUpEmailVM: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?   // ⬅️ 문자열 메시지로 사용

    private let flow: SignUpFlowVM
    private let service: SignUpServicing

    init(flow: SignUpFlowVM, service: SignUpServicing = MockSignUpService()) {
        self.flow = flow
        self.service = service
        self.email = flow.state.email
    }

    @MainActor
    func submit() async {
        guard !email.isEmpty else {
            errorMessage = "이메일을 입력해주세요"
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await service.initiateSignup(email: email)
            flow.state.email = email
            flow.path.append(.code)
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "요청 실패"
        }
    }
}

// MARK: - STEP 2: 코드
final class SignUpCodeVM: ObservableObject {
    @Published var code: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let flow: SignUpFlowVM
    private let service: SignUpServicing

    init(flow: SignUpFlowVM, service: SignUpServicing = MockSignUpService()) {
        self.flow = flow
        self.service = service
        self.code = flow.state.code
    }

    @MainActor
    func submit() async {
        guard !code.isEmpty else {
            errorMessage = "인증 코드를 입력해주세요"
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // 새로운 흐름에서는 사용하지 않음
        // verifyCode는 completeSignup에 통합됨
        errorMessage = "이 기능은 더 이상 사용되지 않습니다."
     

    }
}

// MARK: - STEP 3: 비밀번호
final class SignUpPasswordVM: ObservableObject {
    @Published var password: String = ""
    @Published var confirm: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var finished: Bool = false

    private let flow: SignUpFlowVM
    private let service: SignUpServicing

    init(flow: SignUpFlowVM, service: SignUpServicing = MockSignUpService()) {
        self.flow = flow
        self.service = service
        self.password = flow.state.password
    }

    @MainActor
    func submit() async {
        guard !password.isEmpty, !confirm.isEmpty else {
            errorMessage = "비밀번호를 입력해주세요"
            return
        }
        guard password == confirm else {
            errorMessage = "비밀번호가 일치하지 않습니다"
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // 새로운 흐름에서는 사용하지 않음
        // setPassword는 completeSignup에 통합됨
        errorMessage = "이 기능은 더 이상 사용되지 않습니다."
    }
}
