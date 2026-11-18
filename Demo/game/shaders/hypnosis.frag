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

void main()
{
    vec2 uv = qt_TexCoord0;
    vec2 p = uv + vec2(sin(uv.y * 22.0 + phase * 6.0) * 0.018,
                       sin(uv.x * 12.0 - phase * 4.0) * 0.026) * strength;
    vec2 fringe = vec2(0.012, 0.005) * strength;
    vec3 col;
    col.r = texture(source, clamp(p + fringe, 0.002, 0.998)).r;
    col.g = texture(source, clamp(p, 0.002, 0.998)).g * 0.68;
    col.b = texture(source, clamp(p - fringe, 0.002, 0.998)).b;
    vec3 haze = vec3(0.31, 0.07, 0.36) + 0.10 * sin(vec3(uv.x, uv.y, uv.x + uv.y) * 12.0 + phase);
    fragColor = vec4(mix(col,haze,0.24),1.0) * qt_Opacity;
}
