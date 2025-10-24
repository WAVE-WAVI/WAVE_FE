import SwiftUI

struct ProfileCreationView: View {
    @Binding var path: [Route]
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isValidEmail = false
    @State private var showValidationMessage = false
    @State private var validationMessage = ""
    
    private let signUpService = BackendSignUpService()
    
    // 디버깅을 위한 로그 추가
    init(path: Binding<[Route]>) {
        self._path = path
        print("🔍 ProfileCreationView: BackendSignUpService 사용 중")
    }
    
    var body: some View {
        ZStack{
            Color(hex: "#F1EFF2")
                .ignoresSafeArea()
            VStack() {
                
                // Custom Navigation Bar - 고정된 헤더
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
                
                
                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    
                    // Main Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("새로운 여정, WAVI와 함께")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.PrimaryOnBoardinBlue)
                            .lineLimit(2)
                            .frame(width: 310, alignment: .leading)
                        
                        Text("WAVI를 이용할 E-mail 주소를 확인합니다.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black40)
                            .tracking(-0.5)
                    }
                    .frame(width: 346)
                    .padding(.bottom, 47)
                    
                    // Email Input Section
                    VStack(spacing: 8) {
                        // Email Input Field
                        HStack {
                            TextField("E-mail 주소를 입력하세요", text: $email)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black40)
                                .tracking(-0.5)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .onChange(of: email) { _, newValue in
                                    validateEmail(newValue)
                                }
                            
                            if !email.isEmpty {
                                Button(action: {
                                    email = ""
                                    isValidEmail = false
                                    showValidationMessage = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.primaryBlack)
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        .frame(height: 52)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(Color.black40, lineWidth: 1.5)
                                .background(
                                    RoundedRectangle(cornerRadius: 40)
                                        .fill(Color.baseBackground)
                                )
                        )
                        
                        // Validation Message
                        if showValidationMessage {
                            HStack {
                                Spacer()
                                Text(validationMessage)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(isValidEmail ? .black80 : .red)
                                    .tracking(-0.5)
                                Spacer()
                            }
                            .frame(width: 345)
                            .padding(.horizontal, 10)
                        }
                    }
                    .frame(width: 346)
                    
                    Spacer()
                    
                    // Next Button
                    Button(action: {
                        print("다음으로 버튼 클릭됨")
                        print("isValidEmail: \(isValidEmail)")
                        print("email: \(email)")
                        if isValidEmail {
                            // 이메일 인증 시작
                            Task {
                                do {
                                    try await signUpService.initiateSignup(email: email)
                                    print("✅ 인증번호 발송 성공")
                                    // 인증번호 입력 화면으로 이동
                                    path.append(.verificationCode(email: email))
                                    print("path 추가 완료, 현재 path count: \(path.count)")
                                } catch {
                                    print("❌ 인증번호 발송 실패: \(error)")
                                    validationMessage = "인증번호 발송에 실패했습니다."
                                    showValidationMessage = true
                                }
                            }
                        } else {
                            print("이메일이 유효하지 않음")
                        }
                    }) {
                        Text("다음으로")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.baseWhite)
                            .tracking(-0.5)
                            .frame(width: 343, height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 40)
                                    .fill(isValidEmail ? Color.primaryBlack : Color.black20)
                            )
                    }
                    .disabled(false) // 임시로 항상 활성화
                    .padding(.bottom, 20)
                }
                
            }
            .background(Color.baseBackground)
            .navigationBarBackButtonHidden(true)  // 시스템 뒤로가기 버튼 숨기기
            .navigationBarHidden(true)  // 전체 네비게이션 바 숨기기
        }
    }
    
    private func validateEmail(_ email: String) {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if email.isEmpty {
            isValidEmail = false
            showValidationMessage = false
            return
        }
        
        // 먼저 이메일 형식 검증
        if !emailPredicate.evaluate(with: email) {
            isValidEmail = false
            showValidationMessage = true
            validationMessage = "올바른 E-mail 주소를 입력해주세요."
            return
        }
        
        // 이메일 형식만 검증 (중복 검사는 회원가입 시 처리)
        isValidEmail = true
        showValidationMessage = true
        validationMessage = "사용 가능한 E-mail 주소입니다!"
    }
    
}

#Preview {
    ProfileCreationView(path: .constant([]))
}
