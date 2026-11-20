#version 330

uniform sampler2D InSampler;
uniform sampler2D DepthSampler;

layout(std140) uniform VisualsConfig {
    float RimEnabled;
    float RimStrength;
    float RimThickness;
    float ShaftsEnabled;
    float ShaftIntensity;
    float FoliageResponse;
    float DynamicResponse;
};

in vec2 texCoord;
out vec4 fragColor;

float saturate(float x) { return clamp(x, 0.0, 1.0); }
float luminance(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

void main() {
    vec3 scene = texture(InSampler, texCoord).rgb;
    vec2 texel = 1.0 / vec2(textureSize(InSampler, 0));
    float depth = texture(DepthSampler, texCoord).r;
    // 26.2 uses reversed Z: zero is the far plane/sky and one is the near plane.
    float opaque = smoothstep(0.0005, 0.025, depth);

    if (RimEnabled > 0.5 && opaque > 0.01) {
        vec2 d = texel * max(RimThickness, 1.0);
        float n = texture(DepthSampler, texCoord + vec2(0.0, d.y)).r;
        float s = texture(DepthSampler, texCoord - vec2(0.0, d.y)).r;
        float e = texture(DepthSampler, texCoord + vec2(d.x, 0.0)).r;
        float w = texture(DepthSampler, texCoord - vec2(d.x, 0.0)).r;
        float ne = texture(DepthSampler, texCoord + d).r;
        float sw = texture(DepthSampler, texCoord - d).r;
        float nw = texture(DepthSampler, texCoord + vec2(-d.x, d.y)).r;
        float se = texture(DepthSampler, texCoord + vec2(d.x, -d.y)).r;
        float gradient = max(max(abs(n - s), abs(e - w)),
                             max(abs(ne - sw), abs(nw - se)));
        float edge = smoothstep(0.012, 0.085, gradient) * opaque;
        float foliageHint = smoothstep(0.06, 0.34,
            max(scene.g - scene.r, 0.0) + max(scene.g - scene.b, 0.0));
        float foliageMix = mix(1.0, 0.68 + foliageHint * 0.32, FoliageResponse);
        float sceneResponse = mix(1.0, 0.65 + luminance(scene) * 0.7, DynamicResponse);
        vec3 rimTint = mix(vec3(0.42, 0.58, 1.0), vec3(1.0, 0.78, 0.48),
                           saturate(1.0 - luminance(scene)));
        scene += rimTint * edge * RimStrength * foliageMix * sceneResponse;
    }

    // Depth-aware screen-space light shafts. This samples bright sky toward
    // an upper-sky light source; it does not claim to read Minecraft's shadow map.
    if (ShaftsEnabled > 0.5) {
        const vec2 lightUv = vec2(0.5, 0.12);
        vec2 delta = (texCoord - lightUv) / 12.0;
        vec2 sampleUv = texCoord;
        float illumination = 0.0;
        float weight = 1.0;
        for (int i = 0; i < 12; ++i) {
            sampleUv -= delta;
            float sampleDepth = texture(DepthSampler, sampleUv).r;
            float sky = 1.0 - smoothstep(0.0005, 0.025, sampleDepth);
            vec3 sampleColor = texture(InSampler, sampleUv).rgb;
            float bright = smoothstep(0.45, 1.25, luminance(sampleColor));
            illumination += bright * sky * weight;
            weight *= 0.91;
        }
        scene += vec3(1.0, 0.86, 0.62) * illumination * (ShaftIntensity / 12.0);
    }

    fragColor = vec4(max(scene, vec3(0.0)), 1.0);
}
