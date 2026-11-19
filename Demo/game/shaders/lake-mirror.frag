#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 imageFrame;
    vec4 lightAndTime;
    vec2 waterMotion;
};
layout(binding = 1) uniform sampler2D field;
layout(binding = 2) uniform sampler2D waterMask;

void main()
{
    vec2 uv = qt_TexCoord0;
    vec2 art = (uv - imageFrame.xy) / imageFrame.zw;
    float water = texture(waterMask, art).a;
    if (water < 0.01 || any(lessThan(art, vec2(0.0))) || any(greaterThan(art, vec2(1.0)))) {
        fragColor = vec4(0.0);
        return;
    }

    float depth = max(0.0, art.y - 0.645);
    float time = lightAndTime.w * waterMotion.x;
    float ripple = (sin(art.y * 310.0 + time * 2.1) * 0.0028
        + sin(art.y * 840.0 - art.x * 18.0 - time * 3.6) * 0.0017)
        * (0.7 + waterMotion.x * 0.3);
    vec2 mirrored = vec2(art.x + ripple * (0.42 + depth * 5.3), 0.645 - depth * 1.23);
    vec2 point = imageFrame.xy + mirrored * imageFrame.zw;
    vec4 image = texture(field, point);
    image = (image * 2.0 + texture(field, point + vec2(0.0032, 0.0))
        + texture(field, point - vec2(0.0032, 0.0))) * 0.25;

    float fade = water * waterMotion.y * (0.4 - lightAndTime.y * 0.23)
        * smoothstep(0.0, 0.035, depth) * (1.0 - smoothstep(0.25, 0.37, depth));
    vec4 reflection = vec4(image.rgb * vec3(0.47, 0.66, 0.72), image.a) * fade;

    float shadowShift = (lightAndTime.x - 0.5) * (0.08 + depth * 0.48);
    vec2 shadowPoint = point + vec2(shadowShift, -0.07);
    float shadowAlpha = (texture(field, shadowPoint).a + texture(field, shadowPoint + vec2(0.009, 0.004)).a
        + texture(field, shadowPoint - vec2(0.008, 0.003)).a) / 3.0;
    float shadow = shadowAlpha * water * lightAndTime.z * 0.16 * (1.0 - smoothstep(0.11, 0.32, depth));
    fragColor = (reflection + vec4(vec3(0.04, 0.07, 0.08), 1.0) * shadow * (1.0 - reflection.a)) * qt_Opacity;
}
