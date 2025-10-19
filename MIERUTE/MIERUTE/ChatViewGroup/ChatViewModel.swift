//
//  ChatViewModel.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false

    init() {
        // 初期メッセージを追加
        messages.append(ChatMessage(
            id: UUID().uuidString,
            content: "こんにちは！何かお手伝いできることはありますか？",
            isUser: false,
            timestamp: Date()
        ))
    }

    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = ChatMessage(
            id: UUID().uuidString,
            content: inputText,
            isUser: true,
            timestamp: Date()
        )

        messages.append(userMessage)
        let currentInput = inputText
        inputText = ""
        isLoading = true

        // AIの応答を生成
        Task {
            do {
                let aiResponse = try await AIService.generateResponse(
                    for: currentInput,
                    conversationHistory: messages
                )

                let aiMessage = ChatMessage(
                    id: UUID().uuidString,
                    content: aiResponse,
                    isUser: false,
                    timestamp: Date()
                )

                messages.append(aiMessage)
            } catch {
                print("❌ AI response generation failed: \(error)")

                // エラー時のフォールバック応答
                let errorMessage = ChatMessage(
                    id: UUID().uuidString,
                    content: "申し訳ございません。ただいま応答できません。もう一度お試しください。",
                    isUser: false,
                    timestamp: Date()
                )
                messages.append(errorMessage)
            }

            isLoading = false
        }
    }
}
