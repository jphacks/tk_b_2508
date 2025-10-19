//
//  BorderShineShader.metal
//  MIERUTE
//
//  Created by Claude on 2025/10/19.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 BorderShine(
    float2 position,
    SwiftUI::Layer layer,
    float time,
    float speed,
    float width,
    float angle
) {
    // 元の色を取得
    half4 color = layer.sample(position);

    // 斜めの光の位置を計算（angleの方向に移動）
    float2 direction = float2(cos(angle), sin(angle));
    float offset = dot(position, direction);

    // 時間に基づいて光を移動
    float lightPosition = fmod(time * speed, width * 2.0);

    // 光の強度を計算（ガウシアン分布）
    float distance = abs(offset - lightPosition);
    float shineWidth = 100.0;
    float intensity = exp(-distance * distance / (shineWidth * shineWidth));

    // 光を追加（白い光）
    half3 shine = half3(1.0, 1.0, 1.0) * half(intensity * 0.6);

    // 元の色に光を加算
    color.rgb = saturate(color.rgb + shine);

    return color;
}
