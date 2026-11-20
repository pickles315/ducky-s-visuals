# Ducky's Visuals

Ducky's Visuals now has two delivery paths for Minecraft Java 26.2:

- **Iris shader pack:** the native shader-pack implementation in `iris-shaderpack/`. This is the recommended path for full shader rendering.
- **Fabric mod:** the earlier Satin-based post-processing implementation, retained as a separate legacy add-on.

## Iris shader pack

The Iris pack uses the shader pipeline directly instead of trying to run a mod-owned post-effect over Iris.

Current implementation:
- Terrain G-buffer writes actual interpolated terrain normals to a dedicated color buffer.
- Terrain G-buffer writes a supplementary material estimate (foliage-like, water-like, bright, other).
- Composite pass reads the normal/material buffer and scene depth.
- Rim highlights use both normal discontinuities and depth discontinuities.
- A lightweight screen-space radial light glow is included.
- Iris shader settings expose rim strength, rim thickness, and light-glow strength.

### Install

1. Install Iris for Minecraft 26.2.
2. Download `ducky-s-visuals-iris-26.2.zip` from the GitHub Actions build artifact or release.
3. Put the ZIP in the Minecraft `shaderpacks` folder without extracting it.
4. Select **Ducky's Visuals** in Options → Video Settings → Shader Packs.

The Iris 26.2 build currently requires Iris' OpenGL rendering path; Iris 1.11.0+26.2 does not support Vulkan.

## Current limitations

- Material classes are visual estimates from texture color, not exact Minecraft block registry IDs.
- The dedicated normal/material buffer is currently populated by the terrain G-buffer. Other geometry still uses Iris fallback programs and does not yet write this same custom data.
- The light glow is screen-space approximation, not shadow-tested volumetric scattering.
- A true shadow-map pass, water-specific rendering, and full entity/block-entity material outputs are still planned.
- This shader pack has not yet been runtime-tested in Minecraft. A successful CI build will verify packaging and the legacy mod compilation, not guarantee Iris shader compilation or in-game rendering.

## Legacy Fabric mod

The existing Fabric mod remains available for users who want the original Satin post-processing implementation. It is separate from the Iris shader pack and is not required to load the Iris ZIP.
