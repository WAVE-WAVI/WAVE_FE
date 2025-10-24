//
//  HabitsConfirmView.swift
//  WAVI
//
//  Created by 박현빈 on 10/13/25.
//

import SwiftUI
import Combine

struct HabitModifyView: View {
    // 수정할 습관 데이터
    let habit: Habit
    @Environment(\.dismiss) var dismiss
    
    @State private var habitName: String = ""
    @State private var selectedDays: Set<Int> = []
    @State private var selectedTime: String = ""
    @State private var isTimePickerVisible: Bool = false
    @State private var timeAngle: Double = 90
    @State private var timeDuration: Double = 0.02
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var cancellables = Set<AnyCancellable>()
    
    // API 서비스
    private let habitService = NewHabitService()
    private let weekDays = ["월", "화", "수", "목", "금", "토", "일"]

    var title: String = "저장하기"
    var action: () -> Void = {}
    
    // 초기화
    init(habit: Habit) {
        self.habit = habit
        
        _habitName = State(initialValue: habit.name)
        // 서버 형식(1-7)을 UI 형식(0-6)으로 변환
        _selectedDays = State(initialValue: Set(habit.dayOfWeek.map { $0 - 1 }))
        
        let formattedTime = "\(Self.formatTime(habit.startTime)) - \(Self.formatTime(habit.endTime))"
        _selectedTime = State(initialValue: formattedTime)
        
        let startTime = Self.formatTime(habit.startTime)
        let endTime = Self.formatTime(habit.endTime)
        let calculatedAngle = Self.calculateAngleFromTime(startTime)
        let calculatedDuration = Self.calculateDurationFromTimes(startTime, endTime)
        _timeAngle = State(initialValue: calculatedAngle)
        _timeDuration = State(initialValue: calculatedDuration)
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                Color(hex: "#EAEAEA")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    Spacer()
                    mainContentCard
                    Spacer()
                    bottomActionButtons
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("알림", isPresented: $showAlert) {
            Button("확인") {}
        } message: { Text(alertMessage) }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack() {
            Button(action: {
                print("뒤로가기")
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.black)
            }
            Text("습관 목록")
                .font(.system(size: 36, weight: .bold))
                .lineSpacing(4)
                .foregroundColor(.primaryBlack)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Main Content Card
    private var mainContentCard: some View {
        VStack(spacing: 24) {
            habitNameSection
            Divider()
            executionDaysSection
            Divider()
            executionTimeSection
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .frame(maxWidth: 360, minHeight: 550)
    }

    // MARK: - Habit Name Section
    private var habitNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Circle()
                .fill(Color(red: 87/255, green: 102/255, blue: 0/255))
                .frame(width: 40, height: 40)
                .overlay(Text(habit.icon).font(.system(size: 25)).foregroundColor(.white))
            Text("습관 이름")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.baseBlack)

            HStack {
                TextField("습관 이름을 입력하세요", text: $habitName)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 87/255, green: 102/255, blue: 0/255))
                    .textFieldStyle(PlainTextFieldStyle())

                if !habitName.isEmpty {
                    Button(action: { habitName = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
            }
            .frame(width: 220)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 50).fill(Color.black.opacity(0.1)))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Execution Days Section
    private var executionDaysSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("실행 요일")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.baseBlack)
            
            Text("아래 날짜 블록을 클릭하며 수정하세요")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            HStack(spacing: 18) {
                ForEach(0..<weekDays.count, id: \.self) { index in
                    VStack(spacing: 8) {
                        Text(weekDays[index])
                            .font(.system(size: 12))
                             .foregroundColor(selectedDays.contains(index) ? Color(red: 87/255, green: 102/255, blue: 0/255) : .gray)
                        Button {
                            if selectedDays.contains(index) {
                                selectedDays.remove(index)
                            } else {
                                selectedDays.insert(index)
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 20)
                                 .fill(selectedDays.contains(index) ? Color(red: 87/255, green: 102/255, blue: 0/255) : Color.gray.opacity(0.3))
                                .frame(width: 30, height: 40)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Execution Time Section (수정된 부분)
    private var executionTimeSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("실행 시간")
                .font(.system(size: 14))
                .foregroundColor(.baseBlack)

            Text("아래 시간표를 돌리며 수정하세요")
                .font(.system(size: 12))
                .foregroundColor(.gray)

            VStack(spacing: 8) {
                Text("선택 시간")
                    .font(.system(size: 14))
                Text(selectedTime)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 87/255, green: 102/255, blue: 0/255))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 80)
            .background(timeCircleView)
        }
    }

     // MARK: - 분리된 Circle View 구성
     private var timeCircleView: some View {
         ZStack {
             baseCircle
             activeTimeCircle
         }
         .frame(width: 180, height: 180)
     }

     private var baseCircle: some View {
         Circle()
             .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 20, lineCap: .round))
     }

     private var activeTimeCircle: some View {
         Circle()
             .trim(from: 0, to: timeDuration)
             .stroke(Color(red: 87/255, green: 102/255, blue: 0/255), style: StrokeStyle(lineWidth: 40))
             .rotationEffect(.degrees(timeAngle - 90))
             .gesture(timeDragGesture)
     }

     // MARK: - 제스처 분리
     private var timeDragGesture: some Gesture {
         DragGesture().onChanged { value in
             let center = CGPoint(x: 90, y: 90)
             let angle = atan2(value.location.y - center.y, value.location.x - center.x)
             let degrees = angle * 180 / .pi
             let adjustedAngle = (degrees + 90 + 360).truncatingRemainder(dividingBy: 360)

             timeAngle = adjustedAngle
             updateTimeFromAngle(timeAngle)
         }
     }

    // MARK: - Bottom Action Buttons
    private var bottomActionButtons: some View {
        HStack {
            Spacer()
            Button(action: { createHabit() }) {
                HStack {
                    if isLoading { ProgressView().scaleEffect(0.8) }
                    Text(isLoading ? "추가 중..." : title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .cornerRadius(40)
            }
            .disabled(isLoading)
        }
    }

    // MARK: - Helper Functions
    private func updateTimeFromAngle(_ angle: Double) {
        // 각도를 0-360도 범위로 정규화
        let normalizedAngle = (angle.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        
        // 24시간을 360도로 나누어 시간 계산
        let totalMinutes = normalizedAngle * (24.0 * 60.0) / 360.0
        let hour = Int(totalMinutes / 60)
        let minute = Int(totalMinutes.truncatingRemainder(dividingBy: 60))
        
        // 시간 포맷팅
        let formattedHour = String(format: "%02d", hour)
        let formattedMinute = String(format: "%02d", minute)
        
        // 시작 시간 설정
        let startTime = "\(formattedHour):\(formattedMinute)"
        
        // 현재 시간 길이를 유지하면서 종료 시간 계산
        let durationMinutes = Int(timeDuration * 24 * 60)
        let startTotalMinutes = hour * 60 + minute
        let endTotalMinutes = (startTotalMinutes + durationMinutes) % (24 * 60)
        
        let endHour = endTotalMinutes / 60
        let endMinute = endTotalMinutes % 60
        
        let formattedEndHour = String(format: "%02d", endHour)
        let formattedEndMinute = String(format: "%02d", endMinute)
        
        let endTime = "\(formattedEndHour):\(formattedEndMinute)"
        
        selectedTime = "\(startTime) - \(endTime)"
    }
    
    // MARK: - API Methods
    private func createHabit() {
        guard !habitName.isEmpty else {
            showAlert(message: "습관 이름을 입력해주세요.")
            return
        }
        
        guard !selectedDays.isEmpty else {
            showAlert(message: "최소 하나의 요일을 선택해주세요.")
            return
        }
        
        guard !selectedTime.isEmpty else {
            showAlert(message: "실행 시간을 설정해주세요.")
            return
        }
        
        isLoading = true
        
        // 시간 문자열을 분리
        let timeComponents = selectedTime.components(separatedBy: " - ")
        guard timeComponents.count == 2 else {
            showAlert(message: "시간 형식이 올바르지 않습니다.")
            isLoading = false
            return
        }
        
        let startTime = timeComponents[0]
        let endTime = timeComponents[1]
        
        // API 요청 데이터 생성 (서버 형식: 1=월, 2=화, 3=수, 4=목, 5=금, 6=토, 7=일)
        let dayOfWeek = Array(selectedDays).map { $0 + 1 }.sorted() // 0-6을 1-7로 변환
        let habitRequest = HabitRequest(
            name: habitName,
            dayOfWeek: dayOfWeek,
            icon: habit.icon, // 기존 아이콘 유지
            startTime: startTime,
            endTime: endTime
        )
        
         print("🔍 습관 수정 요청 데이터:")
         print("🔍 name: \(habitName)")
         print("🔍 dayOfWeek: \(dayOfWeek)")
         print("🔍 icon: \(habit.icon)")
         print("🔍 startTime: \(startTime)")
         print("🔍 endTime: \(endTime)")
         
         // 실제 습관 수정 API 호출
         print("🚀 습관 수정 API 호출 시작")
         habitService.updateHabit(id: String(habit.id), request: habitRequest)
             .receive(on: DispatchQueue.main)
             .sink(
                 receiveCompletion: { completion in
                     isLoading = false
                     switch completion {
                     case .failure(let error):
                         print("❌ 습관 수정 실패: \(error)")
                         showAlert(message: "습관 수정에 실패했습니다: \(error.localizedDescription)")
                     case .finished:
                         print("✅ 습관 수정 API 호출 완료")
                         break
                     }
                 },
                 receiveValue: { response in
                     print("✅ 습관 수정 성공: \(response)")
                     if response.status == 200 {
                         showAlert(message: "습관이 성공적으로 수정되었습니다!")
                         
                         // 성공 후 메인 화면으로 돌아가기
                         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                             dismiss()
                         }
                     } else {
                         showAlert(message: response.message ?? "습관 수정에 실패했습니다.")
                     }
                 }
             )
             .store(in: &cancellables)
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    
    private static func formatTime(_ timeString: String) -> String {
        // "05:00:00" -> "05:00" 형식으로 변환
        let components = timeString.components(separatedBy: ":")
        if components.count >= 2 {
            return "\(components[0]):\(components[1])"
        }
        return timeString
    }
    
    private static func calculateAngleFromTime(_ timeString: String) -> Double {
        // "09:00" -> 각도로 변환
        let components = timeString.components(separatedBy: ":")
        guard components.count >= 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return 90 // 기본값 (12시 방향)
        }
        
        // 24시간을 360도로 매핑 (시계방향)
        // 00:00 = 270도 (12시), 06:00 = 0도 (3시), 12:00 = 90도 (6시), 18:00 = 180도 (9시)
        let totalMinutes = hour * 60 + minute
        let angle = Double(totalMinutes) * 360.0 / (24.0 * 60.0) // 24시간 = 360도
        
        // 12시 방향(270도)부터 시계방향으로 시작하되, 90도 오프셋 추가
        let adjustedAngle = (angle + 270.0 + 90.0).truncatingRemainder(dividingBy: 360.0)
        
        return adjustedAngle
    }
    
    private static func calculateDurationFromTimes(_ startTime: String, _ endTime: String) -> Double {
        // 시간 차이를 24시간 기준 비율로 계산
        let startComponents = startTime.components(separatedBy: ":")
        let endComponents = endTime.components(separatedBy: ":")
        
        guard startComponents.count >= 2, endComponents.count >= 2,
              let startHour = Int(startComponents[0]),
              let startMinute = Int(startComponents[1]),
              let endHour = Int(endComponents[0]),
              let endMinute = Int(endComponents[1]) else {
            return 0.02 // 기본값 (30분)
        }
        
        let startTotalMinutes = startHour * 60 + startMinute
        let endTotalMinutes = endHour * 60 + endMinute
        
        // 시간 차이 계산 (하루를 넘어가는 경우 고려)
        var durationMinutes = endTotalMinutes - startTotalMinutes
        if durationMinutes < 0 {
            durationMinutes += 24 * 60 // 다음날로 넘어가는 경우
        }
        
        // 24시간을 1.0으로 하는 비율 계산
        let duration = Double(durationMinutes) / (24.0 * 60.0)
        
        return duration
    }
}

#Preview {
    let sampleHabit = Habit(
        id: 1,
        name: "따뜻한 물 1L 마시기",
        status: "ACTIVE",
        dayOfWeek: [1, 3, 5],
        icon: "💧",
        startTime: "09:30:00",
        endTime: "10:00:00"
    )
    
    return HabitModifyView(habit: sampleHabit)
}
