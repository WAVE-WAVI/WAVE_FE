//
//  SignUpService.swift
//  WAVI
//
//  Created by 박현빈 on 9/23/25.
//

import Foundation

protocol SignUpServicing {
    // 새로운 회원가입 흐름 (2단계)
    
    // 1단계: 이메일 인증 시작 (인증번호 발송)
    func initiateSignup(email: String) async throws
    
    // 2단계: 회원가입 완료 (인증번호 + 비밀번호 + 나머지 정보 한 번에)
    func completeSignup(email: String, code: String, password: String, nickname: String, birthYear: Int, gender: String, job: String, profileImage: Int) async throws
    
    // 유틸리티 메서드
    func checkEmailAvailability(email: String) async throws -> EmailCheckResult
}
