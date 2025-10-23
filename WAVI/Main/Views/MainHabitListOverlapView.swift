//
//  MainHabitListOverlapView.swift
//  WAVI
//
//  Created by 박현빈 on 10/12/25.
//

import SwiftUI

struct MainHabitListOverlapView: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var currentCenterIndex: Int
    @State private var scrollOffset: CGFloat = 0
    @State private var cardDragOffsets: [Int: CGFloat] = [:] // 각 카드별 드래그 오프셋
    @State private var isProcessingSwipe = false // 중복 스와이프 방지
    @State private var showFailureReasons = false
    @State private var selectedFailureReasons: Set<FailureReason> = []
    @State private var customFailureReason = ""
    @State private var currentFailureHabitId: Int?
    
    // 애니메이션 상태들
    @State private var cardAnimationStates: [Int: CardAnimationState] = [:]
    
    struct CardAnimationState {
        var isShowingSuccessAnimation = false
        var isShowingFailureAnimation = false
        var successPercentage = ""
        var failurePercentage = ""
    }
    
    // HabitLogService
    private let habitLogService: HabitLogServicing = BackendHabitLogService()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("오류 발생: \(errorMessage)")
                        .foregroundColor(.red)
                    Button("다시 시도") {
                        Task {
                            await viewModel.loadMainData()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else if viewModel.habits.isEmpty {
                VStack {
                    Text("오늘의 습관이 없습니다")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                // ZStack을 사용한 겹치는 카드 스크롤 뷰
                GeometryReader { geometry in
                    let cardHeight: CGFloat = 122
                    let cardWidth: CGFloat = 351
                    let overlapAmount: CGFloat = cardHeight * 0.5
                    let spacing: CGFloat = cardHeight - overlapAmount
                    
                    ZStack(alignment: .top) {
                        ForEach(Array(viewModel.habits.enumerated()), id: \.offset) { index, habit in
                            let distance = abs(index - currentCenterIndex)
                            
                            if distance <= 2 {
                                let scale = 1.0 - (CGFloat(distance) * 0.15)
                                
                                let rotationAngle: Double = {
                                    if index == currentCenterIndex {
                                        return 0.0
                                    } else {
                                        return -5.0 * Double(distance)
                                    }
                                }()
                                
                                MainHabitCardView(
                                    habit: habit,
                                    cardColor: habit.cardColor,
                                    dragOffset: Binding(
                                        get: { cardDragOffsets[habit.id] ?? 0 },
                                        set: { cardDragOffsets[habit.id] = $0 }
                                    ),
                                    isShowingSuccessAnimation: Binding(
                                        get: { cardAnimationStates[habit.id]?.isShowingSuccessAnimation ?? false },
                                        set: { 
                                            if cardAnimationStates[habit.id] == nil {
                                                cardAnimationStates[habit.id] = CardAnimationState()
                                            }
                                            cardAnimationStates[habit.id]?.isShowingSuccessAnimation = $0
                                        }
                                    ),
                                    isShowingFailureAnimation: Binding(
                                        get: { cardAnimationStates[habit.id]?.isShowingFailureAnimation ?? false },
                                        set: { 
                                            if cardAnimationStates[habit.id] == nil {
                                                cardAnimationStates[habit.id] = CardAnimationState()
                                            }
                                            cardAnimationStates[habit.id]?.isShowingFailureAnimation = $0
                                        }
                                    ),
                                    successPercentage: Binding(
                                        get: { cardAnimationStates[habit.id]?.successPercentage ?? "" },
                                        set: { 
                                            if cardAnimationStates[habit.id] == nil {
                                                cardAnimationStates[habit.id] = CardAnimationState()
                                            }
                                            cardAnimationStates[habit.id]?.successPercentage = $0
                                        }
                                    ),
                                    failurePercentage: Binding(
                                        get: { cardAnimationStates[habit.id]?.failurePercentage ?? "" },
                                        set: { 
                                            if cardAnimationStates[habit.id] == nil {
                                                cardAnimationStates[habit.id] = CardAnimationState()
                                            }
                                            cardAnimationStates[habit.id]?.failurePercentage = $0
                                        }
                                    ),
                                    onSuccess: { habitId in
                                        Task {
                                            await handleSuccess(habitId: habitId)
                                        }
                                    },
                                    onFailure: { habitId in
                                        Task {
                                            await handleFailure(habitId: habitId)
                                        }
                                    }
                                )
                                .scaleEffect(scale)
                                .rotationEffect(.degrees(rotationAngle))
                                .offset(y: CGFloat(index) * spacing + scrollOffset)
                                .zIndex(calculateZIndex(for: index))
                            }
                        }
                    }
                    .frame(width: cardWidth, height: geometry.size.height)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .gesture(
                        // 수직 드래그 - 카드 스크롤
                        DragGesture()
                            .onChanged { value in
                                // 수직 드래그만 처리 (수평 드래그는 별도 제스처에서 처리)
                                let horizontalMovement = abs(value.translation.width)
                                let verticalMovement = abs(value.translation.height)
                                
                                if verticalMovement > horizontalMovement {
                                    scrollOffset = value.translation.height
                                    updateCenterIndex(spacing: spacing)
                                }
                            }
                            .onEnded { value in
                                let horizontalMovement = abs(value.translation.width)
                                let verticalMovement = abs(value.translation.height)
                                
                                if verticalMovement > horizontalMovement {
                                    let cardSpacing = spacing
                                    let velocity = value.predictedEndTranslation.height - value.translation.height
                                    
                                    let currentOffset = scrollOffset
                                    let targetIndex = round(-currentOffset / cardSpacing)
                                    let clampedIndex = max(0, min(CGFloat(viewModel.habits.count - 1), targetIndex))
                                    
                                    var finalIndex = clampedIndex
                                    if abs(velocity) > 100 {
                                        if velocity < 0 {
                                            finalIndex = min(CGFloat(viewModel.habits.count - 1), clampedIndex + 1)
                                        } else {
                                            finalIndex = max(0, clampedIndex - 1)
                                        }
                                    }
                                    
                                    let targetOffset = -finalIndex * cardSpacing
                                    
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        scrollOffset = targetOffset
                                        currentCenterIndex = Int(finalIndex)
                                    }
                                }
                            }
                    )
                    .simultaneousGesture(
                        // 수평 드래그 - 성공/실패 기록 (현재 중앙 카드만)
                        DragGesture()
                            .onChanged { value in
                                // 이미 처리 중인 스와이프가 있으면 무시
                                guard !isProcessingSwipe else { return }
                                
                                let horizontalMovement = abs(value.translation.width)
                                let verticalMovement = abs(value.translation.height)
                                
                                // 수평 움직임이 수직 움직임보다 2배 이상 클 때만 처리 (더 엄격한 조건)
                                if horizontalMovement > verticalMovement * 2 && horizontalMovement > 20 {
                                    // 현재 중앙에 있는 카드의 드래그 오프셋만 업데이트
                                    if currentCenterIndex < viewModel.habits.count {
                                        let currentHabit = viewModel.habits[currentCenterIndex]
                                        cardDragOffsets[currentHabit.id] = value.translation.width
                                    }
                                }
                            }
                            .onEnded { value in
                                // 이미 처리 중인 스와이프가 있으면 무시
                                guard !isProcessingSwipe else { return }
                                
                                let horizontalMovement = abs(value.translation.width)
                                let verticalMovement = abs(value.translation.height)
                                let threshold: CGFloat = 80 // 임계값을 낮춤
                                
                                // 수평 움직임이 수직 움직임보다 2배 이상 크고, 임계값을 넘을 때만 처리
                                if horizontalMovement > verticalMovement * 2 && horizontalMovement > threshold {
                                    // 현재 중앙에 있는 카드만 처리
                                    if currentCenterIndex < viewModel.habits.count {
                                        let currentHabit = viewModel.habits[currentCenterIndex]
                                        
                                        // 처리 중 플래그 설정
                                        isProcessingSwipe = true
                                        
                                        if value.translation.width > 0 {
                                            // 오른쪽 스와이프 - 성공
                                            print("🎯 오른쪽 스와이프 감지 - habitId: \(currentHabit.id)")
                                            Task {
                                                await handleSuccess(habitId: currentHabit.id)
                                                await MainActor.run {
                                                    isProcessingSwipe = false
                                                }
                                            }
                                        } else {
                                            // 왼쪽 스와이프 - 실패
                                            print("🎯 왼쪽 스와이프 감지 - habitId: \(currentHabit.id)")
                                            Task {
                                                await handleFailure(habitId: currentHabit.id)
                                                await MainActor.run {
                                                    isProcessingSwipe = false
                                                }
                                            }
                                        }
                                        
                                        // 드래그 오프셋 리셋
                                        withAnimation(.spring()) {
                                            cardDragOffsets[currentHabit.id] = 0
                                        }
                                    }
                                } else {
                                    // 조건에 맞지 않으면 모든 카드의 드래그 오프셋 리셋
                                    for habit in viewModel.habits {
                                        withAnimation(.spring()) {
                                            cardDragOffsets[habit.id] = 0
                                        }
                                    }
                                }
                            }
                    )
        }
        .frame(height: 350)
            }
        }
        .sheet(isPresented: $showFailureReasons) {
            FailureReasonSelectionView(
                selectedReasons: $selectedFailureReasons,
                customReason: $customFailureReason,
                onSubmit: {
                    submitFailureReasons()
                }
            )
        }
    }
    
    private func calculateZIndex(for index: Int) -> Double {
        let distance = abs(index - currentCenterIndex)
        return Double(viewModel.habits.count * 2) - Double(distance)
    }
    
    private func updateCenterIndex(spacing: CGFloat) {
        let currentOffset = scrollOffset
        let calculatedIndex = round(-currentOffset / spacing)
        let clampedIndex = max(0, min(viewModel.habits.count - 1, Int(calculatedIndex)))
        
        if clampedIndex != currentCenterIndex {
            currentCenterIndex = clampedIndex
        }
    }
    
    // MARK: - Habit Log Handlers
    private func handleSuccess(habitId: Int) async {
        print("🎯 성공 애니메이션 시작 - habitId: \(habitId)")
        
        // 1. 즉시 로컬 상태를 COMPLETED로 변경 (임시 UI 업데이트)
        await MainActor.run {
            viewModel.markHabitAsCompleted(habitId: habitId)
        }
        
        // 2. 성공 애니메이션 시작
        await MainActor.run {
            if cardAnimationStates[habitId] == nil {
                cardAnimationStates[habitId] = CardAnimationState()
            }
            cardAnimationStates[habitId]?.isShowingSuccessAnimation = true
            cardAnimationStates[habitId]?.successPercentage = "100%"
        }
        
        // 3. API 호출 후 서버 데이터로 동기화
        do {
            try await habitLogService.logSuccess(habitId: habitId)
            print("✅ 습관 성공 기록 완료 - habitId: \(habitId)")
            
            // API 호출 성공 시 로컬 상태 유지 (서버 데이터 새로고침 안함)
            print("✅ 로컬 상태 유지 - COMPLETED 상태 보존")
        } catch {
            print("❌ 습관 성공 기록 실패 - habitId: \(habitId), error: \(error)")
            
            // API 호출 실패 시에만 서버 데이터로 복원
            await viewModel.loadMainData()
        }
        
        // 4. 5초 후 애니메이션 완료
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            Task {
                await MainActor.run {
                    cardAnimationStates[habitId]?.isShowingSuccessAnimation = false
                }
            }
        }
    }
    
    private func handleFailure(habitId: Int) async {
        print("🎯 실패 애니메이션 시작 - habitId: \(habitId)")
        
        // 실패 애니메이션 시작
        await MainActor.run {
            if cardAnimationStates[habitId] == nil {
                cardAnimationStates[habitId] = CardAnimationState()
            }
            cardAnimationStates[habitId]?.isShowingFailureAnimation = true
            cardAnimationStates[habitId]?.failurePercentage = "0%"
        }
        
        // 2초 후 실패 이유 선택 팝업 표시 (애니메이션은 유지)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            Task {
                await MainActor.run {
                    // 애니메이션은 끄지 않고 팝업만 표시
                    currentFailureHabitId = habitId
                    selectedFailureReasons = []
                    customFailureReason = ""
                    showFailureReasons = true
                }
            }
        }
    }
    
    private func submitFailureReasons() {
        guard let habitId = currentFailureHabitId else { return }
        
        Task {
            // 1. 즉시 로컬 상태를 DEACTIVE로 변경 (임시 UI 업데이트)
            await MainActor.run {
                viewModel.markHabitAsDeactive(habitId: habitId)
            }
            
            // 2. API 호출 후 서버 데이터로 동기화
            do {
                try await habitLogService.logFailure(
                    habitId: habitId,
                    failureReasonIds: Array(selectedFailureReasons.map { $0.rawValue }),
                    customReason: customFailureReason.isEmpty ? nil : customFailureReason
                )
                print("✅ 습관 실패 기록 완료 - habitId: \(habitId)")
                
                // API 호출 성공 시 로컬 상태 유지 (서버 데이터 새로고침 안함)
                print("✅ 로컬 상태 유지 - DEACTIVE 상태 보존")
            } catch {
                print("❌ 습관 실패 기록 실패 - habitId: \(habitId), error: \(error)")
                
                // API 호출 실패 시에만 서버 데이터로 복원
                await viewModel.loadMainData()
            }
            
            // 3. UI 상태 정리
            await MainActor.run {
                cardAnimationStates[habitId]?.isShowingFailureAnimation = false
                showFailureReasons = false
                currentFailureHabitId = nil
            }
        }
    }
}

#Preview {
    @State var currentCenterIndex: Int = 0
    return MainHabitListOverlapView(
        viewModel: MainViewModel(),
        currentCenterIndex: $currentCenterIndex
    )
    .previewLayout(.sizeThatFits)
    .padding()
}

