#version 330 compatibility

uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform float alphaTestRef;

in vec2 texcoord;
in vec2 lmcoord;
in vec4 glcolor;
in vec3 worldNormal;

/* RENDERTARGETS: 0,1 */
layout(location = 0) out vec4 sceneColor;
layout(location = 1) out vec4 surfaceData;

void main() {
    vec4 albedo = texture(gtexture, texcoord) * glcolor;
    if (albedo.a < alphaTestRef) discard;

    vec3 litColor = albedo.rgb * texture(lightmap, lmcoord).rgb;
    sceneColor = vec4(litColor, albedo.a);

    vec3 n = normalize(worldNormal);
    float greenDominance = max(albedo.g - max(albedo.r, albedo.b), 0.0);
    float blueDominance = max(albedo.b - max(albedo.r, albedo.g), 0.0);
    float brightness = max(max(albedo.r, albedo.g), albedo.b);

    // Approximate surface class: 0=other, 1=foliage-like, 2=water-like, 3=bright.
    float materialClass = 0.0;
    if (greenDominance > 0.12) materialClass = 1.0;
    else if (blueDominance > 0.10) materialClass = 2.0;
    else if (brightness > 0.82) materialClass = 3.0;

    surfaceData = vec4(n * 0.5 + 0.5, materialClass / 3.0);
}
