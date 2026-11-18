#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float phase;
    float strength;
};
layout(binding = 1) uniform sampler2D source;

float grain(vec2 value)
{
    return fract(sin(dot(value, vec2(127.1, 311.7))) * 43758.5453);
}

void main()
{
    vec2 uv = qt_TexCoord0;
    float band = floor(uv.y * 18.0);
    float tick = floor(phase * 8.0);
    float shift = (grain(vec2(band, tick)) - 0.5) * 0.40 * strength;
    vec2 xy = vec2(uv.x + shift, uv.y + sin(uv.x * 10.0 + phase * 8.0) * 0.022 * strength);
    vec3 col;
    col.r = texture(source, clamp(xy + vec2(0.048 * strength, 0.0), vec2(0.003), vec2(0.997))).r;
    col.g = texture(source, clamp(xy, vec2(0.003), vec2(0.997))).g;
    col.b = texture(source, clamp(xy - vec2(0.04 * strength, 0.0), vec2(0.003), vec2(0.997))).b;
    float scan = step(0.45, fract(uv.y * 155.0 + phase * 2.0));
    float cut = step(0.78, grain(vec2(band, tick + 19.0))) * strength;
    vec3 dropout = mix(vec3(0.12, 0.058, 0.14), vec3(0.69, 0.20, 0.49), scan * 0.42);
    col = mix(col * (1.0 - scan * 0.16 * strength), dropout, cut * 0.85);
    fragColor = vec4(col, 1.0) * qt_Opacity;
}
