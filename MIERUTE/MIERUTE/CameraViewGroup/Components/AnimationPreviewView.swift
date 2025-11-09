//
//  AnimationPreviewView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/27.
//

import SwiftUI
import ConfettiSwiftUI

struct AnimationPreviewView: View {
    @State private var selectedAnimation: AnimationType = .failed
    @State private var isPlaying = false
    @State private var photoScale: CGFloat = 0.6
    @State private var photoRotation: Double = 0
    @State private var photoOffset: CGFloat = 0
    @State private var rippleCounter: Int = 0
    @State private var rippleOrigin: CGPoint = .zero
    @State private var confettiTrigger: Int = 0

    enum AnimationType: String, CaseIterable {
        case success = "成功"
        case failed = "失敗"

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .failed: return "xmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: return Color("AppCyan")
            case .failed: return Color("AppOrange")
            }
        }
    }

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            // Photo card
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("AppCyan"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white, lineWidth: 10)
                    )
                    .aspectRatio(3/4, contentMode: .fit)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(photoScale, anchor: .center)
            .rotationEffect(.degrees(photoRotation))
            .offset(y: photoOffset)

            // Controls
            VStack {
                Spacer()

                VStack(spacing: 20) {
                    // Animation type selector
                    HStack(spacing: 16) {
                        ForEach(AnimationType.allCases, id: \.self) { type in
                            Button(action: {
                                selectedAnimation = type
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: type.icon)
                                        .font(.system(size: 30))
                                        .foregroundColor(selectedAnimation == type ? type.color : .white.opacity(0.5))

                                    Text(type.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(selectedAnimation == type ? type.color : .white.opacity(0.5))
                                }
                                .frame(width: 100, height: 100)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedAnimation == type ? type.color.opacity(0.2) : Color.white.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedAnimation == type ? type.color : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                    }

                    // Play button
                    Button(action: playAnimation) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 20))

                            Text("アニメーション再生")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 280)
                        .padding(.vertical, 16)
                        .background(selectedAnimation.color)
                        .cornerRadius(12)
                    }
                    .disabled(isPlaying)
                    .opacity(isPlaying ? 0.5 : 1.0)
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .confettiCannon(counter: $confettiTrigger, num: 50, confettiSize: 20, rainHeight: 800, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 600, repetitions: 1, repetitionInterval: 0.5)
    }

    private func playAnimation() {
        isPlaying = true
        photoScale = 0.6
        photoRotation = 0
        photoOffset = 0

        Task { @MainActor in
            switch selectedAnimation {
            case .success:
                // Success: ポップに消えて花吹雪
                try? await Task.sleep(nanoseconds: 400_000_000)

                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    photoScale = 0.75
                }

                try? await Task.sleep(nanoseconds: 300_000_000)

                confettiTrigger += 1

                withAnimation(.easeOut(duration: 0.4)) {
                    photoScale = 0
                }

                try? await Task.sleep(nanoseconds: 600_000_000)

            case .failed:
                // Failed: カッコンと傾いて落ちる
                try? await Task.sleep(nanoseconds: 200_000_000)

                withAnimation(.easeIn(duration: 0.2)) {
                    photoRotation = -15
                }

                try? await Task.sleep(nanoseconds: 150_000_000)

                withAnimation(.easeOut(duration: 0.8)) {
                    photoRotation = -25
                    photoOffset = 1200
                    photoScale = 0.8
                }

                try? await Task.sleep(nanoseconds: 1_200_000_000)
            }

            // Reset
            photoScale = 0.6
            photoRotation = 0
            photoOffset = 0
            isPlaying = false
        }
    }
}

#Preview {
    AnimationPreviewView()
}
