//
//  AddStepSheetView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/20.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AddStepSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var checkpoint: String = ""
    @State private var achievement: String = ""
    @State private var selectedMedias: [MediaItem] = []
    @State private var showMediaPicker = false
    @State private var show3DFilePicker = false
    @State private var editingMediaIndex: Int?
    @State private var showPhotoEditor = false
    @State private var extractedHighlightColor: String?

    let onAdd: (ManualStep) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("電源を入れる", text: $checkpoint, axis: .vertical)
                        .lineLimit(2...6)
                } header: {
                    Label("チェックポイント", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Color("AppCyan"))
                }

                Section {
                    TextField("ランプが点灯する", text: $achievement, axis: .vertical)
                        .lineLimit(2...6)
                } header: {
                    Label("達成条件", systemImage: "target")
                        .foregroundStyle(Color("AppOrange"))
                }

                Section {
                    Button(action: { showMediaPicker = true }) {
                        Label {
                            HStack {
                                Text("写真・動画を追加")
                                Spacer()
                                if !selectedMedias.isEmpty {
                                    Text("\(selectedMedias.count)")
                                        .foregroundStyle(.secondary)
                                        .fontWeight(.medium)
                                }
                            }
                        } icon: {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundStyle(Color("AppCyan"))
                        }
                    }
                    .foregroundStyle(.primary)

                    Button(action: { show3DFilePicker = true }) {
                        Label {
                            Text("3Dモデルを追加")
                        } icon: {
                            Image(systemName: "cube.fill")
                                .foregroundStyle(Color("AppOrange"))
                        }
                    }
                    .foregroundStyle(.primary)

                    if !selectedMedias.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(selectedMedias.indices, id: \.self) { index in
                                    if let thumbnail = selectedMedias[index].generateThumbnail() {
                                        ZStack(alignment: .topTrailing) {
                                            ZStack {
                                                Image(uiImage: thumbnail)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 80, height: 80)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    .onTapGesture {
                                                        if case .image = selectedMedias[index] {
                                                            editingMediaIndex = index
                                                            showPhotoEditor = true
                                                        }
                                                    }

                                                if selectedMedias[index].isVideo {
                                                    ZStack {
                                                        Circle()
                                                            .fill(.black.opacity(0.5))
                                                            .frame(width: 28, height: 28)

                                                        Image(systemName: "play.fill")
                                                            .font(.system(size: 12))
                                                            .foregroundStyle(.white)
                                                    }
                                                } else if selectedMedias[index].is3DModel {
                                                    // 3Dモデルインジケーター
                                                    VStack {
                                                        Spacer()
                                                        HStack {
                                                            Spacer()
                                                            Image(systemName: "cube.fill")
                                                                .font(.system(size: 16))
                                                                .foregroundStyle(.white, Color("AppOrange"))
                                                                .symbolRenderingMode(.palette)
                                                                .padding(4)
                                                        }
                                                    }
                                                } else {
                                                    // 画像編集可能インジケーター
                                                    VStack {
                                                        Spacer()
                                                        HStack {
                                                            Spacer()
                                                            Image(systemName: "pencil.circle.fill")
                                                                .font(.system(size: 20))
                                                                .foregroundStyle(.white, Color("AppCyan"))
                                                                .symbolRenderingMode(.palette)
                                                                .padding(4)
                                                        }
                                                    }
                                                }
                                            }

                                            Button(action: { selectedMedias.remove(at: index) }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(.white, .red)
                                                    .symbolRenderingMode(.palette)
                                            }
                                            .offset(x: 6, y: -6)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Label("参考メディア（任意）", systemImage: "photo.stack")
                        .foregroundStyle(.secondary)
                }

                if let colorHex = extractedHighlightColor, let color = Color(hex: colorHex) {
                    Section {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(.secondary.opacity(0.3), lineWidth: 1)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text("強調色")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)

                                Text(colorHex)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.primary)
                            }

                            Spacer()

                            Button(action: { extractedHighlightColor = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } header: {
                        Label("抽出された色", systemImage: "eyedropper")
                            .foregroundStyle(Color("AppCyan"))
                    }
                }
            }
            .navigationTitle("ステップを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        addStep()
                    }
                    .disabled(!isValid)
                    .bold()
                }
            }
            .sheet(isPresented: $showMediaPicker) {
                MediaPicker(selectedMedias: $selectedMedias)
            }
            .sheet(isPresented: $show3DFilePicker) {
                Model3DFilePicker(selectedMedias: $selectedMedias)
            }
            .fullScreenCover(isPresented: $showPhotoEditor) {
                if let index = editingMediaIndex,
                   case .image(let image) = selectedMedias[index] {
                    PhotoEditorView(image: image) { editedImage, colorHex in
                        // 編集後の画像で置き換え
                        selectedMedias[index] = .image(editedImage)
                        // 色を抽出した場合は保存
                        if let color = colorHex {
                            extractedHighlightColor = color
                        }
                    }
                }
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
            medias: selectedMedias,
            highlightColor: extractedHighlightColor
        )
        onAdd(newStep)
        dismiss()
    }
}

struct MediaPicker: UIViewControllerRepresentable {
    @Binding var selectedMedias: [MediaItem]
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images, .videos])
        config.selectionLimit = 0

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MediaPicker

        init(_ parent: MediaPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard !results.isEmpty else { return }

            let dispatchGroup = DispatchGroup()
            var loadedMedias: [MediaItem] = []

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    dispatchGroup.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            loadedMedias.append(.image(image))
                        }
                        dispatchGroup.leave()
                    }
                } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    dispatchGroup.enter()
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                        if let url = url {
                            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let fileName = UUID().uuidString + ".mov"
                            let newURL = documentsPath.appendingPathComponent(fileName)

                            do {
                                if FileManager.default.fileExists(atPath: newURL.path) {
                                    try FileManager.default.removeItem(at: newURL)
                                }
                                try FileManager.default.copyItem(at: url, to: newURL)
                                loadedMedias.append(.video(newURL))
                            } catch {
                                print("Error copying video: \(error)")
                            }
                        }
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.parent.selectedMedias.append(contentsOf: loadedMedias)
            }
        }
    }
}

struct Model3DFilePicker: UIViewControllerRepresentable {
    @Binding var selectedMedias: [MediaItem]
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [
                .usdz,  // Apple AR Format
                .threeDContent,  // Generic 3D content
            ],
            asCopy: true
        )
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: Model3DFilePicker

        init(_ parent: Model3DFilePicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.dismiss()

            for url in urls {
                // ファイルをドキュメントディレクトリにコピー
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileName = UUID().uuidString + "_" + url.lastPathComponent
                let newURL = documentsPath.appendingPathComponent(fileName)

                do {
                    if FileManager.default.fileExists(atPath: newURL.path) {
                        try FileManager.default.removeItem(at: newURL)
                    }
                    try FileManager.default.copyItem(at: url, to: newURL)
                    parent.selectedMedias.append(.model3D(newURL))
                    print("✅ 3D Model imported: \(newURL.lastPathComponent)")
                } catch {
                    print("❌ Error importing 3D model: \(error)")
                }
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}

#Preview {
    AddStepSheetView { step in
        print("Added step: \(step)")
    }
}
