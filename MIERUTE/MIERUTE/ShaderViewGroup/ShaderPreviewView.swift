//
//  ShaderPreviewView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import SwiftUI

struct ShaderPreviewView: View {
    @State private var counter: Int = 0
    @State private var origin: CGPoint = .zero
    @StateObject private var motionService = MotionService()

    var body: some View {
        ZStack {
            // Background gradient with tilt shine
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.25, blue: 0.45),
                    Color(red: 0.25, green: 0.15, blue: 0.35)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
//            .tiltShine(tiltOffset: $motionService.tiltOffset, intensity: 0.1, shineWidth: 10)

            VStack(spacing: 40) {
                Spacer()

                // Ripple effect target
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: [Color("AppCyan").opacity(0.3), Color("AppOrange").opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 300, height: 300)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(.white.opacity(0.3), lineWidth: 2)
                        )

                    VStack(spacing: 16) {
                        Text("デバイスを傾けて光を動かす")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        Text("タップして波紋を作る")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .onPressingChanged { point in
                    if let point {
                        origin = point
                        counter += 1
                    }
                }
                .modifier(RippleEffect(at: origin, trigger: counter))
//                .tiltShine(tiltOffset: $motionService.tiltOffset, intensity: 0.2, shineWidth: 10)

                VStack(spacing: 12) {
                    if counter > 0 {
                        Text("タップ回数: \(counter)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.15))
                            )
                    }

//                    VStack(spacing: 8) {
//                        Text("傾きオフセット: \(String(format: "%.2f", motionService.tiltOffset))")
//                            .font(.system(size: 16, weight: .medium))
//                            .foregroundColor(.white.opacity(0.8))
//
//                        Text("左上 ← → 右下")
//                            .font(.system(size: 14, weight: .regular))
//                            .foregroundColor(.white.opacity(0.6))
//                    }
//                    .padding(.horizontal, 24)
//                    .padding(.vertical, 10)
//                    .background(
//                        Capsule()
//                            .fill(.white.opacity(0.1))
//                    )
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ShaderPreviewView()
}
