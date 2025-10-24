//
//  GenderSelectionView.swift
//  WAVI
//
//  Created by 서영채 on 9/11/25.
//

import SwiftUI

struct GenderSelectionView: View {
    @Binding var path: [Route] // NavigationStack 경로를 받기 위한 바인딩
    @Environment(\.dismiss) private var dismiss
    
    // 이전 단계에서 전달받은 데이터
    let email: String
    let code: String
    let password: String
    let nickname: String
    
    @State private var maleSelected = false
    @State private var femaleSelected = false
    @State private var notSelected = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // 백엔드 서비스 (나중에 성별 업데이트 API 연결)
    // private let userService = BackendUserService() // TODO: 구현 예정
    
    private var selectedGender: String? {
        if maleSelected {
            return "남성"
        } else if femaleSelected {
            return "여성"
        } else if notSelected {
            return "선택 안 함"
        } else {
            return nil
        }
    }
    
    var body: some View {
      
        VStack() {
            // 상단 네비게이션
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
            
            
            VStack(alignment: .leading, spacing: 10) {
                // 타이틀
                Text("성별을\n입력해주세요")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(Color.PrimaryOnBoardinBlue)
                    .padding(.top, 80)
                
                Text("개인화된 서비스를 위해 필요한 정보입니다.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom, 45)
                
                // 선택 카드
                HStack(spacing: 20) {
                    SelectionCard(title: "남성", isSelected: $maleSelected)
                    SelectionCard(title: "여성", isSelected: $femaleSelected)
                    SelectionCard(title: "선택 안 함", isSelected: $notSelected)
                }
                
                Spacer()
                
                // 버튼 활성화/비활성화 로직
                NextButton(
                    title: isLoading ? "저장 중..." : "다음으로",
                    isEnabled: selectedGender != nil && !isLoading
                ) {
                    if let gender = selectedGender {
                        print("선택된 성별: \(gender)")
                        Task {
                            await saveGender(gender)
                        }
                    }
                }
                .disabled(selectedGender == nil || isLoading)
                
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
            // 선택된 버튼 유지 로직
            .onChange(of: maleSelected) { newValue in
                if newValue {
                    femaleSelected = false
                    notSelected = false
                }
            }
            .onChange(of: femaleSelected) { newValue in
                if newValue {
                    maleSelected = false
                    notSelected = false
                }
            }
            .onChange(of: notSelected) { newValue in
                if newValue {
                    maleSelected = false
                    femaleSelected = false
                }
            }
        }
    }
    
    // MARK: - 성별 저장 함수
    @MainActor
    private func saveGender(_ gender: String) async {
        isLoading = true
        showError = false
        
        do {
            // TODO: 백엔드 API 연결 (사용자 프로필 업데이트)
            // let result = try await userService.updateGender(gender: gender)
            
            // 임시로 Mock 처리 (성공으로 가정)
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기 (API 호출 시뮬레이션)
            
            print("✅ 성별 저장 성공: \(gender)")
            
            // 성공 시 다음 화면으로 이동 (나이 입력) - 모든 데이터 전달
            path.append(.ageInput(
                email: email,
                code: code,
                password: password,
                nickname: nickname,
                gender: gender
            ))
            
        } catch {
            print("❌ 성별 저장 실패: \(error)")
            showError = true
            errorMessage = "성별 저장에 실패했습니다. 다시 시도해주세요."
        }
        
        isLoading = false
    }
}

struct GenderSelectionView_Previews: PreviewProvider {
    @State static var path: [Route] = []
    static var previews: some View {
        GenderSelectionView(
            path: $path,
            email: "test@example.com",
                code: "123456",
            password: "password123",
            nickname: "테드"
        )
    }
}
