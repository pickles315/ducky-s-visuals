#version 330

uniform sampler2D InSampler;
uniform sampler2D DepthSampler;
uniform sampler2D SurfaceDataSampler;
uniform sampler2D GeometryMaskSampler;

layout(std140) uniform VisualsConfig {
    float RimEnabled;
    float RimStrength;
    float RimThickness;
    float ShaftsEnabled;
    float ShaftIntensity;
    float FoliageResponse;
    float DynamicResponse;
    float NormalResponse;
};

in vec2 texCoord;
out vec4 fragColor;

float saturate(float x) { return clamp(x, 0.0, 1.0); }
float luminance(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

void main() {
    vec3 scene = texture(InSampler, texCoord).rgb;
    vec2 texel = 1.0 / vec2(textureSize(InSampler, 0));
    float opaque = texture(GeometryMaskSampler, texCoord).r;

    // SurfaceData stores view-space normal in RGB and a screen-color material
    // estimate in A (0.25 foliage-like, 0.50 water-like, 0.75 bright, 1.0 other).
    vec4 surfaceData = texture(SurfaceDataSampler, texCoord);
    vec3 normal = normalize(surfaceData.rgb * 2.0 - 1.0);
    float materialClass = surfaceData.a;
    float normalLight = 0.58 + 0.42 * max(dot(normal, normalize(vec3(-0.35, 0.65, 0.68))), 0.0);

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

        float foliageHint = 1.0 - smoothstep(0.08, 0.18, abs(materialClass - 0.25));
        float waterHint = 1.0 - smoothstep(0.08, 0.18, abs(materialClass - 0.50));
        float foliageMix = mix(1.0, 0.68 + foliageHint * 0.32, FoliageResponse);
        float sceneResponse = mix(1.0, 0.65 + luminance(scene) * 0.7, DynamicResponse);
        vec3 rimTint = mix(vec3(0.42, 0.58, 1.0), vec3(1.0, 0.78, 0.48),
                           saturate(1.0 - luminance(scene)));
        rimTint = mix(rimTint, vec3(0.28, 0.62, 0.92), waterHint * 0.35);
        float normalResponse = mix(1.0, normalLight, saturate(NormalResponse));
        scene += rimTint * edge * RimStrength * foliageMix * sceneResponse * normalResponse;
    }

    // Screen-space radial shafts; geometry coverage suppresses samples blocked by
    // visible scene geometry. This is not a shadow-map volumetric solution.
    if (ShaftsEnabled > 0.5) {
        const vec2 lightUv = vec2(0.5, 0.12);
        vec2 delta = (texCoord - lightUv) / 12.0;
        vec2 sampleUv = texCoord;
        float illumination = 0.0;
        float weight = 1.0;
        for (int i = 0; i < 12; ++i) {
            sampleUv -= delta;
            float sky = 1.0 - texture(GeometryMaskSampler, sampleUv).r;
            vec3 sampleColor = texture(InSampler, sampleUv).rgb;
            float bright = smoothstep(0.45, 1.25, luminance(sampleColor));
            illumination += bright * sky * weight;
            weight *= 0.91;
        }
        scene += vec3(1.0, 0.86, 0.62) * illumination * (ShaftIntensity / 12.0);
    }

    fragColor = vec4(max(scene, vec3(0.0)), 1.0);
}
