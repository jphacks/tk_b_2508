//
//  CameraViewModel.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import Foundation
import Combine
import UIKit

@MainActor
final class CameraViewModel: ObservableObject {
    @Published var appState: AppState = .loading
    @Published var instructions: [Instruction] = []
    @Published var errorMessage: String?

    private var currentInstructionIndex: Int = 0
    private var cancellables = Set<AnyCancellable>()
    var scannerService: QRCodeScannerService?

    // 固定のプロジェクトID
    private let defaultProjectId = "vQxQsGgzeEDUt5I45oBv"

    init() {
        // 初期状態はスキャニングモード（手順なし）
        self.instructions = []
        self.appState = .scanning
    }

    private func loadInstructionsFromAPI() async {
        print("📡 Loading instructions from API for project: \(defaultProjectId)")

        // ローディング状態を明示的に設定
        self.appState = .loading

        do {
            // BlockServiceを使ってプロジェクトのブロックを取得
            let blocks = try await BlockService.fetchBlocks(projectId: defaultProjectId)
            print("✅ Fetched \(blocks.count) blocks from API")

            // BlockをInstructionに変換
            let fetchedInstructions = blocks.enumerated().compactMap { (index, block) -> Instruction? in
                // checkpointが必須、achievementはオプショナル
                guard let checkpoint = block.checkpoint else {
                    print("⚠️ Skipping block \(block.id) - missing checkpoint")
                    return nil
                }

                // descriptionを作成（achievementがあれば追加）
                var description = checkpoint
                if let achievement = block.achievement {
                    description += "\n達成条件: \(achievement)"
                }

                // imageUrlがある場合はログ出力
                if let imageUrl = block.imageUrl, !imageUrl.isEmpty {
                    print("📷 Block \(block.id) has image URL: \(imageUrl)")
                } else {
                    print("⚠️ Block \(block.id) has no image URL")
                }

                return Instruction(
                    id: block.id,
                    title: "ステップ \(index + 1)",
                    description: description,
                    order: index,
                    nextNodeId: nil,
                    previousNodeId: nil,
                    imageUrl: block.imageUrl
                )
            }

            // orderでソート
            self.instructions = fetchedInstructions.sorted { $0.order < $1.order }
            self.currentInstructionIndex = 0
            self.appState = .displayingInstructions(currentIndex: 0)
            print("✅ Instructions loaded successfully - switching to displayingInstructions state")
            print("📊 Current state: \(self.appState)")
            print("📊 Instructions count: \(self.instructions.count)")
        } catch {
            print("❌ Failed to fetch instructions from API: \(error)")
            self.errorMessage = "手順書の取得に失敗しました"
            self.appState = .scanning
        }
    }

    // MARK: - Public Methods

    func handleQRCodeDetected(qrCode: String) {
        appState = .loading
        fetchInstructions(from: qrCode)
    }

    func moveToNextInstruction() {
        guard case .displayingInstructions(let currentIndex) = appState else { return }

        let nextIndex = currentIndex + 1
        if nextIndex < instructions.count {
            currentInstructionIndex = nextIndex
            appState = .displayingInstructions(currentIndex: nextIndex)
        }
    }

    func moveToPreviousInstruction() {
        guard case .displayingInstructions(let currentIndex) = appState else { return }

        let previousIndex = currentIndex - 1
        if previousIndex >= 0 {
            currentInstructionIndex = previousIndex
            appState = .displayingInstructions(currentIndex: previousIndex)
        }
    }

    func moveToInstruction(at index: Int) {
        guard index >= 0 && index < instructions.count else { return }
        currentInstructionIndex = index
        appState = .displayingInstructions(currentIndex: index)
    }

    func resetToScanning() {
        appState = .scanning
        instructions = []
        currentInstructionIndex = 0
        errorMessage = nil
    }

    func capturePhoto() {
        // 現在のインデックスを保存
        if case .displayingInstructions(let currentIndex) = appState {
            currentInstructionIndex = currentIndex
            print("📸 Capturing photo at instruction index: \(currentIndex)")
        }

        scannerService?.capturePhoto()
        print("Photo capturing...")
    }

    // MARK: - Public Methods for Image Recognition

    func handleCapturedImage(_ image: UIImage) async {
        print("📸 [ViewModel] handleCapturedImage called")
        print("📸 [ViewModel] Current instruction index: \(currentInstructionIndex)")
        print("📸 [ViewModel] Total instructions: \(instructions.count)")

        do {
            // 保存された currentInstructionIndex を使用
            guard currentInstructionIndex >= 0 && currentInstructionIndex < instructions.count else {
                print("❌ [ViewModel] Invalid instruction index: \(currentInstructionIndex)")
                errorMessage = "現在の手順が見つかりません"
                appState = .displayingInstructions(currentIndex: 0)
                scannerService?.capturedImage = nil
                return
            }

            let currentBlockId = instructions[currentInstructionIndex].id
            let referenceImageUrl = instructions[currentInstructionIndex].imageUrl
            print("📸 [ViewModel] Current block ID: \(currentBlockId)")
            print("📸 [ViewModel] Current instruction: \(instructions[currentInstructionIndex].title)")
            print("📸 [ViewModel] Reference image URL: \(referenceImageUrl ?? "nil")")

            // Step 1: Firebase Storageに画像をアップロード
            print("📤 [ViewModel] Uploading image to Firebase Storage...")
            let userImageUrl = try await FirebaseStorageService.uploadImage(image)
            print("✅ [ViewModel] Image uploaded successfully")
            print("✅ [ViewModel] User Image URL: \(userImageUrl)")

            // Step 2: 画像URLを使って画像認識APIを呼び出し
            print("📸 [ViewModel] Calling ImageRecognitionService.recognizeImage with URLs...")
            let response = try await ImageRecognitionService.recognizeImage(
                blockId: currentBlockId,
                userImageUrl: userImageUrl,
                referenceImageUrl: referenceImageUrl
            )

            print("✅ [ViewModel] Image recognition response received")
            print("✅ [ViewModel] Success: \(response.success)")
            if let nextBlockId = response.blockId {
                print("✅ [ViewModel] Next block ID: \(nextBlockId)")
            }

            // successフィールドをチェック
            guard response.success else {
                print("❌ [ViewModel] Recognition failed - success is false")
                errorMessage = "画像認識に失敗しました。もう一度お試しください"
                appState = .displayingInstructions(currentIndex: currentInstructionIndex)
                scannerService?.capturedImage = nil
                return
            }

            // 最後のブロックかどうかをチェック
            let isLastBlock = currentInstructionIndex == instructions.count - 1
            print("📸 [ViewModel] Is last block: \(isLastBlock)")

            if isLastBlock {
                // 最後のブロックで成功した場合、完了状態に移行
                print("✅ [ViewModel] Completed all instructions!")
                appState = .completed
            } else if let nextBlockId = response.blockId {
                // レスポンスのblock_idに対応するinstructionを探す
                if let nextIndex = instructions.firstIndex(where: { $0.id == nextBlockId }) {
                    // 次のブロックに移動
                    currentInstructionIndex = nextIndex
                    appState = .displayingInstructions(currentIndex: nextIndex)
                    print("✅ [ViewModel] Moved to instruction at index \(nextIndex)")
                    print("✅ [ViewModel] New instruction: \(instructions[nextIndex].title)")
                } else {
                    print("⚠️ [ViewModel] Block ID \(nextBlockId) not found in instructions")
                    print("⚠️ [ViewModel] Available block IDs: \(instructions.map { $0.id })")
                    errorMessage = "次の手順が見つかりません"
                    appState = .displayingInstructions(currentIndex: currentInstructionIndex)
                }
            } else {
                print("⚠️ [ViewModel] No next block ID provided")
                errorMessage = "次の手順情報が取得できませんでした"
                appState = .displayingInstructions(currentIndex: currentInstructionIndex)
            }

            // 処理完了後、capturedImageをクリア
            scannerService?.capturedImage = nil
            print("✅ [ViewModel] handleCapturedImage completed successfully")
        } catch let error as ImageRecognitionError {
            print("❌ [ViewModel] Image recognition failed with ImageRecognitionError")
            switch error {
            case .invalidURL:
                print("❌ [ViewModel] Error type: Invalid URL")
                errorMessage = "APIのURLが不正です"
            case .invalidImage:
                print("❌ [ViewModel] Error type: Invalid Image")
                errorMessage = "画像データが不正です"
            case .invalidResponse:
                print("❌ [ViewModel] Error type: Invalid Response")
                errorMessage = "APIからの応答が不正です"
            case .httpError(let statusCode):
                print("❌ [ViewModel] Error type: HTTP Error - Status code: \(statusCode)")
                errorMessage = "画像認識に失敗しました (エラーコード: \(statusCode))"
            case .decodingError:
                print("❌ [ViewModel] Error type: Decoding Error")
                errorMessage = "APIレスポンスの解析に失敗しました"
            }
            appState = .displayingInstructions(currentIndex: currentInstructionIndex)
            scannerService?.capturedImage = nil
        } catch let error as FirebaseStorageError {
            print("❌ [ViewModel] Firebase Storage upload failed")
            switch error {
            case .uploadFailed:
                print("❌ [ViewModel] Error type: Upload Failed")
                errorMessage = "画像のアップロードに失敗しました"
            case .invalidImage:
                print("❌ [ViewModel] Error type: Invalid Image")
                errorMessage = "画像データが不正です"
            case .downloadFailed:
                print("❌ [ViewModel] Error type: Download Failed")
                errorMessage = "画像のダウンロードに失敗しました"
            case .invalidURL:
                print("❌ [ViewModel] Error type: Invalid URL")
                errorMessage = "URLが不正です"
            }
            appState = .displayingInstructions(currentIndex: currentInstructionIndex)
            scannerService?.capturedImage = nil
        } catch {
            print("❌ [ViewModel] Image recognition failed with unexpected error: \(error)")
            print("❌ [ViewModel] Error description: \(error.localizedDescription)")
            errorMessage = "画像認識に失敗しました"
            appState = .displayingInstructions(currentIndex: currentInstructionIndex)
            scannerService?.capturedImage = nil
        }
    }

    private func loadMockInstructions() {
        // Mock data for initial display - 10 steps
        self.instructions = [
            Instruction(
                id: "1",
                title: "ステップ1",
                description: "製品の箱を開けてください",
                order: 0,
                nextNodeId: "2",
                previousNodeId: nil,
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/mierute-c7b7f.firebasestorage.app/o/blocks%2FKTiQZQLr1teo8vc6b7m4%2Fimages%2F1760837141451_e5dd7e47fcd14ef93c96fdc904788917.jpg?alt=media&token=586ecfa5-288a-40ca-a14c-02c13851e4da"
            ),
            Instruction(
                id: "2",
                title: "ステップ2",
                description: "本体を取り出してください",
                order: 1,
                nextNodeId: "3",
                previousNodeId: "1",
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/mierute-c7b7f.firebasestorage.app/o/blocks%2FKTiQZQLr1teo8vc6b7m4%2Fimages%2F1760837141451_e5dd7e47fcd14ef93c96fdc904788917.jpg?alt=media&token=586ecfa5-288a-40ca-a14c-02c13851e4da"
            ),
            Instruction(
                id: "3",
                title: "ステップ3",
                description: "付属品を確認してください",
                order: 2,
                nextNodeId: "4",
                previousNodeId: "2",
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/mierute-c7b7f.firebasestorage.app/o/blocks%2FKTiQZQLr1teo8vc6b7m4%2Fimages%2F1760837141451_e5dd7e47fcd14ef93c96fdc904788917.jpg?alt=media&token=586ecfa5-288a-40ca-a14c-02c13851e4da"
            ),
            Instruction(
                id: "4",
                title: "ステップ4",
                description: "電源ケーブルを接続してください",
                order: 3,
                nextNodeId: "5",
                previousNodeId: "3",
                imageUrl: nil
            ),
            Instruction(
                id: "5",
                title: "ステップ5",
                description: "本体の電源をオンにしてください",
                order: 4,
                nextNodeId: "6",
                previousNodeId: "4",
                imageUrl: nil
            ),
            Instruction(
                id: "6",
                title: "ステップ6",
                description: "言語設定を選択してください",
                order: 5,
                nextNodeId: "7",
                previousNodeId: "5",
                imageUrl: nil
            ),
            Instruction(
                id: "7",
                title: "ステップ7",
                description: "Wi-Fiに接続してください",
                order: 6,
                nextNodeId: "8",
                previousNodeId: "6",
                imageUrl: nil
            ),
            Instruction(
                id: "8",
                title: "ステップ8",
                description: "アカウントを作成してください",
                order: 7,
                nextNodeId: "9",
                previousNodeId: "7",
                imageUrl: nil
            ),
            Instruction(
                id: "9",
                title: "ステップ9",
                description: "初期設定を完了してください",
                order: 8,
                nextNodeId: "10",
                previousNodeId: "8",
                imageUrl: nil
            ),
            Instruction(
                id: "10",
                title: "ステップ10",
                description: "セットアップが完了しました！",
                order: 9,
                nextNodeId: nil,
                previousNodeId: "9",
                imageUrl: nil
            )
        ]
        self.currentInstructionIndex = 0
    }

    private func fetchInstructions(from qrCode: String) {
        // QRコードからプロジェクトIDを取得（現在は固定値、将来的にはQRコードから解析）
        let projectId = defaultProjectId
        print("📡 Fetching blocks for project ID: \(projectId) (from QR: \(qrCode))")

        Task {
            await loadInstructionsFromAPI()
        }
    }
}
