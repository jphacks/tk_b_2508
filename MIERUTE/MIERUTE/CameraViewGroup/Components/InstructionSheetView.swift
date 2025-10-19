//
//  InstructionSheetView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import SwiftUI

struct InstructionSheetView: View {
    let instructions: [Instruction]
    let currentIndex: Int
    let onStepTap: (Int) -> Void
    let onClose: () -> Void
    @Binding var selectedDetent: PresentationDetent
    @Binding var showChat: Bool
    @Binding var stepNodeHeight: CGFloat
    @Binding var lightAngle: Double
    @Binding var tiltOffset: Double

    var body: some View {
        Group {
            if selectedDetent != .medium && selectedDetent != .large {
                // Show only current step when sheet is minimized
                ZStack {
                    if currentIndex < instructions.count {
                        VStack(spacing: 0) {
                            StepNodeView(
                                instruction: instructions[currentIndex],
                                stepNumber: currentIndex + 1,
                                isActive: true,
                                isPast: false,
                                isFuture: false,
                                showLine: false,
                                lineIsActive: false,
                                lightAngle: $lightAngle,
                                tiltOffset: $tiltOffset
                            )
                            .padding(.top, 20)
                            .padding(.vertical, 24)
                            .padding(.horizontal, 16)
                        }
                        .lightSweep(trigger: currentIndex)
                        .measureHeight($stepNodeHeight)
                        .id(currentIndex)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                    }
                }
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: currentIndex)
            } else {
                // Show all steps when sheet is expanded
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(instructions.enumerated()), id: \.element.id) { index, instruction in
                                StepNodeView(
                                    instruction: instruction,
                                    stepNumber: index + 1,
                                    isActive: index == currentIndex,
                                    isPast: index < currentIndex,
                                    isFuture: index > currentIndex,
                                    showLine: index < instructions.count - 1,
                                    lineIsActive: index < currentIndex,
                                    lightAngle: $lightAngle,
                                    tiltOffset: $tiltOffset
                                )
                                .id(index)
                            }
                        }
                        .padding(.vertical, 24)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo(currentIndex, anchor: .center)
                            }
                        }
                    }
                    .onChange(of: currentIndex) { _, newValue in
                        withAnimation {
                            proxy.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showChat) {
            ChatView(viewModel: .init())
                .presentationDetents([.large])
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
