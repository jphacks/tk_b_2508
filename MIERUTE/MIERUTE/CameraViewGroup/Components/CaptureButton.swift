//
//  CaptureButton.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import SwiftUI

struct CaptureButton: View {
    let onCapture: () -> Void

    var body: some View {
        VStack {
            Spacer()

            Button(action: onCapture) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 70, height: 70)

                    Circle()
                        .stroke(.white, lineWidth: 4)
                        .frame(width: 80, height: 80)
                }
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    ZStack {
        Color.black
        CaptureButton(onCapture: {})
    }
}
