local M = {}

local lg = love.graphics

local function rand(a, b) return a + love.math.random() * (b - a) end
local TAU = math.pi * 2
local SIZE_MULT = 4

local draw = {}

function draw.sparkle(p)
    local u = p.t / p.life
    local fade = (1 - u) ^ p.fade_pow
    local tw = 0.5 + 0.5 * math.sin(p.tw_phase + p.t * p.tw_speed)
    local size = p.size * (0.7 + 0.6 * tw)

    -- glow dot
    lg.setColor(p.col[1], p.col[2], p.col[3], 0.55 * fade)
    lg.circle("fill", p.x, p.y, size * 1.5)

    -- star (two crossed)
    lg.setColor(1, 1, 1, 0.9 * fade)
    lg.setLineWidth(1)
    lg.line(p.x - size, p.y, p.x + size, p.y)
    lg.line(p.x, p.y - size, p.x, p.y + size)
    lg.push()
    lg.translate(p.x, p.y)
    lg.rotate(math.pi / 4)
    lg.line(-size * 0.7, 0, size * 0.7, 0)
    lg.line(0, -size * 0.7, 0, size * 0.7)
    lg.pop()
end

function draw.dot(p)
    local u = p.t / p.life
    local fade = (1 - u) ^ p.fade_pow
    lg.setColor(p.col[1], p.col[2], p.col[3], fade)
    lg.circle("fill", p.x, p.y, p.size)
end

function draw.streak(p)
    local u = p.t / p.life
    local fade = (1 - u) ^ p.fade_pow
    local ang = math.atan2(p.vy, p.vx)
    local len = p.size * (2 + 8 * (1 - u))
    local dx, dy = math.cos(ang) * len * 0.5, math.sin(ang) * len * 0.5
    lg.setColor(p.col[1], p.col[2], p.col[3], 0.9 * fade)
    lg.setLineWidth(1)
    lg.line(p.x - dx, p.y - dy, p.x + dx, p.y + dy)
end

function draw.shard(p)
    local u = p.t / p.life
    local fade = (1 - u) ^ p.fade_pow
    lg.push()
    lg.translate(p.x, p.y)
    lg.rotate(p.rot)
    lg.setColor(p.col[1], p.col[2], p.col[3], 0.85 * fade)
    lg.polygon("fill",
        -p.size, -p.size * 0.4,
         p.size,  0,
        -p.size,  p.size * 0.4)
    lg.pop()
end

function draw.ring(p)
    local u = p.t / p.life
    local fade = (1 - u) ^ p.fade_pow
    lg.setColor(p.col[1], p.col[2], p.col[3], 0.6 * fade)
    lg.setLineWidth(2)
    lg.circle("line", p.x, p.y, p.size * (1 + u * 2))
end

-- emitter

local function spawn_particles(e)
    e.p = {}
    for i = 1, e.n do
        local ang = e.angle + (love.math.random() * e.spread - e.spread * 0.5)
        local spd = rand(e.spd_min, e.spd_max)
        local vx, vy = math.cos(ang) * spd, math.sin(ang) * spd
        local life = rand(e.life_min, e.life_max)
        local size = rand(e.size_min, e.size_max) * SIZE_MULT
        local col  = e.colors[(i - 1) % #e.colors + 1]
        e.p[i] = {
            x = e.x, y = e.y, vx = vx, vy = vy,
            t = 0, life = life, size = size, col = col,
            rot = rand(0, TAU), omg = rand(-e.spin, e.spin),
            tw_phase = rand(0, TAU), tw_speed = rand(10, 16),
            fade_pow = e.fade_pow,
        }
    end
end

function M.new_emitter(x, y, spec)
    local e = {}

    e.mode   = spec.mode or "sparkle"
    e.blend  = spec.blend or "add"
    e.n      = spec.n or 16

    e.x = (x or 0) + (spec.offset_x or 0)
    e.y = (y or 0) + (spec.offset_y or 0)

    e.angle  = spec.angle or 0
    e.spread = spec.spread or TAU
    e.spd_min, e.spd_max = spec.spd_min or 80, spec.spd_max or 140

    e.life_min, e.life_max = spec.life_min or 0.35, spec.life_max or 0.6
    e.size_min, e.size_max = spec.size_min or 1.2, spec.size_max or 2.4

    e.gravity = spec.gravity or 140
    e.drag    = spec.drag or 2.6
    e.spin    = spec.spin or 6
    e.fade_pow= spec.fade_pow or 1.5

    e.colors  = spec.colors or { {1, 1, 1} }

    spawn_particles(e)
    return setmetatable(e, { __index = M })
end

function M:update(dt)
    local alive = false
    for i = 1, #self.p do
        local s = self.p[i]
        if s.t < s.life then
            s.t = s.t + dt
            s.vx = s.vx / (1 + self.drag * dt)
            s.vy = (s.vy + self.gravity * dt) / (1 + self.drag * dt)
            s.x = s.x + s.vx * dt
            s.y = s.y + s.vy * dt
            s.rot = s.rot + s.omg * dt
            alive = true
        end
    end
    if not alive then self.remove = true end
end

function M:draw()
    lg.push("all")
    lg.setBlendMode(self.blend, "alphamultiply")
    local fn = draw[self.mode] or draw.sparkle
    for i = 1, #self.p do
        local s = self.p[i]
        if s.t < s.life then fn(s) end
    end
    lg.pop()
end

return M
