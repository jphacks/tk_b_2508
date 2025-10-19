//
//  LightSweepEffect.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import SwiftUI

struct LightSweepEffect: ViewModifier {
    let trigger: Int
    @State private var progress: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.3),
                            .white.opacity(0.6),
                            .white.opacity(0.3),
                            .clear
                        ]),
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: geometry.size.width * 2 * progress - geometry.size.width * 2)
                    .blendMode(.plusLighter)
                }
            )
            .onChange(of: trigger) { _, _ in
                // トリガーが変わったら1秒待ってアニメーション開始
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒待機

                    // 初期状態にリセット
                    progress = 0

                    // 光を流すアニメーション（右から左へ）
                    withAnimation(.easeInOut(duration: 0.8)) {
                        progress = 1.0
                    }
                }
            }
    }
}

extension View {
    func lightSweep(trigger: Int) -> some View {
        modifier(LightSweepEffect(trigger: trigger))
    }
}
