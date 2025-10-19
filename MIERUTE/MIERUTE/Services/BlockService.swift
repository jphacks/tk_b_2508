//
//  BlockService.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import Foundation

enum BlockService {
    private static let baseURL = "https://us-central1-mierute-c7b7f.cloudfunctions.net/api"

    static func fetchBlocks(projectId: String) async throws -> [Block] {
        guard let url = URL(string: "\(baseURL)/api/blocks/project/\(projectId)") else {
            throw BlockServiceError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BlockServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw BlockServiceError.httpError(statusCode: httpResponse.statusCode)
        }

        // デバッグ: レスポンスボディを確認
        if let responseString = String(data: data, encoding: .utf8) {
            print("📦 [BlockService] Response JSON: \(responseString)")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let blocks = try decoder.decode([Block].self, from: data)

        print("📦 Decoded \(blocks.count) blocks successfully")

        // 各ブロックの内容を確認
        for (index, block) in blocks.enumerated() {
            print("📦 Block[\(index)]: id=\(block.id)")
            print("   - checkpoint: \(block.checkpoint ?? "nil")")
            print("   - imageUrl: \(block.imageUrl ?? "nil")")
        }

        return blocks
    }

    static func fetchBlock(id: String) async throws -> Block {
        guard let url = URL(string: "\(baseURL)/api/blocks/\(id)") else {
            throw BlockServiceError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BlockServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw BlockServiceError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let block = try decoder.decode(Block.self, from: data)

        return block
    }
}

enum BlockServiceError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
}
