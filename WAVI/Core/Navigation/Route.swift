enum Route: Hashable {
    case main
    case emailLogin
    case signup        // 진입
    case signupCode
    case signupPassword(email: String, code: String)  // 이메일 + 인증번호 전달
    case signupDone
    case profileCreation
    case verificationCode(email: String)  // 인증코드 입력 화면
    
    // 새로운 프로필 생성 플로우
    case profileGeneration(email: String, code: String, password: String)  // "나만의 프로필을 만들어볼까요?" 페이지
    case nicknameSelection(email: String, code: String, password: String)  // 닉네임 선택
    case genderSelection(email: String, code: String, password: String, nickname: String)    // 성별 입력
    case ageInput(email: String, code: String, password: String, nickname: String, gender: String)          // 나이 입력
    case jobSelection(email: String, code: String, password: String, nickname: String, gender: String, birthYear: String)      // 직업 선택
    case profileComplete(email: String, code: String, password: String, nickname: String, gender: String, birthYear: String, job: String)   // 최종 프로필 확인
    
    // 습관 목록 화면
    case habitList  // 습관 목록 화면 (겹치지 않는 일반 리스트)
    case habitModify(habit: Habit)  // 습관 수정 화면
    
    // 습관 추가 화면
    case addingHabits  // 습관 추가 (채팅 기반)
    
    // 리포트 화면
    case report  // 리포트 화면
}
