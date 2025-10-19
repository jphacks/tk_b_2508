//
//  ViewHeightPreference.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import SwiftUI

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func measureHeight(_ height: Binding<CGFloat>) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ViewHeightKey.self,
                    value: geometry.size.height
                )
            }
        )
        .onPreferenceChange(ViewHeightKey.self) { newHeight in
            height.wrappedValue = newHeight
        }
    }
}
