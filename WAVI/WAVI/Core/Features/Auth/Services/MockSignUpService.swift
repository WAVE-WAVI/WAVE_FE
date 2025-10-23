//
//  MockSignUpService.swift
//  WAVI
//
//  Created by 박현빈 on 9/23/25.
//

import Foundation

final class MockSignUpService: SignUpServicing {
    
    // 1단계: 이메일 인증 시작 (인증번호 발송)
    func initiateSignup(email: String) async throws {
        print("🎭 MockSignUpService: 이메일 인증 시작 시뮬레이션")
        print("📧 이메일: \(email)")
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
        print("✅ MockSignUpService: 인증번호가 \(email)로 발송되었습니다.")
    }
    
    // 2단계: 회원가입 완료 (인증번호 + 비밀번호 + 나머지 정보 한 번에)
    func completeSignup(email: String, code: String, password: String, nickname: String, birthYear: Int, gender: String, job: String, profileImage: Int) async throws {
        print("🎭 MockSignUpService: 회원가입 완료 시뮬레이션")
        print("📧 이메일: \(email)")
        print("🔢 인증번호: \(code)")
        print("👤 닉네임: \(nickname)")
        print("🎂 출생연도: \(birthYear)")
        print("⚧ 성별: \(gender)")
        print("💼 직업: \(job)")
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // 테스트용: 특정 인증번호는 실패
        if code != "123456" {
            throw HTTPError.message("잘못된 인증번호입니다.")
        }
        
        print("✅ MockSignUpService: 회원가입이 완료되었습니다.")
    }
    
    // 이메일 중복 확인
    func checkEmailAvailability(email: String) async throws -> EmailCheckResult {
        print("🎭 MockSignUpService: 이메일 중복 확인 시뮬레이션")
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // 테스트용: 특정 이메일은 사용 불가
        if email == "test@example.com" {
            return .unavailable
        } else {
            return .available
        }
    }
}
