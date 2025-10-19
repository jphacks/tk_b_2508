//
//  MotionService.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import Foundation
import CoreMotion
import Combine

@MainActor
final class MotionService: ObservableObject {
    @Published var lightAngle: Double = .pi / 4
    @Published var tiltOffset: Double = 0.0

    private let motionManager = CMMotionManager()
    private var smoothedTiltOffset: Double = 0.0
    private let smoothingFactor: Double = 0.15 // 0に近いほど滑らか（遅い）、1に近いほど反応が速い

    init() {
        startMotionUpdates()
    }

    deinit {
        motionManager.stopDeviceMotionUpdates()
    }

    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Device motion not available")
            return
        }

        // 更新間隔を短くして滑らかに
        motionManager.deviceMotionUpdateInterval = 0.02 // 50Hz
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }

            // デバイスの傾きから光の角度を計算
            let roll = motion.attitude.roll
            let pitch = motion.attitude.pitch

            // rollとpitchから角度を計算（atan2で方向を取得）
            let angle = atan2(pitch, roll)

            self.lightAngle = angle

            // 傾きオフセットを計算（-1から1の範囲）
            // rollとpitchの合成値を使用
            let combinedTilt = (roll + pitch) / 2.0
            // -π/4 から π/4 の範囲を -1 から 1 にマッピング
            let maxTilt = Double.pi / 4.0
            let rawOffset = max(-1.0, min(1.0, combinedTilt / maxTilt))

            // 指数移動平均で平滑化（Exponential Moving Average）
            self.smoothedTiltOffset = self.smoothedTiltOffset * (1.0 - self.smoothingFactor) + rawOffset * self.smoothingFactor
            self.tiltOffset = self.smoothedTiltOffset
        }
    }
}
