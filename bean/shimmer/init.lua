local path = ...
local Emitters = require(path .. ".emitters")

local shimmer = {
    _effects = {},
    _next_id = 1,
    _max_effects = 512,
}

local function new_effect(x, y, spec, opts)
    local eff = {
        id = shimmer._next_id, x = x or 0, y = y or 0,
        emitters = {}, remove = false,
        layer = (spec and spec.layer) or (opts and opts.layer) or 50,
    }
    shimmer._next_id = shimmer._next_id + 1

    local list = (spec and spec.emitters) or {}
    for i = 1, #list do
        eff.emitters[#eff.emitters + 1] = Emitters.new_emitter(x, y, list[i])
    end
    return eff
end

function shimmer:add(x, y, spec, opts)
    if not spec then return nil end
    if #self._effects >= self._max_effects then
        table.remove(self._effects, 1)
    end
    local eff = new_effect(x, y, spec, opts)
    self._effects[#self._effects + 1] = eff
    return eff
end

function shimmer:clear()
    self._effects = {}
end

function shimmer:update(dt)
    for i = 1, #self._effects do
        local eff = self._effects[i]
        if not eff.remove then
            local alive = false
            for j = 1, #eff.emitters do
                local e = eff.emitters[j]
                if not e.remove then
                    e:update(dt)
                    alive = true
                end
            end
            if not alive then eff.remove = true end
        end
    end

    local w = 1
    for r = 1, #self._effects do
        local eff = self._effects[r]
        if not eff.remove then
            if w ~= r then self._effects[w] = eff end
            w = w + 1
        end
    end
    for i = w, #self._effects do self._effects[i] = nil end
end

function shimmer:draw()
    if #self._effects == 0 then return end

    local idx = {}
    for i = 1, #self._effects do
        idx[i] = i
    end
    for i = 2, #idx do
        local j = i
        while j > 1 do
            local a = self._effects[idx[j    ]]
            local b = self._effects[idx[j - 1]]
            if a.layer >= b.layer then break end
            idx[j], idx[j - 1] = idx[j - 1], idx[j]
            j = j - 1
        end
    end

    for k = 1, #idx do
        local eff = self._effects[idx[k]]
        if not eff.remove then
            for j = 1, #eff.emitters do
                local e = eff.emitters[j]
                if not e.remove then e:draw() end
            end
        end
    end
end

return shimmer
