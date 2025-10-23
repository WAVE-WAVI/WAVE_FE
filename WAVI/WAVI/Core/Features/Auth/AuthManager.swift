//
//  AuthManager.swift
//  WAVI
//
//  Created by 박현빈 on 9/10/25.
//

import SwiftUI

final class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    func login() {
        isLoggedIn = true
    }
    
    func logout() {
        isLoggedIn = false
    }
}
