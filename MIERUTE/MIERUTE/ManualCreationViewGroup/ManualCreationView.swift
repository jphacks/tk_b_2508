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
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color("AppCyan").opacity(0.1),
                        Color("AppOrange").opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    titleInputSection
                    progressSection
                    stepsList
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .symbolRenderingMode(.hierarchical)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("マニュアル作成")
                        .font(.system(size: 17, weight: .semibold))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveManual) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color("AppCyan")))
                        } else {
                            Text("保存")
                                .fontWeight(.semibold)
                                .foregroundColor(canSave ? Color("AppCyan") : .gray)
                        }
                    }
                    .disabled(!canSave || isSaving)
                }
            }
            .sheet(isPresented: $showAddStepSheet) {
                AddStepSheetView { newStep in
                    steps.append(newStep)
                }
            }
        }
    }

    private var titleInputSection: some View {
        VStack(spacing: 16) {
            TextField("タイトル", text: $title)
                .font(.system(size: 23, weight: .bold))
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
        }
    }

    private var progressSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 20))
                .foregroundColor(Color("AppCyan"))

            Text("\(steps.count) ステップ")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !steps.isEmpty
    }

    private var stepsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                if steps.isEmpty {
                    emptyState
                } else {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        VStack(spacing: 0) {
                            StepNodeCard(
                                step: step,
                                stepNumber: index + 1,
                                onDelete: {
                                    withAnimation {
                                        steps.removeAll { $0.id == step.id }
                                    }
                                }
                            )

                            // 接続線
                            ZStack {
                                Rectangle()
                                    .fill(Color("AppCyan").opacity(0.3))
                                    .frame(width: 3)

                                VStack(spacing: 8) {
                                    Circle()
                                        .fill(Color("AppCyan").opacity(0.5))
                                        .frame(width: 6, height: 6)
                                    Circle()
                                        .fill(Color("AppCyan").opacity(0.5))
                                        .frame(width: 6, height: 6)
                                    Circle()
                                        .fill(Color("AppCyan").opacity(0.5))
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .frame(height: 40)
                            .padding(.vertical, 8)
                        }
                    }

                    // プラスボタン
                    Button(action: { showAddStepSheet = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color("AppCyan"))
                                .symbolRenderingMode(.hierarchical)

                            Text("ステップを追加")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("AppCyan").opacity(0.2),
                                Color("AppOrange").opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "doc.text.badge.plus")
                    .font(.system(size: 50))
                    .foregroundColor(Color("AppCyan"))
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: 12) {
                Text("ステップを追加してください")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)

                Text("+ ボタンをタップして\n最初のステップを追加しましょう")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Button(action: { showAddStepSheet = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))

                    Text("ステップを追加")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("AppCyan"),
                                    Color("AppCyan").opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color("AppCyan").opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            .padding(.top, 8)
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 40)
    }

    private func saveManual() {
        guard canSave else { return }

        isSaving = true

        Task {
            // TODO: Firebase Storageに画像をアップロードしてFirestoreに保存
            print("📝 Saving manual: \(title)")
            print("📝 Steps count: \(steps.count)")

            // 保存完了
            await MainActor.run {
                isSaving = false
                dismiss()
            }
        }
    }
}

struct ManualStep: Identifiable {
    let id = UUID()
    var checkpoint: String
    var achievement: String
    var medias: [MediaItem]
    var highlightColor: String?
}

struct StepNodeCard: View {
    let step: ManualStep
    let stepNumber: Int
    let onDelete: () -> Void
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with step number and delete button
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color("AppCyan"),
                                        Color("AppCyan").opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)

                        Text("\(stepNumber)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text("ステップ \(stepNumber)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }

                Spacer()

                Button(action: { showDeleteConfirmation = true }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.red.opacity(0.6))
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color("AppCyan").opacity(0.05))

            // Content
            VStack(alignment: .leading, spacing: 16) {
                // Checkpoint
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color("AppCyan"))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("チェックポイント")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)

                        Text(step.checkpoint)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                    }
                }

                // Achievement
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "target")
                        .font(.system(size: 22))
                        .foregroundColor(Color("AppOrange"))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("達成条件")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)

                        Text(step.achievement)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                    }
                }

                // Media thumbnails
                if !step.medias.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 16))
                                .foregroundColor(Color("AppCyan"))

                            Text("参考メディア (\(step.medias.count)個)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(step.medias.indices, id: \.self) { index in
                                    if let thumbnail = step.medias[index].generateThumbnail() {
                                        ZStack {
                                            Image(uiImage: thumbnail)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .cornerRadius(12)
                                                .clipped()

                                            if step.medias[index].isVideo {
                                                ZStack {
                                                    Circle()
                                                        .fill(.black.opacity(0.5))
                                                        .frame(width: 36, height: 36)

                                                    Image(systemName: "play.fill")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.white)
                                                }
                                            } else if step.medias[index].is3DModel {
                                                VStack {
                                                    Spacer()
                                                    HStack {
                                                        Spacer()
                                                        Image(systemName: "cube.fill")
                                                            .font(.system(size: 14))
                                                            .foregroundStyle(.white, Color("AppOrange"))
                                                            .symbolRenderingMode(.palette)
                                                            .padding(6)
                                                    }
                                                }
                                            }
                                        }
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .confirmationDialog("このステップを削除しますか？", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("削除", role: .destructive) {
                onDelete()
            }
            Button("キャンセル", role: .cancel) {}
        }
    }
}

#Preview {
    ManualCreationView()
}
