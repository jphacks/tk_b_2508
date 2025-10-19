//
//  LongPressIndicator.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import SwiftUI

struct LongPressIndicator: View {
    let progress: CGFloat

    var body: some View {
        ZStack {
            // Background dimming
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Circular progress indicator
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 8)
                        .frame(width: 100, height: 100)

                    // Progress circle
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.02), value: progress)

                    // Camera icon
                    Image(systemName: "camera.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }

                // Instruction text
                Text("長押しして撮影")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                // Progress percentage
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .monospacedDigit()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray
        LongPressIndicator(progress: 0.6)
    }
}
