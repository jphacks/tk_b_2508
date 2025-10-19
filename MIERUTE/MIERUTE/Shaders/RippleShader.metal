//
//  RippleShader.metal
//  MIERUTE
//
//  Created by Claude on 2025/10/18.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] half4 Ripple(
    float2 position,
    SwiftUI::Layer layer,
    float2 origin,
    float time,
    float amplitude,
    float frequency,
    float decay,
    float speed
) {
    // タップ位置からの距離
    float2 distance = position - origin;
    float dist = length(distance);

    // 波が到達しているか計算
    float delay = dist / speed;

    // 時間に基づく波の計算
    if (time > delay) {
        float elapsed = time - delay;
        float offset = amplitude * sin(elapsed * frequency) * exp(-elapsed * decay);

        // オフセット方向を計算
        float2 direction = distance / (dist + 0.0001); // ゼロ除算を避ける

        // 波紋効果を適用した位置
        float2 samplePosition = position - direction * offset;

        return layer.sample(samplePosition);
    }

    return layer.sample(position);
}
