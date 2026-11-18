/* Shadertoy-compatible test scene. Single pass, no textures. */
float hash21(vec2 p)
{
    vec3 q = fract(vec3(p.xyx) * 0.1031);
    q += dot(q, q.yzx + 33.33);
    return fract((q.x + q.y) * q.z);
}

float stars(vec2 uv, float density, float drift)
{
    vec2 grid = uv * density + vec2(iTime * drift, 0.0);
    vec2 cell = floor(grid);
    float seed = hash21(cell);
    vec2 centre = vec2(hash21(cell + 7.0), hash21(cell - 11.0)) * 0.66 + 0.17;
    float radius = mix(0.025, 0.075, seed * seed);
    float twinkle = 0.72 + 0.28 * sin(iTime * 1.3 + seed * 6.283);
    float size = length(fract(grid) - centre);
    return (1.0 - smoothstep(radius, radius + 0.030, size)) * twinkle * step(0.52, seed);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord - iResolution.xy * 0.5) / iResolution.y;
    float band = exp(-7.0 * abs(uv.y - 0.18 * uv.x + 0.07));
    vec3 colour = vec3(0.024, 0.035, 0.079) + band * vec3(0.053, 0.038, 0.089);
    colour += stars(uv, 56.0, 0.07) * vec3(0.34, 0.42, 0.62);
    colour += stars(uv, 30.0, 0.13) * vec3(0.55, 0.64, 0.81);
    fragColor = vec4(colour, 1.0);
}
