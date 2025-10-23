//
//  CustomTextField.swift
//  WAVI
//
//  Created by 서영채 on 9/11/25.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            // ✅ placeholder: 값이 비어있을 때만 보임
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.primaryBlack.opacity(0.4))
                    .padding(.horizontal, 20)
                    .font(.system(size: 14))
            }
            
            // ✅ 실제 입력 TextField
                   TextField("", text: $text)
                       .padding(.horizontal, 20)
                       .font(.system(size: 14))
                       .foregroundColor(Color.primaryBlack)
                       .frame(height: 52)
                       .focused($isFocused)
                       .tint(Color.primaryBlack)
                       .keyboardType(keyboardType) // 키보드 타입 지원
                       .autocapitalization(.none) // 자동 대문자 변환 비활성화
                       .disableAutocorrection(true) // 자동 교정 비활성화
        }
        .background(
            RoundedRectangle(cornerRadius: 40)
                .stroke(isFocused ? Color.primaryBlack : Color.primaryBlack.opacity(0.4), lineWidth: 1.5)
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(isFocused ? Color.primaryBlack.opacity(0.01) : Color(.systemBackground))
                )
        )
    }
}

struct CustomTextField_Previews: PreviewProvider {
    @State static var sampleText = "" // ✅ 샘플 상태 변수
    
    static var previews: some View {
        VStack(spacing: 20) {
            // 비어 있는 상태 → placeholder 보임
            CustomTextField(placeholder: "닉네임을 입력하세요", text: $sampleText)
            
            // 값이 있는 상태 → 입력 값 보임
            CustomTextField(placeholder: "닉네임을 입력하세요", text: .constant("WAVI"))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
