# Ducky's Visuals

A client-side visual add-on for **Ducky's MC Utilities** for Minecraft 26.2 (Fabric).

## Active effects

- **Depth-based rim lighting:** samples Minecraft's scene depth and adds a configurable colored edge highlight around visible geometry.
- **Screen-space light shafts:** gathers bright, unobstructed sky samples toward an upper-sky light source to create a radial light-shaft effect.
- **Scene-adaptive response:** adjusts rim intensity using scene luminance.
- **Foliage response:** uses a screen-color heuristic to adjust the rim response in green-dominant areas.
- Settings are saved in `config/ducky-visuals.properties`.

The post effect is registered through Satin's Minecraft 26.2 shader-effect API and runs after world rendering. It samples the main color and copied depth buffer, and uses a ping-pong render target so it does not read and write the same target in one pass.

## Important rendering scope

The screen-space shafts are a lightweight approximation. They do **not** use the supplied shadow-map aperture shader, a generated terrain-only mask, or a true volumetric light-space integration pass. Likewise, rim lighting currently detects depth discontinuities across visible geometry rather than using a terrain-only mask. The supplied terrain-mask and shadow-aperture GLSL files remain included as source for a later full shadow/terrain pipeline implementation.

Minecraft 26.2 supports both OpenGL and Vulkan, so this implementation uses the renderer abstraction via Satin rather than raw OpenGL calls.

## Requirements

- Minecraft 26.2
- Fabric Loader 0.20.1+
- Fabric API 0.161.0+26.2
- Java 25+
- Ducky's MC Utilities
- Satin (included as a Jar-in-Jar dependency)

Install Ducky's Utilities and Ducky's Visuals in the `mods` folder. Ducky's Visuals includes its Satin runtime dependency.
