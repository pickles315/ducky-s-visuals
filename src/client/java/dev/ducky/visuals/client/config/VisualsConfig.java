package dev.ducky.visuals.client.config;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;

public final class VisualsConfig {
    private static final Path FILE = Path.of("config", "ducky-visuals.properties");
    public static boolean rimLighting = true;
    public static boolean volumetricShafts = false;
    public static boolean dynamicLighting = true;
    public static boolean foliageLighting = false;
    public static double rimStrength = 0.65;
    public static double rimThickness = 0.35;
    public static double shaftIntensity = 0.50;

    private VisualsConfig() {}

    public static void load() {
        Properties p = new Properties();
        if (Files.exists(FILE)) {
            try (InputStream in = Files.newInputStream(FILE)) { p.load(in); }
            catch (IOException e) { System.err.println("[Ducky's Visuals] Could not load config: " + e.getMessage()); }
        }
        rimLighting = Boolean.parseBoolean(p.getProperty("rimLighting", Boolean.toString(rimLighting)));
        volumetricShafts = Boolean.parseBoolean(p.getProperty("volumetricShafts", Boolean.toString(volumetricShafts)));
        dynamicLighting = Boolean.parseBoolean(p.getProperty("dynamicLighting", Boolean.toString(dynamicLighting)));
        foliageLighting = Boolean.parseBoolean(p.getProperty("foliageLighting", Boolean.toString(foliageLighting)));
        rimStrength = number(p, "rimStrength", rimStrength);
        rimThickness = number(p, "rimThickness", rimThickness);
        shaftIntensity = number(p, "shaftIntensity", shaftIntensity);
    }

    private static double number(Properties p, String key, double fallback) {
        try { return Math.max(0.0, Math.min(1.0, Double.parseDouble(p.getProperty(key, Double.toString(fallback))))); }
        catch (NumberFormatException ignored) { return fallback; }
    }

    public static void save() {
        Properties p = new Properties();
        p.setProperty("rimLighting", Boolean.toString(rimLighting));
        p.setProperty("volumetricShafts", Boolean.toString(volumetricShafts));
        p.setProperty("dynamicLighting", Boolean.toString(dynamicLighting));
        p.setProperty("foliageLighting", Boolean.toString(foliageLighting));
        p.setProperty("rimStrength", Double.toString(rimStrength));
        p.setProperty("rimThickness", Double.toString(rimThickness));
        p.setProperty("shaftIntensity", Double.toString(shaftIntensity));
        try {
            Files.createDirectories(FILE.getParent());
            try (OutputStream out = Files.newOutputStream(FILE)) { p.store(out, "Ducky's Visuals settings"); }
        } catch (IOException e) { System.err.println("[Ducky's Visuals] Could not save config: " + e.getMessage()); }
    }
}
