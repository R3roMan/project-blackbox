#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 windAndScene;
};
layout(binding = 1) uniform sampler2D field;

float foliagePatch(vec2 p, vec2 center, vec2 size)
{
    return 1.0 - smoothstep(0.52, 1.0, length((p - center) / size));
}

void main()
{
    vec2 p = qt_TexCoord0;
    float coverage;
    if (windAndScene.z > 0.5) {
        coverage = max(foliagePatch(p, vec2(0.29, 0.177), vec2(0.221, 0.22)),
            foliagePatch(p, vec2(0.956, 0.424), vec2(0.165, 0.185)));
        coverage = max(coverage, foliagePatch(p, vec2(0.095, 0.763), vec2(0.151, 0.145)));
    } else {
        coverage = max(foliagePatch(p, vec2(0.208, 0.185), vec2(0.136, 0.221)),
            foliagePatch(p, vec2(0.817, 0.197), vec2(0.188, 0.226)));
        coverage = max(coverage, max(foliagePatch(p, vec2(0.047, 0.645), vec2(0.123, 0.16)),
            foliagePatch(p, vec2(0.956, 0.76), vec2(0.118, 0.108))));
    }
    if (coverage <= 0.01) {
        fragColor = vec4(0.0);
        return;
    }

    vec4 still = texture(field, p);
    // Limit the displacement to foliage colours so stone and trunks stay still.
    float green = smoothstep(-0.12, 0.044, still.g - still.r)
        * smoothstep(-0.14, 0.01, still.g - still.b);
    float leaves = mix(green, max(green, smoothstep(0.21, 0.46, still.r - still.b) * 0.8), windAndScene.z);
    float time = windAndScene.x * mix(0.83, 2.42, windAndScene.y);
    float wave = sin(time - p.y * 24.0 + p.x * 10.0) * 0.67 + sin(time * 1.73 + p.x * 52.0) * 0.33;
    float strength = mix(0.0019, 0.0094, windAndScene.y) * mix(1.0, 1.45, windAndScene.w);
    vec2 offset = vec2(wave, 0.4 * sin(time * 1.14 + p.x * 35.0)) * strength * coverage * leaves;
    fragColor = texture(field, clamp(p + offset, vec2(0.0), vec2(1.0)))
        * (coverage * leaves * qt_Opacity);
}
