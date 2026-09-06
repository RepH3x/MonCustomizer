return function(mod)

    local Sprites = require("src.pokemon.Sprites")
    local Assets = require("src.render.Assets")
    local GbcPalette = require("src.render.GbcPalette")
    local Palettes = require("src.world.gen2.Palettes")
    local QuantityBox = require("src.ui.QuantityBox")

    local Font = mod.ui.Font
    local G = love.graphics

    local currentPalette = 1 -- 1-4
    local currentColor = 1 -- 1=R, 2=G, 3=B

    local colors = {
        {0, 0, 0},
        {0, 0, 0},
        {0, 0, 0},
        {0, 0, 0}
    }

    function setR(index, newR)
        colors[index][1] = newR
    end
    function setG(index, newG)
        colors[index][2] = newG
    end
    function setB(index, newB)
        colors[index][3] = newB
    end
    function setColor(index, newR, newG, newB)
        setR(index, newR)
        setG(index, newG)
        setB(index, newB)
    end

    mod.content.screens:register("RepMCMainMenu", {
        new = function(game, mon)

            local self = { game = game, isOpaque = true }
            local monSprite = Assets.image(Sprites.path(game.data, mon.name, "back"))
            local monColors = Palettes.monColors(game.data.gen2Palettes, mon.species)
            colors = monColors
            local box = QuantityBox.new(game, {
                max = 255,
                start = colors[currentPalette][currentColor],
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

            local function normalizeColorLength(number)
                if number < 10 then return "00" .. tostring(number) end
                if number < 100 then return "0" .. tostring(number) end
                return number
            end

            local function createColorString(index)
                return tostring(index) .. ": "
                .. normalizeColorLength(colors[index][1]) .. ","
                .. normalizeColorLength(colors[index][2]) .. ","
                .. normalizeColorLength(colors[index][3])
            end

            function self:update(dt)
                if game.input:wasPressed("a") then
                    game.stack:push(QuantityBox.new(game, {
                        max = 255,
                        start = colors[currentPalette][currentColor],
                        onDone = function(qty)
                            if not qty then qty = 0 end
                            if currentColor == 1 then setR(currentPalette, qty) end
                            if currentColor == 2 then setG(currentPalette, qty) end
                            if currentColor == 3 then setB(currentPalette, qty) end
                        end
                    }))
                end
                if game.input:wasPressed("up") then
                    currentPalette = wrap(currentPalette - 1, 4)
                end
                if game.input:wasPressed("down") then
                    currentPalette = wrap(currentPalette + 1, 4)
                end
                if game.input:wasPressed("left") then
                    currentColor = wrap(currentColor - 1, 3)
                end
                if game.input:wasPressed("right") then
                    currentColor = wrap(currentColor + 1, 3)
                end
                if game.input:wasPressed("b") then
                    game.stack:pop()
                end
            end

            function self:draw()
                Font.drawBox(0, 0, 20, 18) -- full-screen GB frame
                Font.draw(mon.nickname or mon.name, 16, 16)
                Font.draw("R   G   B", 40, 70)
                G.setColor(255, 0, 0, 1)
                G.rectangle("fill", (32*currentColor), 70+(10*currentPalette), 24, 8)
                G.setColor(1, 1, 1, 1)
                Font.draw(createColorString(1), 8, 80)
                Font.draw(createColorString(2), 8, 90)
                Font.draw(createColorString(3), 8, 100)
                Font.draw(createColorString(4), 8, 110)

                local function body()
                    G.draw(monSprite, 96, 16, 0, 1, 1)
                end

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