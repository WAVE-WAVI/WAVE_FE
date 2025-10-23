//
//  FailureReasonSelectionView.swift
//  WAVI
//
//  Created by 박현빈 on 10/12/25.
//

import SwiftUI

struct FailureReasonSelectionView: View {
    @Binding var selectedReasons: Set<FailureReason>
    @Binding var customReason: String
    let onSubmit: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Text("왜 해당 습관을 달성하지 못하였나요?")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Failure Reason Selection Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                    ForEach(FailureReason.allCases, id: \.self) { reason in
                        FailureReasonButton(
                            reason: reason,
                            isSelected: selectedReasons.contains(reason)
                        ) {
                            if selectedReasons.contains(reason) {
                                selectedReasons.remove(reason)
                            } else {
                                selectedReasons.insert(reason)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Custom Reason Input (only show if "기타" is selected)
                if selectedReasons.contains(.other) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("직접 입력:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                        
                        TextField("실패 이유를 입력하세요", text: $customReason)
                            .font(.system(size: 14))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            Spacer()
            
            // Submit Button
            Button(action: {
                onSubmit()
            }) {
                Text("제출하기")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedReasons.isEmpty ? Color.gray : Color.black)
                    )
            }
            .disabled(selectedReasons.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .presentationDetents([.medium])
    }
}

struct FailureReasonButton: View {
    let reason: FailureReason
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(reason.emoji)
                    .font(.system(size: 32))
                
                Text(reason.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.black : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.black.opacity(0.05) : Color.clear)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    FailureReasonSelectionView(
        selectedReasons: .constant([]),
        customReason: .constant(""),
        onSubmit: {}
    )
}

