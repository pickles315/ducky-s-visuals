#version 330

uniform sampler2D DepthSampler;

in vec2 texCoord;
out vec4 fragColor;

void main() {
    float depth = texture(DepthSampler, texCoord).r;
    // Reversed-Z depth: sky/far-plane pixels are close to zero.
    float geometryCoverage = smoothstep(0.0005, 0.025, depth);
    fragColor = vec4(geometryCoverage, geometryCoverage, geometryCoverage, 1.0);
}
