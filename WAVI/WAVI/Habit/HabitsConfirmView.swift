//
//  HabitsConfirmView.swift
//  WAVI
//
//  Created by 박현빈 on 10/13/25.
//

import SwiftUI
import Combine

struct HabitsConfirmView: View {
    // HabitDataStore를 통한 데이터 접근
    @ObservedObject var habitDataStore: HabitDataStore
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

    var title: String = "추가하기"
    var action: () -> Void = {}
    
    // 초기화
    init(habitDataStore: HabitDataStore) {
        self.habitDataStore = habitDataStore
        
        _habitName = State(initialValue: habitDataStore.habitData?.name ?? "")
        _selectedDays = State(initialValue: Set(habitDataStore.habitData?.dayOfWeek.map { $0 } ?? []))
        
        let start = habitDataStore.habitData?.startTime ?? ""
        let end = habitDataStore.habitData?.endTime ?? ""
        let formattedTime = start.isEmpty || end.isEmpty ? "" : "\(Self.formatTime(start)) - \(Self.formatTime(end))"
        _selectedTime = State(initialValue: formattedTime)
        
        let startTime = start.isEmpty ? "09:00" : Self.formatTime(start)
        let endTime = end.isEmpty ? "10:00" : Self.formatTime(end)
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
        .onAppear { setupHabitData() }
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
            Text("습관 추가하기")
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
                .overlay(Text(habitDataStore.habitData?.icon ?? "⭐").font(.system(size: 25)).foregroundColor(.white))
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
            icon: habitDataStore.habitData?.icon ?? "⭐", // 백엔드에서 받아온 아이콘 사용
            startTime: startTime,
            endTime: endTime
        )
        
        print("🔍 습관 추가 요청 데이터:")
        print("🔍 name: \(habitName)")
        print("🔍 dayOfWeek: \(dayOfWeek)")
        print("🔍 icon: \(habitDataStore.habitData?.icon ?? "⭐")")
        print("🔍 startTime: \(startTime)")
        print("🔍 endTime: \(endTime)")
        
        // API 호출
        habitService.createHabit(habitRequest)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    switch completion {
                    case .failure(let error):
                        showAlert(message: "습관 추가 실패: \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                },
                receiveValue: { response in
                    if response.status == 200 {
                        showAlert(message: response.message ?? "습관이 성공적으로 추가되었습니다!")
                        // 성공 시 필요한 후속 작업 (예: 화면 닫기, 데이터 새로고침 등)
                        action()
                    } else if response.status == 403 {
                        showAlert(message: "인증이 만료되었습니다. 다시 로그인해주세요.")
                    } else {
                        showAlert(message: response.message ?? response.error ?? "습관 추가에 실패했습니다.")
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func setupHabitData() {
        print("🔍 HabitsConfirmView setupHabitData 호출됨")
        print("🔍 habitDataStore.habitData: \(habitDataStore.habitData)")
        
        guard let data = habitDataStore.habitData else {
            print("❌ habitDataStore.habitData가 nil입니다")
            return
        }
        
        print("✅ habitDataStore.habitData 존재: \(data)")
        
        // 습관 이름 설정
        habitName = data.name
        print("✅ habitName 설정: \(habitName)")
        
        // 요일 설정 (1-7을 0-6으로 변환)
        selectedDays = Set(data.dayOfWeek.map { $0 - 1 })
        print("✅ selectedDays 설정: \(selectedDays)")
        
        // 시간 설정
        let startTime = Self.formatTime(data.startTime)
        let endTime = Self.formatTime(data.endTime)
        selectedTime = "\(startTime) - \(endTime)"
        print("✅ selectedTime 설정: \(selectedTime)")
        
        // 시간에 맞는 원형 차트 각도와 길이 설정
        timeAngle = Self.calculateAngleFromTime(startTime)
        timeDuration = Self.calculateDurationFromTimes(startTime, endTime)
        print("✅ timeAngle 설정: \(timeAngle)")
        print("✅ timeDuration 설정: \(timeDuration)")
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
    HabitsConfirmView(habitDataStore: HabitDataStore())
}
