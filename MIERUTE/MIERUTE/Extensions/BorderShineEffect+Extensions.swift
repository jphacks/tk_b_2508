//
//  BorderShineEffect+Extensions.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import SwiftUI

struct BorderShineEffect: ViewModifier {
    let speed: Double
    let width: Double
    @Binding var angle: Double

    @State private var startTime = Date()

    func body(content: Content) -> some View {
        TimelineView(.animation) { timeline in
            let elapsedTime = timeline.date.timeIntervalSince(startTime)

            content
                .visualEffect { view, _ in
                    view.layerEffect(
                        ShaderLibrary.BorderShine(
                            .float(elapsedTime),
                            .float(speed),
                            .float(width),
                            .float(angle)
                        ),
                        maxSampleOffset: .zero
                    )
                }
        }
    }
}

extension View {
    func borderShine(speed: Double = 200, width: Double = 1000, angle: Binding<Double>) -> some View {
        self.modifier(BorderShineEffect(speed: speed, width: width, angle: angle))
    }
}
