#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
};
layout(binding = 1) uniform sampler2D source;
void main()
{
    float alpha = texture(source, qt_TexCoord0).a;
    fragColor = vec4(vec3(0.012, 0.009, 0.017) * alpha, alpha) * qt_Opacity;
}
