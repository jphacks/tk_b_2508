//
//  InstructionOverlay.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import SwiftUI

struct InstructionOverlay: View {
    let instruction: Instruction
    let currentIndex: Int
    let totalCount: Int
    let canGoNext: Bool
    let canGoPrevious: Bool
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        Text(instruction.description)
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(.black)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
            .glassEffect(.clear.tint(.white.opacity(0.5)))
    }
}

#Preview {
    ZStack {
        Color.black
        InstructionOverlay(
            instruction: Instruction(
                id: "1",
                title: "ステップ1",
                description: "製品の箱を開けてください",
                order: 0,
                nextNodeId: "2",
                previousNodeId: nil
            ),
            currentIndex: 0,
            totalCount: 3,
            canGoNext: true,
            canGoPrevious: false,
            onNext: {},
            onPrevious: {},
            onClose: {}
        )
    }
}
