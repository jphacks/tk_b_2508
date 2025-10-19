//
//  FirebaseStorageService.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import Foundation
import UIKit

// MARK: - Firebase Storage Service
// Note: Requires Firebase SDK to be installed via SPM
// Add the following package: https://github.com/firebase/firebase-ios-sdk
// Required: FirebaseStorage

#if canImport(FirebaseStorage)
import FirebaseStorage

enum FirebaseStorageService {
    static func uploadImage(_ image: UIImage) async throws -> String {
        print("📤 [FirebaseStorage] Starting image upload")
        print("📤 [FirebaseStorage] Image size: \(image.size)")

        // 画像をJPEGデータに変換
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ [FirebaseStorage] Failed to convert image to JPEG data")
            throw FirebaseStorageError.invalidImage
        }
        print("📤 [FirebaseStorage] Image data size: \(imageData.count) bytes (\(Double(imageData.count) / 1024.0 / 1024.0) MB)")

        // ストレージのリファレンスを作成
        let storage = Storage.storage()
        let storageRef = storage.reference()

        // ファイル名を生成（タイムスタンプ + UUID）
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "images/\(timestamp)_\(UUID().uuidString).jpg"
        print("📤 [FirebaseStorage] File name: \(fileName)")
        let imageRef = storageRef.child(fileName)

        // メタデータを設定
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        print("📤 [FirebaseStorage] Metadata content type: image/jpeg")

        // アップロード
        print("📤 [FirebaseStorage] Uploading to Firebase Storage...")
        do {
            let _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
            print("✅ [FirebaseStorage] Upload completed successfully")
        } catch {
            print("❌ [FirebaseStorage] Upload failed: \(error)")
            throw FirebaseStorageError.uploadFailed
        }

        // ダウンロードURLを取得
        print("📤 [FirebaseStorage] Fetching download URL...")
        do {
            let downloadURL = try await imageRef.downloadURL()
            print("✅ [FirebaseStorage] Download URL retrieved: \(downloadURL.absoluteString)")
            return downloadURL.absoluteString
        } catch {
            print("❌ [FirebaseStorage] Failed to get download URL: \(error)")
            throw FirebaseStorageError.uploadFailed
        }
    }

    static func downloadImage(from urlString: String) async throws -> UIImage {
        print("📥 [FirebaseStorage] Starting image download")
        print("📥 [FirebaseStorage] URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ [FirebaseStorage] Invalid URL")
            throw FirebaseStorageError.invalidURL
        }

        print("📥 [FirebaseStorage] Downloading image data...")
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("❌ [FirebaseStorage] Download failed with invalid response")
            throw FirebaseStorageError.downloadFailed
        }

        print("📥 [FirebaseStorage] Downloaded \(data.count) bytes")

        guard let image = UIImage(data: data) else {
            print("❌ [FirebaseStorage] Failed to create UIImage from data")
            throw FirebaseStorageError.invalidImage
        }

        print("✅ [FirebaseStorage] Image download successful")
        return image
    }
}

enum FirebaseStorageError: Error {
    case invalidImage
    case uploadFailed
    case downloadFailed
    case invalidURL
}

#else

// Firebase Storage not available - mock implementation
enum FirebaseStorageService {
    static func uploadImage(_ image: UIImage) async throws -> String {
        // Mock implementation - returns a placeholder URL
        print("⚠️ Firebase Storage not configured. Using mock URL.")
        return "https://example.com/mock-image-url.jpg"
    }

    static func downloadImage(from urlString: String) async throws -> UIImage {
        print("⚠️ Firebase Storage not configured. Using placeholder image.")
        throw FirebaseStorageError.firebaseNotConfigured
    }
}

enum FirebaseStorageError: Error {
    case invalidImage
    case uploadFailed
    case downloadFailed
    case invalidURL
    case firebaseNotConfigured
}

#endif
