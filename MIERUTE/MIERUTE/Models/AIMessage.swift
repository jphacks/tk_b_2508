//
//  AIMessage.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import Foundation

struct AIMessage: Identifiable {
    let id: String
    let content: String
    let isUser: Bool
    let timestamp: Date

    init(id: String = UUID().uuidString, content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}
