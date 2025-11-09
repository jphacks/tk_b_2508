//
//  CameraView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import SwiftUI
import ConfettiSwiftUI

struct CameraView: View {
    @ObservedObject var viewModel: CameraViewModel
    @StateObject private var scannerService = QRCodeScannerService()
    @StateObject private var motionService = MotionService()
    @State private var selectedDetent: PresentationDetent = .height(130)
    @State private var showChat = false
    @State private var rippleCounter: Int = 0
    @State private var rippleOrigin: CGPoint = .zero
    @State private var capturedPhotoForDisplay: UIImage?
    @State private var showPhotoActions: Bool = false
    @State private var photoScale: CGFloat = 1.0
    @State private var photoRotation: Double = 0
    @State private var photoOffset: CGFloat = 0
    @State private var stepNodeHeight: CGFloat = 130
    @State private var cachedImage: UIImage?
    @State private var confettiTrigger: Int = 0
    @State private var hasDetectedGoodSign: Bool = OnboardingService.hasDetectedGoodSign()
    @State private var showManualCreation = false
    @State private var capturedPhotos: [MediaItem] = []

    private var validStepNodeHeight: CGFloat {
        max(stepNodeHeight, 130)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                cameraPreviewLayer

                if let photo = capturedPhotoForDisplay {
                    let highlightColor: Color? = {
                        if case .displayingInstructions(let currentIndex) = viewModel.appState,
                           currentIndex < viewModel.instructions.count,
                           let colorHex = viewModel.instructions[currentIndex].highlightColor {
                            return Color(hex: colorHex)
                        }
                        return nil
                    }()

                    CapturedPhotoOverlay(
                        photo: photo,
                        highlightColor: highlightColor,
                        photoScale: $photoScale,
                        photoRotation: $photoRotation,
                        photoOffset: $photoOffset,
                        rippleCounter: $rippleCounter,
                        rippleOrigin: $rippleOrigin
                    )
                }

                overlayContent
                longPressGestureArea
                referenceImageView

                if !capturedPhotos.isEmpty {
                    StackedMediaView(medias: capturedPhotos, onDelete: { index in
                        capturedPhotos.remove(at: index)
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .confettiCannon(counter: $confettiTrigger, num: 50, confettiSize: 20, rainHeight: 800, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 600, repetitions: 1, repetitionInterval: 0.5)
            .onAppear(perform: setupCamera)
            .onDisappear { scannerService.stopScanning() }
            .onChange(of: scannerService.scannedCode, handleQRCodeScanned)
            .onChange(of: scannerService.capturedImage, handlePhotoCapture)
            .onChange(of: viewModel.recognitionResult, handleRecognitionResult)
            .sheet(isPresented: .constant(viewModel.appState.isDisplayingInstructions)) {
                instructionSheet
            }
            .fullScreenCover(isPresented: $showManualCreation) {
                ManualCreationView()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
    }

    // MARK: - View Components

    private var cameraPreviewLayer: some View {
        Group {
            if let previewLayer = scannerService.getPreviewLayer() {
                CameraPreviewView(previewLayer: previewLayer)
            }
        }
    }

    private var overlayContent: some View {
        Group {
            if case .scanning = viewModel.appState {
                if !hasDetectedGoodSign {
                    TutorialInstructionView()
                        .allowsHitTesting(false)
                } else {
                    QRScannerOverlay()
                        .allowsHitTesting(false)
                }
            }

            if case .loading = viewModel.appState {
                LoadingOverlay(text: "手順書を読み込み中...")
                    .allowsHitTesting(false)
            }

            if case .completed = viewModel.appState {
                CompletionOverlay(onReset: viewModel.resetToScanning)
            }
        }
    }

    private var longPressGestureArea: some View {
        Group {
            let canCapture: Bool = {
                if showPhotoActions { return false }
                if viewModel.appState.isDisplayingInstructions { return true }
                if case .scanning = viewModel.appState, !hasDetectedGoodSign { return true }
                return false
            }()

            if canCapture {
                Color.clear
                    .contentShape(Rectangle())
                    .onPressingChanged(handleLongPress)
            }
        }
    }

    @ViewBuilder
    private var referenceImageView: some View {
        if case .displayingInstructions(let currentIndex) = viewModel.appState,
           currentIndex < viewModel.instructions.count,
           let imageUrl = viewModel.instructions[currentIndex].imageUrl,
           !imageUrl.isEmpty,
           capturedPhotoForDisplay == nil {
            let showLoadingOverlay: Bool = {
                if case .capture = viewModel.appState {
                    return true
                }
                return false
            }()

            ReferenceImageView(
                imageUrl: imageUrl,
                onImageTap: handleReferenceImageTap,
                onImageLoaded: { cachedImage = $0 },
                showLoadingOverlay: showLoadingOverlay
            )
        }
    }

    @ViewBuilder
    private var instructionSheet: some View {
        if case .displayingInstructions(let currentIndex) = viewModel.appState {
            InstructionSheetView(
                instructions: viewModel.instructions,
                currentIndex: currentIndex,
                onStepTap: { index in
                    confettiTrigger += 1
                    viewModel.moveToInstruction(at: index)
                },
                onClose: viewModel.resetToScanning,
                selectedDetent: $selectedDetent,
                showChat: $showChat,
                stepNodeHeight: $stepNodeHeight,
                lightAngle: $motionService.lightAngle,
                tiltOffset: $motionService.tiltOffset
            )
            .presentationDetents([.height(validStepNodeHeight), .medium, .large], selection: $selectedDetent)
            .presentationBackgroundInteraction(.enabled)
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled(true)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        leadingToolbarItem
        trailingToolbarItem
    }

    @ToolbarContentBuilder
    private var leadingToolbarItem: some ToolbarContent {
        if capturedPhotoForDisplay != nil {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: cancelPhoto) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var trailingToolbarItem: some ToolbarContent {
        if capturedPhotoForDisplay != nil {
            if showPhotoActions {
                ToolbarItem(placement: .navigationBarTrailing) {
                    confirmPhotoButton
                }
            }
        } else {
            if case .scanning = viewModel.appState, hasDetectedGoodSign {
                ToolbarItem(placement: .navigationBarTrailing) {
                    plusButton
                }
            } else if viewModel.appState.isDisplayingInstructions {
                ToolbarItem(placement: .navigationBarTrailing) {
                    chatButton
                }
            }
        }
    }

    private var confirmPhotoButton: some View {
        Button(action: confirmPhoto) {
            Image(systemName: "checkmark")
                .font(.system(size: 18))
                .foregroundColor(Color("AppCyan"))
                .symbolRenderingMode(.hierarchical)
        }
    }

    private var plusButton: some View {
        Button(action: handlePlusButton) {
            Image(systemName: "plus")
                .font(.system(size: 18))
                .foregroundColor(.white)
        }
    }

    private var chatButton: some View {
        Button(action: { showChat = true }) {
            Image(systemName: "message")
                .font(.system(size: 18))
                .foregroundColor(.white)
        }
    }

    // MARK: - Actions

    private func setupCamera() {
        viewModel.scannerService = scannerService
        DispatchQueue.main.async {
            scannerService.setRectOfInterest(screenSize: UIScreen.main.bounds.size)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            scannerService.startScanning()
        }
    }

    private func handleQRCodeScanned(_ oldValue: String?, _ newValue: String?) {
        if let qrCode = newValue {
            viewModel.handleQRCodeDetected(qrCode: qrCode)
            scannerService.scannedCode = nil
        }
    }

    private func handlePhotoCapture(_ oldValue: UIImage?, _ newImage: UIImage?) {
        guard let image = newImage else { return }

        capturedPhotoForDisplay = image
        photoScale = 1.0

        // 撮影した写真をcapturedPhotosに追加
        capturedPhotos.append(.image(image))

        Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.5)) {
                photoScale = 0.6
            }

            try? await Task.sleep(nanoseconds: 500_000_000)
            rippleCounter += 1

            try? await Task.sleep(nanoseconds: 500_000_000)

            // チュートリアル中（.scanning状態 + グッドサイン未検出）の場合、グッドサイン検出を実行
            if case .scanning = viewModel.appState, !hasDetectedGoodSign {
                do {
                    let isGoodSign = try await GoodSignDetectionService.detectGoodSign(in: image)

                    if isGoodSign {
                        print("✅ Good sign detected!")
                        hasDetectedGoodSign = true
                        OnboardingService.completeGoodSignDetection()
                        confettiTrigger += 1

                        // 写真を消すアニメーション
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            photoScale = 0
                        }
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        capturedPhotoForDisplay = nil
                        photoScale = 1.0
                    } else {
                        print("❌ Good sign not detected, showing retry button")
                        showPhotoActions = true
                    }
                } catch {
                    print("❌ Good sign detection failed: \(error)")
                    showPhotoActions = true
                }
            } else {
                // 通常モード（手順表示中 or グッドサイン検出済み）
                showPhotoActions = true
            }
        }
    }

    private func handleLongPress(point: CGPoint?) {
        if let point = point {
            rippleOrigin = point
            viewModel.capturePhoto()
        }
    }

    private func handleReferenceImageTap() {
        guard let image = cachedImage else { return }

        capturedPhotoForDisplay = image
        photoScale = 1.0

        Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.5)) {
                photoScale = 0.6
            }

            try? await Task.sleep(nanoseconds: 500_000_000)
            rippleOrigin = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            rippleCounter += 1
        }
    }

    private func cancelPhoto() {
        showPhotoActions = false

        Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.3)) {
                photoScale = 0
            }

            try? await Task.sleep(nanoseconds: 300_000_000)
            capturedPhotoForDisplay = nil
            photoScale = 1.0
        }
    }

    private func handleRecognitionResult(_ oldValue: RecognitionResult?, _ newValue: RecognitionResult?) {
        guard let result = newValue else { return }

        Task { @MainActor in
            switch result {
            case .success:
                // Success: ポップに消えて花吹雪
                try? await Task.sleep(nanoseconds: 400_000_000)

                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    photoScale = 0.75
                }

                try? await Task.sleep(nanoseconds: 300_000_000)

                confettiTrigger += 1

                withAnimation(.easeOut(duration: 0.4)) {
                    photoScale = 0
                }

                try? await Task.sleep(nanoseconds: 600_000_000)
                capturedPhotoForDisplay = nil
                photoScale = 1.0
                photoRotation = 0
                photoOffset = 0

            case .failed:
                // Failed: カッコンと傾いて落ちる
                try? await Task.sleep(nanoseconds: 200_000_000)

                withAnimation(.easeIn(duration: 0.2)) {
                    photoRotation = -15
                }

                try? await Task.sleep(nanoseconds: 150_000_000)

                withAnimation(.easeOut(duration: 0.8)) {
                    photoRotation = -25
                    photoOffset = 1200
                    photoScale = 0.8
                }

                try? await Task.sleep(nanoseconds: 1_200_000_000)
                capturedPhotoForDisplay = nil
                photoScale = 1.0
                photoRotation = 0
                photoOffset = 0
            }

            viewModel.recognitionResult = nil
        }
    }

    private func confirmPhoto() {
        guard let image = capturedPhotoForDisplay else { return }

        showPhotoActions = false

        let currentIndex: Int
        if case .displayingInstructions(let index) = viewModel.appState {
            currentIndex = index
        } else {
            return
        }

        viewModel.appState = .capture

        Task { @MainActor in
            do {
                await viewModel.handleCapturedImage(image)

                withAnimation(.easeInOut(duration: 0.3)) {
                    photoScale = 0
                }

                try? await Task.sleep(nanoseconds: 300_000_000)
                capturedPhotoForDisplay = nil
                photoScale = 1.0

                if case .displayingInstructions(let newIndex) = viewModel.appState, newIndex > currentIndex {
                    confettiTrigger += 1
                }
            } catch {
                viewModel.errorMessage = "画像認識に失敗しました"
                viewModel.appState = .displayingInstructions(currentIndex: currentIndex)

                withAnimation(.easeInOut(duration: 0.3)) {
                    photoScale = 0
                }

                try? await Task.sleep(nanoseconds: 300_000_000)
                capturedPhotoForDisplay = nil
                photoScale = 1.0
            }
        }
    }

    private func handlePlusButton() {
        showManualCreation = true
    }
}

#Preview {
    CameraView(viewModel: .init())
}
