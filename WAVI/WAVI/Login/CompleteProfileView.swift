//
//  CompleteProfileView.swift
//  WAVI
//
//  Created by 서영채 on 9/30/25.
//

import SwiftUI

struct CompleteProfileView: View {
    @Binding var path: [Route]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var auth: AuthManager
    
    // 이전 단계에서 전달받은 데이터
    let email: String
    let code: String
    let password: String
    let nickname: String
    let gender: String
    let birthYear: String
    let job: String
    
    @State private var editableField: String? = nil  // 현재 수정 중인 필드
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // 편집 가능한 데이터 (로컬 복사본)
    @State private var editableNickname: String
    @State private var editableGender: String
    @State private var editableBirthYear: String
    @State private var editableJob: String
    
    // 백엔드 서비스 사용 (올바른 엔드포인트로 수정됨)
    private let signUpService = BackendSignUpService()
    
    // 프론트엔드 -> 백엔드 매핑 함수들
    private func mapGenderToBackend(_ gender: String) -> String {
        switch gender {
        case "남성": return "MALE"
        case "여성": return "FEMALE"
        default: return "UNKNOWN"
        }
    }
    
    private func mapJobToBackend(_ job: String) -> String {
        switch job {
        case "학생": return "STUDENT"
        case "직장인": return "SALARYMAN"
        case "자영업": return "CEO"
        case "선택 안 함": return "JOBLESS"
        default: return "JOBLESS"
        }
    }
    
    private func mapBirthYearToInt(_ birthYear: String) -> Int {
        // "1995년생" -> 1995
        let yearString = birthYear.replacingOccurrences(of: "년생", with: "")
        return Int(yearString) ?? 1995
    }
    
    init(path: Binding<[Route]>, email: String, code: String, password: String, nickname: String, gender: String, birthYear: String, job: String) {
        self._path = path
        self.email = email
        self.code = code
        self.password = password
        self.nickname = nickname
        self.gender = gender
        self.birthYear = birthYear
        self.job = job
        
        // 로컬 편집 가능한 복사본 초기화
        self._editableNickname = State(initialValue: nickname)
        self._editableGender = State(initialValue: gender)
        self._editableBirthYear = State(initialValue: birthYear)
        self._editableJob = State(initialValue: job)
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#F1EFF2")
                .ignoresSafeArea()
            
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
            .padding(.bottom, 40)
           
            
            VStack(alignment: .leading, spacing: 5) {
                Text("최종 프로필을\n확인해주세요")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(Color.PrimaryOnBoardinBlue)
                    .padding(.top, 10)
                   
                
                Text("새로운 여정을 시작할 준비가 끝났어요!")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.bottom, 25)
                
                // ✅ 필드들
                profileField(title: "닉네임", text: $editableNickname, isEditing: editableField == "nickname") {
                    editableField = "nickname"
                }
                
                profileField(title: "성별", text: $editableGender, isEditing: editableField == "gender") {
                    editableField = "gender"
                }
                
                profileField(title: "나이", text: $editableBirthYear, isEditing: editableField == "birthYear") {
                    editableField = "birthYear"
                }
                
                profileField(title: "직업", text: $editableJob, isEditing: editableField == "job") {
                    editableField = "job"
                }
                
                Spacer()
                
                NextButton(
                    title: isLoading ? "가입 중..." : "시작하기",
                    isEnabled: !isLoading
                ) {
                    print("최종 프로필: \(editableNickname), \(editableGender), \(editableBirthYear), \(editableJob)")
                    Task {
                        await completeSignup()
                    }
                }
                .disabled(isLoading)
                
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
    }
    
    // 공통 프로필 입력칸
    @ViewBuilder
    func profileField(title: String, text: Binding<String>, isEditing: Bool, onEditTap: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            ZStack(alignment: .trailing) {
                // 기존 CustomTextField 사용
                CustomTextField(placeholder: "", text: text)
                    .disabled(!isEditing) // 수정 버튼 눌렀을 때만 편집 가능
                
                // 오른쪽 수정 아이콘
                Button(action: onEditTap) {
                    Image(systemName: "square.and.pencil.circle.fill")
                        .foregroundColor(Color.PrimaryOnBoardinBlue)
                        .font(.system(size: 20))
                        .padding(.trailing, 16)
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - 최종 회원가입 완료 함수
    @MainActor
    private func completeSignup() async {
        isLoading = true
        showError = false
        
        do {
            print("🚀 회원가입 요청 시작")
            print("📧 이메일: \(email)")
            print("👤 닉네임: \(editableNickname)")
            print("⚧ 성별: \(editableGender) -> \(mapGenderToBackend(editableGender))")
            print("🎂 출생연도: \(editableBirthYear) -> \(mapBirthYearToInt(editableBirthYear))")
            print("💼 직업: \(editableJob) -> \(mapJobToBackend(editableJob))")
            
            // 회원가입 완료 요청
            try await signUpService.completeSignup(
                email: email,
                code: code,
                password: password,
                nickname: editableNickname,
                birthYear: mapBirthYearToInt(editableBirthYear),
                gender: mapGenderToBackend(editableGender),
                job: mapJobToBackend(editableJob),
                profileImage: 1
            )
            
            print("✅ 회원가입 완료!")
            
            // 메인 화면으로 이동 (로그인 필요)
            // TODO: 자동 로그인 or 로그인 화면으로 이동
            path.removeAll()
            
        } catch let error as HTTPError {
            print("❌ 회원가입 요청 실패: \(error)")
            showError = true
            errorMessage = "회원가입 요청에 실패했습니다. 다시 시도해주세요."
        } catch {
            print("❌ 알 수 없는 오류: \(error)")
            showError = true
            errorMessage = "회원가입 중 오류가 발생했습니다. 다시 시도해주세요."
        }
        
        isLoading = false
    }
}

struct CompleteProfileView_Previews: PreviewProvider {
    @State static var path: [Route] = []
    static var previews: some View {
        CompleteProfileView(
            path: $path,
            email: "test@example.com",
                code: "123456",
            password: "password123",
            nickname: "테드",
            gender: "남성",
            birthYear: "1995년생",
            job: "학생"
        )
    }
}
