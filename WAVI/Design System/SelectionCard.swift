//
//  SelectionCard.swift
//  WAVI
//
//  Created by 서영채 on 9/18/25.
//

import SwiftUI

struct SelectionCard: View {
    let title: String
    @Binding var isSelected: Bool
    var width: CGFloat = 100   // 기본값 설정
    var height: CGFloat = 150  // 기본값 설정

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.fill")
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .black : .gray)
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .black : .gray)
        }
        .padding(20)
        .frame(width: width, height: height) // ← 여기서 외부 값 반영
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? .black : .gray, lineWidth: 2)
        )
        .onTapGesture {
            self.isSelected.toggle()
        }
    }
}

struct SelectionCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 활성화된 카드: title과 @Binding 변수를 전달합니다.
            // isSelected의 경우, .constant(true)를 사용해 활성화된 상태를 미리보기로 보여줍니다.
            SelectionCard(title: "선택된 카드", isSelected: .constant(true))
            
            // 비활성화된 카드
            SelectionCard(title: "선택되지 않은 카드", isSelected: .constant(false))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

