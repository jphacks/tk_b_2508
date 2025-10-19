//
//  Project.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import Foundation

struct Project: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
