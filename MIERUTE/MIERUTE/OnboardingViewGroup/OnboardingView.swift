//
//  OnboardingView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0

    private let pages = [
        OnboardingPage(
            title: "MIERUTEへようこそ",
            description: "",
            assetImage: "MIERUTELogo",
            color: Color("AppCyan")
        ),
        OnboardingPage(
            title: "写真を撮影",
            description: "このアプリは読まずに、\n手順を知れるマニュアルアプリです\nまずは写真を撮影しましょう",
            systemImage: "camera.fill",
            color: Color("AppCyan")
        ),
        OnboardingPage(
            title: "さあ、始めよう！",
            description: "試しにグッドサインで撮影してみましょう！",
            systemImage: "checkmark.circle.fill",
            color: Color("AppOrange")
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0, green: 0.97, blue: 1.0),
                    Color(red: 0.9, green: 0.49, blue: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        Button(action: {
                            onComplete()
                        }) {
                            Text("始める")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("AppCyan"))
                                .cornerRadius(12)
                        }
                    } else {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("次へ")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("AppCyan"))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let systemImage: String?
    let assetImage: String?
    let color: Color

    init(title: String, description: String, systemImage: String, color: Color) {
        self.title = title
        self.description = description
        self.systemImage = systemImage
        self.assetImage = nil
        self.color = color
    }

    init(title: String, description: String, assetImage: String, color: Color) {
        self.title = title
        self.description = description
        self.systemImage = nil
        self.assetImage = assetImage
        self.color = color
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
                .frame(height: 100)

            Group {
                if let systemImage = page.systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 100))
                        .foregroundColor(page.color)
                        .symbolRenderingMode(.hierarchical)
                } else if let assetImage = page.assetImage {
                    Image(assetImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(24)
                }
            }

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
