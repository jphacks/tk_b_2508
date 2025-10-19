//
//  LoadingOverlay.swift
//  MIERUTE
//
//  Created by 本田輝 on 2025/10/18.
//

import SwiftUI

struct LoadingOverlay: View {
    let text: String
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(2.0)
                .tint(.white)

            Text(text)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.top, 400)
    }
}
