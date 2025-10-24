//
//  SettingView.swift
//  WAVI
//
//  Created by 서영채 on 10/7/25.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let settingItems = [
        SettingItem(icon: "person.circle.fill", title: "프로필", isProfile: true),
        SettingItem(icon: "bell", title: "알림"),
        SettingItem(icon: "staroflife", title: "앱 평가하기"),
        SettingItem(icon: "shareplay", title: "앱 공유하기"),
        SettingItem(icon: "lock", title: "개인정보 처리방침"),
        SettingItem(icon: "doc", title: "이용약관"),
        SettingItem(icon: "doc.badge.gearshape", title: "쿠키 정책"),
        SettingItem(icon: "megaphone", title: "문의하기"),
        SettingItem(icon: "exclamationmark.bubble", title: "의견 보내기"),
        SettingItem(icon: "ipad.and.arrow.forward", title: "로그아웃")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "#EAEAEA")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 상단 헤더
                    headerView
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // 설정 리스트
                    settingsListView
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack(spacing: 8) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.black)
            }
            .buttonStyle(.plain)
            
            Text("환경 설정")
                .font(.system(size: 36, weight: .bold))
                .lineSpacing(4)
                .foregroundColor(.black)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Settings List View
    private var settingsListView: some View {
        VStack(spacing: 0) {
            ForEach(Array(settingItems.enumerated()), id: \.offset) { index, item in
                Button(action: {
                    handleSettingAction(item)
                }) {
                    settingRowView(item: item)
                }
                .buttonStyle(.plain)
                
                if index < settingItems.count - 1 {
                    Divider()
                        .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Setting Row View
    private func settingRowView(item: SettingItem) -> some View {
        HStack(spacing: 16) {
            // 아이콘
            if item.isProfile {
                // 프로필: 박스에 걸쳐진 원형
                ZStack(alignment: .topLeading) {
                    
                    // 프로필 원형 (박스에 걸쳐짐)
                    Circle()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("🧔🏼‍♂️")
                                .font(.system(size: 25))
                                .foregroundColor(.white)
                        )
                }
                .frame(height: 60)
            } else {
                // 일반 아이콘
                Image(systemName: item.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
            }
            
            // 제목
            Text(item.title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
    
    
    
    
    // MARK: - Helper Functions
    private func handleSettingAction(_ item: SettingItem) {
        switch item.title {
        case "프로필":
            // 프로필 액션
            break
        case "알림":
            // 알림 설정 액션
            break
        case "앱 평가하기":
            // 앱 평가 액션
            break
        case "앱 공유하기":
            // 앱 공유 액션
            break
        case "개인정보 처리방침":
            // 개인정보 처리방침 액션
            break
        case "이용약관":
            // 이용약관 액션
            break
        case "쿠키 정책":
            // 쿠키 정책 액션
            break
        case "문의하기":
            // 문의하기 액션
            break
        case "의견 보내기":
            // 의견 보내기 액션
            break
        case "로그아웃":
            // 로그아웃 액션
            break
        default:
            break
        }
    }
}

// MARK: - Setting Item Model
struct SettingItem {
    let icon: String
    let title: String
    let isProfile: Bool
    let isDestructive: Bool
    
    init(icon: String, title: String, isProfile: Bool = false, isDestructive: Bool = false) {
        self.icon = icon
        self.title = title
        self.isProfile = isProfile
        self.isDestructive = isDestructive
    }
}

#Preview {
    SettingView()
}
