//
//  DebugMenuView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/28.
//

import SwiftUI

struct DebugMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            List {
                Section("審査用サンプルデータ") {
                    ForEach(Array(SampleDataService.allSampleProjects.enumerated()), id: \.offset) { index, sample in
                        Button(action: {
                            loadSampleData(sample: sample)
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .foregroundStyle(Color("AppOrange"))
                                    Text(sample.project.name)
                                        .foregroundStyle(.primary)
                                }
                                Text("\(sample.instructions.count)ステップ • QR: \(sample.qrCode)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }


                Section("シェーダープレビュー") {
                    NavigationLink(destination: ColorHighlightPreviewView()) {
                        Label("色強調シェーダー", systemImage: "paintbrush.fill")
                            .foregroundStyle(Color("AppCyan"))
                    }

                    NavigationLink(destination: ShaderPreviewView()) {
                        Label("波紋エフェクト", systemImage: "circle.dotted")
                            .foregroundStyle(Color("AppCyan"))
                    }

                    NavigationLink(destination: AnimationPreviewView()) {
                        Label("認識アニメーション", systemImage: "wand.and.stars")
                            .foregroundStyle(Color("AppCyan"))
                    }
                }

                Section("UI プレビュー") {
                    NavigationLink(destination: ManualCreationView()) {
                        Label("マニュアル作成", systemImage: "doc.text.fill")
                            .foregroundStyle(Color("AppOrange"))
                    }
                }
            }
            .navigationTitle("開発用メニュー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .alert("サンプルデータ", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func loadSampleData(sample: (project: Project, instructions: [Instruction], qrCode: String)) {
        // サンプルデータをUserDefaultsに保存
        UserDefaults.standard.set(sample.qrCode, forKey: "sampleQRCode")

        // サンプル手順データをJSON形式で保存
        if let instructionsData = try? JSONEncoder().encode(sample.instructions) {
            UserDefaults.standard.set(instructionsData, forKey: "sampleInstructions_\(sample.qrCode)")
        }

        // サンプルプロジェクトデータを保存
        if let projectData = try? JSONEncoder().encode(sample.project) {
            UserDefaults.standard.set(projectData, forKey: "sampleProject_\(sample.qrCode)")
        }

        alertMessage = """
        サンプルデータがロードされました

        プロジェクト: \(sample.project.name)
        ステップ数: \(sample.instructions.count)
        QRコード: \(sample.qrCode)

        カメラ画面でQRコードスキャンの代わりにこのデータが使用されます。
        画面を長押しして撮影をシミュレートしてください。
        """
        showAlert = true
    }
}

#Preview {
    DebugMenuView()
}
