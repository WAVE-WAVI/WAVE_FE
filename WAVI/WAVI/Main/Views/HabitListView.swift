//
//  HabitListView.swift
//  WAVI
//
//  Created by 박현빈 on 7/28/25.
//

import SwiftUI

struct HabitListView: View {
    // MARK: - Properties
    @StateObject private var viewModel = HabitListViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    let onHabitSelected: (Habit) -> Void
    
    // MARK: - Computed Properties
    var filteredHabits: [Habit] {
        if searchText.isEmpty {
            return viewModel.habits
        } else {
            return viewModel.habits.filter { habit in
                habit.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 배경색
            Color(hex: "#EAEAEA")
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
            // 헤더
            HStack(spacing: 20) {
                Button(action: {
                    dismiss()
                }) {
                    Image("chevron.backward")
                        .frame(width: 24, height: 24)
                }
                    
                Text("습관 목록")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(hex: "#040415"))
                
                Spacer()
                
        
            }
            .padding(.top,20)
            .padding(.horizontal, 20)
            
             HStack(spacing: 20) {
                 // 돋보기 아이콘 (원형 배경)
                 HStack(spacing :-2){
                     ZStack {
                         Circle()
                             .fill(Color(hex: "#D9D9D9"))
                             .frame(width: 39.228, height: 39.228)
                         
                         Image("magnifyingglass")
                             .frame(width: 19.708, height: 19.708)
                     }
                     
                     
                     // 검색 입력 필드
                     ZStack {
                         RoundedRectangle(cornerRadius: 50)
                             .fill(Color(hex: "#D9D9D9"))
                             .frame(width: 319, height: 40)
                         
                         TextField("습관을 검색하세요", text: $searchText)
                             .font(.custom("Pretendard", size: 20))
                             //.fontWeight(.light)
                             .foregroundColor(Color(hex: "#9B9BA1"))
                             .padding(.horizontal, 30)
                             .autocapitalization(.none)
                             .disableAutocorrection(true)
                     }
                 }
          
                 
                 // 플러스 아이콘 (점선 테두리 원형)
//                 ZStack {
//                     Circle()
//                         .stroke(Color(hex: "#040415"), style: StrokeStyle(lineWidth: 2, dash: [5]))
//                         .frame(width: 40, height: 40)
//                     
//                     Image("plus_black")
//                         .frame(width: 20, height: 20)
//                 }
             }
             .padding(.horizontal, 20)
            
            // 습관 목록
            if viewModel.isLoading {
                ProgressView("습관을 불러오는 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    
                    Text("오류가 발생했습니다")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.red)
                    
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#9B9BA1"))
                        .multilineTextAlignment(.center)
                    
                    Button("다시 시도") {
                        Task {
                            await viewModel.loadAllHabits()
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#4281B6"))
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
            } else if filteredHabits.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: searchText.isEmpty ? "checkmark.circle" : "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "#4281B6"))
                    
                    Text(searchText.isEmpty ? "오늘의 습관이 없습니다" : "검색 결과가 없습니다")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "#040415"))
                    
                    Text(searchText.isEmpty ? "새로운 습관을 추가해보세요!" : "'\(searchText)'에 해당하는 습관이 없습니다")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#9B9BA1"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredHabits, id: \.id) { habit in
                            HabitListCardView(
                                habitName: habit.name,
                                timeRange: habit.timeRange,
                                icon: habit.icon,
                                cardColor: habit.listCardColor,
                                dayOfWeek: habit.dayOfWeek
                            )
                            .onTapGesture {
                                onHabitSelected(habit)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        }
        .navigationBarBackButtonHidden(true)  // 시스템 뒤로가기 버튼 숨기기
        .onAppear {
            Task {
                await viewModel.loadAllHabits()
            }
        }
    }
}

#Preview {
    HabitListView { habit in
        print("습관 선택됨: \(habit.name)")
    }
    .previewLayout(.sizeThatFits)
    .padding()
}
