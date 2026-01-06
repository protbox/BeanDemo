local b = {}
local lg = love.graphics

local PATH = ...
require(PATH ..".run")
local res = require(PATH .. ".res")
local flux = require(PATH .. ".flux")
local baton = require(PATH .. ".baton")
-- don't bother loading these unless you actually want them
local shimmer
local presets

--[[ helpers ]]
local function hex_to_color(hex, alpha)
    return { tonumber("0x" .. hex:sub(1,2)) / 255,
           tonumber("0x" .. hex:sub(3,4)) / 255,
           tonumber("0x" .. hex:sub(5,6)) / 255,
           alpha or 1 }
end

local function load_palette(path)
    local image_data = love.image.newImageData(path)
    local width, height = image_data:getDimensions()
    
    local cell_size = 8
    local cols = 8
    local rows = math.floor(height / cell_size)
    
    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            local x = col * cell_size + cell_size / 2
            local y = row * cell_size + cell_size / 2
            
            local r, g, b, a = image_data:getPixel(x, y)
            
            local index = row * cols + col + 1
            slack.col[index] = {r, g, b, a}
        end
    end
end

local function point_in_rect(px, py, x, y, w, h)
    return px >= x and px <= x + w
       and py >= y and py <= y + h
end

-- enums
local ANCHOR = {
    DEFAULT = 1,
    CENTER = 2
}

function b.start(opts)
    local defaults = {
        background = "1d173c",
        crisp = false,
        width = 320*4,
        height = 180*4,
        fx = false,
        scale = 1,
        controls = {
            ["up"]      = {'key:up', 'button:dpup'},
            ["down"]    = {'key:down', 'button:dpdown'},
            ["left"]    = {'key:left', 'button:dpleft'},
            ["right"]   = {'key:right', 'button:dpright'},
            ["x"]       = {'key:x', 'button:a'},
            ["z"]       = {'key:z', 'button:x'},
            ["start"]   = {'key:return', 'button:start'},
            ["select"]  = {'key:lshift', 'button:back'}
        }
    }

    b.opts = {}
    for k, v in pairs(defaults) do
        b.opts[k] = opts and opts[k] ~= nil and opts[k] or v
    end

    if b.opts.fx then
        shimmer = require(PATH .. ".shimmer")
        presets = require(PATH .. ".shimmer.presets")
    end

    b.opts.background = hex_to_color(b.opts.background)

    -- the crisp option enables pixel art optimizationings
    if b.opts.crisp then
        lg.setDefaultFilter("nearest", "nearest")
        lg.setLineStyle("rough")
    end

    b.scenes = {}
    b.world = {}
    b.systems = {}
    b.sprites = {}
    b.sounds = {}
    b.audio = {}
    b.flux = flux.group()
    b.fonts = {}

    local default_font = lg.newFont(opts.font_size or 12)
    b.fonts.font = default_font

    --[[ system draw functions ]]

    b.systems.text_draw = {
        entities = {},

        draw = function()
            for _, e in ipairs(b.systems.text_draw.entities) do
                local p = e.pos
                local t = e.text

                -- color
                if e.color then
                    love.graphics.setColor(
                        e.color.r,
                        e.color.g,
                        e.color.b,
                        e.color.a
                    )
                end

                -- font
                if e.font then
                    love.graphics.setFont(b.fonts[e.font.id])
                else
                    love.graphics.setFont(b.fonts.font)
                end

                local font = e.font and b.fonts[e.font.id] or b.fonts.font
                local t = e.text

                if e.anchor and e.anchor.mode == ANCHOR.CENTER then
                    local w = font:getWidth(t.value)
                    local h = font:getHeight()
                    t.offset.x = w / 2
                    t.offset.y = h / 2
                else
                    t.offset.x = 0
                    t.offset.y = 0
                end

                love.graphics.print(
                    t.value,
                    p.x,
                    p.y,
                    t.rot,
                    t.scale.x,
                    t.scale.y,
                    t.offset.x,
                    t.offset.y
                )
            end

            -- reset state
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setFont(b.fonts.font)
        end
    }

    b.systems.sprite_draw = {
        draw = function()
            for _, e in ipairs(b.systems.sprite_draw.entities) do
                local p = e.pos
                local s = e.sprite
                local quad = s.asset.frames[s.frame]

                if e.anchor and e.anchor.mode == ANCHOR.CENTER then
                    local fw, fh = s.asset.frame_width, s.asset.frame_height
                    s.offset.x = fw / 2
                    s.offset.y = fh / 2
                else
                    s.offset.x = 0
                    s.offset.y = 0
                end

                lg.draw(
                    s.img,
                    quad,
                    p.x, p.y,
                    s.rot,
                    s.scale.x, s.scale.y,
                    s.offset.x, s.offset.y
                )
            end
        end,
        entities = {},
        sort = function(j, k)
            local za = j.z and j.z.value or 0
            local zb = k.z and k.z.value or 0
            return za < zb
        end
    }

    -- configure window
    love.window.setMode(b.opts.width*b.opts.scale, b.opts.height*b.opts.scale)
    local default_white = hex_to_color("fff5f5")
    lg.setColor(default_white)

    -- configure baton/input
    love.joystick.loadGamepadMappings(PATH .. "/gamecontrollerdb.txt")
    local joystick = love.joystick.getJoysticks()[1]
    b.input = baton.new({ controls = b.opts.controls, joystick = joystick })
end

function b.scene(name, fn)
    b.scenes[name] = fn
end

function b.go(name)
    -- reset world the world and systems
    b.world = {}
    for _, sys in pairs(b.systems) do
        sys.entities = {}
    end

    -- flip current scene to the new one
    local sc = {}
    b.current_scene = sc

    b.scenes[name](b.current_scene)
end

function b.rand(...) return love.math.random(...) end

function b.add(components)
    local e = {}

    for _, c in ipairs(components) do
        if c.__type then
            e[c.__type] = c

            if c.systems then
                for _, s in ipairs(c.systems) do
                    table.insert(b.systems[s].entities, e)

                    local sys = b.systems[s]
                    table.insert(sys.entities, e)

                    if sys.sort then
                        table.sort(sys.entities, sys.sort)
                    end
                end
            end
        else
            -- assume custom user data if no .__type is found I guess
            for k, v in pairs(c) do
                e[k] = v
            end
        end
    end

    if not e.pos then
        e.pos = { x = 0, y = 0 }
    end

    table.insert(b.world, e)

    if e.z then
        b.resort()
    end

    return e
end

--[[ groups ]]
local BEAN_GROUP = {}
BEAN_GROUP.__index = BEAN_GROUP

function b.group()
    return setmetatable({ entities = {} }, BEAN_GROUP)
end

function BEAN_GROUP:add(e)
    self.entities[#self.entities + 1] = e
    return e
end

function BEAN_GROUP:loop(fn)
    for i = #self.entities, 1, -1 do
        local e = self.entities[i]
        if e._destroyed then
            table.remove(self.entities, i)
        else
            fn(e)
        end
    end
end

function BEAN_GROUP:bake(opts)
    opts = opts or {}
    local padding = opts.padding or 0

    -- compute bounds
    local min_x, min_y = math.huge, math.huge
    local max_x, max_y = -math.huge, -math.huge

    for _, e in ipairs(self.entities) do
        local p = e.pos
        local s = e.sprite
        local fw = s.asset.frame_width
        local fh = s.asset.frame_height

        local x1 = p.x - s.offset.x
        local y1 = p.y - s.offset.y
        local x2 = x1 + fw
        local y2 = y1 + fh

        if x1 < min_x then min_x = x1 end
        if y1 < min_y then min_y = y1 end
        if x2 > max_x then max_x = x2 end
        if y2 > max_y then max_y = y2 end
    end

    min_x = min_x - padding
    min_y = min_y - padding
    max_x = max_x + padding
    max_y = max_y + padding

    local w = math.ceil(max_x - min_x)
    local h = math.ceil(max_y - min_y)

    local canvas = lg.newCanvas(w, h)
    lg.setCanvas(canvas)
    lg.clear()

    -- draw all entities into canvas
    for _, e in ipairs(self.entities) do
        local p = e.pos
        local s = e.sprite

        local quad = s.asset.frames[s.frame]

        lg.draw(
            s.img,
            quad,
            p.x - min_x,
            p.y - min_y,
            s.rot,
            s.scale.x,
            s.scale.y,
            s.offset.x,
            s.offset.y
        )
    end

    lg.setCanvas()

    -- destroy the originals
    self:destroy()

    local baked = bean.add {
        bean.baked_sprite(canvas),
        bean.pos(min_x, min_y)
    }

    return baked
end

function BEAN_GROUP:destroy()
    for i = #self.entities, 1, -1 do
        b.destroy(self.entities[i])
    end
    self.entities = {}
end

function b.tween(target, vars, dur)
    return b.flux:to(target, vars, dur)
end

function b.vec2(x, y)
    return { x = x, y = y or x }
end

function b.pos(x, y)
    return { __type = "pos", x = x, y = y }
end

function b.set_pos(e, x, y)
    e.pos.x = x
    e.pos.y = y
end

function b.set_x(e, x) e.pos.x = x end
function b.set_y(e, y) e.pos.y = y end

--[[ input stuff ]]
function b.btn(name)
    return b.input:pressed(name)
end

function b.btn_down(name)
    return b.input:down(name)
end

function b.btn_up(name)
    return b.input:released(name)
end

function b.axis(name)
    return b.input:get(name)
end

--[[ sound stuff ]]
function b.load_sound(id, file, opts)
    opts = opts or {}

    b.sounds[id] = {
        source = love.audio.newSource(file, opts.stream and "stream" or "static"),
        overlap = opts.overlap or false, -- clones and plays
        blocker = opts.blocker or false, -- stops and plays
        volume = opts.volume or 1
    }

    b.sounds[id].source:setVolume(b.sounds[id].volume)
end

function b.play(id, opts)
    opts = opts or {}

    local snd = b.sounds[id]
    assert(snd, "Sound not found: " .. tostring(id))

    local src

    if snd.blocker then
        src = snd.source
        src:stop()
    elseif snd.overlap then
        src = snd.source:clone()
    end

    if opts.pitch then
        local semitones = opts.pitch
        local pitch = 2 ^ (semitones / 12)
        src:setPitch(pitch)
    else
        src:setPitch(1)
    end

    if opts.volume then
        src:setVolume(opts.volume)
    end

    src:play()
end

function b.pause(id)
    local snd = b.sounds[id]
    if snd then snd.source:pause() end
end

function b.stop(id)
    local snd = b.sounds[id]
    if snd then snd.source:stop() end
end

function b.set_volume(id, v)
    local snd = b.sounds[id]
    if snd then snd.source:setVolume(v) end
end

--[[ sprite and draw stuff ]]
function b.sprite(id, opts)
    opts = opts or {}
    local spr = b.sprites[id]

    return {
        __type = "sprite",
        id = id,
        img = spr.img,
        asset = spr,
        frame = opts.frame or 1,
        rot = opts.rot or 0,
        scale = opts.scale or { x = 1, y = 1 },
        offset = opts.offset or { x = 0, y = 0 },

        systems = { "sprite_draw" }
    }
end

function b.set_frame(e, f)
    local s = e.sprite
    s.frame = f
    s.quad = s.asset.frames[f]
end

function b.anchor(mode)
    if mode == "center" then
        mode = ANCHOR.CENTER
    else
        mode = ANCHOR.DEFAULT
    end

    return {
        __type = "anchor",
        mode = mode
    }
end

function b.get_frame_dimensions(id)
    assert(b.sprites[id], string.format("get_frame_dimensions: Sprite with id '%s' does not exist", id))

    return b.sprites[id].frame_width, b.sprites[id].frame_height
end

function b.z(v)
    return {
        __type = "z",
        value = v or 1
    }
end

function b.set_z(e, new_z)
    assert(new_z, "set_z: Expects entity, new_z")

    if not e.z then
        e.z = { value = new_z }
    else
        e.z.value = new_z
    end

    b.resort()
end

function b.resort()
    for _, sys in pairs(b.systems) do
        if sys.sort then
            table.sort(sys.entities, sys.sort)
        end
    end
end

function b.load_sprite(id, file, opts)
    opts = opts or {}

    b.sprites[id] = {}
    local spr = b.sprites[id]

    spr.img = lg.newImage(file)
    spr.frames = {}

    local sw, sh = spr.img:getDimensions()
    spr.width = sw
    spr.height = sh
    spr.frame_width = sw
    spr.frame_height = sh

    if opts.sliceX and opts.sliceY then
        if sw % opts.sliceX ~= 0 or sh % opts.sliceY ~= 0 then
            error(("Sprite '%s' can't be evenly sliced: %dx%d into %dx%d")
                :format(id, sw, sh, opts.sliceX, opts.sliceY))
        end

        local fw = sw / opts.sliceX
        local fh = sh / opts.sliceY

        spr.frame_width = fw
        spr.frame_height = fh

        for y = 0, opts.sliceY - 1 do
            for x = 0, opts.sliceX - 1 do
                local q = lg.newQuad(
                    x * fw, y * fh,
                    fw, fh,
                    sw, sh
                )
                table.insert(spr.frames, q)
            end
        end
    else
        -- single-frame sprite
        local sw, sh = spr.img:getDimensions()
        spr.frames[1] = lg.newQuad(0, 0, sw, sh, sw, sh)
    end

    return spr
end

function b.baked_sprite(canvas)
    local w, h = canvas:getWidth(), canvas:getHeight()

    return {
        __type = "sprite",
        img = canvas,
        asset = {
            frames = {
                lg.newQuad(0, 0, w, h, w, h)
            },
            frame_width = w,
            frame_height =h
        },
        frame = 1,
        rot = 0,
        scale = { x = 1, y = 1 },
        offset = { x = 0, y = 0 },
        systems = { "sprite_draw" }
    }
end

function b.text(value)
    return {
        __type = "text",
        value = value,

        scale  = { x = 1, y = 1 },
        offset = { x = 0, y = 0 },
        rot    = 0,

        systems = { "text_draw" }
    }
end

-- use id "font" to override the default font
function b.load_font(id, path, font_size)
    font_size = font_size or 12

    b.fonts[id] = lg.newFont(path, font_size)
end

function b.font(id)
    return {
        __type = "font",
        id = id or "font"
    }
end

function b.col(hex, alpha)
    hex = hex:gsub("#", "")
    return hex_to_color(hex, alpha)
end

function b.color(hex, alpha)
    -- let 'em use a hash at the front
    hex = hex:gsub("#", "")

    local r, g, b_, a = unpack(hex_to_color(hex, alpha))
    return {
        __type = "color",
        r = r,
        g = g,
        b = b_,
        a = a
    }
end

function b.fx(pvec, t)
    shimmer:add(pvec.x, pvec.y, presets[t])
end

function b.set_text(e, value)
    if e.text then
        e.text.value = value
    end
end

function b.area()
    return {
        __type = "area"
    }
end

function b.get_bounds(e)
    local fw = e.sprite.asset.frame_width
    local fh = e.sprite.asset.frame_height

    local x = e.pos.x - e.sprite.offset.x
    local y = e.pos.y - e.sprite.offset.y

    return x, y, fw, fh
end

function b.mousepos() return res.get_mouse_position(b.opts.width, b.opts.height) end

function b.hover(e)
    if not e.area then return false end

    local mx, my = b.mousepos()
    local x, y, w, h = b.get_bounds(e)

    return point_in_rect(mx, my, x, y, w, h)
end

function b.clicked(e, btn)
    btn = btn or 1
    if not e.area then return false end
    if not b.hover(e) then return false end
    return b.btn("mouse" .. btn)
end

function b.destroy(e)
    if not e or e._destroyed then return end
    e._destroyed = true

    -- remove from world
    for i = #b.world, 1, -1 do
        if b.world[i] == e then
            table.remove(b.world, i)
            break
        end
    end

    -- remove from all systems
    for _, sys in pairs(b.systems) do
        local list = sys.entities
        for i = #list, 1, -1 do
            if list[i] == e then
                table.remove(list, i)
            end
        end
    end
end

function b.draw()
    b.systems.sprite_draw.draw()
    b.systems.text_draw.draw()
end

--[[ love callbacks ]]
function love.update(dt)
    b.input:update(dt)
    b.flux:update(dt)
    if b.opts.fx then shimmer:update(dt) end
    if b.current_scene.tick then
        b.current_scene.tick(dt)
    end
end

function love.draw()
    lg.clear(b.opts.background)
    res.set(b.opts.width, b.opts.height)
    b.draw()
    if b.opts.fx then shimmer:draw() end
    res.unset()
end

return b