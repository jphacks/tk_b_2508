//
//  ChatView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ChatViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.97, blue: 1.0),
                        Color(red: 0.98, green: 0.99, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // メッセージリスト
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubbleView(message: message)
                                        .id(message.id)
                                        .transition(.scale.combined(with: .opacity))
                                }

                                // ローディングインジケーター
                                if viewModel.isLoading {
                                    HStack(spacing: 8) {
                                        ForEach(0..<3) { index in
                                            Circle()
                                                .fill(Color("AppCyan").opacity(0.6))
                                                .frame(width: 8, height: 8)
                                                .scaleEffect(viewModel.isLoading ? 1.0 : 0.5)
                                                .animation(
                                                    .easeInOut(duration: 0.6)
                                                    .repeatForever()
                                                    .delay(Double(index) * 0.2),
                                                    value: viewModel.isLoading
                                                )
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white)
                                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                                    )
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.vertical, 20)
                        }
                        .onChange(of: viewModel.messages.count) { _, _ in
                            if let lastMessage = viewModel.messages.last {
                                withAnimation(.spring(response: 0.3)) {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }

                    // メッセージ入力
                    VStack(spacing: 0) {
                        Divider()
                            .background(Color.gray.opacity(0.2))

                        MessageInputView(
                            text: $viewModel.inputText,
                            onSend: {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.sendMessage()
                                }
                            }
                        )
                        .background(Color.white)
                    }
                }
            }
            .navigationTitle("AIアシスタント")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.white.opacity(0.95), for: .navigationBar)
        }
    }
}

#Preview {
    ChatView(viewModel: .init())
}
