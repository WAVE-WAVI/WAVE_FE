//
//  SplashView.swift
//  WAVI
//
//  Created by Assistant on 10/23/25.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            RootView()
                .environmentObject(auth)
        } else {
            // Splash 이미지 - 화면 전체
            Image("Splash")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.isActive = true
                    }
                }
        }
    }
}

#Preview {
    SplashView()
}
