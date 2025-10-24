//
//  ProfileGenerationView.swift
//  WAVI
//
//  Created by 서영채 on 9/9/25.
//

import SwiftUI

struct ProfileGenerationView: View {
    @Binding var path: [Route]
    @Environment(\.dismiss) private var dismiss
    
    // 이전 단계에서 전달받은 데이터
    let email: String
    let code: String
    let password: String
    
    var body: some View {
        ZStack {
            Color(hex: "#F1EFF2")
                .ignoresSafeArea()
            
            VStack {
            // Custom Navigation Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 24, height: 24)
                }
                .padding(.trailing, 12)
                Text("프로필 생성하기")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.black80)
                // Invisible spacer to center the title
                //Color.clear
                // .frame(width: 24, height: 24)
            }
            .padding(.top, 20)
            .padding(.trailing, 182)
            .padding(.leading, 24)
            
            Spacer()
            
            // 메인 텍스트
            VStack(alignment: .leading, spacing: 12) {
                Text("나만의 프로필을\n만들어볼까요?")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(Color.PrimaryOnBoardinBlue)
                
                Text("천 리 길도 한 걸음부터 차근차근!")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // 다음으로 버튼
            Button(action: {
                path.append(.nicknameSelection(email: email, code: code, password: password))
            }) {
                Text("다음으로")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#040415"))
                    .cornerRadius(30)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}

struct ProfileGenerationView_Previews: PreviewProvider {
    @State static var path: [Route] = []
    static var previews: some View {
        ProfileGenerationView(
            path: $path,
            email: "test@example.com",
                code: "123456",
            password: "password123"
        )
    }
}
