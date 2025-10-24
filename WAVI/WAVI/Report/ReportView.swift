//
//  ReportView.swift
//  WAVI
//
//  Created by 박현빈 on 10/23/25.
//

//
//  ReportView.swift
//  WAVI
//
//  Created by 서영채 on 10/8/25.
//

import SwiftUI
import Combine

struct ReportView: View {
    @Environment(\.dismiss) private var dismiss
    @State var weekDates: [Int] = []
    @State var currentSelectedDate: Int
    @State var selectedTab = 0
    @State var selectedHabit = 0
    @State var habitCompletionStatus: [Bool] = [true, true, false, true, false] // 3번째, 5번째 습관 미완료
    @State var selectedWeek = 0
    @State var currentMonth = 10
    @State var currentYear = 2025
    @State var currentWeekOffset = 0 // 현재 주의 오프셋 (0 = 현재 주, -1 = 이전 주, 1 = 다음 주)
    @State var monthlyCurrentPage = 0 // 월간 기록의 현재 페이지
    
    // API 관련 상태
    @State var habitLogs: [HabitLogData] = []
    @State var isLoadingLogs = false
    @State var reports: [ReportData] = []
    @State var isLoadingReports = false
    @State var cancellables = Set<AnyCancellable>()
    
    // 실제 습관 데이터
    @State var actualHabits: [(id: Int, name: String, icon: String, completed: Bool)] = []
    
    // 리포트 데이터
    @State var overallSuccessRate: Double = 0.0
    @State var topFailureReasons: [TopFailureReason] = []
    @State var habitSuccessRates: [HabitSuccessRate] = []
    @State var recommendations: [ReportRecommendation] = []
    
    // API 서비스
    let habitService = NewHabitService()
    
    let tabs = ["하루 기록", "주간 기록", "월간 기록"]
    let days = ["월", "화", "수", "목", "금", "토", "일"] // 월요일부터 시작
    
    // 확장된 날짜 데이터 (12월부터 19월까지)
    @State var extendedWeekDates: [Int] = []
    @State var extendedDays: [String] = []
    
    // MARK: - Data
    let habitColors: [Color] = [
        Color(red: 155/255, green: 203/255, blue: 244/255),
        Color(red: 66/255, green: 129/255, blue: 182/255),
        Color.gray,
        Color(red: 113/255, green: 82/255, blue: 50/255),
        Color.gray
    ]
    
    @State var habitIcons: [String] = [
        "💦",
        "🏊‍♀️",
        "🌞",
        "💻",
        "📚"
    ]
    
    let habitCardTitles: [String] = [
        "물 마시기",
        "500m 수영하기",
        "자외선 차단제 바르기",
        "코딩 테스트 문제풀기",
        "독서하기"
    ]
    
    let habitCardTimes: [String] = [
        "07:00-07:30",
        "09:30-10:00",
        "12:30-13:00",
        "14:00-15:00",
        "20:00-21:00"
    ]
    
    init() {
        // 오늘 날짜를 기본값으로 설정
        let today = Date()
        let calendar = Calendar.current
        let todayDay = calendar.component(.day, from: today)
        let todayMonth = calendar.component(.month, from: today)
        let todayYear = calendar.component(.year, from: today)
        
        self._currentSelectedDate = State(initialValue: todayDay)
        self._weekDates = State(initialValue: [])
        self._currentMonth = State(initialValue: todayMonth)
        self._currentYear = State(initialValue: todayYear)
        
        print("🔍 ReportView 초기화: 오늘 날짜=\(todayDay), 월=\(todayMonth), 년=\(todayYear)")
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경색 - 항상 회색
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 상단 헤더
                    topHeaderView
                    
                    // 메인 컨텐츠 카드
                    mainCardView
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                setupWeekDates()
                loadHabitLogs()
                loadReports()
            }
        }
    }
    
    // MARK: - Top Header View
    var topHeaderView: some View {
        HStack() {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.black)
            }
            Text("습관 리포트")
                .font(.system(size: 36, weight: .bold))
                .lineSpacing(4)
                .foregroundColor(.primaryBlack)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Main Card View
    var mainCardView: some View {
        VStack(spacing: 0) {
            // 카드 안의 헤더 (월/년도 네비게이션)
            monthNavigationView
            
            // 탭 선택
            tabSelectionView
            
            // 월간기록일 때만 3개 막대기 표시
            if selectedTab == 2 {
                monthlyPageIndicatorView
            }
            
            // 날짜 선택 (하루 기록일 때만 표시)
            if selectedTab == 0 {
                weekCalendarView
            }
            
            // 탭뷰로 변경된 하단 섹션 (스크롤 가능)
            ScrollView {
                TabView(selection: $selectedTab) {
                    // 하루 기록
                    dailyReportView
                        .tag(0)
                    
                    // 주간 기록
                    weeklyReportView
                        .tag(1)
                    
                    // 월간 기록
                    monthlyReportView
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(minHeight: selectedTab == 1 ? 400 : 500)
            }
            .padding(.top, 20)
            
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(cardBackgroundView)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, selectedTab == 1 ? 0 : 20)
    }
    
    // MARK: - Month Navigation View
    var monthNavigationView: some View {
        HStack {
            Button(action: {
                moveToPreviousMonth()
            }) {
                Image(systemName: "arrowtriangle.backward.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(selectedTab == 2 ? .white : .black)
            }
            
            Text("\(String(currentYear))년 \(String(currentMonth))월")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(selectedTab == 2 ? .white : .black)
            
            Button(action: {
                moveToNextMonth()
            }) {
                Image(systemName: "arrowtriangle.forward.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(selectedTab == 2 ? .white : .black)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Tab Selection View
    var tabSelectionView: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                VStack(spacing: 0) {
                    if selectedTab == index {
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 8))
                            .foregroundColor(selectedTab == 2 ? .white : .black)
                    } else {
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.clear)
                    }
                    
                    Text(tabs[index])
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedTab == 2 ? .white : (selectedTab == index ? .black : .gray))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedTab = index
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 16)
    }
    
    // MARK: - Week Calendar View
    var weekCalendarView: some View {
        HStack(spacing: 8) {
            ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                VStack(spacing: 2) {
                    Text("\(date)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(currentSelectedDate == date ? .black : .gray)
                    
                    Text(days[index])
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(currentSelectedDate == date ? .black : .gray)
                }
                .frame(width: 38, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(currentSelectedDate == date ? Color.gray.opacity(0.2) : Color.clear)
                )
                       .onTapGesture {
                           currentSelectedDate = date
                           // 날짜 선택 시 해당 날짜의 습관 로그 조회
                           loadHabitLogsForDate(selectedDate: date)
                       }
            }
        }
        .padding(.top, 16)
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width > threshold {
                        // 오른쪽으로 swipe - 이전 주
                        moveToPreviousWeek()
                    } else if value.translation.width < -threshold {
                        // 왼쪽으로 swipe - 다음 주
                        moveToNextWeek()
                    }
                }
        )
    }
    
    // MARK: - Monthly Page Indicator View
    var monthlyPageIndicatorView: some View {
        HStack(spacing: 20) {
            ForEach(0..<3, id: \.self) { index in
                Rectangle()
                    .fill(
                        index <= monthlyCurrentPage // 현재 페이지까지 활성화
                            ? Color.white
                            : Color.white.opacity(0.3)
                    )
                    .frame(width: 70, height: 2)
                    .animation(.easeInOut(duration: 0.3), value: monthlyCurrentPage)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Card Background View
    var cardBackgroundView: some View {
        Group {
            if selectedTab == 2 {
                // 월간 기록만 - 그라데이션 배경
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 155/255, green: 203/255, blue: 244/255),
                            Color.white
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            } else {
                // 하루/주간 기록 - 흰색 배경
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
        }
    }
    
    
    // MARK: - Daily Report View
    var dailyReportView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 습관 목록 섹션
            habitListSectionView
            
            // 성공률 차트 섹션
            progressChartSectionView
            
            // 습관 카드 섹션
            habitCardsSectionView
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Weekly Report View
    var weeklyReportView: some View {
        WeeklyReportView(
            selectedWeek: $selectedWeek,
            currentMonth: $currentMonth,
            currentYear: $currentYear,
            overallSuccessRate: overallSuccessRate,
            topFailureReasons: topFailureReasons,
            habitSuccessRates: habitSuccessRates,
            recommendations: recommendations
        )
    }
    
    // MARK: - Monthly Report View
    var monthlyReportView: some View {
        MonthlyReportView(
            monthlyCurrentPage: $monthlyCurrentPage,
            overallSuccessRate: overallSuccessRate,
            topFailureReasons: topFailureReasons,
            habitSuccessRates: habitSuccessRates,
            recommendations: recommendations
        )
    }
    
    
    // MARK: - Habit List Section View
    var habitListSectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("습관 목록")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Text("좌우로 스와이프해 습관을 확인하세요")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
            
            // 습관 아이콘들 (실제 습관만 표시)
            HStack(spacing: 16) {
                ForEach(Array(actualHabits.enumerated()), id: \.offset) { index, habit in
                    Circle()
                        .fill(habit.completed ? habitColors[index % habitColors.count] : Color.gray.opacity(0.3))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text(habit.icon)
                                .font(.system(size: 14))
                                .foregroundColor(habit.completed ? .white : .gray)
                        )
                }
                Spacer()
            }
        }
    }
    
    // MARK: - Progress Chart Section View
    var progressChartSectionView: some View {
        VStack(spacing: 20) {
            // 도넛 차트
            ZStack {
                // 배경 원
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                // 성공률 원
                Circle()
                    .trim(from: 0, to: overallSuccessRate)
                    .stroke(Color(red: 66/255, green: 129/255, blue: 182/255), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                // 중앙 텍스트
                VStack(spacing: 4) {
                    Text("전체 성공률")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("\(String(format: "%.0f", overallSuccessRate * 100))%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                }
            }
        }
    }
    
    // MARK: - Habit Cards Section View
    var habitCardsSectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(actualHabits.enumerated()), id: \.offset) { index, habit in
                    habitCardView(habit: habit, index: index)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Habit Card View
    func habitCardView(habit: (id: Int, name: String, icon: String, completed: Bool), index: Int) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(habit.completed ? habitColors[index % habitColors.count] : Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(habit.icon)
                        .font(.system(size: 20))
                        .foregroundColor(habit.completed ? .white : .gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(currentSelectedDate)일")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(habit.completed ? Color.white : Color.gray.opacity(0.2))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - API Methods
    func loadHabitLogs() {
        loadHabitLogsForDate(selectedDate: currentSelectedDate)
    }
    
    func loadHabitLogsForDate(selectedDate: Int) {
        isLoadingLogs = true
        
        // 선택된 날짜 기준으로 로그 조회
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: currentYear, month: currentMonth, day: selectedDate)
        
        guard let selectedDateObj = calendar.date(from: dateComponents) else {
            print("❌ 날짜 생성 실패")
            isLoadingLogs = false
            return
        }
        
        // 선택된 날짜의 요일 계산 (1=일요일, 2=월요일, ..., 7=토요일)
        let weekday = calendar.component(.weekday, from: selectedDateObj)
        // Calendar.current.weekday를 서버 형식으로 변환 (1=월요일, 2=화요일, ..., 7=일요일)
        let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDateObj)
        
        print("📅 선택된 날짜: \(dateString), 요일: \(adjustedWeekday) (1=월, 7=일)")
        
        // 1. 먼저 해당 날짜의 로그 조회
        habitService.getHabitLogs(startDate: dateString, endDate: dateString)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoadingLogs = false
                    switch completion {
                    case .failure(let error):
                        print("❌ 습관 로그 조회 실패: \(error)")
                    case .finished:
                        break
                    }
                },
                receiveValue: { response in
                    print("✅ 습관 로그 조회 성공: \(response)")
                    if let logs = response.data {
                        habitLogs = logs
                        // 2. 해당 요일에 맞는 습관들만 필터링하여 표시
                        updateHabitCompletionStatusForWeekday(from: logs, weekday: adjustedWeekday)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func updateHabitCompletionStatusForWeekday(from logs: [HabitLogData], weekday: Int) {
        // 해당 요일에 맞는 습관들만 필터링하여 표시
        print("🔍 요일별 습관 필터링 시작: \(logs.count)개 항목, 요일: \(weekday)")
        
        // 먼저 모든 습관을 가져와서 해당 요일에 실행되는 습관들만 필터링
        habitService.getAllHabits()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("❌ 모든 습관 조회 실패: \(error)")
                    case .finished:
                        break
                    }
                },
                receiveValue: { response in
                    print("✅ 모든 습관 조회 성공: \(response)")
                    if let habits = response.data {
                        // 해당 요일에 실행되는 습관들만 필터링 (1-7)
                        let weekdayHabits = habits.filter { habit in
                            habit.dayOfWeek.contains(weekday)
                        }
                        
                        print("📅 요일 \(weekday)에 실행되는 습관: \(weekdayHabits.count)개")
                        for habit in weekdayHabits {
                            print("🔍 습관: \(habit.name), 아이콘: \(habit.icon)")
                        }
                        
                        // 로그 데이터와 매칭하여 완료 상태 업데이트
                        self.updateHabitCompletionStatusWithWeekdayFilter(from: logs, weekdayHabits: weekdayHabits)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func updateHabitCompletionStatusWithWeekdayFilter(from logs: [HabitLogData], weekdayHabits: [HabitData]) {
        // 요일별 필터링된 습관들의 완료 상태 업데이트
        print("🔍 요일별 습관 완료 상태 업데이트: \(weekdayHabits.count)개 습관")
        
        var habitStatusMap: [Int: (completed: Bool, name: String, icon: String)] = [:]
        
        // 로그에서 완료 상태 확인
        for log in logs {
            habitStatusMap[log.habitId] = (completed: log.completed, name: log.name, icon: "📝") // 기본 아이콘
        }
        
        // 요일별 습관들을 actualHabits에 추가
        actualHabits = weekdayHabits.map { habit in
            let status = habitStatusMap[habit.id] ?? (completed: false, name: habit.name, icon: habit.icon)
            return (id: habit.id, name: status.name, icon: habit.icon, completed: status.completed)
        }
        
        // 전체 성공률 계산
        calculateOverallSuccessRate(from: logs)
        
        print("✅ 요일별 습관 업데이트 완료: \(actualHabits.count)개")
    }
    
    func updateHabitCompletionStatus(from logs: [HabitLogData], habits: [HabitData]) {
        // 로그 데이터를 기반으로 습관 완료 상태 업데이트
        print("🔍 습관 로그 업데이트 시작: \(logs.count)개 항목")
        
        // 습관별로 최신 상태 확인 (같은 날짜, 같은 습관의 경우 마지막 로그가 최신)
        var habitStatusMap: [Int: (completed: Bool, name: String, icon: String)] = [:]
        
        // 먼저 서버에서 받은 습관 데이터로 초기화
        for habit in habits {
            habitStatusMap[habit.id] = (completed: false, name: habit.name, icon: habit.icon)
        }
        
        // 로그 데이터로 완료 상태 업데이트
        for log in logs {
            // 같은 습관에 대해 여러 로그가 있을 경우, 마지막 상태를 사용
            if let existingHabit = habitStatusMap[log.habitId] {
                habitStatusMap[log.habitId] = (completed: log.completed, name: existingHabit.name, icon: existingHabit.icon)
            } else {
                habitStatusMap[log.habitId] = (completed: log.completed, name: log.name, icon: "📝")
            }
            print("📝 습관 \(log.habitId) (\(log.name)): \(log.completed ? "완료" : "미완료")")
        }
        
        // 실제 습관 데이터 생성
        let sortedHabits = habitStatusMap.sorted { $0.key < $1.key }
        actualHabits = sortedHabits.map { (habitId, habitData) in
            print("🎯 실제 습관 생성: \(habitData.name) (\(habitData.completed ? "완료" : "미완료"))")
            return (id: habitId, name: habitData.name, icon: habitData.icon, completed: habitData.completed)
        }
        
        // 전체 성공률 계산
        calculateOverallSuccessRate(from: logs)
        
        print("✅ 습관 상태 업데이트 완료")
    }
    
    func calculateOverallSuccessRate(from logs: [HabitLogData]) {
        // 습관별로 최신 상태만 고려하여 성공률 계산
        var habitLatestStatus: [Int: Bool] = [:]
        
        // 각 습관의 마지막 로그 상태 저장
        for log in logs {
            habitLatestStatus[log.habitId] = log.completed
        }
        
        let totalHabits = habitLatestStatus.count
        let completedHabits = habitLatestStatus.values.filter { $0 }.count
        
        if totalHabits > 0 {
            overallSuccessRate = Double(completedHabits) / Double(totalHabits)
            print("📊 성공률 계산 (습관별): \(completedHabits)/\(totalHabits) = \(String(format: "%.1f", overallSuccessRate * 100))%")
            print("📝 습관별 상태:")
            for (habitId, completed) in habitLatestStatus {
                print("  - 습관 \(habitId): \(completed ? "완료" : "미완료")")
            }
        } else {
            overallSuccessRate = 0.0
            print("📊 성공률 계산: 습관 없음")
        }
    }
    
    
    func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MM월 dd일"
            return formatter.string(from: date)
        }
        
        return dateString
    }
    
    func loadReports() {
        isLoadingReports = true
        
        // 주간 리포트 조회
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)
        
        habitService.getReports(type: "WEEKLY", startDate: todayString, endDate: todayString)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoadingReports = false
                    switch completion {
                    case .failure(let error):
                        print("❌ 리포트 조회 실패: \(error)")
                    case .finished:
                        break
                    }
                },
                receiveValue: { response in
                    print("✅ 리포트 조회 성공: \(response)")
                    if let reportData = response.data {
                        reports = reportData
                        updateUIFromReports(reportData)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func updateUIFromReports(_ reportData: [ReportData]) {
        // 리포트 데이터를 기반으로 UI 업데이트
        for report in reportData {
            print("📊 리포트 타입: \(report.type)")
            print("📝 요약: \(report.summary)")
            
            // 전체 성공률 업데이트
            if let successRate = report.overallSuccessRate {
                overallSuccessRate = successRate
                print("📈 전체 성공률: \(successRate)%")
            }
            
            // 주요 실패 요인 업데이트
            if let failureReasons = report.topFailureReasons {
                topFailureReasons = failureReasons
                print("❌ 주요 실패 요인:")
                for reason in failureReasons {
                    print("  - \(reason.reason) (우선순위: \(reason.priority))")
                }
            }
            
            // 습관별 성공률 업데이트
            if let habitRates = report.habitSuccessRates {
                habitSuccessRates = habitRates
                print("📊 습관별 성공률:")
                for habitRate in habitRates {
                    print("  - \(habitRate.name): \(habitRate.rate)%")
                }
            }
            
            if let recommendations = report.recommendation {
                self.recommendations = recommendations
                print("💡 추천 습관:")
                for rec in recommendations {
                    print("  - \(rec.name) (\(rec.startTime) - \(rec.endTime))")
                }
            }
        }
    }
    
    // MARK: - Setup Week Dates
    func setupWeekDates() {
        let calendar = Calendar.current
        let today = Date()
        
        // 오늘 날짜가 포함된 주의 시작일(월요일) 찾기
        let weekday = calendar.component(.weekday, from: today)
        // 일요일=1, 월요일=2, 화요일=3, ..., 토요일=7
        // 월요일부터 시작하려면: 월요일=0, 화요일=1, ..., 일요일=6
        let daysFromMonday = (weekday == 1) ? 6 : (weekday - 2)
        
        let startOfWeek = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        
        // 일주일치 날짜 생성 (월요일부터 일요일까지)
        var dates: [Int] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let day = calendar.component(.day, from: date)
                dates.append(day)
            }
        }
        
        weekDates = dates
        
        // 확장된 날짜도 설정 (현재 주 + 다음 주 일부)
        var extendedDates: [Int] = dates
        var extendedDayNames: [String] = []
        
        // 현재 주의 요일 이름들 (월요일부터)
        for i in 0..<7 {
            extendedDayNames.append(days[i])
        }
        
        // 다음 주 일부 추가
        if let lastDate = calendar.date(byAdding: .day, value: 7, to: startOfWeek) {
            let nextWeekDay = calendar.component(.day, from: lastDate)
            extendedDates.append(nextWeekDay)
            extendedDayNames.append("월") // 다음 주 월요일
        }
        
        extendedWeekDates = extendedDates
        extendedDays = extendedDayNames
        
        print("📅 주간 날짜 설정 (월요일부터): \(weekDates)")
        print("📅 확장된 날짜 설정: \(extendedWeekDates)")
        print("📅 확장된 요일 설정: \(extendedDays)")
    }
    
    // MARK: - Week Navigation
    func moveToPreviousWeek() {
        currentWeekOffset -= 1
        updateWeekDates()
        print("📅 이전 주로 이동: 오프셋 \(currentWeekOffset)")
    }
    
    func moveToNextWeek() {
        currentWeekOffset += 1
        updateWeekDates()
        print("📅 다음 주로 이동: 오프셋 \(currentWeekOffset)")
    }
    
    func updateWeekDates() {
        let calendar = Calendar.current
        let today = Date()
        
        // 현재 주의 시작일(월요일) 찾기
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday == 1) ? 6 : (weekday - 2)
        let startOfCurrentWeek = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        
        // 오프셋에 따라 주 이동
        let targetWeekStart = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: startOfCurrentWeek) ?? startOfCurrentWeek
        
        // 일주일치 날짜 생성 (월요일부터 일요일까지)
        var dates: [Int] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: targetWeekStart) {
                let day = calendar.component(.day, from: date)
                dates.append(day)
            }
        }
        
        weekDates = dates
        
        // 월/년도도 업데이트 (첫 번째 날짜 기준)
        if let firstDate = calendar.date(byAdding: .day, value: 0, to: targetWeekStart) {
            let month = calendar.component(.month, from: firstDate)
            let year = calendar.component(.year, from: firstDate)
            currentMonth = month
            currentYear = year
        }
        
        print("📅 주간 날짜 업데이트: \(weekDates), \(currentYear)년 \(currentMonth)월")
    }
    
    // MARK: - Month Navigation
    func moveToPreviousMonth() {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: currentYear, month: currentMonth, day: 1)
        
        if let currentDate = calendar.date(from: dateComponents) {
            if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDate) {
                let newMonth = calendar.component(.month, from: previousMonth)
                let newYear = calendar.component(.year, from: previousMonth)
                
                currentMonth = newMonth
                currentYear = newYear
                currentWeekOffset = 0 // 월이 바뀌면 현재 주로 리셋
                selectedWeek = 0 // 주간 선택도 첫 번째 주로 리셋
                setupWeekDates()
                
                print("📅 이전 달로 이동: \(currentYear)년 \(currentMonth)월")
            }
        }
    }
    
    func moveToNextMonth() {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: currentYear, month: currentMonth, day: 1)
        
        if let currentDate = calendar.date(from: dateComponents) {
            if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) {
                let newMonth = calendar.component(.month, from: nextMonth)
                let newYear = calendar.component(.year, from: nextMonth)
                
                currentMonth = newMonth
                currentYear = newYear
                currentWeekOffset = 0 // 월이 바뀌면 현재 주로 리셋
                selectedWeek = 0 // 주간 선택도 첫 번째 주로 리셋
                setupWeekDates()
                
                print("📅 다음 달로 이동: \(currentYear)년 \(currentMonth)월")
            }
        }
    }
}

#Preview {
    ReportView()
}

