//
//  ImageRecognitionResponse.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import Foundation

struct ImageRecognitionResponse: Codable {
    let success: Bool
    let blockId: String?

    enum CodingKeys: String, CodingKey {
        case success
        case blockId = "block_id"
    }
}
