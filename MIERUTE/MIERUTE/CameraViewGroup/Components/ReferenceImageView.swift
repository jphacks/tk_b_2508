//
//  ReferenceImageView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import SwiftUI

struct ReferenceImageView: View {
    let imageUrl: String
    let onImageTap: () -> Void
    let onImageLoaded: (UIImage) -> Void
    let showLoadingOverlay: Bool

    var body: some View {
        VStack {
            HStack {
                Button(action: onImageTap) {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 170)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white, lineWidth: 4)
                                )
                                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 4)
                                .onAppear {
                                    Task {
                                        if let url = URL(string: imageUrl),
                                           let data = try? Data(contentsOf: url),
                                           let uiImage = UIImage(data: data) {
                                            onImageLoaded(uiImage)
                                        }
                                    }
                                }
                        case .failure(_):
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 170)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.white)
                                )
                        case .empty:
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 100, height: 170)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.leading, 20)
                .padding(.top, 60)

                Spacer()
            }

            if showLoadingOverlay {
                LoadingOverlay(text: "写真を保存中...")
                    .allowsHitTesting(false)
            }

            Spacer()
        }
    }
}
