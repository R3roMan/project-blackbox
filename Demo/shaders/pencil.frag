#version 440
layout(location=0) in vec2 qt_TexCoord0;
layout(location=0) out vec4 fragColor;
layout(std140,binding=0) uniform buf { mat4 qt_Matrix; float qt_Opacity; };
layout(binding=1) uniform sampler2D source;
void main() {
    vec2 uv = qt_TexCoord0;
    vec2 tap = vec2(.003);
    vec4 base = texture(source,uv);
    float grey = dot(base.rgb / max(0.01,base.a),vec3(.299,.587,.114));
    float edges = length(texture(source,uv+vec2(tap.x,0)).rgb - texture(source,uv-vec2(tap.x,0)).rgb)
        + length(texture(source,uv+vec2(0,tap.y)).rgb - texture(source,uv-vec2(0,tap.y)).rgb);
    float hatch = smoothstep(.48,.86,fract((gl_FragCoord.x-gl_FragCoord.y)*.21));
    float ink = clamp(.30+(1.0-grey)*.46+hatch*.16+edges*.28,0.0,1.0);
    float alpha = base.a * ink * qt_Opacity;
    vec3 tone = mix(vec3(.18,.084,.084),base.rgb/max(.01,base.a),.28);
    fragColor = vec4(tone*alpha,alpha);
}
