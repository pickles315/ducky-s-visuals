package dev.ducky.visuals.client;

import dev.ducky.visuals.client.config.VisualsConfig;
import net.minecraft.resources.Identifier;
import org.ladysnake.satin.api.event.ShaderEffectRenderCallback;
import org.ladysnake.satin.api.managed.ManagedShaderEffect;
import org.ladysnake.satin.api.managed.ShaderEffectManager;

/** Applies depth-aware post-processing after the world has rendered. */
public final class VisualsRenderer {
    private static final ManagedShaderEffect EFFECT = ShaderEffectManager.getInstance()
            .manage(Identifier.fromNamespaceAndPath("ducky_visuals", "visuals"));
    private static boolean registered;

    private VisualsRenderer() {}

    public static void initialize() {
        if (registered) return;
        registered = true;
        ShaderEffectRenderCallback.EVENT.register(tickDelta -> {
            if (!VisualsConfig.rimLighting && !VisualsConfig.volumetricShafts) return;
            EFFECT.setUniformValue("RimEnabled", VisualsConfig.rimLighting ? 1.0f : 0.0f);
            EFFECT.setUniformValue("RimStrength", (float) VisualsConfig.rimStrength);
            EFFECT.setUniformValue("RimThickness", 1.0f + (float) VisualsConfig.rimThickness * 5.0f);
            EFFECT.setUniformValue("ShaftsEnabled", VisualsConfig.volumetricShafts ? 1.0f : 0.0f);
            EFFECT.setUniformValue("ShaftIntensity", (float) VisualsConfig.shaftIntensity);
            EFFECT.setUniformValue("FoliageResponse", VisualsConfig.foliageLighting ? 1.0f : 0.0f);
            EFFECT.setUniformValue("DynamicResponse", VisualsConfig.dynamicLighting ? 1.0f : 0.0f);
            EFFECT.setUniformValue("NormalResponse", 1.0f);
            EFFECT.render(tickDelta);
        });
    }
}
