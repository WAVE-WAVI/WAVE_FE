//
//  VerificationCodeInputView.swift
//  WAVI
//
//  Created by 박현빈 on 9/23/25.
//

import SwiftUI

struct VerificationCodeInputView: View {
    @Binding var path: [Route]
    @Environment(\.dismiss) private var dismiss
    
    let email: String // 이전 화면에서 전달받은 이메일
    
    @State private var code: [String] = ["", "", "", "", "", ""] // 6자리 코드 입력
    @State private var isCodeValid = false
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    @State private var isVerifying = false
    @FocusState private var focusedField: Int? // 포커스 관리
    
    private let signUpService = BackendSignUpService()
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar (이전 화면과 동일)
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 24, height: 24)
                }
                .padding(.trailing, 12)
                Text("프로필 생성하기")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.black80)
                // Invisible spacer to center the title
                //Color.clear
                // .frame(width: 24, height: 24)
            }
            .padding(.top, 20)
            .padding(.trailing, 182)
            .padding(.leading, 24)
                                
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 47) {
                // 헤더 섹션
                VStack(alignment: .leading, spacing: 8) {
                    Text("인증코드를\n입력하세요")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.PrimaryOnBoardinBlue)
                        .lineSpacing(8)
                        .frame(width: 310, alignment: .leading)
                    
                    Text("\(email)으로 인증 코드를 보냈습니다.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black40)
                        .tracking(-0.5)
                        .lineSpacing(6)
                }
                
                // 인증번호 입력하는 6개 박스
                HStack(spacing: 10) {
                    ForEach(0..<6) { index in
                        CodeInputBox(
                            text: $code[index],
                            isError: showErrorMessage,
                            focusedField: $focusedField,
                            index: index
                        )
                        .onChange(of: code[index]) { newValue in
                            handleCodeInput(newValue, at: index)
                        }
                    }
                }
                .frame(width: 345)
                
                // 에러 메시지 표시
                if showErrorMessage && !errorMessage.isEmpty {
                    HStack {
                        Spacer()
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primaryRed)
                            .tracking(-0.5)
                        Spacer()
                    }
                    .frame(width: 345)
                    .padding(.horizontal, 10)
                }
                
                // "E-mail 주소가 틀렸나요?" 링크
                HStack {
                    Spacer()
                    Button("E-mail 주소가 틀렸나요?") {
                        // 이전 화면으로 돌아가기
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.PrimaryOnBoardinBlue)
                    .tracking(-0.5)
                    .multilineTextAlignment(.trailing)
                }
                .frame(width: 345)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // "다음으로" 버튼
            Button {
                Task {
                    await verifyCode()
                }
            } label: {
                Text(isVerifying ? "확인 중..." : "다음으로")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.baseWhite)
                    .tracking(-0.5)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(isCodeValid ? Color.green100 : Color.black20)
                    )
            }
            .disabled(!isCodeValid || isVerifying)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .navigationBarHidden(true)
        .onAppear {
            focusedField = 0 // 화면 진입 시 첫 번째 입력 필드에 포커스
            // 인증 코드는 이전 화면(SetPasswordView)에서 이미 전송됨
        }
    }
    
    // MARK: - Helper Views
    struct CodeInputBox: View {
        @Binding var text: String
        let isError: Bool
        @FocusState.Binding var focusedField: Int?
        let index: Int
        
        var body: some View {
            TextField("", text: $text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(isError ? .primaryRed : .black80)
                .frame(width: 50, height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isError ? Color.primaryRed : Color.black80, lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.baseBackground)
                        )
                )
                .focused($focusedField, equals: index)
                .onChange(of: text) { newValue in
                    if newValue.count > 1 {
                        text = String(newValue.prefix(1)) // 한 글자만 허용
                    }
                }
                
        }
    }
    
    // MARK: - Logic
    private func handleCodeInput(_ newValue: String, at index: Int) {
        if newValue.count == 1 {
            if index < 5 {
                focusedField = index + 1 // 다음 필드로 포커스 이동
            } else {
                focusedField = nil // 마지막 필드면 포커스 해제
            }
        } else if newValue.isEmpty {
            if index > 0 {
                focusedField = index - 1 // 이전 필드로 포커스 이동
            }
        }
        
        // 모든 필드가 채워졌는지 확인
        isCodeValid = code.allSatisfy { !$0.isEmpty }
        showErrorMessage = false // 입력 시 에러 메시지 숨김
    }
    
    private func sendVerificationCode() {
        Task {
            do {
                try await signUpService.initiateSignup(email: email)
                print("인증 코드가 \(email)으로 전송되었습니다.")
            } catch {
                errorMessage = "인증 코드 전송에 실패했습니다: \(error.localizedDescription)"
                showErrorMessage = true
                print("인증 코드 전송 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func verifyCode() async {
        let enteredCode = code.joined()
        guard enteredCode.count == 6 else {
            errorMessage = "6자리 인증 코드를 모두 입력해주세요."
            showErrorMessage = true
            isCodeValid = false
            return
        }
        
        isVerifying = true
        
        // 인증번호를 저장하고 비밀번호 설정 화면으로 이동
        // (실제 인증은 회원가입 완료 시 함께 진행)
        print("✅ 인증번호 입력 완료: \(enteredCode)")
        print("📝 다음 단계: 비밀번호 설정")
        
        // 비밀번호 설정 화면으로 이동 (이메일 + 인증번호 전달)
        path.append(.signupPassword(email: email, code: enteredCode))
        
        isVerifying = false
    }
}

struct VerificationCodeInputView_Previews: PreviewProvider {
    @State static var path: [Route] = []
    static var previews: some View {
        VerificationCodeInputView(path: $path, email: "tedkim00@hotmail.com")
    }
}
