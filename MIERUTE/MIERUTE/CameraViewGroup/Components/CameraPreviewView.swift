//
//  CameraPreviewView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.backgroundColor = .black

        // プレビューレイヤーが既に親レイヤーを持っている場合は削除
        previewLayer.removeFromSuperlayer()

        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {
        // 既にサブレイヤーとして追加されているか確認
        if previewLayer.superlayer != uiView.layer {
            previewLayer.removeFromSuperlayer()
            uiView.layer.insertSublayer(previewLayer, at: 0)
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        previewLayer.frame = uiView.bounds
        CATransaction.commit()
    }
}

class PreviewUIView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.first?.frame = bounds
    }
}
