//
//  StackedImagesView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI
import AVKit

struct StackedMediaView: View {
    let medias: [MediaItem]
    let onDelete: (Int) -> Void
    @State private var isExpanded = false
    @Namespace private var animation
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: -10) {
                mediaGrid(screenWidth: geometry.size.width)
                    .frame(height: isExpanded ? nil : 170, alignment: .topLeading)
                    .onTapGesture {
                        if !isExpanded {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                isExpanded = true
                            }
                        }
                    }
            }
            .padding(.top, isExpanded ? 0 : 70)
            .padding(isExpanded ? 0 : 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .ignoresSafeArea()
            .background {
                if isExpanded {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                isExpanded = false
                            }
                        }
                }
            }
        }
    }
    
    private func mediaGrid(screenWidth: CGFloat) -> some View {
        // 展開時: 左右padding 16px + 中央spacing 12px = 44px
        // 重なっている時: 固定サイズ 100px
        let itemWidth = isExpanded ? (screenWidth - 44) / 2 : 100
        let itemHeight = isExpanded ? itemWidth * 1.4 : 140
        
        let columns = [
            GridItem(.fixed(itemWidth), spacing: 12),
            GridItem(.fixed(itemWidth), spacing: 12)
        ]
        
        return ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 12, pinnedViews: []) {
                ForEach(Array(medias.enumerated()), id: \.offset) { index, media in
                    mediaGridItem(for: media, at: index, itemWidth: itemWidth, itemHeight: itemHeight)
                }
            }
            .padding(.top, isExpanded ? 70 : 0)
            .background {
                if isExpanded {
                    Color.clear.opacity(0.1)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                isExpanded = false
                            }
                        }
                }
            }
        }
        .scrollDisabled(!isExpanded)
    }
    
    @ViewBuilder
    private func mediaGridItem(for media: MediaItem, at index: Int, itemWidth: CGFloat, itemHeight: CGFloat) -> some View {
        if let thumbnail = media.generateThumbnail() {
            ZStack {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: itemWidth, height: itemHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(alignment: .center) {
                        if media.isVideo {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: isExpanded ? 50 : 30))
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                        }
                    }
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .rotationEffect(isExpanded ? .degrees(0) : rotationAngle(for: index))
                    .offset(isExpanded ? .zero : stackedOffset(for: index, itemWidth: itemWidth, itemHeight: itemHeight))
                    .opacity(isExpanded ? 1 : (index < 3 ? 1 : 0))
                    .scaleEffect(isExpanded ? 1 : (index < 3 ? 1 : 0))
                    .padding(.leading)
            }
            .frame(height: itemHeight + 10)
            .zIndex(Double(medias.count - index))
        }
    }
    
    private func stackedOffset(for index: Int, itemWidth: CGFloat, itemHeight: CGFloat) -> CGSize {
        // グリッド位置から1番目（左上）の位置への移動量を計算
        let column = index % 2 // 0: 左列, 1: 右列
        let row = index / 2 // 行番号

        let spacing: CGFloat = 12

        // 各グリッド位置から左上（0, 0）への移動量
        let xOffset = column == 0 ? 0 : -(itemWidth + spacing)
        let yOffset = -(CGFloat(row) * (itemHeight + spacing))

        // 傾き用の小さなオフセットを追加
        // 3枚目以降は3枚目と同じオフセットを使う
        let stackOffset = offsetPosition(for: index >= 3 ? 2 : index)

        return CGSize(
            width: xOffset + stackOffset.width,
            height: yOffset + stackOffset.height
        )
    }
    
    private func rotationAngle(for index: Int) -> Angle {
        switch index {
        case 0:
            return .degrees(0)
        case 1:
            return .degrees(-4)
        default:
            // 2枚目以降は全て-8度
            return .degrees(-8)
        }
    }
    
    private func offsetPosition(for index: Int) -> CGSize {
        switch index {
        case 0:
            return CGSize(width: 0, height: 0)
        case 1:
            return CGSize(width: -3, height: 2)
        case 2:
            return CGSize(width: -6, height: -8)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
}

#Preview("空の状態") {
    StackedMediaView(medias: [], onDelete: { _ in })
}

#Preview("画像1枚") {
    let sampleImage = {
        let size = CGSize(width: 100, height: 160)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor(Color("AppCyan")).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let text = "画像 1"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
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
    
    return StackedMediaView(medias: [.image(sampleImage)], onDelete: { _ in })
}

#Preview("画像3枚 - 重ねた状態") {
    let createImage: (Int, UIColor) -> UIImage = { index, color in
        let size = CGSize(width: 100, height: 160)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let text = "画像 \(index)"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
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
    }
    
    return StackedMediaView(medias: [
        .image(createImage(1, UIColor(Color("AppCyan")))),
        .image(createImage(2, UIColor(Color("AppCyan")))),
        .image(createImage(3, UIColor(Color("AppOrange"))))
    ], onDelete: { _ in })
}

#Preview("画像6枚") {
    let createImage: (Int, UIColor) -> UIImage = { index, color in
        let size = CGSize(width: 100, height: 160)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let text = "\(index)"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
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
    }
    
    return StackedMediaView(medias: [
        .image(createImage(1, UIColor(Color("AppCyan")))),
        .image(createImage(2, UIColor(Color("AppCyan")))),
        .image(createImage(3, UIColor(Color("AppOrange")))),
        .image(createImage(4, UIColor(Color("AppCyan")))),
        .image(createImage(5, UIColor(Color("AppOrange")))),
        .image(createImage(6, UIColor(Color("AppCyan"))))
    ], onDelete: { _ in })
}
