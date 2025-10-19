//
//  CapturedPhotoOverlay.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import SwiftUI

struct CapturedPhotoOverlay: View {
    let photo: UIImage
    @Binding var photoScale: CGFloat
    @Binding var rippleCounter: Int
    @Binding var rippleOrigin: CGPoint

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            Image(uiImage: photo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white, lineWidth: 10)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(photoScale, anchor: .center)
                .modifier(RippleEffect(at: rippleOrigin, trigger: rippleCounter))
        }
        .allowsHitTesting(true)
        .onPressingChanged { point in
            if let point = point {
                rippleOrigin = point
                rippleCounter += 1
            }
        }
    }
}
