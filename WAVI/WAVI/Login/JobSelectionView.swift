//
//  JobSelectionView.swift
//  WAVI
//
//  Created by 서영채 on 9/19/25.
//

import SwiftUI

struct JobSelectionView: View {
    @Binding var path: [Route] // NavigationStack 경로를 받기 위한 바인딩
    @Environment(\.dismiss) private var dismiss
    
    // 이전 단계에서 전달받은 데이터
    let email: String
    let code: String
    let password: String
    let nickname: String
    let gender: String
    let birthYear: String
    
    @State private var studentSelected = false
    @State private var workerSelected = false
    @State private var selfEmployedSelected = false
    @State private var notSelectedSelected = false // "선택 안 함" 항목
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // 백엔드 서비스 (나중에 직업 업데이트 API 연결)
    // private let userService = BackendUserService() // TODO: 구현 예정
    
    // 선택된 직업을 추적하는 계산 프로퍼티
    private var selectedJob: String? {
        if studentSelected {
            return "학생"
        } else if workerSelected {
            return "직장인"
        } else if selfEmployedSelected {
            return "자영업"
        } else if notSelectedSelected {
            return "선택 안 함"
        } else {
            return nil
        }
    }
    
    var body: some View {
        VStack{
            
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
                Text("직업을\n선택해주세요")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(Color.PrimaryOnBoardinBlue)
                    .padding(.top, 80)
                
                Text("개인화된 서비스를 위해 필요한 정보입니다.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                HStack(spacing: 20) {
                    SelectionCard(title: "학생", isSelected: $studentSelected, width: 160)
                    SelectionCard(title: "직장인", isSelected: $workerSelected, width: 160)
                }
                HStack(spacing: 20) {
                    SelectionCard(title: "자영업", isSelected: $selfEmployedSelected, width: 160)
                    SelectionCard(title: "선택 안 함", isSelected: $notSelectedSelected, width: 160)
                }
                
                Spacer()
                
                NextButton(
                    title: isLoading ? "저장 중..." : "다음으로",
                    isEnabled: selectedJob != nil && !isLoading
                ) {
                    if let job = selectedJob {
                        print("선택된 직업: \(job)")
                        Task {
                            await saveJob(job)
                        }
                    }
                }
                .disabled(selectedJob == nil || isLoading)
                
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
            .onChange(of: studentSelected) { newValue in
                if newValue {
                    workerSelected = false
                    selfEmployedSelected = false
                    notSelectedSelected = false
                }
            }
            .onChange(of: workerSelected) { newValue in
                if newValue {
                    studentSelected = false
                    selfEmployedSelected = false
                    notSelectedSelected = false
                }
            }
            .onChange(of: selfEmployedSelected) { newValue in
                if newValue {
                    studentSelected = false
                    workerSelected = false
                    notSelectedSelected = false
                }
            }
            .onChange(of: notSelectedSelected) { newValue in
                if newValue {
                    studentSelected = false
                    workerSelected = false
                    selfEmployedSelected = false
                }
            }
        }
    }
    
    // MARK: - 직업 저장 함수
    @MainActor
    private func saveJob(_ job: String) async {
        isLoading = true
        showError = false
        
        do {
            // TODO: 백엔드 API 연결 (사용자 프로필 업데이트)
            // let result = try await userService.updateJob(job: job)
            
            // 임시로 Mock 처리 (성공으로 가정)
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기 (API 호출 시뮬레이션)
            
            print("✅ 직업 저장 성공: \(job)")
            
            // 성공 시 다음 화면으로 이동 (프로필 완성) - 모든 데이터 전달
            path.append(.profileComplete(
                email: email,
                code: "123456",
                password: password,
                nickname: nickname,
                gender: gender,
                birthYear: birthYear,
                job: job
            ))
            
        } catch {
            print("❌ 직업 저장 실패: \(error)")
            showError = true
            errorMessage = "직업 저장에 실패했습니다. 다시 시도해주세요."
        }
        
        isLoading = false
    }
}

struct JobSelectionView_Previews: PreviewProvider {
    @State static var path: [Route] = []
    static var previews: some View {
        JobSelectionView(
            path: $path,
            email: "test@example.com",
                code: "123456",
            password: "password123",
            nickname: "테드",
            gender: "남성",
            birthYear: "1995년생"
        )
    }
}
