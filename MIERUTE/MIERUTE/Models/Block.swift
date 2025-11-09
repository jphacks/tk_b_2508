//
//  Block.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import Foundation

struct Block: Codable, Identifiable {
    let id: String
    let checkpoint: String?
    let achievement: String?
    let projectId: String?
    let imageUrl: String?
    let highlightColor: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case checkpoint
        case achievement
        case projectId
        case imageUrl
        case highlightColor
        case createdAt
        case updatedAt
    }

    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
