-- constants
local HEX_CELL_W = 44
local HEX_CELL_H = 46

local HEX_SPRITE_W = 56
local HEX_SPRITE_H = 57

local HEX_OFFSET_X = 5
local HEX_OFFSET_Y = 0

local HEX_X_SPACING = HEX_CELL_W
local HEX_Y_SPACING = HEX_CELL_H * 0.75

local HEX_NEIGHBORS = {
    odd = {
        {  0, -1 }, {  0,  1 },
        { -1,  0 }, { -1,  1 },
        {  1,  0 }, {  1,  1 },
    },
    even = {
        {  0, -1 }, {  0,  1 },
        { -1, -1 }, { -1,  0 },
        {  1, -1 }, {  1,  0 },
    }
}

-- these aren't really constants
-- but they need the scope, so here they are
local board = {}
local gems = bean.group()
local layout
local score
local current_layout = 1

local origin_x = 218
local origin_y = 80
local layouts = {
    -- default
    [1] = {
        rows = { 6, 7, 6, 7, 6, 7, 6 },
        origin = { x = 218, y = 80 }
    },

    -- the shield
    [2] = {
        rows = { 2, 3, 6, 7, 8, 9, 8, 7, 6, 3, 2 },
        origin = { x = 180, y = 24 }
    },
}

local GEM_TYPES = {
    ray       = { frame = 1, weight = 40, name = "ray" },
    pulse     = { frame = 2, weight = 30, name = "pulse" },
    star      = { frame = 3, weight = 20, name = "star" },
    converter = { frame = 4, weight = 15, name = "converter" },
    blocker   = { frame = 5, weight = 5, name = "blocker" },
}

-- helpers
local function compute_row_offsets()
    local max_cols = 0
    for _, c in ipairs(layout.rows) do
        max_cols = math.max(max_cols, c)
    end

    local offsets = {}
    for row, cols in ipairs(layout.rows) do
        offsets[row] = (max_cols - cols) * 0.5
    end

    return offsets
end

local function get_neighbors(row, col)
    local neighbors = {}

    local this_offset = layout.row_offsets[row]
    local this_cols   = layout.rows[row]

    -- same horizontal row
    if col > 1 then
        table.insert(neighbors, { row = row, col = col - 1 })
    end
    if col < this_cols then
        table.insert(neighbors, { row = row, col = col + 1 })
    end

    -- row above
    if row > 1 then
        local above_cols   = layout.rows[row - 1]
        local above_offset = layout.row_offsets[row - 1]

        local x = this_offset + (col - 0.5)
        local above_col = math.floor(x - above_offset + 0.5)

        for dc = 0, 1 do
            local c = above_col + dc
            if c >= 1 and c <= above_cols then
                table.insert(neighbors, { row = row - 1, col = c })
            end
        end
    end

    -- row below
    if row < #layout.rows then
        local below_cols   = layout.rows[row + 1]
        local below_offset = layout.row_offsets[row + 1]

        local x = this_offset + (col - 0.5)
        local below_col = math.floor(x - below_offset + 0.5)

        for dc = 0, 1 do
            local c = below_col + dc
            if c >= 1 and c <= below_cols then
                table.insert(neighbors, { row = row + 1, col = c })
            end
        end
    end

    return neighbors
end

local function hex_cell_center(row, col, origin_x, origin_y)
    local max_cols = 0
    for _, c in ipairs(layout.rows) do
        max_cols = math.max(max_cols, c)
    end

    local row_cols = layout.rows[row]
    local row_offset = (max_cols - row_cols) * 0.5 * HEX_CELL_W

    local x = origin_x
        + row_offset
        + (col - 1) * HEX_CELL_W
        + HEX_CELL_W * 0.5

    local y = origin_y
        + (row - 1) * HEX_CELL_H * 0.75
        + HEX_CELL_H * 0.5

    return x, y
end

local function ray_cells(gem, range)
    local cells = {}

    for i = 1, range do
        table.insert(cells, { row = gem.row, col = gem.col - i })
        table.insert(cells, { row = gem.row, col = gem.col + i })
    end

    return cells
end

local function pulse_cells(gem, range)
    local visited = {}
    local frontier = {
        { row = gem.row, col = gem.col }
    }

    visited[gem.row .. "," .. gem.col] = true

    for _ = 1, range do
        local next_frontier = {}

        for _, cell in ipairs(frontier) do
            for _, n in ipairs(get_neighbors(cell.row, cell.col)) do
                local key = n.row .. "," .. n.col
                if not visited[key] then
                    visited[key] = true
                    table.insert(next_frontier, n)
                end
            end
        end

        frontier = next_frontier
    end

    -- remove the origin
    visited[gem.row .. "," .. gem.col] = nil

    local out = {}
    for key in pairs(visited) do
        local r, c = key:match("([^,]+),([^,]+)")
        table.insert(out, { row = tonumber(r), col = tonumber(c) })
    end

    return out
end

-- project two diagonal rays upward and downward from the gems absolute X position
-- fuck you, math
local function star_cells(gem, range)
    local out = {}
    
    local source_offset = layout.row_offsets[gem.row]
    local source_abs_x = source_offset + (gem.col - 0.5)
    
    for dist = 1, range do
        -- upper rows
        if gem.row - dist >= 1 then
            local target_row = gem.row - dist
            local target_offset = layout.row_offsets[target_row]
            local target_cols = layout.rows[target_row]
            
            -- left arm going up
            local left_col = math.floor(source_abs_x - (dist > 1 and 1 or 0) - target_offset + 0.5)
            if left_col >= 1 and left_col <= target_cols then
                table.insert(out, { row = target_row, col = left_col })
            end
            
            -- right arm going up
            local right_col = math.floor(source_abs_x + dist - (dist > 1 and 1 or 0) - target_offset + 0.5)
            if right_col >= 1 and right_col <= target_cols then
                table.insert(out, { row = target_row, col = right_col })
            end
        end
        
        -- lower rows
        if gem.row + dist <= #layout.rows then
            local target_row = gem.row + dist
            local target_offset = layout.row_offsets[target_row]
            local target_cols = layout.rows[target_row]
            
            -- left arm going down
            -- left arm going up
            local left_col = math.floor(source_abs_x - (dist > 1 and 1 or 0) - target_offset + 0.5)
            if left_col >= 1 and left_col <= target_cols then
                table.insert(out, { row = target_row, col = left_col })
            end
            
            -- right arm going down
            local right_col = math.floor(source_abs_x + dist - (dist > 1 and 1 or 0) - target_offset + 0.5)
            if right_col >= 1 and right_col <= target_cols then
                table.insert(out, { row = target_row, col = right_col })
            end
        end
    end
    
    return out
end

local function compute_blast_cells(gem)
    if gem.gem_type == "ray" then
        return ray_cells(gem, 2)
    elseif gem.gem_type == "star" then
        return star_cells(gem, 2)
    elseif gem.gem_type == "pulse" then
        return pulse_cells(gem, gem.armed and 2 or 1)
    elseif gem.gem_type == "converter" then
        return pulse_cells(gem, 2)
    end
end

local function pick_weighted(defs)
    local total = 0
    for _, d in pairs(defs) do
        total = total + d.weight
    end

    local roll = love.math.random() * total

    for _, d in pairs(defs) do
        roll = roll - d.weight
        if roll <= 0 then
            return d
        end
    end
end

local function layout_cols_for_row(row)
    return layout.rows[row]
end

local function spawn_gem_at(row, col)
    local gem_def = pick_weighted(GEM_TYPES)
    local cx, cy = hex_cell_center(row, col, origin_x, origin_y)

    local gem = bean.add {
        bean.sprite("gems", {
            frame = gem_def.frame,
            scale = { x = 0, y = 0 }
        }),
        bean.pos(cx, cy),
        bean.anchor("center"),
        bean.z(row + 20),
        bean.area(),
        {
            row = row,
            col = col,
            gem_type = gem_def.name,
            armed = false
        }
    }

    gem.blast_cells = compute_blast_cells(gem)

    gems:add(gem)
    board[row][col] = gem

    bean.tween(gem.sprite.scale, bean.vec2(1.4, 1.4), 0.15)
        :after(gem.sprite.scale, bean.vec2(1, 1), 0.2)

    return gem
end

-- gameplay helpers
local function add_score(n)
    score.text.str = score.text.str + n
    bean.tween(score.text.scale, bean.vec2(1.4, 1.4), 0.2)
        :after(score.text.scale, bean.vec2(1, 1), 0.1)
end

local function get_gem_at(row, col)
    return board[row] and board[row][col]
end

local function remove_gem(gem)
    board[gem.row][gem.col] = nil
    bean.destroy(gem)
end

local function get_blast_targets(gem)
    local targets = {}

    for _, cell in ipairs(gem.blast_cells or {}) do
        local target = board[cell.row] and board[cell.row][cell.col]
        -- TODO: i may need to remove the .blast_cells check if blockers
        -- are to be destroyable
        if target and target.blast_cells then
            table.insert(targets, target)
        end
    end

    return targets
end

local function get_empty_cells()
    local empty = {}

    for row = 1, #layout.rows do
        for col = 1, layout_cols_for_row(row) do
            if not board[row][col] then
                table.insert(empty, { row = row, col = col })
            end
        end
    end

    return empty
end

local function spawn_random_gem()
    local empty = get_empty_cells()
    if #empty == 0 then return end

    local cell = empty[love.math.random(#empty)]
    spawn_gem_at(cell.row, cell.col)
end

local function detonate_gem(gem, queue)
    -- do nothing if already gone
    if not board[gem.row][gem.col] then
        return
    end

    bean.fx(gem.pos, "ice_shatter")
    bean.play(gem.gem_type)
    remove_gem(gem)

    local arm_queue = {}

    for i, cell in ipairs(gem.blast_cells or {}) do
        local target = get_gem_at(cell.row, cell.col)

        if target and target.blast_cells then
            if target.armed then
                table.insert(queue, target)
            else
                target.armed = true
                table.insert(arm_queue, target)
            end
        end
    end

    for i, g in ipairs(queue) do
        bean.tween(g.sprite.scale, bean.vec2(1.5, 1.5), 0.2)
            :ease("backinout")
            :delay(i * 0.05)
            :oncomplete(function()
                if g.gem_type == "converter" or g.gem_type == "pulse" then
                    detonate_gem(g, { g })
                    add_score(50 * i)
                else
                    add_score(10 * i)
                end

                remove_gem(g)
                bean.fx(g.pos, "arrow_impact")
                bean.play(g.gem_type, { pitch = i })
            end)
    end

    for i, g in ipairs(arm_queue) do
        bean.tween(g.sprite.scale, bean.vec2(0.6, 0.6), 0.2)
            :ease("quadout")
            :delay(i * 0.2)
            :oncomplete(function()
                bean.fx(g.pos, "heal_burst")
                bean.play("armed", { pitch = i })
                add_score(5 * i)
                -- eeehhh unreliable
                --[[if i >= #arm_queue then
                    spawn_random_gem()
                end]]
            end)
    end
end

local function resolve_click(start_gem)
    local queue = { start_gem }

    while #queue > 0 do
        local gem = table.remove(queue, 1)

        -- gem may have been destroyed already via another chain
        if gem and not gem.armed then
            local empty_cells = #get_empty_cells()
            local num_spawns = 1
            if empty_cells > 20 then num_spawns = 4
            elseif empty_cells > 14 then num_spawns = 2
            elseif empty_cells < 9 then num_spawns = 1
            end

            for i=1, num_spawns do
                spawn_random_gem()
            end
            detonate_gem(gem, queue)
        end
    end
end

-- the scene
return function(sc)
    -- reset
    local ready = false
    gems:destroy()
    board = {}
    layout = layouts[current_layout]
    layout.row_offsets = compute_row_offsets()

    origin_x = layout.origin.x
    origin_y = layout.origin.y

    bean.add {
        bean.sprite("background"),
        bean.pos(0, 0),
        bean.z(1),
    }

    local hex_board = bean.group()

    local spawn_delay = 0
    local SPAWN_STAGGER = 0.08

    local cell_lookup = {}
    -- first pass (hex grid)
    for row = 1, #layout.rows do
        local cols = layout_cols_for_row(row)
        cell_lookup[row] = {}
        board[row] = {}

        for col = 1, cols do
            local x, y = hex_cell_center(row, col, origin_x, origin_y)
            cell_lookup[row][col] = true
            board[row][col] = nil

            hex_board:add(bean.add {
                bean.sprite("hex"),
                bean.pos(
                    x - HEX_CELL_W * 0.5 - HEX_OFFSET_X,
                    y - HEX_CELL_H * 0.5
                ),
                bean.z(row)
            })
        end
    end

    local baked_board = hex_board:bake()
    bean.set_z(baked_board, 2)

    -- second pass (gems)
    local next_gem_id = 1

    for row = 1, #layout.rows do
        local cols = layout_cols_for_row(row)
        for col = 1, cols do
            -- decide if this cell gets a gem
            -- TODO: should be based on level really
            -- ie: < levels[current_level].spawn_chance
            if love.math.random() < 0.7 then
                local gem_def = pick_weighted(GEM_TYPES)
                local cx, cy = hex_cell_center(row, col, origin_x, origin_y)

                local gem = bean.add {
                    bean.sprite("gems", {
                        frame = gem_def.frame,
                        scale = bean.vec2(0, 0)
                    }),
                    bean.pos(cx, cy),
                    bean.anchor("center"),
                    bean.z(row + col + 20),
                    bean.area(),
                    {
                        id = next_gem_id,
                        gem_type = gem_def.name,
                        armed = false,
                        col = col,
                        row = row
                    }
                }

                gem.blast_cells = compute_blast_cells(gem)

                gems:add(gem)
                next_gem_id = next_gem_id + 1

                board[row][col] = gem

                bean.tween(gem.sprite.scale, bean.vec2(1.4, 1.4), 0.15)
                    :delay(spawn_delay)
                    :oncomplete(function() bean.play("spawn_" .. gem_def.name) end)
                    :after(gem.sprite.scale, bean.vec2(1, 1), 0.2)

                spawn_delay = spawn_delay + SPAWN_STAGGER
            end
        end
    end

    local hovered_gem = nil
    local highlights = bean.group()

    ready = true

    score = bean.add {
        bean.text(0),
        bean.pos(360, 36),
        bean.color("ffd9e5"),
        bean.anchor("center")
    }

    sc.tick = function(dt)
        if not ready then return end

        if bean.btn "restart" then
            bean.go("game")
        end

        if bean.btn "1" then
            current_layout = 1
            bean.go("game")
        elseif bean.btn "2" then
            current_layout = 2
            bean.go("game")
        end

        local currently_hovered = nil

        gems:loop(function(e)
            if e.blast_cells and not e.armed and bean.hover(e) then
                currently_hovered = e
            end
        end)

        if currently_hovered and bean.clicked(currently_hovered) then
            resolve_click(currently_hovered)
        end

        -- hovering a new gem
        if currently_hovered and (hovered_gem ~= currently_hovered and currently_hovered.blast_cells) then
            hovered_gem = currently_hovered

            highlights:destroy()
            bean.play("click")

            -- highlight the target (center) gem
            highlights:add(bean.add {
                bean.sprite("hex_highlight_target"),
                bean.pos(currently_hovered.pos.x+1,currently_hovered.pos.y+5),
                bean.anchor("center"),
                bean.z(100)
            })

            bean.tween(currently_hovered.sprite.scale, bean.vec2(1.2, 1.2), 0.14)
                :after(currently_hovered.sprite.scale, bean.vec2(1, 1), 0.1)
                :ease("backinout")

            for i, cell in ipairs(hovered_gem.blast_cells) do
                if cell_lookup[cell.row] and cell_lookup[cell.row][cell.col] then
                    local cx, cy = hex_cell_center(cell.row, cell.col, origin_x, origin_y)

                    highlights:add(bean.add {
                        bean.sprite("hex_highlight"),
                        bean.pos(cx+1, cy+5),
                        bean.anchor("center"),
                        bean.z(60 + i)
                    })
                end
            end
        end

        -- stopped hovering anything
        -- TODO: maybe include currently_hovered and not currently_hovered.blast_cells
        -- to remove highlighting if you highlight a blocker (or something with no blast_cells)
        if not currently_hovered and hovered_gem then
            hovered_gem = nil
            highlights:destroy()
        end
    end
end