//
//  OnboardingLoginView.swift
//  WAVI
//
//  Created by 박현빈 on 9/29/25.
//

import SwiftUI

/// 온보딩 첫 화면의 "콘텐츠" 뷰.
/// - NavigationStack 은 루트에서만 소유하고, 이 뷰는 @Binding path 로만 푸시합니다.
struct OnboardingLoginView: View {
    @Binding var path: [Route]      // 루트 스택의 경로를 바인딩으로 받음

    var body: some View {
        ZStack {
            // OnboardingImageExport 이미지를 배경으로 사용
            Image("OnboardingImageExport")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            VStack {
                Spacer()
                Spacer()
                OnboardingLoginBlock {
                    path.append(.emailLogin)   // 이메일 로그인 화면으로 push
                }
                .padding(.top, 300)
                Spacer()
            }
        }
    }
}

struct OnboardingLoginBlock: View {
    let onEmailContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("A WAY TO\nVICTORY")
                .foregroundColor(.baseWhite)
                .typography(Typography.Headline2)
                .textCase(.uppercase)

            Text("수십 번, 수백 번 실패하더라도 성공하는 그 날까지.")
                .foregroundColor(.baseWhite.opacity(0.9))
                .typography(Typography.Body1)
                .padding(.bottom, 10)

            Button(action: onEmailContinue) {
                HStack(spacing: 8) {
                    Image("envelope")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("이메일로 계속하기")
                        .typography(Typography.Body3)
                }
                .foregroundColor(.baseBlack)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(Color.baseWhite)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.baseWhite.opacity(0.0), lineWidth: 1))
            }
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)

            HStack(spacing: 12) {
                SocialPillButton(title: "Apple", icon: Image(systemName: "apple.logo")) { }
                SocialPillButton(title: "Google", icon: Image("logo_google")) { }
                SocialPillButton(title: "Facebook", icon: Image("logo_facebook")) { }
            }

            Text("By continuing you agree on Terms of Services & Private Policy")
                .multilineTextAlignment(.center)
                .foregroundColor(.baseWhite.opacity(0.8))
                .typography(Typography.Chip)
        }
        .padding(.horizontal, 24)
        .frame(width: 393, height: 312)
        .background(Color.clear)
    }
}

struct SocialPillButton: View {
    let title: String
    let icon: Image?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                }
                Text(title)
                    .typography(Typography.Body3)
            }
            .foregroundColor(.baseBlack)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.baseWhite)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.baseBlack.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview (미리보기용)
//
// ⚠️ 미리보기에서만 NavigationStack 을 만들어 바인딩을 공급합니다.
// 실제 앱에서는 루트에서 단 한 번만 NavigationStack 을 생성하세요.
#Preview {
    PreviewContainer()
}

private struct PreviewContainer: View {
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            OnboardingLoginView(path: $path)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .emailLogin:
                        Text("Email Login Placeholder")
                            .navigationTitle("이메일로 계속하기")
                    case .main:
                        Text("Main Placeholder")
                    case .profileCreation:
                        Text("Profile Creation Placeholder")
                    case .verificationCode(let email):
                        Text("Verification Code Placeholder for \(email)")
                    case .signup, .signupCode, .signupPassword, .signupDone, .profileGeneration, .nicknameSelection, .genderSelection, .ageInput, .jobSelection, .profileComplete:
                        Text("Signup Flow Placeholder")
                    case .habitList:
                        Text("Habit List Placeholder")
                    case .habitModify(let habit):
                        Text("Habit Modify Placeholder for \(habit.name)")
                    case .addingHabits:
                        Text("Adding Habits Placeholder")
                    case .report:
                        Text("Report Placeholder")
                    case .settings:
                        Text("Settings Placeholder")
                    }
                }
        }
    }
}
