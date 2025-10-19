//
//  ImageRecognitionService.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import Foundation
import UIKit

enum ImageRecognitionService {
    private static let baseURL = "https://us-central1-mierute-c7b7f.cloudfunctions.net/api"
    private static let endpoint = "/api/image-recognition"

    static func recognizeImage(blockId: String, userImageUrl: String, referenceImageUrl: String?) async throws -> ImageRecognitionResponse {
        print("🔍 [ImageRecognition] Starting image recognition with URL")
        print("🔍 [ImageRecognition] Block ID: \(blockId)")
        print("🔍 [ImageRecognition] User Image URL: \(userImageUrl)")
        print("🔍 [ImageRecognition] Reference Image URL: \(referenceImageUrl ?? "nil")")

        // リクエストURLを構築
        guard let url = URL(string: baseURL + endpoint) else {
            print("❌ [ImageRecognition] Invalid URL: \(baseURL + endpoint)")
            throw ImageRecognitionError.invalidURL
        }
        print("🔍 [ImageRecognition] Request URL: \(url.absoluteString)")

        // JSONボディを作成
        var requestBody: [String: Any] = [
            "block_id": blockId,
            "image_url": userImageUrl
        ]

        // 参照画像URLがあれば追加
        if let referenceImageUrl = referenceImageUrl {
            requestBody["reference_image_url"] = referenceImageUrl
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ [ImageRecognition] Failed to create JSON data")
            throw ImageRecognitionError.invalidImage
        }

        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("🔍 [ImageRecognition] Request body: \(jsonString)")
        }

        // URLRequestを構築
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData

        // API呼び出し
        print("🔍 [ImageRecognition] Sending request to API...")
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        print("🔍 [ImageRecognition] Received response")

        // レスポンスを確認
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [ImageRecognition] Invalid response type")
            throw ImageRecognitionError.invalidResponse
        }

        print("🔍 [ImageRecognition] Status code: \(httpResponse.statusCode)")
        print("🔍 [ImageRecognition] Response headers: \(httpResponse.allHeaderFields)")
        print("🔍 [ImageRecognition] Response data size: \(data.count) bytes")

        // レスポンスボディを文字列として表示
        if let responseString = String(data: data, encoding: .utf8) {
            print("🔍 [ImageRecognition] Response body: \(responseString)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ [ImageRecognition] HTTP Error - Status code: \(httpResponse.statusCode)")
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ [ImageRecognition] Error response body: \(errorString)")
            }
            throw ImageRecognitionError.httpError(statusCode: httpResponse.statusCode)
        }

        // レスポンスをデコード
        print("🔍 [ImageRecognition] Decoding response...")
        let decoder = JSONDecoder()
        do {
            let recognitionResponse = try decoder.decode(ImageRecognitionResponse.self, from: data)
            print("✅ [ImageRecognition] Successfully decoded response")
            print("✅ [ImageRecognition] Success: \(recognitionResponse.success)")
            if let nextBlockId = recognitionResponse.blockId {
                print("✅ [ImageRecognition] Next block ID: \(nextBlockId)")
            } else {
                print("✅ [ImageRecognition] No next block ID (possibly last block)")
            }
            return recognitionResponse
        } catch {
            print("❌ [ImageRecognition] Decoding error: \(error)")
            throw ImageRecognitionError.decodingError
        }
    }
}

enum ImageRecognitionError: Error {
    case invalidURL
    case invalidImage
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
}
