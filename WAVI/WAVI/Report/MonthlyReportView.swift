//
//  MonthlyReportView.swift
//  WAVI
//
//  Created by 박현빈 on 10/23/25.
//


import SwiftUI

struct MonthlyReportView: View {
    @State private var currentPage = 0
    
    // ReportView에서 받은 데이터
    let overallSuccessRate: Double
    let topFailureReasons: [TopFailureReason]
    let habitSuccessRates: [HabitSuccessRate]
    let recommendations: [ReportRecommendation]
    
    init(overallSuccessRate: Double = 0.0, topFailureReasons: [TopFailureReason] = [], habitSuccessRates: [HabitSuccessRate] = [], recommendations: [ReportRecommendation] = []) {
        self.overallSuccessRate = overallSuccessRate
        self.topFailureReasons = topFailureReasons
        self.habitSuccessRates = habitSuccessRates
        self.recommendations = recommendations
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 3페이지 스크롤 컨텐츠 (페이지 인디케이터 제거)
            TabView(selection: $currentPage) {
                // 1페이지: 성공률 차트
                page1View
                    .tag(0)
                
                // 2페이지: 패턴 분석
                page2View
                    .tag(1)
                
                // 3페이지: 노력 지수 & 동기부여
                page3View
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 600)
        }
    }
    
    // MARK: - Helper Functions
    private func getIconForHabit(_ name: String) -> String {
        if name.contains("수영") {
            return "🏊‍♀️"
        } else if name.contains("코딩") {
            return "💻"
        } else if name.contains("운동") {
            return "🏃"
        } else if name.contains("독서") {
            return "📚"
        } else {
            return "⭐"
        }
    }
    
    // MARK: - 1페이지: 성공률 차트 + 습관 성공률
    private var page1View: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 전체 성공률 차트
            ZStack {
                // 배경 원
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                // 진행률 원 (API 데이터)
                Circle()
                    .trim(from: 0, to: overallSuccessRate / 100.0)
                    .stroke(
                        Color(Color(red: 66/255, green: 129/255, blue: 182/255)),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                // 중앙 텍스트
                VStack(spacing: 8) {
                    Text("전체 성공률")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 66/255, green: 129/255, blue: 182/255))
                    
                    Text("\(Int(overallSuccessRate))%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            
            // 습관별 성공률
            HStack(spacing: 12) {
                ForEach(Array(habitSuccessRates.enumerated()), id: \.offset) { index, habitRate in
                    habitSuccessCard(icon: getIconForHabit(habitRate.name), title: habitRate.name, rate: "\(Int(habitRate.rate))%")
                }
            }
            
            // 꾸준함 지수
            VStack(spacing: 10) {
                Text("꾸준함 지수: 높음 🔥")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Text("오전 운동도 바쁜 평일 아침에 60%나 성공했다는 건\n 테드님의 의지가 얼마나 강한지 보여줍니다.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 66/255, green: 129/255, blue: 182/255))
                    .lineLimit(nil)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 2페이지: 실패 요인 분석
    private var page2View: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 주요 원인
            VStack(spacing: 5) {
                // 습관별 실패 요인
                ForEach(Array(habitSuccessRates.enumerated()), id: \.offset) { index, habitRate in
                    habitFailureSection(icon: getIconForHabit(habitRate.name), title: habitRate.name)
                }
            }
            Spacer()
            VStack(spacing:8) {
                Text("평일 체력 부담이 주요 원인!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Text("아침엔 기상 장벽, 저녁엔 피로와 약속")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 66/255, green: 129/255, blue: 182/255))
                
            }
            
            
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - 3페이지: 패턴 & 노력 지수 & 동기부여
    private var page3View: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 전체 성공률 차트
            ZStack {
                // 배경 원
                Circle()
                    .stroke(Color.white, lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                // 진행률 원 (API 데이터)
                Circle()
                    .trim(from: 0, to: overallSuccessRate / 100.0)
                    .stroke(
                        Color(red: 255/255, green: 165/255, blue: 0/255), // 오렌지색
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                // 중앙 텍스트
                VStack(spacing: 8) {
                    Text("전체 성공률")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 66/255, green: 129/255, blue: 182/255))
                    
                    Text("\(Int(overallSuccessRate))%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 255/255, green: 165/255, blue: 0/255))
                }
            }
            
            // 전체 패턴 섹션
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("⚡")
                            .font(.system(size: 20))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("전체 패턴")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text("특정 요일보단 바쁜 날, 피곤한 날에 어려움")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(red: 66/255, green: 129/255, blue: 182/255))
                        .lineLimit(nil)
                }
                
                Spacer()
            }
            
            // 노력 지수 섹션
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("🤘")
                            .font(.system(size: 20))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("노력 지수")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text("꾸준함 충분!")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(red: 66/255, green: 129/255, blue: 182/255))
                }
                
                Spacer()
            }
            
            // 동기부여 메시지
            VStack(spacing: 8) {
                HStack {
                    Text("작은 시도가 큰 변화를 만듭니다")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 255/255, green: 165/255, blue: 0/255))
                    
                    Text("🙇‍♂️")
                        .font(.system(size: 16))
                }
                
                Text("결과보다 시도 자체를 칭찬하세요!")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 66/255, green: 129/255, blue: 182/255))
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    
    // MARK: - 습관 성공률 카드
    private func habitSuccessCard(icon: String, title: String, rate: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(icon)
                        .font(.system(size: 20))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text("\(rate) 성공")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.clear)
        )
    }
    
    // MARK: - 습관별 실패 요인 섹션
    private func habitFailureSection(icon: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text(icon)
                            .font(.system(size: 16))
                    )
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
            }
            
            HStack(spacing: 12) {
                failureFactorCard(rank: "1위", icon: "😥", title: "예상치 못한 피로감")
                failureFactorCard(rank: "2위", icon: "👥", title: "친구와의 약속")
            }
        }
    }
    
    // MARK: - 실패 요인 카드
    private func failureFactorCard(rank: String, icon: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 30, height: 30)
                .overlay(
                    Text(icon)
                        .font(.system(size: 18))
                )
            
            Text(rank)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .lineLimit(2)
        }
        .frame(width: 130, height: 100)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - 페이지 인디케이터
    private var pageIndicatorView: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Rectangle()
                    .fill(
                        index <= currentPage
                            ? Color.white
                            : Color.white.opacity(0.3)
                    )
                    .frame(width: 3, height: 20)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MonthlyReportView()
}
