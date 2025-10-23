//
//  SignUpFlowView.swift
//  WAVI
//
//  Created by 박현빈 on 9/23/25.
//

import SwiftUI

/// 상위 `NavigationStack(path: $path)`의 `path`만 사용.
/// 이 파일은 추가로 NavigationStack을 만들지 않는다.
struct SignUpFlowView: View {
    // 상위 스택의 경로를 그대로 바인딩으로 받는다.
    @Binding var path: [Route]

    // 플로우 내부 상태 (이메일 등)는 로컬 state로 관리
    @State private var email: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        // 첫 화면: 이메일 입력 스텝
        SignUpEmailStep(
            email: $email,
            isLoading: $isLoading,
            errorMessage: $errorMessage,
            onSubmit: { emailText in
                // 네트워크/검증이 있다면 비동기로 처리 후 메인에서 푸시
                await next { path.append(.signupCode) }
            }
        )
        .navigationTitle("프로필 생성하기")
        // ✅ 여기서 destination을 등록하면,
        // 상위 스택(한 곳)에서 이 매핑을 사용한다. (중첩 스택 아님)
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .signupCode:
                SignUpCodeStep(
                    isLoading: $isLoading,
                    errorMessage: $errorMessage,
                    onSubmit: { code in
                        await next { path.append(.signupPassword(email: "temp@example.com", code: code)) }
                    }
                )

            case .signupPassword:
                SignUpPasswordStep(
                    isLoading: $isLoading,
                    errorMessage: $errorMessage,
                    onSubmit: { pwd, confirm in
                        await next { path.append(.signupDone) }
                    }
                )

            case .signupDone:
                SignUpDoneView(email: email)

            // 그 외 라우트는 이 화면에서 처리하지 않음
            default:
                EmptyView()
            }
        }
    }

    /// 비동기 작업 후 메인에서 경로 변경을 보장하는 헬퍼
    private func next(_ push: @escaping () -> Void) async {
        if isLoading { return }
        isLoading = true
        errorMessage = nil
        // 실제로는 네트워크/검증 로직이 들어갈 자리
        // try await api.validate(...)
        try? await Task.sleep(nanoseconds: 150_000_000) // 데모용 딜레이
        await MainActor.run {
            push()
            isLoading = false
        }
    }
}

// MARK: - STEP 1: 이메일
private struct SignUpEmailStep: View {
    @Binding var email: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?

    let onSubmit: (_ email: String) async -> Void

    var body: some View {
        VStack(spacing: 16) {
            TextField("E-mail", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.4)))

            Button {
                Task { await onSubmit(email) }
            } label: {
                Text(isLoading ? "전송 중..." : "다음")
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(isLoading || email.isEmpty ? .gray : .blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(isLoading || email.isEmpty)

            if let e = errorMessage {
                Text(e).foregroundColor(.red).font(.footnote)
            }
            Spacer()
        }
        .padding(24)
    }
}

// MARK: - STEP 2: 코드 입력
private struct SignUpCodeStep: View {
    @State private var code: String = ""
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?

    let onSubmit: (_ code: String) async -> Void

    var body: some View {
        VStack(spacing: 16) {
            TextField("6자리 인증 코드", text: $code)
                .keyboardType(.numberPad)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.4)))

            Button {
                Task { await onSubmit(code) }
            } label: {
                Text(isLoading ? "확인 중..." : "다음")
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(isLoading || code.isEmpty ? .gray : .blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(isLoading || code.isEmpty)

            if let e = errorMessage {
                Text(e).foregroundColor(.red).font(.footnote)
            }
            Spacer()
        }
        .padding(24)
        .navigationTitle("이메일 인증")
    }
}

// MARK: - STEP 3: 비밀번호
private struct SignUpPasswordStep: View {
    @State private var password: String = ""
    @State private var confirm: String = ""
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?

    let onSubmit: (_ password: String, _ confirm: String) async -> Void

    var body: some View {
        VStack(spacing: 16) {
            SecureField("새 비밀번호", text: $password)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.4)))

            SecureField("비밀번호 확인", text: $confirm)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(.gray.opacity(0.4)))

            Button {
                Task { await onSubmit(password, confirm) }
            } label: {
                Text(isLoading ? "설정 중..." : "완료")
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(isLoading || password.isEmpty || confirm.isEmpty ? .gray : .blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(isLoading || password.isEmpty || confirm.isEmpty)

            if let e = errorMessage {
                Text(e).foregroundColor(.red).font(.footnote)
            }
            Spacer()
        }
        .padding(24)
        .navigationTitle("비밀번호 설정")
    }
}

// MARK: - 완료
private struct SignUpDoneView: View {
    let email: String
    var body: some View {
        VStack(spacing: 16) {
            Text("회원가입 완료 🎉")
                .font(.title2).bold()
            Text(email)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(24)
        .navigationTitle("완료")
    }
}

// 미리보기는 더미 path로
#Preview {
    // 미리보기용 더미 루트 path
    StatefulPreview { (path: Binding<[Route]>) in
        NavigationStack(path: path) {
            SignUpFlowView(path: path)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .signup: EmptyView() // 실제 진입은 외부에서 .signup push로 들어온다고 가정
                    case .signupCode: EmptyView()
                    case .signupPassword: EmptyView()
                    case .signupDone: EmptyView()
                    default: EmptyView()
                    }
                }
        }
    }
}

/// 미리보기 헬퍼
private struct StatefulPreview<Content: View, T>: View where T: MutableCollection & RangeReplaceableCollection, T: RandomAccessCollection, T.Element: Hashable {
    @State private var state: T = .init()
    let content: (Binding<T>) -> Content
    init(@ViewBuilder _ content: @escaping (Binding<T>) -> Content) {
        self.content = content
    }
    var body: some View { content($state) }
}
