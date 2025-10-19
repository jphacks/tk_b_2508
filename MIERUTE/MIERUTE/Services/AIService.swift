//
//  AIService.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import Foundation

enum AIService {
    private static func getAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let apiKey = plist["OPENAI_API_KEY"] as? String else {
            return nil
        }
        return apiKey
    }

    static func generateResponse(for message: String, conversationHistory: [ChatMessage]) async throws -> String {
        return try await generateWithGPT(message: message, history: conversationHistory)
    }

    private static func generateWithGPT(message: String, history: [ChatMessage]) async throws -> String {
        print("🤖 Using GPT API for message: \(message)")

        guard let apiKey = getAPIKey() else {
            print("❌ OpenAI API key not found in Info.plist")
            throw NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "API key not configured"])
        }

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 会話履歴を構築
        var messages: [[String: String]] = [
            [
                "role": "system",
                "content": "あなたは製品マニュアルのアシスタントです。ユーザーの質問に対して、わかりやすく丁寧に日本語で回答してください。"
            ]
        ]

        // 最新5件の会話履歴を含める
        for msg in history.suffix(5) {
            messages.append([
                "role": msg.isUser ? "user" : "assistant",
                "content": msg.content
            ])
        }

        messages.append([
            "role": "user",
            "content": message
        ])

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "max_tokens": 1000,
            "temperature": 0.7
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ OpenAI API error (\(httpResponse.statusCode)): \(errorMessage)")
            throw NSError(domain: "AIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API request failed: \(errorMessage)"])
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let messageDict = firstChoice["message"] as? [String: Any],
              let content = messageDict["content"] as? String else {
            throw NSError(domain: "AIService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }

        print("✅ GPT response generated successfully")
        return content
    }
}
