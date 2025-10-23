//
//  SignUpFlowVM.swift
//  WAVI
//
//  Created by 박현빈 on 9/23/25.
//

import SwiftUI

enum SignUpRoute: Hashable { case email, code, password, done }

final class SignUpFlowVM: ObservableObject {
    @Published var state = SignUpState()
    @Published var path: [SignUpRoute] = []
}
