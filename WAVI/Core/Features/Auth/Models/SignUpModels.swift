//
//  SignUpModels.swift
//  WAVI
//
//  Created by 박현빈 on 9/23/25.
//

import Foundation


public enum LoginType: String, Codable { case normal = "NORMAL" }
public enum Gender: String, Codable, CaseIterable { case male = "MALE", female = "FEMALE", unknown = "UNKNOWN" }
public enum Job: String, Codable, CaseIterable { case student = "STUDENT", salaryman = "SALARYMAN", jobless = "JOBLESS", ceo = "CEO" }

// 회원가입 최종 요청 (실서버)
public struct SignUpRequest: Encodable {
    public let email: String
    public let password: String
    //public let loginType: LoginType
    public let nickname: String
    public let birthYear: Int
    public let gender: Gender
    public let job: Job
    public let profileImage: Int   // 0~2
}

// 성공 201
public struct SignUpResponse: Decodable {
    public let code: Int
    public let message: String
}

// 실패 응답

// 플로우 중 화면 간 공유 상태 (클라이언트 내부용)
public struct SignUpState: Equatable {
    public var email: String = ""
    public var code: String = ""
    public var password: String = ""
}

// 백엔드 API 스펙에 맞춘 모델들
public struct UserSignupRequestDto: Codable {
    public let email: String
    public let password: String
    public let loginType: String
    public let nickname: String
    public let birthYear: Int
    public let gender: String
    public let job: String
    public let profileImage: Int
}

public struct EmailVerificationRequestDto: Codable {
    public let email: String
    public let code: String
}
