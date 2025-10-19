//
//  ChatMessage.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import Foundation

struct ChatMessage: Identifiable {
    let id: String
    let content: String
    let isUser: Bool
    let timestamp: Date
}
