# Ducky's Visuals

A client-side visual add-on for **Ducky's MC Utilities** for Minecraft 26.2 (Fabric).

## Features in this initial build
- A matching Ducky's Visuals settings screen opened from Ducky's Utilities.
- Persistent toggles for rim lighting, volumetric light shafts, dynamic day/night lighting, and foliage-aware lighting.
- Persistent strength/thickness/intensity controls.
- Automatic versioned GitHub prereleases and build artifacts.

**Rendering status:** the supplied GLSL is the design/source material for the effects. This initial build establishes the add-on, settings UI, and saved configuration; the GLSL passes are not yet connected to Minecraft's render graph, so the toggles currently save settings but do not yet change rendered pixels. The rendering integration is the next implementation stage and requires backend-specific render pipeline hooks.

## Requirements
- Minecraft 26.2
- Fabric Loader 0.20.1+
- Fabric API 0.161.0+26.2
- Java 25+
- Ducky's MC Utilities (required)

Install both Ducky's `.jar` files in the `mods` folder.
