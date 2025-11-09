//
//  FoundationModelsService.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/29.
//

import Foundation

// MARK: - Tool Result Models

struct ExternalAIResult: Codable {
    let response: String
    let source: String
}

// MARK: - Foundation Models Service

enum FoundationModelsService {

    /// メッセージに応答する（Foundation ModelsまたはChatGPT APIを使い分け）
    static func respond(to userText: String, conversationHistory: [ChatMessage]) async throws -> String {

        // Foundation Modelsで判断させる
        // ツール: ChatGPT APIを呼び出す機能を提供
        let externalAITool = createExternalAITool(conversationHistory: conversationHistory)

        // Foundation Modelsに問い合わせ
        // NOTE: iOS 18以降のApple Intelligence APIを使用することを想定
        // 実際の実装では、Apple's Foundation Modelsを使用する必要があります
        //
        // システムプロンプト（将来の実装用）:
        // "あなたは製品マニュアルのアシスタントです。
        // 一般的な挨拶や簡単な質問には直接応答し、
        // 製品の使い方や技術的な詳細は 'callExternalAI' ツールを使用してください。"

        // 現時点ではモック実装として、簡単なルールベースで判定
        let response = try await processWithRuleBasedApproach(
            userText: userText,
            conversationHistory: conversationHistory,
            externalAITool: externalAITool
        )

        return response
    }

    // MARK: - Private Methods

    /// ChatGPT APIを呼び出すツールを作成
    private static func createExternalAITool(conversationHistory: [ChatMessage]) -> (String) async throws -> ExternalAIResult {
        return { query in
            print("🔧 [Tool] Calling External AI for query: \(query)")

            // AIServiceの既存のメソッドを使用
            let response = try await AIService.generateResponse(
                for: query,
                conversationHistory: conversationHistory
            )

            return ExternalAIResult(
                response: response,
                source: "ChatGPT API"
            )
        }
    }

    /// ルールベースのアプローチ（Foundation Modelsの代替実装）
    /// 実際のプロダクションでは、Apple's Foundation Modelsを使用する
    private static func processWithRuleBasedApproach(
        userText: String,
        conversationHistory: [ChatMessage],
        externalAITool: (String) async throws -> ExternalAIResult
    ) async throws -> String {

        let lowerText = userText.lowercased()

        // 簡単な挨拶パターン
        let greetingPatterns = ["こんにちは", "おはよう", "こんばんは", "やあ", "はじめまして"]
        let thanksPatterns = ["ありがとう", "感謝", "助かり"]
        let simpleQuestions = ["元気", "調子"]

        // 挨拶への応答
        if greetingPatterns.contains(where: { lowerText.contains($0) }) {
            print("✅ [Foundation Models] Simple greeting detected")
            return "こんにちは！何かお手伝いできることはありますか？"
        }

        // 感謝への応答
        if thanksPatterns.contains(where: { lowerText.contains($0) }) {
            print("✅ [Foundation Models] Thanks pattern detected")
            return "どういたしまして！他に何かお手伝いできることがあれば、お気軽にお申し付けください。"
        }

        // 元気かどうかの質問
        if simpleQuestions.contains(where: { lowerText.contains($0) }) {
            print("✅ [Foundation Models] Simple question detected")
            return "はい、調子は良好です！あなたはいかがですか？何かお手伝いできることはありますか？"
        }

        // それ以外は外部AIツールを呼び出す
        print("🔄 [Foundation Models] Complex query detected, calling external AI tool")
        let result = try await externalAITool(userText)

        print("✅ [Tool Result] Response from \(result.source)")
        return result.response
    }
}

// MARK: - Advanced Foundation Models Integration (Future Implementation)

/*

 実際のApple Foundation Modelsを使用する場合の実装例：

 import NaturalLanguage

 extension FoundationModelsService {

     static func processWithAppleIntelligence(
         userText: String,
         conversationHistory: [ChatMessage],
         tools: [AITool]
     ) async throws -> String {

         // Apple's Foundation Models APIを使用
         // iOS 18以降で利用可能

         let request = NLContextualEmbedding.create(
             text: userText,
             context: conversationHistory.map { $0.content }
         )

         // ツール呼び出しの判定
         let shouldUseTool = try await request.shouldCallTool(
             tools: tools,
             threshold: 0.7
         )

         if shouldUseTool {
             // 外部AIツールを呼び出し
             let toolResult = try await tools.first?.execute(userText)
             return toolResult?.response ?? "応答を生成できませんでした"
         } else {
             // Foundation Modelsで直接応答
             return try await request.generateResponse()
         }
     }
 }

 */
