//
//  NextButton.swift
//  WAVI
//
//  Created by 서영채 on 9/10/25.
//

import SwiftUI

struct NextButton: View {
    var title: String = "다음으로"
    var isEnabled: Bool = true      // 버튼 활성화 여부
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEnabled ? Color.primaryBlack : Color.gray.opacity(0.3))
                .cornerRadius(40)
        }
        .disabled(!isEnabled) // 입력 없을 때 비활성화
        .padding(.bottom, 40)
    }
}

struct NextButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 활성화된 버튼
            NextButton(isEnabled: true) {
                print("버튼 눌림")
            }
            
            // 비활성화된 버튼
            NextButton(isEnabled: false) {
                print("버튼 눌림")
            }
        }
        .padding()
        .previewLayout(.sizeThatFits) // ✅ 버튼 크기에 맞게 프리뷰
    }
}
