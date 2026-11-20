#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;
uniform float viewWidth;
uniform float viewHeight;

in vec2 texcoord;

#define DUCKY_RIM_STRENGTH 0.28 // [0.0 0.05 0.10 0.15 0.20 0.28 0.35 0.45 0.60]
#define DUCKY_RIM_THICKNESS 1.0 // [0.5 0.75 1.0 1.5 2.0 3.0]
#define DUCKY_SHAFT_STRENGTH 0.12 // [0.0 0.03 0.06 0.12 0.18 0.25 0.35]

vec3 decodeNormal(vec3 encoded) {
    return normalize(encoded * 2.0 - 1.0);
}

void main() {
    vec2 pixel = 1.0 / vec2(viewWidth, viewHeight);
    vec4 base = texture(colortex0, texcoord);
    vec4 surface = texture(colortex1, texcoord);
    float depth = texture(depthtex0, texcoord).r;

    vec3 normal = decodeNormal(surface.rgb);
    float materialClass = surface.a * 3.0;

    vec3 normalX = decodeNormal(texture(colortex1, texcoord + vec2(pixel.x * DUCKY_RIM_THICKNESS, 0.0)).rgb);
    vec3 normalY = decodeNormal(texture(colortex1, texcoord + vec2(0.0, pixel.y * DUCKY_RIM_THICKNESS)).rgb);
    float normalEdge = max(length(normal - normalX), length(normal - normalY));

    float depthX = texture(depthtex0, texcoord + vec2(pixel.x * DUCKY_RIM_THICKNESS, 0.0)).r;
    float depthY = texture(depthtex0, texcoord + vec2(0.0, pixel.y * DUCKY_RIM_THICKNESS)).r;
    float depthEdge = max(abs(depth - depthX), abs(depth - depthY));
    float edge = smoothstep(0.035, 0.22, normalEdge) * 0.65
               + smoothstep(0.001, 0.018, depthEdge) * 0.35;

    float foliageBoost = 1.0 + step(0.65, materialClass) * 0.12;
    vec3 rimTint = vec3(0.52, 0.72, 1.0);
    vec3 rim = rimTint * edge * DUCKY_RIM_STRENGTH * foliageBoost * step(0.00001, depth);

    // Subtle screen-space sun glow approximation; this is not shadow-map volumetrics.
    vec2 lightOrigin = vec2(0.5, 0.82);
    vec2 delta = texcoord - lightOrigin;
    float radial = 0.0;
    for (int i = 1; i <= 8; i++) {
        float t = float(i) / 8.0;
        vec2 sampleUv = texcoord - delta * t * 0.82;
        float sampleDepth = texture(depthtex0, sampleUv).r;
        radial += step(0.00001, sampleDepth) * (1.0 - t) * 0.125;
    }
    float shaftMask = smoothstep(0.15, 0.95, radial);
    vec3 shafts = vec3(1.0, 0.88, 0.68) * shaftMask * DUCKY_SHAFT_STRENGTH;

    vec3 result = base.rgb + rim + shafts;
    gl_FragColor = vec4(result, base.a);
}
