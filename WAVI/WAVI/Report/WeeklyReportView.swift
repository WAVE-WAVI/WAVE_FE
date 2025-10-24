//
//  WeeklyReportView.swift
//  WAVI
//
//  Created by 박현빈 on 10/23/25.
//
//
//  WeeklyReportView.swift
//  WAVI
//
//  Created by 서영채 on 10/12/25.
//

import SwiftUI
import Combine

struct WeeklyReportView: View {
    @Binding var selectedWeek: Int
    @Binding var currentMonth: Int
    @Binding var currentYear: Int
    @State var failureReasons: [String] = []
    @State var overallSuccessRate: Double = 0.0
    @State var habitSuccessRates: [(String, Double)] = []
    @State var appliedRecommendations: Set<Int> = [] // 적용된 추천 ID들
    @State private var cancellables = Set<AnyCancellable>()
    
    // ReportView에서 받은 데이터
    let reportOverallSuccessRate: Double
    let reportTopFailureReasons: [TopFailureReason]
    let reportHabitSuccessRates: [HabitSuccessRate]
    let reportRecommendations: [ReportRecommendation]
    
    init(selectedWeek: Binding<Int>, currentMonth: Binding<Int>, currentYear: Binding<Int>, overallSuccessRate: Double, topFailureReasons: [TopFailureReason], habitSuccessRates: [HabitSuccessRate], recommendations: [ReportRecommendation]) {
        self._selectedWeek = selectedWeek
        self._currentMonth = currentMonth
        self._currentYear = currentYear
        self.reportOverallSuccessRate = overallSuccessRate
        self.reportTopFailureReasons = topFailureReasons
        self.reportHabitSuccessRates = habitSuccessRates
        self.reportRecommendations = recommendations
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 주간 선택 (동적) - 가로 스크롤
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(weekOptions.enumerated()), id: \.offset) { index, week in
                                Text(week)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedWeek == index ? .black : .gray)
                                    .padding(.horizontal, 12) // 주차 선택 버튼 좌우 여백
                                    .padding(.vertical, 6) // 주차 선택 버튼 상하 여백
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(selectedWeek == index ? Color.gray.opacity(0.2) : Color.clear)
                                    )
                                    .onTapGesture {
                                        selectedWeek = index
                                    }
                                    .id(index)
                            }
                        }
                        .padding(.horizontal, 20) // 주차 선택 영역 좌우 여백
                    }
                    .onAppear {
                        // 현재 선택된 주차를 센터로 스크롤
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(selectedWeek, anchor: .center)
                        }
                    }
                    .onChange(of: selectedWeek) { _, newWeek in
                        // 주차가 변경될 때도 센터로 스크롤
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(newWeek, anchor: .center)
                        }
                    }
                }
                
                // 성공률 섹션
                weeklySuccessRateSection
                
                // 주요 실패 요인 섹션
                failureFactorsSection
                
                // 대체하는 습관 추천 섹션
                alternativeHabitsSection
            }
            .padding(.horizontal, 20) // 주간 리포트 뷰 좌우 여백
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
    
    private func getIconForFailureReason(_ reason: String) -> String {
        if reason.contains("피로") {
            return "😪"
        } else if reason.contains("약속") {
            return "👥"
        } else if reason.contains("기상") {
            return "😴"
        } else if reason.contains("시간") {
            return "⏰"
        } else {
            return "😥"
        }
    }
    
    private func getCurrentHabitName(for recommendation: ReportRecommendation) -> String {
        return recommendation.currentHabitName ?? "현재 습관"
    }
    
    private func getCurrentHabitSchedule(for recommendation: ReportRecommendation) -> String {
        if let startTime = recommendation.currentHabitStartTime,
           let endTime = recommendation.currentHabitEndTime,
           let dayOfWeek = recommendation.currentHabitDayOfWeek {
            return formatScheduleWithDays(startTime, endTime, dayOfWeek)
        }
        return "현재 스케줄"
    }
    
    private func formatSchedule(_ startTime: String, _ endTime: String) -> String {
        let start = formatTime(startTime)
        let end = formatTime(endTime)
        return "\(start)-\(end)"
    }
    
    private func formatScheduleWithDays(_ startTime: String, _ endTime: String, _ dayOfWeek: [Int]) -> String {
        let timeSchedule = formatSchedule(startTime, endTime)
        let dayNames = ["월", "화", "수", "목", "금", "토", "일"]
        let dayStrings = dayOfWeek.map { dayNames[$0 - 1] }.joined(separator: "·")
        return "\(dayStrings) \(timeSchedule)"
    }
    
    private func formatTime(_ timeString: String) -> String {
        // "09:00:00" -> "09:00" 형태로 변환
        let components = timeString.components(separatedBy: ":")
        if components.count >= 2 {
            return "\(components[0]):\(components[1])"
        }
        return timeString
    }
    
    // MARK: - Week Options
    private var weekOptions: [String] {
        let calendar = Calendar.current
        let monthNames = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
        let monthName = monthNames[currentMonth - 1]
        
        // 해당 월의 주 수 계산
        let dateComponents = DateComponents(year: currentYear, month: currentMonth, day: 1)
        guard let firstDayOfMonth = calendar.date(from: dateComponents) else { return [] }
        
        let range = calendar.range(of: .weekOfMonth, in: .month, for: firstDayOfMonth)
        let weekCount = range?.count ?? 4
        
        var weeks: [String] = []
        for i in 1...weekCount {
            let weekNames = ["첫째", "둘째", "셋째", "넷째", "다섯째", "여섯째"]
            if i <= weekNames.count {
                weeks.append("\(monthName) \(weekNames[i-1]) 주")
            }
        }
        
        return weeks
    }
    
    // MARK: - Weekly Success Rate Section
    private var weeklySuccessRateSection: some View {
        HStack(spacing: 20) {
            // 도넛 차트
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: reportOverallSuccessRate / 100.0)
                    .stroke(Color(red: 66/255, green: 129/255, blue: 182/255), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("전체 성공률")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                    
                    Text("\(Int(reportOverallSuccessRate))%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            
            // 습관별 성공률 (스크롤 가능)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(reportHabitSuccessRates.enumerated()), id: \.offset) { index, habitRate in
                        weeklyHabitSuccessItem(icon: habitRate.icon, title: habitRate.name, rate: "\(Int(habitRate.rate))%")
                    }
                }
            }
            .frame(maxHeight: 300) // 최대 높이 제한
            
            Spacer()
        }
    }
    
    private func weeklyHabitSuccessItem(icon: String, title: String, rate: String) -> some View {
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
    
    // MARK: - Failure Factors Section
    private var failureFactorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주요 실패 요인")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
            
            if sortedFailureReasons.isEmpty {
                // 데이터가 없을 때 표시할 메시지
                VStack(spacing: 8) {
                    Text("📊")
                        .font(.system(size: 32))
                    Text("실패 요인 데이터가 없습니다")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text("이번 주에는 실패한 습관이 없었어요!")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20) // 데이터 없음 메시지 상하 여백
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
            } else {
                HStack(spacing: 12) {
                    ForEach(Array(sortedFailureReasons.enumerated()), id: \.offset) { index, reason in
                        let rank = "\(index + 1)위"
                        let icon = getIconForFailureReason(reason.reason)
                        failureFactorCard(rank: rank, icon: icon, title: reason.reason)
                    }
                }
            }
        }
    }
    
    // 실패 요인을 우선순위(priority)로 정렬
    private var sortedFailureReasons: [TopFailureReason] {
        return reportTopFailureReasons.sorted { $0.priority < $1.priority }
    }
    
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
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16) // 습관 카드 상하 여백
        .padding(.horizontal, 2) // 습관 카드 좌우 여백
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    
    // MARK: - Alternative Habits Section
    private var alternativeHabitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                Text("습관 변경 추천")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            if reportRecommendations.isEmpty {
                // Mock 데이터 표시
                VStack(spacing: 16) {
                    habitChangeCard(
                        recommendation: ReportRecommendation(id: 1, name: "300m 수영하기", startTime: "07:00:00", endTime: "07:30:00", dayOfWeek: [1, 3, 5], currentHabitName: "500m 수영하기", currentHabitStartTime: "07:00:00", currentHabitEndTime: "07:30:00", currentHabitDayOfWeek: [1, 3, 5]),
                        currentTitle: "500m 수영하기",
                        currentSchedule: "월·수·금 07:00-07:30",
                        currentIcon: "🏊‍♀️",
                        recommendedTitle: "300m 수영하기",
                        recommendedSchedule: "월·수·금 07:00-07:30",
                        recommendedIcon: "🏊‍♀️",
                        isApplied: false
                    )
                    
                    habitChangeCard(
                        recommendation: ReportRecommendation(id: 2, name: "알고리즘 기초 학습", startTime: "20:00:00", endTime: "21:00:00", dayOfWeek: [1, 2, 3, 4, 5], currentHabitName: "코딩 테스트 문제 풀기", currentHabitStartTime: "20:00:00", currentHabitEndTime: "21:00:00", currentHabitDayOfWeek: [1, 2, 3, 4, 5]),
                        currentTitle: "코딩 테스트 문제 풀기",
                        currentSchedule: "월·화·수·목·금 20:00-21:00",
                        currentIcon: "💻",
                        recommendedTitle: "알고리즘 기초 학습",
                        recommendedSchedule: "월·화·수·목·금 20:00-21:00",
                        recommendedIcon: "📚",
                        isApplied: false
                    )
                }
            } else {
                // 추천 습관 카드들
                VStack(spacing: 16) {
                    ForEach(Array(reportRecommendations.enumerated()), id: \.offset) { index, recommendation in
                        habitChangeCard(
                            recommendation: recommendation,
                            currentTitle: getCurrentHabitName(for: recommendation),
                            currentSchedule: getCurrentHabitSchedule(for: recommendation),
                            currentIcon: getIconForHabit(recommendation.name),
                            recommendedTitle: recommendation.name,
                            recommendedSchedule: formatScheduleWithDays(recommendation.startTime, recommendation.endTime, recommendation.dayOfWeek),
                            recommendedIcon: getIconForHabit(recommendation.name),
                            isApplied: appliedRecommendations.contains(recommendation.id)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Habit Change Card
    private func habitChangeCard(
        recommendation: ReportRecommendation,
        currentTitle: String,
        currentSchedule: String,
        currentIcon: String,
        recommendedTitle: String,
        recommendedSchedule: String,
        recommendedIcon: String,
        isApplied: Bool
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
                
                // 습관 정보
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(currentSchedule)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 변경 전 라벨
                Text("변경 전")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            // 변경 아이콘 (스위치 버튼)
            HStack {
                Spacer()
                Button(action: {
                    applyHabitChange(recommendation: recommendation)
                }) {
                    Circle()
                        .fill(isApplied ? Color.green : Color.black)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: isApplied ? "checkmark" : "arrow.up.arrow.down")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        )
                }
                .buttonStyle(.plain)
                Spacer()
            }
            
            // 변경 후 습관
            HStack(spacing: 12) {
                // 아이콘
                Circle()
                    .fill(Color(red: 87/255, green: 102/255, blue: 0/255))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(recommendedIcon)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    )
                
                // 습관 정보
                VStack(alignment: .leading, spacing: 2) {
                    Text(recommendedTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(recommendedSchedule)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 변경 후 라벨
                Text("변경 후")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(16) // 추천 습관 카드 내부 여백
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - Helper Functions
    private func applyHabitChange(recommendation: ReportRecommendation) {
        if appliedRecommendations.contains(recommendation.id) {
            // 이미 적용된 경우 취소
            appliedRecommendations.remove(recommendation.id)
            print("❌ 습관 변경 취소: \(recommendation.name)")
        } else {
            // 추천 적용
            appliedRecommendations.insert(recommendation.id)
            print("✅ 습관 변경 적용: \(recommendation.name)")
            
            // 실제 습관 변경 API 호출
            do {
                let habitService = NewHabitService()
                let request = HabitRequest(
                    name: recommendation.name,
                    dayOfWeek: recommendation.dayOfWeek,
                    icon: "🏃‍♂️",
                    startTime: recommendation.startTime,
                    endTime: recommendation.endTime
                )
                
                habitService.updateHabit(id: "1", request: request)
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { completion in
                            switch completion {
                            case .failure(let error):
                                print("❌ 습관 변경 실패: \(error)")
                                // 실패 시 적용 상태 취소
                                appliedRecommendations.remove(recommendation.id)
                            case .finished:
                                print("✅ 습관 변경 완료: \(recommendation.name)")
                            }
                        },
                        receiveValue: { response in
                            print("✅ 습관 변경 API 응답: \(response.message)")
                        }
                    )
                    .store(in: &cancellables)
            } catch {
                print("❌ 습관 변경 요청 생성 실패: \(error)")
                appliedRecommendations.remove(recommendation.id)
            }
        }
    }
}

struct WeeklyReportView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyReportView(
            selectedWeek: .constant(0),
            currentMonth: .constant(10),
            currentYear: .constant(2025),
            overallSuccessRate: 69.0,
            topFailureReasons: [
                TopFailureReason(id: 1, reason: "예상치 못한 피로감", priority: 1),
                TopFailureReason(id: 2, reason: "친구와의 약속", priority: 2),
                TopFailureReason(id: 3, reason: "늦어진 기상 시간", priority: 3)
            ],
            habitSuccessRates: [
                HabitSuccessRate(name: "3km 러닝", rate: 66.0, icon: "🏊‍♀️"),
                HabitSuccessRate(name: "코딩 테스트 3문제 풀기", rate: 71.0, icon: "💻")
            ],
            recommendations: [
                ReportRecommendation(id: 1, name: "1km 러닝", startTime: "07:00:00", endTime: "07:30:00", dayOfWeek: [1, 3, 5], currentHabitName: "3km 러닝", currentHabitStartTime: "07:00:00", currentHabitEndTime: "07:30:00", currentHabitDayOfWeek: [1, 3, 5]),
                ReportRecommendation(id: 2, name: "코딩 테스트 문제 풀기", startTime: "20:00:00", endTime: "21:00:00", dayOfWeek: [1, 2, 3, 4, 5], currentHabitName: "알고리즘 공부", currentHabitStartTime: "20:00:00", currentHabitEndTime: "21:00:00", currentHabitDayOfWeek: [1, 2, 3, 4, 5])
            ]
        )
    }
}

