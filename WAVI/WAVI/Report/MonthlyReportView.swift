//
//  MonthlyReportView.swift
//  WAVI
//
//  Created by 박현빈 on 10/23/25.
//


import SwiftUI

struct MonthlyReportView: View {
    @State private var currentPage = 0
    @Binding var monthlyCurrentPage: Int
    
    // ReportView에서 받은 데이터
    let overallSuccessRate: Double
    let topFailureReasons: [TopFailureReason]
    let habitSuccessRates: [HabitSuccessRate]
    let recommendations: [ReportRecommendation]
    let consistencyMessage: String
    
    init(monthlyCurrentPage: Binding<Int>, overallSuccessRate: Double = 0.0, topFailureReasons: [TopFailureReason] = [], habitSuccessRates: [HabitSuccessRate] = [], recommendations: [ReportRecommendation] = [], consistencyMessage: String = "") {
        self._monthlyCurrentPage = monthlyCurrentPage
        self.overallSuccessRate = overallSuccessRate
        self.topFailureReasons = topFailureReasons
        self.habitSuccessRates = habitSuccessRates
        self.recommendations = recommendations
        self.consistencyMessage = consistencyMessage
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 3페이지 스크롤 컨텐츠 (페이지 인디케이터 제거)
            TabView(selection: $currentPage) {
                // 1페이지: 성공률 차트
                ScrollView {
                    page1View
                }
                .tag(0)
                
                // 2페이지: 패턴 분석
                ScrollView {
                    page2View
                }
                .tag(1)
                
                // 3페이지: 노력 지수 & 동기부여
                ScrollView {
                    page3View
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: currentPage) { _, newPage in
                monthlyCurrentPage = newPage
            }
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
    
    private func formatScheduleWithDays(_ startTime: String, _ endTime: String, _ dayOfWeek: [Int]) -> String {
        let dayNames = ["일", "월", "화", "수", "목", "금", "토"]
        let dayStrings = dayOfWeek.map { dayNames[$0 - 1] }
        let dayText = dayStrings.joined(separator: ", ")
        
        let startHour = String(startTime.prefix(5))
        let endHour = String(endTime.prefix(5))
        
        return "\(startHour) - \(endHour) (\(dayText))"
    }
    
    // MARK: - Habit Change Card
    private func habitChangeCard(
        currentTitle: String,
        currentSchedule: String,
        currentIcon: String,
        recommendedTitle: String,
        recommendedSchedule: String,
        recommendedIcon: String
    ) -> some View {
        VStack(spacing: 12) {
            // 변경 전 습관
            HStack(spacing: 12) {
                // 아이콘
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(currentIcon)
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text(currentSchedule)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // 화살표
            HStack {
                Spacer()
                Image(systemName: "arrow.down")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 66/255, green: 129/255, blue: 182/255))
                Spacer()
            }
            
            // 변경 후 습관
            HStack(spacing: 12) {
                // 아이콘
                Circle()
                    .fill(Color(red: 66/255, green: 129/255, blue: 182/255).opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(recommendedIcon)
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 66/255, green: 129/255, blue: 182/255))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(recommendedTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(recommendedSchedule)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(red: 66/255, green: 129/255, blue: 182/255))
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - Failure Reason Icon Mapping
    private func getIconForFailureReason(_ reason: String) -> String {
        let lowercasedReason = reason.lowercased()
        
        if lowercasedReason.contains("피로") || lowercasedReason.contains("피로감") {
            return "😭"
        } else if lowercasedReason.contains("친구") || lowercasedReason.contains("약속") {
            return "👥"
        } else if lowercasedReason.contains("기상") || lowercasedReason.contains("늦어") {
            return "😴"
        } else if lowercasedReason.contains("의지") || lowercasedReason.contains("부족") {
            return "😔"
        } else if lowercasedReason.contains("시간") || lowercasedReason.contains("부족") {
            return "⏰"
        } else if lowercasedReason.contains("건강") || lowercasedReason.contains("문제") {
            return "💊"
        } else if lowercasedReason.contains("일정") || lowercasedReason.contains("충돌") {
            return "🤯"
        } else if lowercasedReason.contains("시험") || lowercasedReason.contains("시험기간") {
            return "📚"
        } else {
            return "🤔"
        }
    }
    
    // MARK: - 1페이지: 성공률 차트 + 습관 성공률
    private var page1View: some View {
        VStack(spacing: 0) {
            // 스크롤 가능한 상단 영역
            ScrollView {
                VStack(spacing: 30) {
                    // 전체 성공률 차트
                    ZStack {
                        // 배경 원
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                            .frame(width: 150, height: 150)
                        
                        // 진행률 원 (API 데이터)
                        Circle()
                            .trim(from: 0, to: overallSuccessRate / 100.0)
                            .stroke(
                                Color(Color(red: 66/255, green: 129/255, blue: 182/255)),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 150, height: 150)
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
                    
                    // 습관별 성공률 (상위 2개만 가로 나열)
                    HStack(spacing: 12) {
                        if habitSuccessRates.isEmpty {
                            // Mock 데이터 (실제 데이터가 없을 때만 사용)
                            habitSuccessCard(icon: "🏊‍♀️", title: "500m 수영하기", rate: "66%")
                            habitSuccessCard(icon: "💻", title: "코딩 테스트 문제 풀기", rate: "71%")
                        } else {
                            // 실제 DB 데이터 사용 (상위 2개만)
                            ForEach(Array(habitSuccessRates.prefix(2).enumerated()), id: \.offset) { index, habitRate in
                                habitSuccessCard(icon: habitRate.icon, title: habitRate.name, rate: "\(Int(habitRate.rate))%")
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
            }
            
            // 고정된 하단 영역 (꾸준함 지수)
            VStack(spacing: 10) {
                Text("꾸준함 지수: 높음 🔥")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Text(consistencyMessage.isEmpty ? "오전 운동도 바쁜 평일 아침에 60%나 성공했다는 건 테드님의 의지가 얼마나 강한지 보여줍니다." : consistencyMessage)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 66/255, green: 129/255, blue: 182/255))
                    .lineLimit(nil)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top,50)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - 2페이지: 실패 요인 분석
    private var page2View: some View {
        VStack(spacing: 0) {
            // 스크롤 가능한 상단 영역
            ScrollView {
                VStack(spacing: 30) {
                    // 주요 원인
                    VStack(spacing: 10) {
                    // 습관별 실패 요인 (상위 2개만)
                        ForEach(Array(habitSuccessRates.prefix(2).enumerated()), id: \.offset) { index, habitRate in
                            habitFailureSection(icon: habitRate.icon, title: habitRate.name)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
            
            // 고정된 하단 영역 (주요 원인 텍스트)
            VStack(spacing: 8) {
                Text("평일 체력 부담이 주요 원인!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Text("아침엔 기상 장벽, 저녁엔 피로와 약속")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 66/255, green: 129/255, blue: 182/255))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 50)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - 3페이지: 패턴 & 노력 지수 & 동기부여
    private var page3View: some View {
        VStack(spacing: 30) {
            // 전체 성공률 차트
            ZStack {
                // 배경 원
                Circle()
                    .stroke(Color.white, lineWidth: 20)
                    .frame(width: 150, height: 150)
                
                // 진행률 원 (API 데이터)
                Circle()
                    .trim(from: 0, to: overallSuccessRate / 100.0)
                    .stroke(
                        Color(red: 255/255, green: 165/255, blue: 0/255), // 오렌지색
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
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
            .padding(.top, 30)
            
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
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
    
    
    // MARK: - 습관 성공률 카드 (WeeklyReportView와 동일한 디자인)
    private func habitSuccessCard(icon: String, title: String, rate: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(icon)
                        .font(.system(size: 16))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
                
                Text("\(rate) 성공")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
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
                if topFailureReasons.isEmpty {
                    // Mock 데이터 (실제 데이터가 없을 때만 사용)
                    failureFactorCard(rank: "1위", icon: "😥", title: "예상치 못한 피로감")
                    failureFactorCard(rank: "2위", icon: "👥", title: "친구와의 약속")
                } else {
                    // 실제 DB 데이터 사용 (상위 2개만)
                    ForEach(Array(topFailureReasons.prefix(2).enumerated()), id: \.offset) { index, reason in
                        let rank = "\(index + 1)위"
                        let icon = getIconForFailureReason(reason.reason)
                        failureFactorCard(rank: rank, icon: icon, title: reason.reason)
                    }
                }
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
    MonthlyReportView(monthlyCurrentPage: .constant(0), consistencyMessage: "이번 달 꾸준함이 정말 좋아요! 계속 이렇게 유지해보세요! 🔥")
}
