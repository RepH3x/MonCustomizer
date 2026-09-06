return function(mod)

    local Sprites = require("src.pokemon.Sprites")
    local Assets = require("src.render.Assets")
    local GbcPalette = require("src.render.GbcPalette")
    local QuantityBox = require("src.ui.QuantityBox")

    local Font = mod.ui.Font
    local G = love.graphics

    local currentPalette = 1
    local currentColor = 1 -- 1=R, 2=G, 3=B

    -- in each array, pos 1 is palette color 1 in rgb aggregrate from each array, pos 2 is palette color 2, etc
    local r = {0, 0, 0, 0}
    local g = {0, 0, 0, 0}
    local b = {0, 0, 0, 0}

    function setR(index, newR)
        if index == 1 then r = {newR, r[2], r[3], r[4]} end
        if index == 2 then r = {r[1], newR, r[3], r[4]} end
        if index == 3 then r = {r[1], r[2], newR, r[4]} end
        if index == 4 then r = {r[1], r[2], r[3], newR} end
    end
    function setG(index, newG)
        if index == 1 then g = {newG, g[2], g[3], g[4]} end
        if index == 2 then g = {g[1], newG, g[3], g[4]} end
        if index == 3 then g = {g[1], g[2], newG, g[4]} end
        if index == 4 then g = {g[1], g[2], g[3], newG} end
    end
    function setB(index, newB)
        if index == 1 then b = {newB, b[2], b[3], b[4]} end
        if index == 2 then b = {b[1], newB, b[3], b[4]} end
        if index == 3 then b = {b[1], b[2], newB, b[4]} end
        if index == 4 then b = {b[1], b[2], b[3], newB} end
    end
    function setColor(index, newR, newG, newB)
        setR(index, newR)
        setG(index, newG)
        setB(index, newB)
    end

    --setColor(1, 255, 0, 0)
    --setColor(2, 0, 255, 0)
    --setColor(3, 0, 0, 255)

    mod.content.screens:register("RepMCMainMenu", {
        new = function(game, mon)

            local self = { game = game, isOpaque = true }
            local monSprite = Assets.image(Sprites.path(game.data, mon.name, "back"))
            local box = QuantityBox.new(game, {
                max = 255,
                onDone = function(qty)
                    if not qty then qty = 0 end
                    if currentColor == 1 then setR(currentPalette, qty) end
                    if currentColor == 2 then setG(currentPalette, qty) end
                    if currentColor == 3 then setB(currentPalette, qty) end
                end
            })

            local function wrap(number, max)
                if number < 1 then return max end
                if number > max then return 1 end
                return number
            end

            local function getColorChar(number)
                if number == 1 then return "R" end
                if number == 2 then return "G" end
                if number == 3 then return "B" end
                return "?"
            end

            function self:update(dt)
                if game.input:wasPressed("a") then
                    game.stack:push(box)
                end
                if game.input:wasPressed("up") then
                    currentColor = wrap(currentColor + 1, 3)
                end
                if game.input:wasPressed("down") then
                    currentColor = wrap(currentColor - 1, 3)
                end
                if game.input:wasPressed("left") then
                    currentPalette = wrap(currentPalette - 1, 4)
                end
                if game.input:wasPressed("right") then
                    currentPalette = wrap(currentPalette + 1, 4)
                end
                if game.input:wasPressed("b") then
                    game.stack:pop()
                end
            end

            function self:draw()
                Font.drawBox(0, 0, 20, 18) -- full-screen GB frame
                Font.draw(mon.nickname or mon.name, 16, 16)
                Font.draw(tostring(currentPalette), 8, 40)
                Font.draw(getColorChar(currentColor), 8, 50)
                --Font.draw("{")

                local function body()
                    G.draw(monSprite, 96, 16, 0, 1, 1)
                end

                local colors = {
                    { r[1], g[1], b[1] },
                    { r[2], g[2], b[2] },
                    { r[3], g[3], b[3] },
                    { r[4], g[4], b[4] }
                }

                GbcPalette.with(colors, body)
            end

            return self
        end
    })

    mod.hooks:wrap("ui.party.submenu", function(next, game, items, mon, ctx)
        mod.ui.insertBefore(items, "CANCEL", {
            label = "EDIT COLOR",
            onSelect = function() mod.ui.push(game, "RepMCMainMenu", mon)  end,
        })
        return next(game,items)
    end)
end