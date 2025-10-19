//
//  QRCodeScannerService.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import AVFoundation
import SwiftUI
import Combine

class QRCodeScannerService: NSObject, ObservableObject {
    @Published var scannedCode: String?
    @Published var capturedImage: UIImage?

    private var captureSession: AVCaptureSession?
    private let metadataOutput = AVCaptureMetadataOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private var cachedPreviewLayer: AVCaptureVideoPreviewLayer?

    override init() {
        super.init()
        setupCaptureSession()
    }

    deinit {
        stopScanning()
        captureSession = nil
        cachedPreviewLayer = nil
    }

    private func setupCaptureSession() {
        let session = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get video capture device")
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Failed to create video input: \(error)")
            return
        }

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            print("Could not add video input")
            return
        }

        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Could not add metadata output")
            return
        }

        // Add photo output for capturing photos
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        } else {
            print("Could not add photo output")
        }

        self.captureSession = session
    }

    func setRectOfInterest(screenSize: CGSize) {
        // 300x300の四角形を画面中央に配置
        let scanAreaSize: CGFloat = 300
        let x = (screenSize.width - scanAreaSize) / 2
        let y = (screenSize.height - scanAreaSize) / 2

        // 画面座標からビデオ座標に変換（0-1の範囲）
        // rectOfInterestは (x, y, width, height) で、座標系が90度回転している
        let videoWidth = screenSize.height
        let videoHeight = screenSize.width

        let rectX = y / videoWidth
        let rectY = x / videoHeight
        let rectWidth = scanAreaSize / videoWidth
        let rectHeight = scanAreaSize / videoHeight

        metadataOutput.rectOfInterest = CGRect(
            x: rectX,
            y: rectY,
            width: rectWidth,
            height: rectHeight
        )
    }

    func startScanning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    func stopScanning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }

    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        if let cachedLayer = cachedPreviewLayer {
            return cachedLayer
        }

        guard let captureSession = captureSession else { return nil }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        cachedPreviewLayer = previewLayer
        return previewLayer
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension QRCodeScannerService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            scannedCode = stringValue
        }
    }
}

extension QRCodeScannerService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Failed to convert photo to UIImage")
            return
        }

        DispatchQueue.main.async {
            self.capturedImage = image
            // Provide haptic feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
