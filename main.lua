bean = require "bean"

bean.start {
    width = 384*2, -- can't be bothered multiplying in my head loool
    height = 216*2,
    scale = 2,
    crisp = true,
    fx = true,
    controls = {
        ["mouse1"]  = {'mouse:1'},
        ["mouse2"]  = {'mouse:2'},
        ["restart"] = {'key:r'},
        ["1"] = {'key:1'},
        ["2"] = {'key:2'}
    }
}

bean.load_font("font", "fonts/PressStart2P-Regular.ttf", 12)

bean.load_sprite("background", "img/background.png")
bean.load_sprite("hex", "img/hex.png")
bean.load_sprite("hex_highlight", "img/hex_highlight.png")
bean.load_sprite("hex_highlight_target", "img/hex_highlight_target.png")
bean.load_sprite("gems", "img/gems.png", {
    sliceX = 6,
    sliceY = 1,
})

bean.load_sound("click", "snd/notif.wav", { blocker = true })
bean.load_sound("spawn_ray", "snd/pop_small.wav", { blocker = true })
bean.load_sound("spawn_pulse", "snd/pop_high.wav", { blocker = true })
bean.load_sound("spawn_star", "snd/pop_crunch.wav", { blocker = true })
bean.load_sound("spawn_converter", "snd/pop_wet.wav", { blocker = true })
bean.load_sound("spawn_blocker", "snd/pop_low.wav", { blocker = true })
bean.load_sound("armed", "snd/pop_medium.wav", { overlap = true })
bean.load_sound("ray", "snd/ray.wav", { overlap = true })
bean.load_sound("star", "snd/star.wav", { overlap = true })
bean.load_sound("pulse", "snd/pulse.wav", { overlap = true })
bean.load_sound("converter", "snd/converter.wav", { overlap = true })

bean.scene("game", require("scenes.game"))

bean.go("game")