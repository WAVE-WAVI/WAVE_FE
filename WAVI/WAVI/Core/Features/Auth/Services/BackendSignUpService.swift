//
//  BackendSignUpService.swift
//  WAVI
//
//  Created by 박현빈 on 9/23/25.
//

import Foundation

class BackendSignUpService: SignUpServicing {
    private let apiClient = LegacyAPIClient()
    
    // 1단계: 이메일 인증 시작 (인증번호 발송)
    func initiateSignup(email: String) async throws {
        print("🚀 BackendSignUpService: 이메일 인증 시작")
        print("📧 이메일: \(email)")
        
        let request = InitiateSignUpRequest(email: email)
        
        do {
            let response: APISignUpResponse = try await apiClient.request(.initiateSignup, body: request)
            print("✅ 인증 코드 발송 성공: \(response.message)")
            if let data = response.data {
                print("📧 인증 코드 데이터: \(data)")
            }
        } catch let error as HTTPError {
            print("❌ 인증 코드 발송 실패: \(error)")
            switch error {
            case .server:
                print("❌ 서버 에러 - 서버가 응답하지 않거나 내부 오류 발생")
            case .message(let message):
                print("❌ 서버 메시지: \(message)")
            default:
                print("❌ 기타 네트워크 에러: \(error)")
            }
            throw error
        } catch {
            print("❌ 알 수 없는 오류: \(error)")
            throw HTTPError.invalidRequest
        }
    }
    
    // 2단계: 회원가입 완료 (인증번호 + 비밀번호 + 나머지 정보 한 번에)
    func completeSignup(email: String, code: String, password: String, nickname: String, birthYear: Int, gender: String, job: String, profileImage: Int) async throws {
        print("🚀 BackendSignUpService: 회원가입 완료 요청 시작")
        print("📧 이메일: \(email)")
        print("🔢 인증번호: \(code)")
        print("👤 닉네임: \(nickname)")
        print("🎂 출생연도: \(birthYear)")
        print("⚧ 성별: \(gender)")
        print("💼 직업: \(job)")
        
        let request = CompleteSignUpRequest(
            email: email,
            code: code,
            password: password,
            nickname: nickname,
            birthYear: birthYear,
            gender: gender,
            job: job,
            profileImage: profileImage
        )
        
        do {
            let response: APISignUpResponse = try await apiClient.request(.completeSignup, body: request)
            print("✅ 회원가입 완료: \(response.message)")
            if let data = response.data {
                print("📧 회원가입 데이터: \(data)")
            }
        } catch let error as HTTPError {
            print("❌ 회원가입 실패: \(error)")
            switch error {
            case .server:
                print("❌ 서버 에러 - 서버가 응답하지 않거나 내부 오류 발생")
            case .message(let message):
                print("❌ 서버 메시지: \(message)")
            default:
                print("❌ 기타 네트워크 에러: \(error)")
            }
            throw error
        } catch {
            print("❌ 알 수 없는 오류: \(error)")
            throw HTTPError.invalidRequest
        }
    }
    
    // 유틸리티: 이메일 중복 확인
    func checkEmailAvailability(email: String) async throws -> EmailCheckResult {
        let request = EmailCheckRequest(email: email)
        
        do {
            let response: EmailCheckResponse = try await apiClient.request(.checkEmail, body: request)
            return response.available ? .available : .unavailable
        } catch let error as HTTPError {
            return .failure(error)
        } catch {
            return .failure(error)
        }
    }
}
