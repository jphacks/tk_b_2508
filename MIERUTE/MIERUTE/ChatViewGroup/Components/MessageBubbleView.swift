//
//  MessageBubbleView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 50)
            } else {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {
                Text(message.content)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        Group {
                            if message.isUser {
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            } else {
                                Color.white
                            }
                        }
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                    .shadow(
                        color: message.isUser
                            ? Color.blue.opacity(0.3)
                            : Color.black.opacity(0.08),
                        radius: message.isUser ? 8 : 4,
                        x: 0,
                        y: message.isUser ? 2 : 1
                    )

                Text(timeString(from: message.timestamp))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.8))
                    .padding(.horizontal, 6)
            }

            if message.isUser {
                // User Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.7), Color.teal.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: "person.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
            } else {
                Spacer(minLength: 50)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
