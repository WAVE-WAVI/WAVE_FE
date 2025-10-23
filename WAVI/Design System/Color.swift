//
//  Color.swift
//  WAVI
//
//  Created by 박현빈 on 9/5/25.
//

import SwiftUI

extension Color {
    // Hex 색상 초기화
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Primary Colors
    static let primaryBlack   = Color(hex: "#040415")
    static let primaryBlue   = Color(hex: "#5188CC")
    static let primaryRed    = Color(hex: "#D55050")
    static let primaryGreen  = Color(hex: "#4DC6B2")
    static let primaryLightGreen   = Color(hex: "#9AE3AB")
    static let primaryPurple = Color(hex: "#66598F")
    static let primaryYellow = Color(hex: "#D5BA50")
    
    // Design System Colors
    static let black80 = Color(hex: "#363644")
    static let black60 = Color(hex: "#686873")
    static let black40 = Color(hex: "#9B9BA1")
    static let black20 = Color(hex: "#CDCDD0")
    
    static let green100 = Color(hex: "#4DC6B2")
    static let green40 = Color(hex: "#B8E8E0")
    
    static let blue80 = Color(hex: "#74A0D6")
    static let blue40 = Color(hex: "#B9CFEB")
    static let PrimaryOnBoardinBlue = Color(hex: "#7BBBF2")
    
    static let baseWhite = Color(hex: "#FFFFFF")
    static let baseBlack = Color(hex: "#000000")
    static let baseBackground = Color(hex: "#F1EFF2")
}
