//
//  Typography_Kor.swift
//  WAVI
//
//  Created by 박현빈 on 9/5/25.
//

import SwiftUI

// lineHeight modifier 추가
extension Text {
    func lineHeight(_ lineHeight: CGFloat) -> some View {
        self.lineSpacing(lineHeight - UIFont.systemFont(ofSize: 14).lineHeight)
    }
}

extension View {
    func lineHeight(_ lineHeight: CGFloat) -> some View {
        self.modifier(LineHeightModifier(lineHeight: lineHeight))
    }
}

struct LineHeightModifier: ViewModifier {
    let lineHeight: CGFloat
    
    func body(content: Content) -> some View {
        content
            .lineSpacing(lineHeight - 14) // 기본 폰트 크기 기준
    }
}

// 1) 폰트 스펙 구조
struct AppTypography {
    let size: CGFloat
    let lineHeight: CGFloat
    let weight: Font.Weight
    let letterSpacing: CGFloat
    
    var font: Font {
        .system(size: size, weight: weight)
    }
}

// 2) Modifier 정의
struct TypographyModifier: ViewModifier {
    let spec: AppTypography
    
    func body(content: Content) -> some View {
        content
            .font(spec.font)
            .lineSpacing(max(spec.lineHeight - spec.size, 0))
            .tracking(spec.letterSpacing)
    }
}

// 3) View 확장
extension View {
    func typography(_ spec: AppTypography) -> some View {
        self.modifier(TypographyModifier(spec: spec))
    }
}

// 4) 실제 토큰 
enum Typography {
    static let Headline0 = AppTypography(size: 48, lineHeight: 56, weight: .bold, letterSpacing: 0)
    static let Headline1 = AppTypography(size: 45, lineHeight: 56, weight: .semibold, letterSpacing: 0)
    static let Headline2 = AppTypography(size: 40, lineHeight: 48, weight: .semibold, letterSpacing: 0)
    static let Headline3 = AppTypography(size: 36, lineHeight: 40, weight: .semibold, letterSpacing: 0)
    static let Headline4 = AppTypography(size: 32, lineHeight: 40, weight: .semibold, letterSpacing: 0)
    static let Headline5 = AppTypography(size: 24, lineHeight: 32, weight: .semibold, letterSpacing: 0)
    static let Headline6 = AppTypography(size: 20, lineHeight: 24, weight: .medium, letterSpacing: 0)
    static let Title     = AppTypography(size: 18, lineHeight: 24, weight: .medium, letterSpacing: 0)
    static let Body1     = AppTypography(size: 14, lineHeight: 20, weight: .regular, letterSpacing: 0)
    static let Body2     = AppTypography(size: 14, lineHeight: 20, weight: .bold, letterSpacing: 0)
    static let Body3     = AppTypography(size: 14, lineHeight: 20, weight: .medium, letterSpacing: 0)
    static let Chip      = AppTypography(size: 10, lineHeight: 16, weight: .semibold, letterSpacing: 0)
}


  
