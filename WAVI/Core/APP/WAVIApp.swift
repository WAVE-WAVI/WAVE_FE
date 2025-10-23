// WAVIApp.swift
import SwiftUI

@main
struct WAVIApp: App {
    @StateObject private var auth = AuthManager()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(auth)
        }
    }
}

