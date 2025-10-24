//
//  MainHeaderView.swift
//  WAVI
//
//  Created by 박현빈 on 7/28/25.
//

import SwiftUI

struct MainHeaderView: View {
    // MARK: - Properties
    @StateObject private var viewModel = MainViewModel()
    @State private var path: [Route] = []
    @State private var currentCenterIndex: Int = 0
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // 전체 배경색
                Color(hex: "#EAEAEA")
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // 메인 콘텐츠
                    //Spacer()
                    
                    // 상단 헤더 (날짜, 인사말, 프로필)
                    HStack(spacing: 0) {
                        // 왼쪽: 날짜와 인사말
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentDate())
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(Color(hex: "#040415"))
                            
                            Text("\(viewModel.nickname)님 안녕하세요!")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(Color(hex: "#9B9BA1"))
                        }
                        
                        Spacer()
                        
                        VStack {
                            // 오른쪽: 프로필 아이콘
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image("image 2069")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.gray)
                                )
                            Button(action: {
                                path.append(.settings)
                            }) {
                                RoundedRectangle(cornerRadius: 50, style: .continuous)
                                    .fill(Color(hex: "#CDCDD0"))
                                    .frame(width: 30, height: 20)
                                    .overlay(
                                        Image("equal_main")
                                            .padding(.vertical, 1)
                                            .padding(.horizontal, 4),
                                        alignment: .center
                                    )
                                    .fixedSize()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(width: 361)
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    .padding(.bottom, 15)
                    
                    // 하단: 당일 습관 아이콘들
                    VStack(alignment: .leading, spacing: 0){
                        HStack(alignment: .center, spacing: 5) {
                            ForEach(viewModel.habits, id: \.id) { habit in
                                Circle()
                                    .fill(Color(hex: habit.cardColor.primaryColor))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Text(habit.icon)
                                            .font(.system(size: 14))
                                    )
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    }
                    
                    //.padding(.horizontal, 20)
                    
                    // 원형 진행 바
                    ProgressRingView(
                        habits: viewModel.habits,
                        currentCenterIndex: currentCenterIndex
                    )
                        .padding(.vertical, 16)
                    
                    // 습관 목록 추가 (백엔드 연결)
                    MainHabitListOverlapView(
                        viewModel: viewModel,
                        currentCenterIndex: $currentCenterIndex
                    )
                    
                    Spacer()
                    
                    
                    
                    // 고정 하단 네비게이션 바
                    VStack {
                        HStack(spacing :60) {
                            // 캘린더 아이콘
                            Button(action: {
                                path.append(.report)
                            }) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "#040415"))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color(hex: "#040415"), style: StrokeStyle(lineWidth: 2, dash: [5]))
                                            .frame(width: 40, height: 40)
                                    )
                            }
                            
                            
                            
                            // 습관 추가 버튼
                            Button(action: {
                                path.append(.addingHabits)
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(hex: "#F1EFF2"))
                                    
                                    Text("습관 추가")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(hex: "#F1EFF2"))
                                        .tracking(-0.5)
                                        .lineSpacing(20)
                                }
                                .frame(width: 107, height: 36)
                                .background(Color(hex: "#040415"))
                                .clipShape(Capsule())
                            }
                            
                        
                            
                            // 리스트 아이콘
                            Button(action: {
                                path.append(.habitList)
                            }) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "#040415"))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color(hex: "#040415"), style: StrokeStyle(lineWidth: 2, dash: [5]))
                                            .frame(width: 40, height: 40)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#EAEAEA"))
                    }
                }
                .padding(.top, 4)
                .padding(.bottom,15)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .habitList:
                    HabitListView { habit in
                        path.append(.habitModify(habit: habit))
                    }
                case .habitModify(let habit):
                    HabitModifyView(habit: habit)
                        .onDisappear {
                            // 습관 수정 화면에서 돌아올 때 데이터 새로고침
                            Task {
                                await viewModel.loadMainData()
                            }
                        }
                case .addingHabits:
                    AddingHabitsMainView()
                case .report:
                    ReportView()
                case .settings:
                    SettingView()
                default:
                    EmptyView()
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadMainData()
                }
            }
        }
    }
    
    private func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
}

#Preview {
    MainHeaderView()
}
