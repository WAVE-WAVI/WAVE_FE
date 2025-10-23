//
//  AddingHabitsMainView.swift
//  WAVI
//
//  Created by 박현빈 on 10/13/25.
//

//
//  AddingHabitsMainView.swift
//  WAVI
//
//  Created by 채서영 on 10/2/25.
//

import SwiftUI
import Combine


struct AddingHabitsMainView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var habitText: String = ""
    @State private var isKeyboardVisible: Bool = true
    @State private var sentMessages: [String] = []
    @State private var chatHistory: [String] = []
    @State private var isLoading: Bool = false
    @State private var loadingDotsAnimation: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    // HabitsConfirmView로 이동을 위한 상태
    @State private var showHabitsConfirm: Bool = false
    @State private var habitData: ChatAnalysisData? = nil
    @State private var showLoadingScreen: Bool = false
    @State private var passedHabitData: ChatAnalysisData? = nil
    @StateObject private var habitDataStore = HabitDataStore()
    
    // API 서비스
    private let habitService = NewHabitService()
    
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
                    
                    // 채팅과 헤더 사이 간격
                    Spacer()
                        .frame(height: 14)
                    
                    // WAVI 채팅 메시지 (항상 표시)
                    waviChatView
                        .padding(.horizontal, 20)
                    
                    // 채팅 메시지들 (사용자와 AI 대화)
                    if !chatHistory.isEmpty {
                        userChatViews
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                    }
                    
                    Spacer()
                    
                    // 안내 카드들 (입력창 바로 위)
                    if chatHistory.isEmpty {
                        guideCardsView
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                    }
                    
                    // 텍스트 입력 영역
                    inputAreaView
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            isTextFieldFocused = true
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인") { }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $showLoadingScreen) {
            loadingView
        }
        .fullScreenCover(isPresented: $showHabitsConfirm) {
            HabitsConfirmView(habitDataStore: habitDataStore)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack() {
            Button(action: {
                print("메인 뷰로 돌아가기")
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
    
    // MARK: - WAVI Chat View
    private var waviChatView: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // WAVI 프로필 아이콘
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text("🐋")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                )
            
            // WAVI 말풍선 (원형)
            Text("어떤 새로운 습관을 기르고 싶나요?")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.baseBlack)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            
            Spacer()
        }
    }
    
    // MARK: - Guide Cards View
    private var guideCardsView: some View {
        HStack(spacing: 12) {
            // 왼쪽 카드
            VStack(alignment: .leading, spacing: 4) {
                Text("새로운 습관을 마음껏 추가해요")
                    .typography(Typography.Body2)
                    .foregroundColor(.baseBlack)
                
                Text("시작은 간단하게!")
                    .typography(Typography.Chip)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            
            // 오른쪽 카드
            VStack(alignment: .leading, spacing: 4) {
                Text("아래 예시를 참고하세요")
                    .typography(Typography.Body2)
                    .foregroundColor(.baseBlack)
                
                Text("ex) \"매일 물 한 잔을 마시고 싶어.\"")
                    .typography(Typography.Chip)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    // MARK: - User Chat Views
    private var userChatViews: some View {
        VStack(spacing: 16) {
            ForEach(Array(chatHistory.enumerated()), id: \.offset) { index, message in
                let isUser = message.hasPrefix("User:")
                let messageText = isUser ? String(message.dropFirst(6)) : String(message.dropFirst(4))
                
                if isUser {
                    // 사용자 메시지 (오른쪽 정렬)
                    HStack(alignment: .bottom, spacing: 12) {
                        Spacer()
                        
                        Text(messageText)
                            .typography(Typography.Body1)
                            .foregroundColor(.baseBlack)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                    }
                    .padding(.trailing, 20) // 사용자 메시지 오른쪽 여백 추가
                    .transition(.opacity.combined(with: .scale))
                } else {
                    // AI 메시지 (왼쪽 정렬)
                    HStack(alignment: .bottom, spacing: 12) {
                        // WAVI 프로필 아이콘
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("🐋")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        Text(messageText)
                            .typography(Typography.Body1)
                            .foregroundColor(.baseBlack)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.gray.opacity(0.3))
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                        
                        Spacer()
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
            
            // 로딩 중일 때 AI 응답 대기 표시
            if isLoading {
                HStack(alignment: .bottom, spacing: 12) {
                    // WAVI 프로필 아이콘
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("🐋")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    // 점 3개 애니메이션
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.gray.opacity(0.6))
                                .frame(width: 6, height: 6)
                                .scaleEffect(loadingDotsAnimation ? 1.0 : 0.5)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: loadingDotsAnimation
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.gray.opacity(0.3))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    
                    Spacer()
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
    
    // MARK: - Input Area View
    private var inputAreaView: some View {
        HStack(spacing: 12) {
            // 되돌리기 버튼
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text("🧔🏼‍♂️")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                )
            
            // 텍스트 입력 필드 (고정 크기)
            HStack(spacing: 10) {
                TextField(habitText.isEmpty ? "습관 입력" : "", text: $habitText)
                    .typography(Typography.Body1)
                    .foregroundColor(.baseBlack)
                    .focused($isTextFieldFocused)
                
                if !habitText.isEmpty {
                    Button(action: {
                        habitText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(width: 240, height: 30)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.gray.opacity(0.3))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            
            // 전송 버튼
            Button(action: {
                // 전송 액션
                if !habitText.isEmpty {
                    sendMessage()
                }
            }) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(habitText.isEmpty ? .black : .white)
                    .frame(width: 30, height: 30)
                    .background(
                        habitText.isEmpty ? 
                        AnyView(
                            Circle()
                                .stroke(Color.black, style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                        ) :
                        AnyView(
                            Circle()
                                .fill(Color.baseBlack)
                        )
                    )
            }
            .disabled(habitText.isEmpty)
            
            // 오른쪽 여백 (전송 버튼이 잘리지 않도록)
            Spacer()
                .frame(width: 20)
            
        }
        
    }
    
    // MARK: - API Methods
    private func sendMessage() {
        let userMessage = habitText
        sentMessages.append(userMessage)
        chatHistory.append("User: \(userMessage)")
        
        isLoading = true
        loadingDotsAnimation = true
        
        // API 요청 데이터 생성9tl
        let request = ChatAnalysisRequest(
            currentPrompt: userMessage,
            history: chatHistory
        )
        
        // API 호출
        print(1)
        habitService.analyzeUserMessage(request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    loadingDotsAnimation = false
                    switch completion {
                    case .failure(let error):
                        showAlert(message: "메시지 분석 실패: \(error.localizedDescription)")
                        print(2)
                    case .finished:
                        break
                    }
                },
                receiveValue: { response in
                    print(3)
                    handleChatResponse(response)
                    print(4)
                }
            )
            .store(in: &cancellables)
        print(5)
        habitText = ""
    }
    
    private func handleChatResponse(_ response: ChatAnalysisResponse) {
        if response.status == 200 {
            if let data = response.habitData {
                print("🔍 습관 데이터 받음: \(data)")
                // 습관 데이터 저장
                habitData = data
                print("🔍 habitData 저장됨: \(String(describing: habitData))")
                // 로딩 화면 표시
                showLoadingScreen = true
                
                // 3초 후 HabitsConfirmView로 이동
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    showLoadingScreen = false
                    habitDataStore.setHabitData(data) // HabitDataStore에 데이터 저장
                    showHabitsConfirm = true
                    print("🔍 HabitsConfirmView 표시됨, habitDataStore: \(habitDataStore.habitData)")
                }
            } else {
                showAlert(message: "습관 데이터가 비어 있어요.")
            }
        } else if response.status == 400 {
            // 400 상태일 때 data 필드의 메시지를 채팅으로 표시
            if let dataMessage = response.dataMessage {
                // data 필드의 메시지를 AI 응답으로 추가
                chatHistory.append("AI: \(dataMessage)")
                // 알림은 보여주지 않음 (채팅에서 처리)
            } else if let message = response.message {
                // data가 없으면 message 사용
                chatHistory.append("AI: \(message)")
            } else {
                chatHistory.append("AI: 추가 정보가 필요해요.")
            }
        } else {
            showAlert(message: response.message ?? "알 수 없는 오류가 발생했어요.")
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        ZStack {
            // 배경 (이미지로 대체)
            Image("loading_screen")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        }
    }
    
    // Combine cancellables
    @State private var cancellables = Set<AnyCancellable>()
}

struct AddingHabitsMainView_Previews: PreviewProvider {
    static var previews: some View {
        AddingHabitsMainView()
    }
}
