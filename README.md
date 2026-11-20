# Ducky's Visuals

A client-side visual add-on for **Ducky's MC Utilities** for Minecraft 26.2 (Fabric).

## Active effects

- **Depth-based rim lighting:** uses a depth-derived surface-normal buffer and visible-geometry coverage buffer to shape the edge response.
- **Screen-space light shafts:** gathers bright samples toward an upper-sky light source and uses the geometry coverage buffer to reject blocked samples.
- **Scene-adaptive response:** adjusts rim intensity using scene luminance.
- **Foliage and water response:** uses a screen-color material estimate to adjust rim tint and response.
- Settings are saved in `config/ducky-visuals.properties`.

## Screen-space data buffers

The post effect builds two intermediate GPU targets before compositing:

- **Surface data:** RGB stores a normal reconstructed from neighboring depth samples; alpha stores a coarse screen-color material estimate (foliage-like, water-like, bright, or other).
- **Geometry coverage:** stores whether a pixel has visible depth rather than sky/far-plane depth.

These are real intermediate screen-space textures consumed by the final effect. They are not a terrain-only mask or a true block/material ID buffer: entities are included in visible geometry, and material labels are visual estimates rather than block registry IDs. A terrain-only mask and exact per-block material IDs require a separate terrain draw pipeline.

The screen-space shafts remain a lightweight approximation. They do **not** use shadow-map aperture data or true light-space volumetric integration.

Minecraft 26.2 supports both OpenGL and Vulkan, so this implementation uses the renderer abstraction via Satin rather than raw OpenGL calls.

## Requirements

- Minecraft 26.2
- Fabric Loader 0.20.1+
- Fabric API 0.161.0+26.2
- Java 25+
- Ducky's MC Utilities
- Satin (included as a Jar-in-Jar dependency)

Install Ducky's Utilities and Ducky's Visuals in the `mods` folder. Ducky's Visuals includes its Satin runtime dependency.
