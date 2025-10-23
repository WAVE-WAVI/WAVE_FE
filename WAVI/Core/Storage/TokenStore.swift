//
//  TokenStore.swift
//  WAVI
//
//  Created by 박현빈 on 9/5/25.
//
import Foundation
import Security

final class TokenStore {
    static let shared = TokenStore()
    private init() {}

    private let service = "com.wavi.auth"
    
    // WAVIEndpoint에서 사용할 accessToken 프로퍼티
    var accessToken: String? {
        return loadAccess()
    }

    func save(access: String, refresh: String) {
        save(key: "accessToken", value: access)
        save(key: "refreshToken", value: refresh)
    }
    
    func saveTokens(accessToken: String, refreshToken: String) {
        save(key: "accessToken", value: accessToken)
        save(key: "refreshToken", value: refreshToken)
    }
    func loadAccess() -> String? { read(key: "accessToken") }
    func loadRefresh() -> String? { read(key: "refreshToken") }
    func clear() {
        delete(key: "accessToken")
        delete(key: "refreshToken")
    }

    private func save(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
        var add = query
        add[kSecValueData as String] = data
        SecItemAdd(add as CFDictionary, nil)
    }
    private func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var out: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &out)
        guard let data = out as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
