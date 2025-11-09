//
//  SampleDataService.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/28.
//

import Foundation

enum SampleDataService {

    /// App Store審査用のサンプルプロジェクト
    static let sampleProject = Project(
        id: "sample-project-1",
        name: "コーヒーメーカーの使い方",
        description: "初めての方でも簡単にコーヒーを淹れられるガイドです",
        createdAt: Date(),
        updatedAt: Date()
    )

    /// サンプルの手順データ
    static let sampleInstructions: [Instruction] = [
        Instruction(
            id: "step-1",
            title: "水タンクに水を入れる",
            description: "水タンクを取り外し、新鮮な水を目盛りまで入れてください。",
            order: 0,
            nextNodeId: "step-2",
            previousNodeId: nil,
            imageUrl: nil,
            highlightColor: "#0088CC" // シアン色
        ),
        Instruction(
            id: "step-2",
            title: "コーヒー豆をセットする",
            description: "フィルターに適量のコーヒー豆を入れてセットします。",
            order: 1,
            nextNodeId: "step-3",
            previousNodeId: "step-1",
            imageUrl: nil,
            highlightColor: "#8B4513" // 茶色
        ),
        Instruction(
            id: "step-3",
            title: "電源ボタンを押す",
            description: "緑色の電源ボタンを押して抽出を開始します。",
            order: 2,
            nextNodeId: "step-4",
            previousNodeId: "step-2",
            imageUrl: nil,
            highlightColor: "#00FF00" // 緑色
        ),
        Instruction(
            id: "step-4",
            title: "抽出完了まで待つ",
            description: "約3分で抽出が完了します。ビープ音が鳴るまでお待ちください。",
            order: 3,
            nextNodeId: nil,
            previousNodeId: "step-3",
            imageUrl: nil,
            highlightColor: "#FF6B6B" // 赤色
        )
    ]

    /// サンプルのブロックデータ
    static let sampleBlocks: [Block] = [
        Block(
            id: "block-1",
            checkpoint: "水タンクに水を入れる",
            achievement: "水タンクが満たされている",
            projectId: "sample-project-1",
            imageUrl: nil,
            highlightColor: "#0088CC",
            createdAt: nil,
            updatedAt: nil
        ),
        Block(
            id: "block-2",
            checkpoint: "コーヒー豆をセットする",
            achievement: "フィルターに豆が入っている",
            projectId: "sample-project-1",
            imageUrl: nil,
            highlightColor: "#8B4513",
            createdAt: nil,
            updatedAt: nil
        ),
        Block(
            id: "block-3",
            checkpoint: "電源ボタンを押す",
            achievement: "緑色のランプが点灯している",
            projectId: "sample-project-1",
            imageUrl: nil,
            highlightColor: "#00FF00",
            createdAt: nil,
            updatedAt: nil
        ),
        Block(
            id: "block-4",
            checkpoint: "抽出完了まで待つ",
            achievement: "ビープ音が鳴り、抽出が完了",
            projectId: "sample-project-1",
            imageUrl: nil,
            highlightColor: "#FF6B6B",
            createdAt: nil,
            updatedAt: nil
        )
    ]

    /// サンプルQRコード用のURL（プロジェクトID）
    static let sampleQRCode = "sample-project-1"

    /// サンプルの手順セット
    static let sampleInstructionSet = InstructionSet(
        id: "sample-instruction-set-1",
        name: "コーヒーメーカーの使い方",
        instructions: sampleInstructions
    )

    /// 別のサンプルプロジェクト（洗濯機の使い方）
    static let sampleProject2 = Project(
        id: "sample-project-2",
        name: "洗濯機の使い方",
        description: "洗濯機の基本的な使い方を学びます",
        createdAt: Date(),
        updatedAt: Date()
    )

    static let sampleInstructions2: [Instruction] = [
        Instruction(
            id: "wash-step-1",
            title: "洗濯物を入れる",
            description: "洗濯物を洗濯槽に入れます。入れすぎに注意してください。",
            order: 0,
            nextNodeId: "wash-step-2",
            previousNodeId: nil,
            imageUrl: nil,
            highlightColor: "#4A90E2" // 青色
        ),
        Instruction(
            id: "wash-step-2",
            title: "洗剤を入れる",
            description: "洗剤投入口に適量の洗剤を入れます。",
            order: 1,
            nextNodeId: "wash-step-3",
            previousNodeId: "wash-step-1",
            imageUrl: nil,
            highlightColor: "#FFD700" // 金色
        ),
        Instruction(
            id: "wash-step-3",
            title: "コースを選択",
            description: "標準コースまたはお好みのコースを選択します。",
            order: 2,
            nextNodeId: "wash-step-4",
            previousNodeId: "wash-step-2",
            imageUrl: nil,
            highlightColor: "#9B59B6" // 紫色
        ),
        Instruction(
            id: "wash-step-4",
            title: "スタートボタンを押す",
            description: "スタートボタンを押して洗濯を開始します。",
            order: 3,
            nextNodeId: nil,
            previousNodeId: "wash-step-3",
            imageUrl: nil,
            highlightColor: "#2ECC71" // 緑色
        )
    ]

    static let sampleQRCode2 = "sample-project-2"

    /// すべてのサンプルプロジェクト
    static let allSampleProjects: [(project: Project, instructions: [Instruction], qrCode: String)] = [
        (sampleProject, sampleInstructions, sampleQRCode),
        (sampleProject2, sampleInstructions2, sampleQRCode2)
    ]
}
