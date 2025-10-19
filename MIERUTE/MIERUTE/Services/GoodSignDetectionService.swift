//
//  GoodSignDetectionService.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import UIKit
import Vision
import CoreML

enum GoodSignDetectionService {
    static func detectGoodSign(in image: UIImage) async throws -> Bool {
        guard let ciImage = CIImage(image: image) else {
            throw NSError(domain: "GoodSignDetectionService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert to CIImage"])
        }

        // Step 1: Detect hand pose keypoints
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 1

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([handPoseRequest])

                    guard let observation = handPoseRequest.results?.first else {
                        print("⚠️ No hand detected in image")
                        continuation.resume(returning: false)
                        return
                    }

                    // Step 2: Convert keypoints to MLMultiArray
                    let keypointsArray = try convertHandPoseToMLMultiArray(observation: observation)

                    // Step 3: Load model and classify
                    let config = MLModelConfiguration()
                    let mlModel = try GoodSignClassifier(configuration: config)

                    let input = GoodSignClassifierInput(poses: keypointsArray)
                    let output = try mlModel.prediction(input: input)

                    print("🤖 Good Sign Classification: \(output.label) (confidence: \(output.labelProbabilities[output.label] ?? 0.0))")

                    // Check if it's a "good sign"
                    let isGoodSign = output.label.lowercased().contains("good")

                    continuation.resume(returning: isGoodSign)
                } catch {
                    print("❌ Good sign detection failed: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private static func convertHandPoseToMLMultiArray(observation: VNHumanHandPoseObservation) throws -> MLMultiArray {
        // Create MLMultiArray with shape [1, 3, 21] (1 frame, 3 values (x, y, confidence), 21 keypoints)
        let array = try MLMultiArray(shape: [1, 3, 21], dataType: .float32)

        let allJoints: [VNHumanHandPoseObservation.JointName] = [
            .wrist,
            .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
            .indexMCP, .indexPIP, .indexDIP, .indexTip,
            .middleMCP, .middlePIP, .middleDIP, .middleTip,
            .ringMCP, .ringPIP, .ringDIP, .ringTip,
            .littleMCP, .littlePIP, .littleDIP, .littleTip
        ]

        for (index, jointName) in allJoints.enumerated() {
            if let point = try? observation.recognizedPoint(jointName) {
                // x coordinate
                array[[0, 0, index] as [NSNumber]] = NSNumber(value: point.location.x)
                // y coordinate
                array[[0, 1, index] as [NSNumber]] = NSNumber(value: point.location.y)
                // confidence
                array[[0, 2, index] as [NSNumber]] = NSNumber(value: point.confidence)
            } else {
                // If point not found, set all to 0
                array[[0, 0, index] as [NSNumber]] = 0
                array[[0, 1, index] as [NSNumber]] = 0
                array[[0, 2, index] as [NSNumber]] = 0
            }
        }

        return array
    }
}
