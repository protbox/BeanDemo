local presets = {}

presets.small_score = {
    emitters = {
        { mode = "sparkle", n = 12, spd_min = 90, spd_max = 170, gravity = 140, drag = 2.6,
          size_min = 1.2, size_max = 2.2, colors = { {0.90, 0.95, 1.00} } },
    }
}

presets.medium_score = {
    emitters = {
        { mode = "sparkle", n = 18, spd_min = 120, spd_max = 200, gravity = 120, drag = 2.8,
          size_min = 1.4, size_max = 2.6, colors = { {0.90, 0.95, 1.00} } },
        { mode = "sparkle", n = 10, spd_min = 140, spd_max = 240, gravity = 140, drag = 2.6,
          size_min = 1.8, size_max = 3.2, colors = { {1.00, 0.90, 0.45} } },
        { mode = "sparkle", n = 3,  spd_min = 90,  spd_max = 140, gravity = 100, drag = 3.2,
          size_min = 2.8, size_max = 3.6, colors = { {1.00, 0.95, 0.70} } },
    }
}

presets.coin_pop = {
    emitters = {
        { mode = "ring", n = 1, size_min = 8, size_max = 8, life_min = 0.25, life_max = 0.35,
          gravity = 0, drag = 1, colors = { {1, 0.95, 0.7} }, fade_pow = 2.0 },
        { mode = "sparkle", n = 10, spd_min = 80, spd_max = 160, gravity = 140, drag = 3.0,
          size_min = 1.2, size_max = 2.2, colors = { {1, 0.95, 0.7} } },
    }
}

presets.firework_burst = {
    emitters = {
        { mode = "sparkle", n = 22, spd_min = 140, spd_max = 260, gravity = 160, drag = 2.8,
          colors = { {1.00, 0.90, 0.45} } },
        { mode = "sparkle", n = 18, spd_min = 120, spd_max = 220, gravity = 160, drag = 2.8,
          colors = { {1.00, 0.45, 0.55} } },
        { mode = "sparkle", n = 18, spd_min = 120, spd_max = 220, gravity = 160, drag = 2.8,
          colors = { {0.45, 0.80, 1.00} } },
        { mode = "sparkle", n = 18, spd_min = 120, spd_max = 220, gravity = 160, drag = 2.8,
          colors = { {1.00, 0.70, 1.00} } },
    }
}

presets.ice_shatter = {
    emitters = {
        { mode = "shard", n = 22, spd_min = 220, spd_max = 420, gravity = 300, drag = 2.0,
          size_min = 2.2, size_max = 4.2, colors = { {0.85, 0.95, 1.00}, {0.65, 0.85, 1.00} }, fade_pow = 2.4 },
        { mode = "sparkle", n = 14, spd_min = 120, spd_max = 240, gravity = 260, drag = 2.4,
          size_min = 1.1, size_max = 2.0, colors = { {0.90, 0.97, 1.00}, {0.75, 0.90, 1.00} }, fade_pow = 2.6 },
        { mode = "ring", n = 1, size_min = 7, size_max = 11, life_min = 0.18, life_max = 0.26,
          gravity = 0, drag = 1.0, colors = { {0.80, 0.92, 1.00} }, fade_pow = 2.6 },
    }
}

presets.arrow_impact = {
    emitters = {
        { mode = "streak", n = 8, spd_min = 200, spd_max = 320, gravity = 360, drag = 2.6,
          size_min = 1.2, size_max = 2.0, colors = { {1.00, 0.90, 0.45}, {1.00, 0.75, 0.35} }, fade_pow = 2.2 },
        { mode = "sparkle", n = 10, spd_min = 90, spd_max = 160, gravity = 300, drag = 3.2,
          size_min = 1.0, size_max = 1.8, colors = { {1.00, 0.95, 0.70} }, fade_pow = 2.4 },
        { mode = "ring", n = 1, size_min = 4, size_max = 6, life_min = 0.12, life_max = 0.18,
          gravity = 0, drag = 1.0, colors = { {1.00, 0.85, 0.40} }, fade_pow = 2.4 },
        { mode = "dot", n = 10, spd_min = 60, spd_max = 120, gravity = 260, drag = 4.0,
          size_min = 0.8, size_max = 1.4, colors = { {0.55, 0.50, 0.45}, {0.45, 0.42, 0.38} },
          life_min = 0.30, life_max = 0.55, fade_pow = 2.0 },
        { mode = "circle", n = 1, size_min = 8, size_max = 12, life_min = 0.20, life_max = 0.28,
          gravity = 0, drag = 1.0, colors = { {1.00, 0.90, 0.50}, {1.00, 0.75, 0.35} }, fade_pow = 2.6 },
    }
}

presets.dust_cloud_thick = {
    emitters = {
        { mode = "dot", n = 60, spd_min = 100, spd_max = 240, gravity = 90, drag = 3.2,
          size_min = 3.2, size_max = 6.0, colors = { {0.60, 0.55, 0.50}, {0.50, 0.46, 0.42}, {0.42, 0.38, 0.34} },
          life_min = 0.90, life_max = 1.40, fade_pow = 2.2 },
        { mode = "dot", n = 40, spd_min = 80, spd_max = 180, gravity = 100, drag = 3.4,
          size_min = 2.2, size_max = 4.0, colors = { {0.50, 0.46, 0.42}, {0.42, 0.38, 0.34} },
          life_min = 1.00, life_max = 1.60, fade_pow = 2.4 },
        { mode = "ring", n = 1, size_min = 14, size_max = 20, life_min = 0.35, life_max = 0.55,
          gravity = 0, drag = 1.0, colors = { {0.65, 0.58, 0.50} }, fade_pow = 2.0 },
        { mode = "circle", n = 1, size_min = 24, size_max = 24, life_min = 0.40, life_max = 0.60,
          gravity = 0, drag = 1.0, colors = { {0.55, 0.50, 0.45}, {0.45, 0.42, 0.38} }, fade_pow = 2.8 },
    }
}

presets.lightning_strike = {
    emitters = {
        { mode = "streak", n = 3, spd_min = 600, spd_max = 900, gravity = 800, drag = 0.5,
          life_min = 0.08, life_max = 0.14, size_min = 3.0, size_max = 5.0,
          colors = { {1.00, 1.00, 1.00}, {0.70, 0.90, 1.00} }, fade_pow = 2.0 },
        { mode = "streak", n = 10, spd_min = 300, spd_max = 600, gravity = 600, drag = 0.8,
          life_min = 0.10, life_max = 0.18, size_min = 1.4, size_max = 2.2,
          colors = { {0.85, 0.95, 1.00}, {0.50, 0.80, 1.00} }, fade_pow = 2.2 },
        { mode = "dot", n = 16, spd_min = 60, spd_max = 120, gravity = 200, drag = 3.0,
          life_min = 0.06, life_max = 0.12, size_min = 4.0, size_max = 7.0,
          colors = { {1.00, 1.00, 1.00}, {1.00, 0.95, 0.80} }, fade_pow = 1.8 },
        { mode = "sparkle", n = 20, spd_min = 200, spd_max = 360, gravity = 400, drag = 1.6,
          life_min = 0.15, life_max = 0.30, size_min = 1.0, size_max = 1.8,
          colors = { {0.85, 0.95, 1.00}, {0.50, 0.70, 1.00} }, fade_pow = 2.4 },
        { mode = "ring", n = 1, size_min = 12, size_max = 18, life_min = 0.14, life_max = 0.22,
          gravity = 0, drag = 1.0, colors = { {0.90, 0.95, 1.00} }, fade_pow = 2.8 },
    }
}

presets.fire_blast = {
    emitters = {
        { mode = "sparkle", n = 30, spd_min = 180, spd_max = 360, gravity = 280, drag = 2.2,
          life_min = 0.18, life_max = 0.35, size_min = 1.4, size_max = 2.2,
          colors = { {1.00, 0.90, 0.45}, {1.00, 0.65, 0.20} }, fade_pow = 2.0 },
        { mode = "shard", n = 16, spd_min = 160, spd_max = 300, gravity = 320, drag = 2.2, spin = 4,
          life_min = 0.22, life_max = 0.45, size_min = 2.2, size_max = 3.6,
          colors = { {1.00, 0.55, 0.20}, {0.95, 0.30, 0.10} }, fade_pow = 2.0 },
        { mode = "streak", n = 10, spd_min = 140, spd_max = 260, gravity = 360, drag = 2.8,
          life_min = 0.20, life_max = 0.32, size_min = 0.8, size_max = 1.4,
          colors = { {1.00, 0.80, 0.40} }, fade_pow = 2.0 },
        { mode = "ring", n = 1, size_min = 10, size_max = 16, life_min = 0.22, life_max = 0.36,
          gravity = 0, drag = 1.0, colors = { {1.00, 0.70, 0.25} }, fade_pow = 2.2 },
        { mode = "dot", blend = "alpha", n = 24, spd_min = 40, spd_max = 120, gravity = -60, drag = 5.0,
          life_min = 0.90, life_max = 1.60, size_min = 2.6, size_max = 5.0,
          colors = { {0.40, 0.36, 0.32}, {0.32, 0.30, 0.28} }, fade_pow = 2.4 },
        { mode = "dot", blend = "alpha", n = 18, spd_min = 20, spd_max = 80, gravity = -40, drag = 5.4,
          life_min = 1.20, life_max = 2.00, size_min = 3.0, size_max = 6.0,
          colors = { {0.30, 0.28, 0.26}, {0.22, 0.20, 0.18} }, fade_pow = 2.6 },
    }
}

presets.confetti_explosion = {
    emitters = {
        { mode = "shard", n = 90, spd_min = 220, spd_max = 420, gravity = 520, drag = 1.8,
          life_min = 0.90, life_max = 1.50, size_min = 2.2, size_max = 3.8, spin = 6,
          colors = {
            {1.00, 0.35, 0.35}, {1.00, 0.75, 0.25}, {0.30, 0.85, 0.40},
            {0.30, 0.65, 1.00}, {0.75, 0.45, 1.00}, {1.00, 0.55, 0.80}
          },
          fade_pow = 2.2 },
        { mode = "shard", n = 45, spd_min = 180, spd_max = 320, gravity = 560, drag = 2.2,
          life_min = 1.00, life_max = 1.70, size_min = 1.6, size_max = 2.6, spin = 8,
          colors = {
            {1.00, 0.85, 0.30}, {0.25, 0.90, 0.80}, {0.95, 0.40, 0.30},
            {0.35, 0.55, 1.00}, {0.95, 0.60, 0.20}, {0.60, 0.95, 0.30}
          },
          fade_pow = 2.4 },
        { mode = "ring", n = 1, size_min = 14, size_max = 22, life_min = 0.22, life_max = 0.34,
          gravity = 0, drag = 1.0, colors = { {1.00, 0.95, 0.80} }, fade_pow = 2.2 },
        { mode = "sparkle", n = 18, spd_min = 120, spd_max = 220, gravity = 220, drag = 2.8,
          life_min = 0.20, life_max = 0.40, size_min = 1.2, size_max = 2.0,
          colors = { {1.00, 0.95, 0.90}, {1.00, 0.90, 0.60} }, fade_pow = 2.6 },
    }
}

presets.heal_burst = {
    emitters = {
        { mode = "sparkle", n = 28, spd_min = 120, spd_max = 260, gravity = 120, drag = 2.0,
          life_min = 0.22, life_max = 0.40, size_min = 1.2, size_max = 2.0,
          colors = { {0.90, 1.00, 0.90}, {0.60, 0.95, 0.70} }, fade_pow = 2.0 },
        { mode = "ring", n = 1, size_min = 10, size_max = 16, life_min = 0.24, life_max = 0.38,
          gravity = 0, drag = 1.0, colors = { {0.75, 1.00, 0.80} }, fade_pow = 2.2 },
        { mode = "dot", n = 12, spd_min = 20, spd_max = 60, gravity = -40, drag = 3.8,
          life_min = 0.90, life_max = 1.40, size_min = 1.6, size_max = 2.6,
          colors = { {0.55, 0.95, 0.65}, {0.45, 0.85, 0.55} }, fade_pow = 2.6 },
    }
}

presets.leaf_fall = {
    emitters = {
        { mode = "shard", n = 18, spd_min = 40, spd_max = 90, gravity = 220, drag = 4.2, spin = 6,
          life_min = 1.40, life_max = 2.20, size_min = 2.2, size_max = 3.4,
          colors = { {0.85, 0.65, 0.25}, {0.70, 0.45, 0.20}, {0.55, 0.75, 0.35} }, fade_pow = 2.6 },
        { mode = "shard", n = 12, spd_min = 30, spd_max = 70, gravity = 260, drag = 4.6, spin = 8,
          life_min = 1.60, life_max = 2.60, size_min = 1.6, size_max = 2.6,
          colors = { {0.90, 0.75, 0.30}, {0.65, 0.50, 0.25} }, fade_pow = 2.8 },
    }
}

-- hey buddy, don't forget to override angle for this one so the trail goes in the direction you want
-- okay, I'm out for now. bye love u
presets.slash_trail = {
    emitters = {
        { mode = "streak", n = 14, spd_min = 320, spd_max = 520, gravity = 200, drag = 1.2,
          angle = 0, spread = 0.50, life_min = 0.08, life_max = 0.14, size_min = 1.6, size_max = 2.6,
          colors = { {1.00, 0.95, 0.85}, {1.00, 0.85, 0.50} }, fade_pow = 2.0 },
        { mode = "sparkle", n = 10, spd_min = 160, spd_max = 300, gravity = 260, drag = 1.8,
          angle = 0, spread = 0.80, life_min = 0.10, life_max = 0.18, size_min = 1.0, size_max = 1.6,
          colors = { {1.00, 0.95, 0.85} }, fade_pow = 2.2 },
        { mode = "ring", n = 1, size_min = 6, size_max = 10, life_min = 0.10, life_max = 0.16,
          gravity = 0, drag = 1.0, colors = { {1.00, 0.90, 0.60} }, fade_pow = 2.4 },
    }
}

presets.fire_embers = {
    emitters = {
        { mode = "sparkle", n = 18, spd_min = 20, spd_max = 80, gravity = -60, drag = 5.0,
          life_min = 1.20, life_max = 2.20, size_min = 1.0, size_max = 1.8,
          colors = { {1.00, 0.80, 0.40}, {1.00, 0.65, 0.25} }, fade_pow = 2.6 },
        { mode = "dot", n = 14, spd_min = 10, spd_max = 60, gravity = -40, drag = 5.4,
          life_min = 1.40, life_max = 2.60, size_min = 1.2, size_max = 2.2,
          colors = { {0.90, 0.55, 0.25}, {0.80, 0.45, 0.20} }, fade_pow = 2.8 },
        { mode = "dot", n = 10, spd_min = 0, spd_max = 30, gravity = -30, drag = 6.0,
          life_min = 1.80, life_max = 3.20, size_min = 1.0, size_max = 1.6,
          colors = { {0.70, 0.40, 0.20}, {0.55, 0.32, 0.16} }, fade_pow = 3.0 },
    }
}


return presets
