//
//  AddStepSheetView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI
import PhotosUI

struct AddStepSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var checkpoint: String = ""
    @State private var achievement: String = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false

    let onAdd: (ManualStep) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("チェックポイント", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)

                        TextField("例: 電源を入れる", text: $checkpoint, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(3...6)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("チェックポイント")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("達成条件", systemImage: "target")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.orange)

                        TextField("例: ランプが点灯する", text: $achievement, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(3...6)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("達成条件")
                }

                Section {
                    if let image = selectedImage {
                        VStack(spacing: 12) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(12)

                            Button(action: { selectedImage = nil }) {
                                Label("画像を削除", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        Button(action: { showImagePicker = true }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .foregroundColor(.blue)
                                Text("写真を選択")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                } header: {
                    Text("参考画像（オプション）")
                }
            }
            .navigationTitle("ステップを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        addStep()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }

    private var isValid: Bool {
        !checkpoint.trimmingCharacters(in: .whitespaces).isEmpty &&
        !achievement.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func addStep() {
        let newStep = ManualStep(
            checkpoint: checkpoint.trimmingCharacters(in: .whitespaces),
            achievement: achievement.trimmingCharacters(in: .whitespaces),
            image: selectedImage
        )
        onAdd(newStep)
        dismiss()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

#Preview {
    AddStepSheetView { step in
        print("Added step: \(step)")
    }
}
