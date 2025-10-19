//
//  TiltShineEffect+Extensions.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import SwiftUI

struct TiltShineEffect: ViewModifier {
    @Binding var tiltOffset: Double
    let intensity: Double
    let shineWidth: Double

    func body(content: Content) -> some View {
        content
            .visualEffect { view, proxy in
                view.layerEffect(
                    ShaderLibrary.TiltShine(
                        .float2(proxy.size),
                        .float(tiltOffset),
                        .float(intensity),
                        .float(shineWidth)
                    ),
                    maxSampleOffset: .zero
                )
            }
    }
}

extension View {
    func tiltShine(tiltOffset: Binding<Double>, intensity: Double = 0.15, shineWidth: Double = 12) -> some View {
        self.modifier(TiltShineEffect(tiltOffset: tiltOffset, intensity: intensity, shineWidth: shineWidth))
    }
}
