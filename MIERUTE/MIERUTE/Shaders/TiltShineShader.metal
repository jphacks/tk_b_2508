//
//  TiltShineShader.metal
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 TiltShine(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float tiltOffset,
    float intensity,
    float shineWidth
) {
    // 元の色を取得
    half4 color = layer.sample(position);

    // 光の角度を固定（左上から右下：-45度）
    float lightAngle = -3.14159 / 4.0;  // -45度
    float2 lightDirection = float2(cos(lightAngle), sin(lightAngle));

    // 光の線に垂直な方向
    float2 perpendicular = float2(-lightDirection.y, lightDirection.x);

    // 位置を光の線に垂直な方向に投影
    float projection = dot(position, perpendicular);

    // 傾きに基づいて光の位置をオフセット
    float lightPosition = size.x * 0.5 + tiltOffset * size.x * 2.0;

    // 光の線からの距離
    float distanceFromLine = abs(projection - lightPosition);

    // 光の強度を計算（細くて微かなブラー）
    float blur = shineWidth * 1.2;
    float lightIntensity = exp(-distanceFromLine * distanceFromLine / (blur * blur));

    // 最終的な光の強度（元の色のアルファ値で調整）
    float finalIntensity = lightIntensity * intensity * color.a;

    // 光を加算（白い光）
    half3 shine = half3(1.0, 1.0, 1.0) * half(finalIntensity);

    // 元の色に光を加算
    color.rgb = saturate(color.rgb + shine);

    return color;
}
