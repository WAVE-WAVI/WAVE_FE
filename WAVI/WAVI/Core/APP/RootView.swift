// RootView.swift
import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var path: [Route] = []   // 루트에서만 스택 경로를 보유

    var body: some View {
        if auth.isLoggedIn {
            MainHeaderView()
        } else {
            NavigationStack(path: $path) {
                // 온보딩 첫 화면 (스택 없음, 바인딩만 받아서 push)
                OnboardingLoginView(path: $path)
                    // 루트에서 한 번만 매핑
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .emailLogin:
                            OnboardingLoginEmailView(path: $path, authManager: auth)

                        case .signup:
                            // ⛳️ 오류 원인 해결: 바인딩 전달
                            SignUpFlowView(path: $path)

                        case .main:
                            MainHeaderView()
                            
                        case .profileCreation:
                            ProfileCreationView(path: $path)
                            
                        case .verificationCode(let email):
                            VerificationCodeInputView(path: $path, email: email)

                        // 회원가입 세부 단계는 SignUpFlowView 내부에서 매핑하므로 여기선 생략
                        case .signupCode, .signupDone:
                            EmptyView()
                        case .signupPassword(let email, let code):
                            SetPasswordView(path: $path, email: email, code: code)
                            
                        // 새로운 프로필 생성 플로우
                        case .profileGeneration(let email, let code, let password):
                            ProfileGenerationView(path: $path, email: email, code: code, password: password)
                               case .nicknameSelection(let email, let code, let password):
                                   NicknameSelectionView(path: $path, email: email, code: code, password: password)
                        case .genderSelection(let email, let code, let password, let nickname):
                            GenderSelectionView(path: $path, email: email, code: code, password: password, nickname: nickname)
                        case .ageInput(let email, let code, let password, let nickname, let gender):
                            BirthYearSelectionView(path: $path, email: email, code: code, password: password, nickname: nickname, gender: gender)
                        case .jobSelection(let email, let code, let password, let nickname, let gender, let birthYear):
                            JobSelectionView(path: $path, email: email, code: code, password: password, nickname: nickname, gender: gender, birthYear: birthYear)
                        case .profileComplete(let email, let code, let password, let nickname, let gender, let birthYear, let job):
                            CompleteProfileView(path: $path, email: email, code: code, password: password, nickname: nickname, gender: gender, birthYear: birthYear, job: job)
                            
                        case .habitList:
                            HabitListView { habit in
                                // 로그인 플로우에서는 습관 수정을 지원하지 않음
                                print("습관 선택됨: \(habit.name)")
                            }
                        case .habitModify(let habit):
                            HabitModifyView(habit: habit)
                        case .addingHabits:
                            AddingHabitsMainView()
                        case .report:
                            ReportView()
                        case .settings:
                            SettingView()
                        }
                    }
            }
        }
    }
}

