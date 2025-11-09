//
//  PhotoEditorView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/28.
//

import SwiftUI

struct PhotoEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage
    let onSave: (UIImage, String?) -> Void

    @State private var annotations: [Annotation] = []
    @State private var currentAnnotationType: AnnotationType = .circle
    @State private var extractedColor: Color?
    @State private var extractedColorHex: String?
    @State private var isDrawing = false
    @State private var currentPoint: CGPoint = .zero
    @State private var imageSize: CGSize = .zero

    enum AnnotationType: String, CaseIterable {
        case circle = "丸"
        case arrow = "矢印"
        case colorPicker = "色抽出"

        var icon: String {
            switch self {
            case .circle: return "circle"
            case .arrow: return "arrow.right"
            case .colorPicker: return "eyedropper"
            }
        }
    }

    struct Annotation: Identifiable {
        let id = UUID()
        let type: AnnotationType
        let startPoint: CGPoint
        var endPoint: CGPoint
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // 画像表示エリア
                    GeometryReader { geometry in
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(
                                    GeometryReader { imageGeo in
                                        Color.clear.onAppear {
                                            imageSize = imageGeo.size
                                        }
                                    }
                                )

                            // 注釈レイヤー
                            Canvas { context, size in
                                for annotation in annotations {
                                    drawAnnotation(context: context, annotation: annotation, size: size)
                                }

                                if isDrawing {
                                    drawCurrentAnnotation(context: context, size: size)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        handleDrag(value: value, in: geometry.size)
                                    }
                                    .onEnded { value in
                                        handleDragEnd(value: value, in: geometry.size)
                                    }
                            )
                        }
                    }

                    // ツールバー
                    toolBar
                }
            }
            .navigationTitle("写真を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        saveEditedImage()
                    }
                    .bold()
                }
            }
        }
    }

    private var toolBar: some View {
        VStack(spacing: 16) {
            // ツール選択
            HStack(spacing: 12) {
                ForEach(AnnotationType.allCases, id: \.self) { type in
                    Button(action: { currentAnnotationType = type }) {
                        VStack(spacing: 6) {
                            Image(systemName: type.icon)
                                .font(.system(size: 24))
                                .foregroundStyle(currentAnnotationType == type ? Color("AppCyan") : .white.opacity(0.6))

                            Text(type.rawValue)
                                .font(.system(size: 12))
                                .foregroundStyle(currentAnnotationType == type ? Color("AppCyan") : .white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(currentAnnotationType == type ? Color("AppCyan").opacity(0.2) : Color.clear)
                        )
                    }
                }
            }
            .padding(.horizontal, 20)

            // 抽出された色を表示
            if let color = extractedColor, let hex = extractedColorHex {
                HStack(spacing: 12) {
                    Circle()
                        .fill(color)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: 2)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("抽出された色")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.7))

                        Text(hex)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.green)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.1))
                )
                .padding(.horizontal, 20)
            }

            // アクションボタン
            HStack(spacing: 12) {
                Button(action: clearAll) {
                    Label("全て削除", systemImage: "trash")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white.opacity(0.2))
                        )
                }
                .disabled(annotations.isEmpty && extractedColor == nil)

                if !annotations.isEmpty {
                    Button(action: undoLast) {
                        Label("取り消し", systemImage: "arrow.uturn.backward")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white.opacity(0.2))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
    }

    private func handleDrag(value: DragGesture.Value, in size: CGSize) {
        let location = value.location

        if currentAnnotationType == .colorPicker {
            // 色抽出モード
            extractColor(at: location)
        } else {
            // 描画モード
            if !isDrawing {
                isDrawing = true
                currentPoint = location
            } else {
                if !annotations.isEmpty {
                    annotations[annotations.count - 1].endPoint = location
                }
            }
        }
    }

    private func handleDragEnd(value: DragGesture.Value, in size: CGSize) {
        if currentAnnotationType != .colorPicker && isDrawing {
            isDrawing = false
            if annotations.isEmpty || annotations.last?.endPoint != value.location {
                annotations.append(Annotation(
                    type: currentAnnotationType,
                    startPoint: currentPoint,
                    endPoint: value.location
                ))
            }
        }
    }

    private func drawAnnotation(context: GraphicsContext, annotation: Annotation, size: CGSize) {
        let strokeStyle = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)

        switch annotation.type {
        case .circle:
            let center = annotation.startPoint
            let radius = hypot(annotation.endPoint.x - center.x, annotation.endPoint.y - center.y)
            let circlePath = Circle()
                .path(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
            context.stroke(circlePath, with: .color(.red), style: strokeStyle)

        case .arrow:
            var path = Path()
            path.move(to: annotation.startPoint)
            path.addLine(to: annotation.endPoint)

            // 矢印の先端
            let angle = atan2(annotation.endPoint.y - annotation.startPoint.y, annotation.endPoint.x - annotation.startPoint.x)
            let arrowLength: CGFloat = 20
            let arrowAngle: CGFloat = .pi / 6

            let arrowPoint1 = CGPoint(
                x: annotation.endPoint.x - arrowLength * cos(angle - arrowAngle),
                y: annotation.endPoint.y - arrowLength * sin(angle - arrowAngle)
            )
            let arrowPoint2 = CGPoint(
                x: annotation.endPoint.x - arrowLength * cos(angle + arrowAngle),
                y: annotation.endPoint.y - arrowLength * sin(angle + arrowAngle)
            )

            path.move(to: annotation.endPoint)
            path.addLine(to: arrowPoint1)
            path.move(to: annotation.endPoint)
            path.addLine(to: arrowPoint2)

            context.stroke(path, with: .color(.yellow), style: strokeStyle)

        case .colorPicker:
            break
        }
    }

    private func drawCurrentAnnotation(context: GraphicsContext, size: CGSize) {
        if let lastAnnotation = annotations.last {
            drawAnnotation(context: context, annotation: lastAnnotation, size: size)
        }
    }

    private func extractColor(at point: CGPoint) {
        guard let cgImage = image.cgImage else { return }

        // 画像座標に変換
        let scaleX = CGFloat(cgImage.width) / imageSize.width
        let scaleY = CGFloat(cgImage.height) / imageSize.height

        let x = Int(point.x * scaleX)
        let y = Int(point.y * scaleY)

        guard x >= 0, x < cgImage.width, y >= 0, y < cgImage.height else { return }

        // ピクセルデータから色を取得
        let pixelData = cgImage.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelInfo = ((cgImage.width * y) + x) * 4

        let r = CGFloat(data[pixelInfo]) / 255.0
        let g = CGFloat(data[pixelInfo + 1]) / 255.0
        let b = CGFloat(data[pixelInfo + 2]) / 255.0

        extractedColor = Color(red: r, green: g, blue: b)
        extractedColorHex = String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    private func clearAll() {
        annotations.removeAll()
        extractedColor = nil
        extractedColorHex = nil
    }

    private func undoLast() {
        if !annotations.isEmpty {
            annotations.removeLast()
        }
    }

    private func saveEditedImage() {
        // 注釈を画像に合成
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let editedImage = renderer.image { context in
            // 元の画像を描画
            image.draw(at: .zero)

            let scaleX = image.size.width / imageSize.width
            let scaleY = image.size.height / imageSize.height

            // 注釈を描画
            for annotation in annotations {
                let scaledStart = CGPoint(x: annotation.startPoint.x * scaleX, y: annotation.startPoint.y * scaleY)
                let scaledEnd = CGPoint(x: annotation.endPoint.x * scaleX, y: annotation.endPoint.y * scaleY)

                switch annotation.type {
                case .circle:
                    let center = scaledStart
                    let radius = hypot(scaledEnd.x - center.x, scaledEnd.y - center.y)
                    let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)

                    context.cgContext.setStrokeColor(UIColor.red.cgColor)
                    context.cgContext.setLineWidth(6)
                    context.cgContext.strokeEllipse(in: rect)

                case .arrow:
                    context.cgContext.setStrokeColor(UIColor.yellow.cgColor)
                    context.cgContext.setLineWidth(6)
                    context.cgContext.setLineCap(.round)

                    // 線を描画
                    context.cgContext.move(to: scaledStart)
                    context.cgContext.addLine(to: scaledEnd)
                    context.cgContext.strokePath()

                    // 矢印の先端
                    let angle = atan2(scaledEnd.y - scaledStart.y, scaledEnd.x - scaledStart.x)
                    let arrowLength: CGFloat = 40
                    let arrowAngle: CGFloat = .pi / 6

                    let arrowPoint1 = CGPoint(
                        x: scaledEnd.x - arrowLength * cos(angle - arrowAngle),
                        y: scaledEnd.y - arrowLength * sin(angle - arrowAngle)
                    )
                    let arrowPoint2 = CGPoint(
                        x: scaledEnd.x - arrowLength * cos(angle + arrowAngle),
                        y: scaledEnd.y - arrowLength * sin(angle + arrowAngle)
                    )

                    context.cgContext.move(to: scaledEnd)
                    context.cgContext.addLine(to: arrowPoint1)
                    context.cgContext.move(to: scaledEnd)
                    context.cgContext.addLine(to: arrowPoint2)
                    context.cgContext.strokePath()

                case .colorPicker:
                    break
                }
            }
        }

        onSave(editedImage, extractedColorHex)
        dismiss()
    }
}

#Preview {
    PhotoEditorView(
        image: UIImage(systemName: "photo")!,
        onSave: { _, _ in }
    )
}
