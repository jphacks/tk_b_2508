//
//  MediaItem.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/26.
//

import SwiftUI
import AVFoundation

enum MediaItem: Identifiable {
    case image(UIImage)
    case video(URL)
    case model3D(URL)

    var id: String {
        switch self {
        case .image:
            return UUID().uuidString
        case .video(let url):
            return url.absoluteString
        case .model3D(let url):
            return url.absoluteString
        }
    }

    func generateThumbnail() -> UIImage? {
        switch self {
        case .image(let image):
            return image
        case .video(let url):
            return VideoThumbnailGenerator.generateThumbnail(for: url)
        case .model3D:
            return Model3DThumbnailGenerator.generateThumbnail()
        }
    }

    var isVideo: Bool {
        switch self {
        case .video:
            return true
        case .image, .model3D:
            return false
        }
    }

    var is3DModel: Bool {
        switch self {
        case .model3D:
            return true
        case .image, .video:
            return false
        }
    }

    var displayName: String {
        switch self {
        case .image:
            return "画像"
        case .video:
            return "動画"
        case .model3D(let url):
            return url.lastPathComponent
        }
    }
}

enum VideoThumbnailGenerator {
    static func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 0, preferredTimescale: 600)

        var thumbnail: UIImage?
        let semaphore = DispatchSemaphore(value: 0)

        imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, _, error in
            if let cgImage = cgImage {
                thumbnail = UIImage(cgImage: cgImage)
            } else if let error = error {
                print("Error generating thumbnail: \(error)")
            }
            semaphore.signal()
        }

        semaphore.wait()
        return thumbnail
    }
}

enum Model3DThumbnailGenerator {
    static func generateThumbnail() -> UIImage? {
        // 3Dモデルアイコンを生成（システムシンボルを使用）
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let image = UIImage(systemName: "cube.fill", withConfiguration: config)?
            .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)

        // 背景付きのサムネイルを生成
        let size = CGSize(width: 80, height: 80)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // 背景
            UIColor.systemGray6.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // アイコン
            if let icon = image {
                let iconSize = icon.size
                let x = (size.width - iconSize.width) / 2
                let y = (size.height - iconSize.height) / 2
                icon.draw(at: CGPoint(x: x, y: y))
            }
        }
    }
}
