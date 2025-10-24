//
//  BirthYearSelectionView.swift
//  WAVI
//
//  Created by 서영채 on 9/11/25.
//

import SwiftUI

struct BirthYearSelectionView: View {
    @Binding var path: [Route] // NavigationStack 경로를 받기 위한 바인딩
    @Environment(\.dismiss) private var dismiss
    
    // 이전 단계에서 전달받은 데이터
    let email: String
    let code: String
    let password: String
    let nickname: String
    let gender: String
    
    @State private var birthyear = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // 백엔드 서비스 (나중에 나이 업데이트 API 연결)
    // private let userService = BackendUserService() // TODO: 구현 예정
    
    var body: some View {
        VStack() {
            HStack {
                Button(action: {
                    dismiss() // 뒤로가기 액션
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
            .padding(.bottom, 40)
            
            
            VStack(alignment: .leading, spacing: 10) {
                Text("나이를\n입력해주세요")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(Color.PrimaryOnBoardinBlue)
                    .padding(.top, 80)
                
                Text("개인화된 서비스를 위해 필요한 정보입니다.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                CustomTextField(
                    placeholder: "출생연도를 선택해주세요",
                    text: $birthyear,
                    keyboardType: .numberPad // 숫자 키보드 표시
                )
                
                Spacer()
                
                NextButton(
                    title: isLoading ? "저장 중..." : "다음으로",
                    isEnabled: !birthyear.isEmpty && !isLoading
                ) {
                    print("출생연도: \(birthyear)")
                    Task {
                        await saveBirthYear()
                    }
                }
                .disabled(birthyear.isEmpty || isLoading)
                
                // 에러 메시지 표시
                if showError {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.primaryRed)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.horizontal, 24)
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - 출생연도 저장 함수
    @MainActor
    private func saveBirthYear() async {
        guard !birthyear.isEmpty else {
            showError = true
            errorMessage = "출생연도를 입력해주세요."
            return
        }
        
        // 출생연도 유효성 검사
        guard let year = Int(birthyear), year >= 1900, year <= Calendar.current.component(.year, from: Date()) else {
            showError = true
            errorMessage = "올바른 출생연도를 입력해주세요."
            return
        }
        
        isLoading = true
        showError = false
        
        do {
            // TODO: 백엔드 API 연결 (사용자 프로필 업데이트)
            // let result = try await userService.updateBirthYear(birthYear: year)
            
            // 임시로 Mock 처리 (성공으로 가정)
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기 (API 호출 시뮬레이션)
            
            print("✅ 출생연도 저장 성공: \(year)")
            
            // 성공 시 다음 화면으로 이동 (직업 선택) - 모든 데이터 전달
            path.append(.jobSelection(
                email: email,
                code: code,
                password: password,
                nickname: nickname,
                gender: gender,
                birthYear: "\(year)년생"
            ))
            
        } catch {
            print("❌ 출생연도 저장 실패: \(error)")
            showError = true
            errorMessage = "출생연도 저장에 실패했습니다. 다시 시도해주세요."
        }
        
        isLoading = false
    }
}

struct BirthYearSelectionView_Previews: PreviewProvider {
    @State static var path: [Route] = []
    static var previews: some View {
        BirthYearSelectionView(
            path: $path,
            email: "test@example.com",
                code: "123456",
            password: "password123",
            nickname: "테드",
            gender: "남성"
        )
    }
}
