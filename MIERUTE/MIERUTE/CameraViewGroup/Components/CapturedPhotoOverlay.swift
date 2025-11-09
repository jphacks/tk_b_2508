//
//  CapturedPhotoOverlay.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import SwiftUI

struct CapturedPhotoOverlay: View {
    let photo: UIImage
    let highlightColor: Color?
    @Binding var photoScale: CGFloat
    @Binding var photoRotation: Double
    @Binding var photoOffset: CGFloat
    @Binding var rippleCounter: Int
    @Binding var rippleOrigin: CGPoint

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            ZStack {
                let image = Image(uiImage: photo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                if let color = highlightColor {
                    image
                        .colorIsolate(
                            targetColor: color,
                            threshold: 0.4
                        )
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white, lineWidth: 10)
                        )
                } else {
                    image
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white, lineWidth: 10)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(photoScale, anchor: .center)
            .rotationEffect(.degrees(photoRotation))
            .offset(y: photoOffset)
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

#Preview("Success Animation") {
    @Previewable @State var photoScale: CGFloat = 1.0
    @Previewable @State var photoRotation: Double = 0
    @Previewable @State var photoOffset: CGFloat = 0
    @Previewable @State var rippleCounter: Int = 0
    @Previewable @State var rippleOrigin: CGPoint = .zero

    let sampleImage = {
        let size = CGSize(width: 300, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor(Color("AppCyan")).setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let text = "Success!"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attrs)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attrs)
        }
    }()

    return ZStack {
        CapturedPhotoOverlay(
            photo: sampleImage,
            highlightColor: Color("AppCyan"),
            photoScale: $photoScale,
            photoRotation: $photoRotation,
            photoOffset: $photoOffset,
            rippleCounter: $rippleCounter,
            rippleOrigin: $rippleOrigin
        )

        VStack {
            Spacer()
            Button("Play Success Animation") {
                Task { @MainActor in
                    photoScale = 1.0
                    photoRotation = 0
                    photoOffset = 0

                    try? await Task.sleep(nanoseconds: 200_000_000)

                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        photoScale = 1.3
                    }

                    try? await Task.sleep(nanoseconds: 200_000_000)

                    withAnimation(.easeOut(duration: 0.4)) {
                        photoScale = 0
                    }

                    try? await Task.sleep(nanoseconds: 600_000_000)
                    photoScale = 1.0
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .padding(.bottom, 50)
        }
    }
}

#Preview("Failed Animation") {
    @Previewable @State var photoScale: CGFloat = 1.0
    @Previewable @State var photoRotation: Double = 0
    @Previewable @State var photoOffset: CGFloat = 0
    @Previewable @State var rippleCounter: Int = 0
    @Previewable @State var rippleOrigin: CGPoint = .zero

    let sampleImage = {
        let size = CGSize(width: 300, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemRed.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let text = "Failed!"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attrs)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attrs)
        }
    }()

    return ZStack {
        CapturedPhotoOverlay(
            photo: sampleImage,
            highlightColor: Color("AppCyan"),
            photoScale: $photoScale,
            photoRotation: $photoRotation,
            photoOffset: $photoOffset,
            rippleCounter: $rippleCounter,
            rippleOrigin: $rippleOrigin
        )

        VStack {
            Spacer()
            Button("Play Failed Animation") {
                Task { @MainActor in
                    photoScale = 1.0
                    photoRotation = 0
                    photoOffset = 0

                    try? await Task.sleep(nanoseconds: 200_000_000)

                    withAnimation(.easeIn(duration: 0.2)) {
                        photoRotation = -15
                    }

                    try? await Task.sleep(nanoseconds: 100_000_000)

                    withAnimation(.easeOut(duration: 0.6)) {
                        photoRotation = -25
                        photoOffset = 1200
                        photoScale = 0.8
                    }

                    try? await Task.sleep(nanoseconds: 800_000_000)
                    photoScale = 1.0
                    photoRotation = 0
                    photoOffset = 0
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .padding(.bottom, 50)
        }
    }
}
