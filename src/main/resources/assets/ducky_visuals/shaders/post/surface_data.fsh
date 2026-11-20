#version 330

uniform sampler2D InSampler;
uniform sampler2D DepthSampler;

in vec2 texCoord;
out vec4 fragColor;

float linearDepth(float depth) {
    // Reversed-Z: depth 1 is near, depth 0 is far.
    const float nearPlane = 0.05;
    const float farPlane = 4096.0;
    return (nearPlane * farPlane) /
           max(nearPlane + depth * (farPlane - nearPlane), 1e-5);
}

vec3 reconstructNormal(vec2 uv, vec2 texel, float depth) {
    float z = linearDepth(depth);
    float zL = linearDepth(texture(DepthSampler, uv - vec2(texel.x, 0.0)).r);
    float zR = linearDepth(texture(DepthSampler, uv + vec2(texel.x, 0.0)).r);
    float zD = linearDepth(texture(DepthSampler, uv - vec2(0.0, texel.y)).r);
    float zU = linearDepth(texture(DepthSampler, uv + vec2(0.0, texel.y)).r);

    vec3 dx = vec3(2.0 * texel.x * z, 0.0, zR - zL);
    vec3 dy = vec3(0.0, 2.0 * texel.y * z, zU - zD);
    vec3 n = cross(dx, dy);
    float n2 = dot(n, n);
    return n2 > 1e-12 ? normalize(n) : vec3(0.0, 0.0, 1.0);
}

// Screen-color material estimate, not a block-ID lookup.
// 0.25 foliage-like, 0.50 water-like, 0.75 bright/emissive-like, 1.0 other.
float classifyMaterial(vec3 color) {
    float greenLead = color.g - max(color.r, color.b);
    float blueLead = color.b - max(color.r, color.g);
    float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
    if (greenLead > 0.055) return 0.25;
    if (blueLead > 0.065 && color.r < 0.42) return 0.50;
    if (brightness > 0.82) return 0.75;
    return 1.0;
}

void main() {
    float depth = texture(DepthSampler, texCoord).r;
    vec2 texel = 1.0 / vec2(textureSize(DepthSampler, 0));
    vec3 normal = reconstructNormal(texCoord, texel, depth);
    vec3 color = texture(InSampler, texCoord).rgb;
    float material = classifyMaterial(color);
    fragColor = vec4(normal * 0.5 + 0.5, material);
}
