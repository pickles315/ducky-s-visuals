package dev.ducky.visuals.client;

import dev.ducky.visuals.client.config.VisualsConfig;
import dev.ducky.visuals.client.gui.VisualsScreen;
import net.fabricmc.api.ClientModInitializer;
import net.minecraft.client.gui.screens.Screen;

public final class DuckyVisualsClient implements ClientModInitializer {
    @Override
    public void onInitializeClient() {
        VisualsConfig.load();
    }

    /** Entry point called reflectively by Ducky's MC Utilities when this add-on is installed. */
    public static void openScreen(Screen parent) {
        net.minecraft.client.Minecraft.getInstance().gui.setScreen(new VisualsScreen(parent));
    }
}
