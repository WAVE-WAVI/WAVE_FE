//
//  MainService.swift
//  WAVI
//
//  Created by 박현빈 on 10/12/25.
//

import Foundation


// MARK: - Main Service Protocol
protocol MainService {
    func fetchMainScreenData() async -> Result<MainScreenData, Error>
}

// MARK: - Backend Main Service
class BackendMainService: MainService {
    private let apiClient: LegacyAPIClient
    
    init(apiClient: LegacyAPIClient = LegacyAPIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchMainScreenData() async -> Result<MainScreenData, Error> {
        print("🌐 BackendMainService: 메인 화면 데이터 요청")
        
        do {
            let response: MainScreenResponse = try await apiClient.request(
                .main,
                body: EmptyRequest()
            )
            
            print("✅ BackendMainService: 메인 화면 데이터 로드 성공")
            print("   닉네임: \(response.data.nickname)")
            print("   프로필 이미지: \(response.data.profileImage)")
            print("   습관 개수: \(response.data.habits.count)")
            return .success(response.data)
            
        } catch let error as HTTPError {
            print("❌ BackendMainService: HTTPError - \(error)")
            return .failure(error)
        } catch {
            print("❌ BackendMainService: 일반 오류 - \(error)")
            return .failure(error)
        }
    }
}

