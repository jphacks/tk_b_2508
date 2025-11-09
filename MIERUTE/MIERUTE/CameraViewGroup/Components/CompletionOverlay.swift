//
//  CompletionOverlay.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import SwiftUI

struct CompletionOverlay: View {
    let onReset: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color("AppCyan"))

                Text("完了")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)

                Text("すべての手順が完了しました")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.8))

                Button(action: onReset) {
                    Text("最初に戻る")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color("AppCyan"))
                        .cornerRadius(12)
                }
                .padding(.top, 20)
            }
        }
        .allowsHitTesting(true)
    }
}

#Preview {
    CompletionOverlay(onReset: {})
}
