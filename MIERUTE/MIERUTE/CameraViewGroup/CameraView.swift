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
    @State private var longPressTask: Task<Void, Never>?
    @State private var capturedPhotoForDisplay: UIImage?
    @State private var showPhotoActions: Bool = false
    @State private var photoScale: CGFloat = 1.0
    @State private var stepNodeHeight: CGFloat = 130
    @State private var cachedImage: UIImage?
    @State private var confettiTrigger: Int = 0

    private var validStepNodeHeight: CGFloat {
        max(stepNodeHeight, 130)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                cameraPreviewLayer

                if let photo = capturedPhotoForDisplay {
                    CapturedPhotoOverlay(
                        photo: photo,
                        photoScale: $photoScale,
                        rippleCounter: $rippleCounter,
                        rippleOrigin: $rippleOrigin
                    )
                }

                overlayContent
                longPressGestureArea
                referenceImageView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .confettiCannon(counter: $confettiTrigger, num: 50, confettiSize: 20, rainHeight: 800, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 600, repetitions: 1, repetitionInterval: 0.5)
            .onAppear(perform: setupCamera)
            .onDisappear { scannerService.stopScanning() }
            .onChange(of: scannerService.scannedCode, handleQRCodeScanned)
            .onChange(of: scannerService.capturedImage, handlePhotoCapture)
            .sheet(isPresented: .constant(viewModel.appState.isDisplayingInstructions)) {
                instructionSheet
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
                QRScannerOverlay()
                    .allowsHitTesting(false)
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
            if !showPhotoActions {
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
        if capturedPhotoForDisplay != nil {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: cancelPhoto) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .symbolRenderingMode(.hierarchical)
                }
            }

            if showPhotoActions {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: confirmPhoto) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }

            if !showPhotoActions && viewModel.appState.isDisplayingInstructions {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showChat = true }) {
                        Image(systemName: "message")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }
            }
        } else if viewModel.appState.isDisplayingInstructions {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showChat = true }) {
                    Image(systemName: "message")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
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

        Task { @MainActor in
            withAnimation(.easeInOut(duration: 0.5)) {
                photoScale = 0.6
            }

            try? await Task.sleep(nanoseconds: 500_000_000)
            rippleCounter += 1

            try? await Task.sleep(nanoseconds: 500_000_000)
            showPhotoActions = true
        }
    }

    private func handleLongPress(point: CGPoint?) {
        if let point = point {
            rippleOrigin = point
            longPressTask?.cancel()

            longPressTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                viewModel.capturePhoto()
            }
        } else {
            longPressTask?.cancel()
            longPressTask = nil
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
}

#Preview {
    CameraView(viewModel: .init())
}
