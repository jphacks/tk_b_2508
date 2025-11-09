//
//  ColorHighlightPreviewView.swift
//  MIERUTE
//
//  Created by Claude on 2025/10/28.
//

import SwiftUI

struct ColorHighlightPreviewView: View {
    @State private var selectedEffect: EffectType = .highlight
    @State private var targetColor: Color = .cyan
    @State private var threshold: Double = 0.3
    @State private var intensity: Double = 0.5
    @State private var saturation: Double = 2.0

    enum EffectType: String, CaseIterable {
        case highlight = "強調"
        case isolate = "分離"
        case pop = "ポップ"

        var icon: String {
            switch self {
            case .highlight: return "sparkles"
            case .isolate: return "eye.fill"
            case .pop: return "bolt.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // プレビューエリア
                sampleImageView
                    .frame(maxHeight: .infinity)

                Divider()

                // コントロールエリア
                ScrollView {
                    VStack(spacing: 24) {
                        // エフェクト選択
                        effectSelector

                        // 対象色選択
                        colorPicker

                        // パラメータ調整
                        parameterControls
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
                .frame(height: 350)
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("色強調フィルター")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var sampleImageView: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black

                // サンプル画像の代わりにカラフルな図形を配置
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 80, height: 80)

                        Circle()
                            .fill(Color.green)
                            .frame(width: 80, height: 80)

                        Circle()
                            .fill(Color.blue)
                            .frame(width: 80, height: 80)
                    }

                    HStack(spacing: 20) {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 80, height: 80)

                        Circle()
                            .fill(Color.orange)
                            .frame(width: 80, height: 80)

                        Circle()
                            .fill(Color.purple)
                            .frame(width: 80, height: 80)
                    }

                    HStack(spacing: 20) {
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 80, height: 80)

                        Circle()
                            .fill(Color.pink)
                            .frame(width: 80, height: 80)

                        Circle()
                            .fill(Color.mint)
                            .frame(width: 80, height: 80)
                    }
                }
                .applyColorEffect(
                    effect: selectedEffect,
                    targetColor: targetColor,
                    threshold: threshold,
                    intensity: intensity,
                    saturation: saturation
                )
            }
        }
    }

    private var effectSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("エフェクトタイプ")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(EffectType.allCases, id: \.self) { effect in
                    Button(action: { selectedEffect = effect }) {
                        VStack(spacing: 8) {
                            Image(systemName: effect.icon)
                                .font(.system(size: 24))
                                .foregroundStyle(selectedEffect == effect ? Color("AppCyan") : .secondary)

                            Text(effect.rawValue)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(selectedEffect == effect ? .primary : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedEffect == effect ? Color("AppCyan").opacity(0.15) : Color(.systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedEffect == effect ? Color("AppCyan") : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
    }

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("対象色")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    colorButton(.red)
                    colorButton(.green)
                    colorButton(.blue)
                    colorButton(.yellow)
                    colorButton(.orange)
                    colorButton(.purple)
                    colorButton(.cyan)
                    colorButton(.pink)
                    colorButton(.mint)
                }
            }
        }
    }

    private func colorButton(_ color: Color) -> some View {
        Button(action: { targetColor = color }) {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(targetColor == color ? Color.white : Color.clear, lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }

    private var parameterControls: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("閾値")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.2f", threshold))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)
                }

                Slider(value: $threshold, in: 0.1...1.0)
                    .tint(Color("AppCyan"))
            }

            if selectedEffect == .highlight {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("強調度")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(String(format: "%.2f", intensity))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                    }

                    Slider(value: $intensity, in: 0...2.0)
                        .tint(Color("AppCyan"))
                }
            }

            if selectedEffect == .pop {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("彩度")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(String(format: "%.2f", saturation))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                    }

                    Slider(value: $saturation, in: 1.0...4.0)
                        .tint(Color("AppCyan"))
                }
            }
        }
    }
}

// MARK: - Helper Extension

extension View {
    @ViewBuilder
    func applyColorEffect(
        effect: ColorHighlightPreviewView.EffectType,
        targetColor: Color,
        threshold: Double,
        intensity: Double,
        saturation: Double
    ) -> some View {
        switch effect {
        case .highlight:
            self.colorHighlight(
                targetColor: targetColor,
                threshold: threshold,
                intensity: intensity
            )
        case .isolate:
            self.colorIsolate(
                targetColor: targetColor,
                threshold: threshold
            )
        case .pop:
            self.colorPop(
                targetColor: targetColor,
                threshold: threshold,
                saturation: saturation
            )
        }
    }
}

#Preview {
    ColorHighlightPreviewView()
}
