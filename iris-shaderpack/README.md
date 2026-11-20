# Ducky's Visuals — Iris Shader Pack

This is the Iris-native shader-pack edition of Ducky's Visuals for Minecraft Java 26.2.

## Install

1. Install Iris for Minecraft 26.2 and launch once.
2. Put `Duckys-Visuals-Iris-26.2.zip` in the Minecraft `shaderpacks` folder.
3. Select **Ducky's Visuals** in Options → Video Settings → Shader Packs.
4. Open Shader Pack Settings to adjust rim highlights and light-shaft strength.

## Current rendering features

- Terrain G-buffer pass writes the normal map directly from Minecraft's terrain vertex normals.
- Terrain pass writes a supplementary surface-data buffer with approximate foliage-like, water-like, bright, and other classes based on sampled texture color.
- Composite pass reads the normal/material buffer and depth buffer.
- Screen-space edge highlights use both normal discontinuities and depth discontinuities.
- Lightweight radial screen-space light glow.

## Known limitations

- The surface classes are color heuristics, not exact registry/block IDs.
- This first pack pass writes the custom normal/material buffer for terrain. Other geometry uses Iris fallback programs and does not yet write the same custom data.
- Light shafts are a screen-space approximation. The shadow map is configured but a true shadow-tested volumetric scattering pass is not implemented yet.
- The pack targets Iris' OpenGL rendering path. Iris 1.11.0+26.2 notes that Vulkan is not supported.

This is an initial native Iris shader-pack conversion, not yet a fully tested graphics release. It must be loaded in-game on the target Minecraft/Iris version before the effects can be considered runtime-verified.
