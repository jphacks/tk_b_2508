//
//  TutorialInstructionView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import SwiftUI

struct TutorialInstructionView: View {
    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .symbolRenderingMode(.hierarchical)

                Text("グッドサインで写真を撮る")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("画面を長押しして撮影")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ZStack {
        Color.black
        TutorialInstructionView()
    }
}
