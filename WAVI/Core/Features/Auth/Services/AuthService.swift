//
//  AuthService.swift
//  WAVI
//
//  Created by 박현빈 on 9/5/25.
//


protocol AuthService {
    func login(email: String, password: String) async throws -> LoginResult
    func signup(email: String, password: String, nickname: String, birthYear: Int, gender: String, job: String, profileImage: Int) async throws -> SignUpResult
}
