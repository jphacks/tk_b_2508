//
//  TutorialCompleteOverlay.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

struct TutorialCompleteOverlay: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .symbolRenderingMode(.hierarchical)

                Text("アプリをお楽しみください")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Button(action: onDismiss) {
                    Text("閉じる")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 200)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 40)
        }
        .allowsHitTesting(true)
    }
}

#Preview {
    TutorialCompleteOverlay(onDismiss: {})
}
