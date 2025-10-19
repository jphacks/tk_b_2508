import Foundation
import Combine
import PlaygroundSupport

// MARK: - Models

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

struct Instruction {
    let id: String
    let title: String
    let description: String
    let order: Int
    let nextNodeId: String?
    let previousNodeId: String?
}

// MARK: - AI Response Logic (Simplified for Playground)

class AIAssistantPlayground {
    var currentInstruction: Instruction?

    func generateIntelligentResponse(for query: String) -> String {
        let lowercasedQuery = query.lowercased()

        if lowercasedQuery.contains("手順") || lowercasedQuery.contains("やり方") {
            return "現在の手順は「\(currentInstruction?.description ?? "なし")」です。画面に表示されている指示に従って進めてください。"
        } else if lowercasedQuery.contains("次") || lowercasedQuery.contains("進") {
            return "画面下部のボタンで次の手順に進むことができます。現在の手順を完了してから次に進んでください。"
        } else if lowercasedQuery.contains("戻") || lowercasedQuery.contains("前") {
            return "前の手順に戻るには、画面下部の戻るボタンを使用してください。"
        } else if lowercasedQuery.contains("確認") || lowercasedQuery.contains("写真") {
            return "写真撮影ボタンで現在の作業状態を記録できます。撮影した画像を私が分析することもできます。"
        } else if lowercasedQuery.contains("ヘルプ") || lowercasedQuery.contains("help") {
            return "以下のことができます:\n・現在の手順の確認\n・次の手順への進め方\n・前の手順への戻り方\n・写真撮影による記録\n・画像の分析"
        } else {
            return "ご質問ありがとうございます。手順の実行をサポートいたします。何か具体的にお困りのことはありますか？"
        }
    }

    func setCurrentInstruction(_ instruction: Instruction) {
        currentInstruction = instruction
        print("✅ 現在の手順を設定: \(instruction.description)")
    }
}

// MARK: - テストケース

print("=== AIアシスタント Playground テスト ===\n")

let assistant = AIAssistantPlayground()

// テスト用の手順を設定
let testInstruction = Instruction(
    id: "1",
    title: "ステップ1",
    description: "製品の箱を開けてください",
    order: 0,
    nextNodeId: "2",
    previousNodeId: nil
)

assistant.setCurrentInstruction(testInstruction)

print("\n--- テストケース1: 手順について質問 ---")
let query1 = "現在の手順を教えて"
let response1 = assistant.generateIntelligentResponse(for: query1)
print("質問: \(query1)")
print("回答: \(response1)\n")

print("--- テストケース2: 次の手順への進め方 ---")
let query2 = "次に進むにはどうすればいい？"
let response2 = assistant.generateIntelligentResponse(for: query2)
print("質問: \(query2)")
print("回答: \(response2)\n")

print("--- テストケース3: 前の手順への戻り方 ---")
let query3 = "前の手順に戻りたい"
let response3 = assistant.generateIntelligentResponse(for: query3)
print("質問: \(query3)")
print("回答: \(response3)\n")

print("--- テストケース4: 写真撮影について ---")
let query4 = "写真で確認できる？"
let response4 = assistant.generateIntelligentResponse(for: query4)
print("質問: \(query4)")
print("回答: \(response4)\n")

print("--- テストケース5: ヘルプ ---")
let query5 = "ヘルプ"
let response5 = assistant.generateIntelligentResponse(for: query5)
print("質問: \(query5)")
print("回答: \(response5)\n")

print("--- テストケース6: 一般的な質問 ---")
let query6 = "これはどう使うの？"
let response6 = assistant.generateIntelligentResponse(for: query6)
print("質問: \(query6)")
print("回答: \(response6)\n")

print("=== テスト完了 ===")

// MARK: - メッセージフロー確認

print("\n=== メッセージフローテスト ===\n")

var messages: [AIMessage] = []

// ウェルカムメッセージ
let welcomeMessage = AIMessage(
    content: "こんにちは！作業手順のサポートをいたします。ご質問や確認したいことがあればお気軽にお聞きください。",
    isUser: false
)
messages.append(welcomeMessage)
print("🤖 AI: \(welcomeMessage.content)\n")

// ユーザーからの質問
let userQuestion1 = AIMessage(content: "手順を教えて", isUser: true)
messages.append(userQuestion1)
print("👤 User: \(userQuestion1.content)")

let aiResponse1 = AIMessage(
    content: assistant.generateIntelligentResponse(for: userQuestion1.content),
    isUser: false
)
messages.append(aiResponse1)
print("🤖 AI: \(aiResponse1.content)\n")

// 2つ目の質問
let userQuestion2 = AIMessage(content: "次に進むには？", isUser: true)
messages.append(userQuestion2)
print("👤 User: \(userQuestion2.content)")

let aiResponse2 = AIMessage(
    content: assistant.generateIntelligentResponse(for: userQuestion2.content),
    isUser: false
)
messages.append(aiResponse2)
print("🤖 AI: \(aiResponse2.content)\n")

print("📊 合計メッセージ数: \(messages.count)")
print("👤 ユーザーメッセージ: \(messages.filter { $0.isUser }.count)")
print("🤖 AIメッセージ: \(messages.filter { !$0.isUser }.count)")

print("\n=== すべてのテスト完了 ===")

PlaygroundPage.current.finishExecution()
