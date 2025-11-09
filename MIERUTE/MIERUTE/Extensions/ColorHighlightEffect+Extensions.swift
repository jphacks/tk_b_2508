//
//  ColorHighlightEffect+Extensions.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/28.
//

import SwiftUI

// MARK: - Color Highlight Effect

extension View {
    /// 特定の色を強調し、その他の色を薄くする
    func colorHighlight(
        targetColor: Color,
        threshold: Double = 0.3,
        intensity: Double = 0.5
    ) -> some View {
        self.modifier(ColorHighlightModifier(
            targetColor: targetColor,
            threshold: threshold,
            intensity: intensity
        ))
    }

    /// 特定の色だけを残し、その他を完全にグレースケール化
    func colorIsolate(
        targetColor: Color,
        threshold: Double = 0.3
    ) -> some View {
        self.modifier(ColorIsolateModifier(
            targetColor: targetColor,
            threshold: threshold
        ))
    }

    /// 特定の色を鮮やかにポップさせる
    func colorPop(
        targetColor: Color,
        threshold: Double = 0.3,
        saturation: Double = 2.0
    ) -> some View {
        self.modifier(ColorPopModifier(
            targetColor: targetColor,
            threshold: threshold,
            saturation: saturation
        ))
    }
}

// MARK: - Color Highlight Modifier

struct ColorHighlightModifier: ViewModifier {
    let targetColor: Color
    let threshold: Double
    let intensity: Double

    func body(content: Content) -> some View {
        let shader = ShaderLibrary.ColorHighlight(
            .color(targetColor),
            .float(threshold),
            .float(intensity)
        )

        content.layerEffect(shader, maxSampleOffset: .zero)
    }
}

// MARK: - Color Isolate Modifier

struct ColorIsolateModifier: ViewModifier {
    let targetColor: Color
    let threshold: Double

    func body(content: Content) -> some View {
        let shader = ShaderLibrary.ColorIsolate(
            .color(targetColor),
            .float(threshold)
        )

        content.layerEffect(shader, maxSampleOffset: .zero)
    }
}

// MARK: - Color Pop Modifier

struct ColorPopModifier: ViewModifier {
    let targetColor: Color
    let threshold: Double
    let saturation: Double

    func body(content: Content) -> some View {
        let shader = ShaderLibrary.ColorPop(
            .color(targetColor),
            .float(threshold),
            .float(saturation)
        )

        content.layerEffect(shader, maxSampleOffset: .zero)
    }
}
