//
//  SetPasswordView.swift
//  WAVI
//
//  Created by 서영채 on 9/11/25.
//

import SwiftUI

struct SetPasswordView: View {
    @Binding var path: [Route]
    @Environment(\.dismiss) private var dismiss
    
    let email: String // 이전 화면에서 전달받은 이메일
    let code: String  // 인증번호
    
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showMismatchError = false
    @State private var isLoading = false
    
    // 임시로 Mock 서비스 사용 (백엔드 엔드포인트 404 에러로 인해)
    private let signUpService = BackendSignUpService()
    
    var body: some View {
        
        VStack() {
            HStack {
                Button(action: {
                    dismiss()
                    print("뒤로가기")
                }) {
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
            
            VStack(alignment: .leading, spacing: 10) {
                Text("비밀번호를\n설정하세요")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(Color.PrimaryOnBoardinBlue)
                    .padding(.top, 80)
                
                Text("언제든 비밀번호를 새롭게 재설정할 수 있습니다.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                
                CustomSecureField(
                    placeholder: "새로운 비밀번호를 입력하세요",
                    text: $password
                )
                .padding(.bottom,20)
                
                CustomSecureField(
                    placeholder: "새로운 비밀번호를 확인해주세요",
                    text: $confirmPassword
                )
                // 비밀번호 불일치 시 에러 메시지
                if showMismatchError {
                    Text("비밀번호가 서로 일치하지 않습니다!")
                        .font(.system(size: 14))
                        .foregroundColor(.primaryRed)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                Spacer()
                
                NextButton(
                    title: isLoading ? "회원가입 중..." : "다음으로",
                    isEnabled: !password.isEmpty && !confirmPassword.isEmpty && !isLoading
                ) {
                    // 비밀번호 일치 여부 확인 (버튼 클릭 시에만)
                    if password == confirmPassword {
                        showMismatchError = false
                        print("✅ 비밀번호 일치!")
                        Task {
                            await completeSignup()
                        }
                    } else {
                        showMismatchError = true
                        print("❌ 비밀번호 불일치!")
                    }
                }
                .disabled(password.isEmpty || confirmPassword.isEmpty)
            }
            .padding(.horizontal, 24)
            .navigationBarHidden(true)
        }
    }
    
    @MainActor
    private func completeSignup() async {
        // 이미 버튼 클릭 시 검증했으므로 여기서는 빈 값만 체크
        guard !password.isEmpty && !confirmPassword.isEmpty else {
            showMismatchError = true
            return
        }
        
        isLoading = true
        
        // 비밀번호 입력 후 프로필 생성 화면으로 이동
        // 인증 코드는 모든 정보를 입력한 후에 요청
        print("✅ 비밀번호 설정 완료")
        print("📝 다음 단계: 프로필 정보 입력")
        path.append(.profileGeneration(email: email, code: code, password: password))
        
        isLoading = false
    }
}
    
struct SetPasswordView_Previews: PreviewProvider {
    @State static var path: [Route] = []
    static var previews: some View {
        SetPasswordView(
            path: $path,
            email: "test@example.com",
            code: "123456"
        )
    }
}

