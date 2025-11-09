//
//  StepNodeView.swift
//  MIERUTE
//
//  Created by 本田輝 on 2025/10/18.
//

import SwiftUI

struct StepNodeView: View {
    let instruction: Instruction
    let stepNumber: Int
    let isActive: Bool
    let isPast: Bool
    let isFuture: Bool
    let showLine: Bool
    let lineIsActive: Bool
    @Binding var lightAngle: Double
    @Binding var tiltOffset: Double

    private let circleSize: CGFloat = 50
    private let leadingPadding: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content with background
            ZStack {
                // Background and content
                HStack(alignment: .center, spacing: 16) {
                    // Step Number Circle
                    ZStack {
                        Circle()
                            .fill(circleColor)
                            .frame(width: circleSize, height: circleSize)

                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                    }
                    .frame(width: circleSize, height: circleSize)
                    .scaleEffect(isActive ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isActive)

                    // Step Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text(instruction.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(isActive ? .primary : .secondary)

                        Text(instruction.description)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(isActive ? .primary : .secondary)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isPast ? Color("AppCyan").opacity(0.1) : Color.gray.opacity(0.1))
                )
                .padding(.horizontal, 16)

                // Stroke with tilt shine (only when active)
                if isActive {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("AppCyan"), lineWidth: 2)
                        .tiltShine(tiltOffset: $tiltOffset, intensity: 0.2, shineWidth: 10)
                        .padding(.horizontal, 16)
                }
            }

            // Connecting Line between backgrounds
            if showLine {
                Rectangle()
                    .fill(lineIsActive ? Color("AppCyan") : Color.gray.opacity(0.3))
                    .frame(width: 3, height: 50)
            }
        }
    }
    
    private var circleColor: Color {
        if isPast {
            return Color("AppCyan")
        } else if isActive {
            return Color.gray.opacity(0.3)
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State private var selectedDetent: PresentationDetent = .height(130)
        @State private var showChat = false
        @State private var stepNodeHeight: CGFloat = 130
        @State private var lightAngle: Double = .pi / 4
        @State private var tiltOffset: Double = 0.0

        var body: some View {
            InstructionSheetView(
                instructions: [
                    Instruction(
                        id: "1",
                        title: "ステップ1",
                        description: "製品の箱を開けてください",
                        order: 0,
                        nextNodeId: "2",
                        previousNodeId: nil,
                        imageUrl: nil
                    ),
                    Instruction(
                        id: "2",
                        title: "ステップ2",
                        description: "本体を取り出してください",
                        order: 1,
                        nextNodeId: "3",
                        previousNodeId: "1",
                        imageUrl: nil
                    ),
                    Instruction(
                        id: "3",
                        title: "ステップ3",
                        description: "電源ケーブルを接続してください",
                        order: 2,
                        nextNodeId: nil,
                        previousNodeId: "2",
                        imageUrl: nil
                    )
                ],
                currentIndex: 1,
                onStepTap: { _ in },
                onClose: {},
                selectedDetent: $selectedDetent,
                showChat: $showChat,
                stepNodeHeight: $stepNodeHeight,
                lightAngle: $lightAngle,
                tiltOffset: $tiltOffset
            )
        }
    }

    return PreviewWrapper()
}
