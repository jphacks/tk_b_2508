//
//  ColorHighlightShader.metal
//  MIERUTE
//
//  Created by Claude on 2025/10/28.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// RGB to HSV 変換
half3 rgbToHsv(half3 rgb) {
    half maxVal = max(max(rgb.r, rgb.g), rgb.b);
    half minVal = min(min(rgb.r, rgb.g), rgb.b);
    half delta = maxVal - minVal;

    half h = 0.0;
    half s = 0.0;
    half v = maxVal;

    if (delta > 0.0001) {
        s = delta / maxVal;

        if (rgb.r >= maxVal) {
            h = (rgb.g - rgb.b) / delta;
        } else if (rgb.g >= maxVal) {
            h = 2.0 + (rgb.b - rgb.r) / delta;
        } else {
            h = 4.0 + (rgb.r - rgb.g) / delta;
        }

        h /= 6.0;
        if (h < 0.0) h += 1.0;
    }

    return half3(h, s, v);
}

// HSV to RGB 変換
half3 hsvToRgb(half3 hsv) {
    half h = hsv.x * 6.0;
    half s = hsv.y;
    half v = hsv.z;

    int i = int(floor(h));
    half f = h - half(i);
    half p = v * (1.0 - s);
    half q = v * (1.0 - s * f);
    half t = v * (1.0 - s * (1.0 - f));

    if (i == 0) return half3(v, t, p);
    if (i == 1) return half3(q, v, p);
    if (i == 2) return half3(p, v, t);
    if (i == 3) return half3(p, q, v);
    if (i == 4) return half3(t, p, v);
    return half3(v, p, q);
}

[[ stitchable ]] half4 ColorHighlight(
    float2 position,
    SwiftUI::Layer layer,
    half3 targetColor,
    float threshold,
    float intensity
) {
    half4 currentColor = layer.sample(position);

    // 対象色との距離を計算（色空間での距離）
    half3 colorDiff = currentColor.rgb - targetColor;
    float distance = length(colorDiff);

    // 閾値内の色を強調
    if (distance < threshold) {
        // 距離に基づいて強調度を計算（近いほど強く強調）
        float highlightAmount = (1.0 - distance / threshold) * intensity;

        // 彩度と明度を上げる
        half3 enhanced = currentColor.rgb * (1.0 + highlightAmount);

        return half4(enhanced, currentColor.a);
    } else {
        // 閾値外の色は彩度を下げる（グレースケール化）
        half gray = dot(currentColor.rgb, half3(0.299, 0.587, 0.114));
        half3 desaturated = mix(half3(gray), currentColor.rgb, 0.3);

        return half4(desaturated, currentColor.a);
    }
}

[[ stitchable ]] half4 ColorIsolate(
    float2 position,
    SwiftUI::Layer layer,
    half3 targetColor,
    float threshold
) {
    half4 currentColor = layer.sample(position);

    // 対象色との距離を計算
    half3 colorDiff = currentColor.rgb - targetColor;
    float distance = length(colorDiff);

    // 閾値内の色はそのまま、外は完全にグレースケール化
    if (distance < threshold) {
        return currentColor;
    } else {
        half gray = dot(currentColor.rgb, half3(0.299, 0.587, 0.114));
        return half4(half3(gray), currentColor.a);
    }
}

[[ stitchable ]] half4 ColorPop(
    float2 position,
    SwiftUI::Layer layer,
    half3 targetColor,
    float threshold,
    float saturation
) {
    half4 currentColor = layer.sample(position);

    // 対象色との距離を計算
    half3 colorDiff = currentColor.rgb - targetColor;
    float distance = length(colorDiff);

    if (distance < threshold) {
        // 対象色は彩度を大幅に上げる
        half3 hsv = rgbToHsv(currentColor.rgb);
        hsv.y = min(hsv.y * saturation, 1.0); // 彩度を上げる
        hsv.z = min(hsv.z * 1.2, 1.0); // 明度も少し上げる
        half3 enhanced = hsvToRgb(hsv);

        return half4(enhanced, currentColor.a);
    } else {
        // その他は薄くする
        half gray = dot(currentColor.rgb, half3(0.299, 0.587, 0.114));
        half3 desaturated = mix(half3(gray), currentColor.rgb, 0.2);

        return half4(desaturated * 0.7, currentColor.a);
    }
}
