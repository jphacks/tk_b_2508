//
//  ManualCreationView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI

struct ManualCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var steps: [ManualStep] = []
    @State private var showAddStepSheet = false
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                titleSection
                stepsList
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddStepSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddStepSheet) {
                AddStepSheetView { newStep in
                    steps.append(newStep)
                }
            }
        }
    }

    private var titleSection: some View {
        VStack(spacing: 16) {
            TextField("マニュアルのタイトルを入力", text: $title)
                .font(.system(size: 24, weight: .bold))
                .textFieldStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.top, 20)

            if !steps.isEmpty {
                Button(action: saveManual) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        Text(isSaving ? "保存中..." : "マニュアルを保存")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(canSave ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!canSave || isSaving)
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 16)
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !steps.isEmpty
    }

    private var stepsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                if steps.isEmpty {
                    emptyState
                } else {
                    ForEach(steps.indices, id: \.self) { index in
                        StepNodeCard(step: steps[index], stepNumber: index + 1)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("ステップを追加してください")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)

            Text("右上の + ボタンをタップして\n最初のステップを追加しましょう")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)
    }

    private func saveManual() {
        guard canSave else { return }

        isSaving = true

        Task {
            do {
                // TODO: Firebase Storageに画像をアップロードしてFirestoreに保存
                print("📝 Saving manual: \(title)")
                print("📝 Steps count: \(steps.count)")

                // 保存完了
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            } catch {
                print("❌ Failed to save manual: \(error)")
                await MainActor.run {
                    isSaving = false
                }
            }
        }
    }
}

struct ManualStep: Identifiable {
    let id = UUID()
    var checkpoint: String
    var achievement: String
    var image: UIImage?
}

struct StepNodeCard: View {
    let step: ManualStep
    let stepNumber: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ステップ \(stepNumber)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 8) {
                Label {
                    Text(step.checkpoint)
                        .font(.system(size: 15))
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }

                Label {
                    Text(step.achievement)
                        .font(.system(size: 15))
                } icon: {
                    Image(systemName: "target")
                        .foregroundColor(.orange)
                }

                if let image = step.image {
                    HStack(spacing: 8) {
                        Image(systemName: "photo")
                            .foregroundColor(.blue)
                            .font(.system(size: 13))

                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                            .clipped()

                        Text("参考画像")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ManualCreationView()
}
