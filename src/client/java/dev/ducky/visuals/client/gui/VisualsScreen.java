package dev.ducky.visuals.client.gui;

import dev.ducky.visuals.client.config.VisualsConfig;
import net.minecraft.client.gui.GuiGraphicsExtractor;
import net.minecraft.client.gui.components.Button;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.network.chat.Component;

public final class VisualsScreen extends Screen {
    private final Screen parent;
    public VisualsScreen(Screen parent) { super(Component.literal("Ducky's Visuals")); this.parent = parent; }

    @Override protected void init() {
        clearWidgets();
        int panelWidth = Math.max(1, Math.min(660, width - 16));
        int buttonWidth = Math.min(360, panelWidth - 28);
        int x = (width - buttonWidth) / 2;
        int top = 68;
        int h = 24;
        int gap = 9;
        addRenderableWidget(toggle("Rim lighting", () -> VisualsConfig.rimLighting, v -> VisualsConfig.rimLighting = v, x, top, buttonWidth, h));
        addRenderableWidget(toggle("Volumetric light shafts", () -> VisualsConfig.volumetricShafts, v -> VisualsConfig.volumetricShafts = v, x, top + (h + gap), buttonWidth, h));
        addRenderableWidget(toggle("Dynamic day / night lighting", () -> VisualsConfig.dynamicLighting, v -> VisualsConfig.dynamicLighting = v, x, top + 2 * (h + gap), buttonWidth, h));
        addRenderableWidget(toggle("Foliage-aware lighting", () -> VisualsConfig.foliageLighting, v -> VisualsConfig.foliageLighting = v, x, top + 3 * (h + gap), buttonWidth, h));
        addRenderableWidget(Button.builder(Component.literal("Rim strength: " + percent(VisualsConfig.rimStrength)), b -> {
            VisualsConfig.rimStrength = step(VisualsConfig.rimStrength); b.setMessage(Component.literal("Rim strength: " + percent(VisualsConfig.rimStrength))); VisualsConfig.save();
        }).bounds(x, top + 4 * (h + gap), buttonWidth, h).build());
        addRenderableWidget(Button.builder(Component.literal("Rim thickness: " + percent(VisualsConfig.rimThickness)), b -> {
            VisualsConfig.rimThickness = step(VisualsConfig.rimThickness); b.setMessage(Component.literal("Rim thickness: " + percent(VisualsConfig.rimThickness))); VisualsConfig.save();
        }).bounds(x, top + 5 * (h + gap), buttonWidth, h).build());
        addRenderableWidget(Button.builder(Component.literal("Shaft intensity: " + percent(VisualsConfig.shaftIntensity)), b -> {
            VisualsConfig.shaftIntensity = step(VisualsConfig.shaftIntensity); b.setMessage(Component.literal("Shaft intensity: " + percent(VisualsConfig.shaftIntensity))); VisualsConfig.save();
        }).bounds(x, top + 6 * (h + gap), buttonWidth, h).build());
        addRenderableWidget(Button.builder(Component.literal("Done"), b -> { VisualsConfig.save(); minecraft.gui.setScreen(parent); })
                .bounds(width - x - 92, height - 34, 80, 20).build());
    }

    private interface Getter { boolean get(); }
    private interface Setter { void set(boolean value); }
    private Button toggle(String name, Getter getter, Setter setter, int x, int y, int w, int h) {
        return Button.builder(text(name, getter.get()), b -> { setter.set(!getter.get()); b.setMessage(text(name, getter.get())); VisualsConfig.save(); })
                .bounds(x, y, w, h).build();
    }
    private static Component text(String name, boolean enabled) { return Component.literal(name + ": " + (enabled ? "ON" : "OFF")); }
    private static double step(double v) { return v >= 0.95 ? 0.0 : Math.min(1.0, v + 0.1); }
    private static String percent(double v) { return Math.round(v * 100) + "%"; }

    @Override public void extractRenderState(GuiGraphicsExtractor graphics, int mouseX, int mouseY, float partialTick) {
        int panelWidth = Math.max(1, Math.min(660, width - 16));
        int left = (width - panelWidth) / 2;
        graphics.fill(left, 8, left + panelWidth, height - 8, 0xE90B0B0B);
        graphics.fill(left, 8, left + panelWidth, 11, 0xFFFFD52A);
        graphics.text(font, Component.literal("DUCKY'S VISUALS"), left + 14, 18, 0xFFFFD52A);
        graphics.text(font, Component.literal("Visual effects and lighting controls"), left + 14, 38, 0xFFAAAAAA);
        super.extractRenderState(graphics, mouseX, mouseY, partialTick);
    }
    @Override public void onClose() { VisualsConfig.save(); minecraft.gui.setScreen(parent); }
}
