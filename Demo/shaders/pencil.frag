#version 440
layout(location=0) in vec2 qt_TexCoord0;
layout(location=0) out vec4 fragColor;
layout(std140,binding=0) uniform buf { mat4 qt_Matrix; float qt_Opacity; };
layout(binding=1) uniform sampler2D source;
void main() {
 vec2 uv=qt_TexCoord0; vec2 d=vec2(1.0/512.0);
 vec4 a=texture(source,uv);float l=dot(a.rgb,vec3(.299,.587,.114));
 float edge=length(texture(source,uv+vec2(d.x*2,0)).rgb-texture(source,uv-vec2(d.x*2,0)).rgb)
          +length(texture(source,uv+vec2(0,d.y*2)).rgb-texture(source,uv-vec2(0,d.y*2)).rgb);
 float hatch=step(.62,fract((gl_FragCoord.x+gl_FragCoord.y)*.19));
 float paper=clamp(.82-edge*1.8-l*.40-hatch*l*.22,.08,.92);
 fragColor=vec4(vec3(paper)*vec3(1.0,.94,.81),1)*qt_Opacity;
}
