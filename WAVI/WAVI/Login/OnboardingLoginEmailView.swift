import SwiftUI

struct OnboardingLoginEmailView: View {
    @Binding var path: [Route]                 // ✅ 루트의 경로 바인딩
    @StateObject private var vm: EmailLoginVM
    @Environment(\.dismiss) private var dismiss

    init(path: Binding<[Route]>, service: AuthService = BackendAuthService(), authManager: AuthManager) {
        _path = path
        _vm = StateObject(wrappedValue: EmailLoginVM(service: service, authManager: authManager))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 24, height: 24)
                    
                }
                .padding(.trailing, 6)
                Text("이메일로 계속하기")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.black80)
                
              
                
                // Invisible spacer to center the title
                //Color.clear
                   // .frame(width: 24, height: 24)
            }
            .padding(.top, 20)
            .padding(.trailing, 161)
            .padding(.leading, 24)
            .padding(.bottom, 160)
            
            Image("Logo_wavi")
                .padding(.bottom, 47)
              
            
            // Input Fields
            VStack(spacing: 30) {
                // Email Input
                HStack {
                    TextField("E-mail", text: $vm.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#9B9BA1"))
                        .tracking(-0.5)
                    
                    if !vm.email.isEmpty {
                        Button(action: { vm.email = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(hex: "#9B9BA1"))
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.black40, lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 40)
                                .fill(Color.baseBackground)
                        )
                )

                // Password Input
                HStack {
                    SecureField("Password", text: $vm.password)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primaryBlack)
                        .tracking(-0.5)
                    
                    if !vm.password.isEmpty {
                        Button(action: { vm.password = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.primaryBlack)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.black40, lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 40)
                                .fill(Color.baseBackground)
                        )
                )
                
                // Forgot Password Link
                HStack {
                    Spacer()
                    Button("비밀번호를 잊으셨나요?") {
                        // TODO: Implement forgot password
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black60)
                    .tracking(-0.5)
                }
            }
            .padding(.horizontal, 20)

            
            // Login Button
            Button { Task { await vm.login() } } label: {
                Text(vm.isLoading ? "로그인 중..." : "로그인하기")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.baseWhite)
                    .tracking(-0.5)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(
                                vm.isLoading ? Color.gray :
                                    (vm.email.isEmpty || vm.password.isEmpty) ? Color.black20 : Color.primaryBlack
                            )
                    )
            }
            .disabled(vm.isLoading || vm.email.isEmpty || vm.password.isEmpty)
            .padding(.horizontal, 20)
            .padding(.top, 24)

            if let msg = vm.errorMessage {
                Text(msg)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }

            // Sign Up Link
            Button {
                print("before push, path.count =", path.count)
                path.append(.profileCreation)            // ✅ 프로필 생성으로 push
                print("after push, path.count =", path.count)
            } label: {
                Text("새로운 계정 만들기")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black60)
                    .tracking(-0.5)
                    .padding(.top, 24)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .background(Color.baseBackground)
        .navigationBarBackButtonHidden(true)  // 시스템 뒤로가기 버튼 숨기기
        .onChange(of: vm.loginSucceeded) { _, ok in
            if ok { path.append(.main) }        // ✅ 로그인 성공 → 메인
        }
    }
}

#Preview {
    @State var path: [Route] = []
    @StateObject var authManager = AuthManager()
    
    return NavigationStack(path: $path) {
        OnboardingLoginEmailView(path: $path, authManager: authManager)
    }
    .environmentObject(authManager)
}
