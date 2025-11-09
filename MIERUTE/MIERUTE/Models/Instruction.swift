//
//  Instruction.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import Foundation

struct Instruction: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
    var order: Int
    var nextNodeId: String?
    var previousNodeId: String?
    var imageUrl: String?
    var highlightColor: String?

    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }
}

struct InstructionSet: Codable {
    let id: String
    let name: String
    let instructions: [Instruction]

    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
