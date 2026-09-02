return function(mod)

    local Sprites = require("src.pokemon.Sprites")
    local Assets = require("src.render.Assets")
    local GbcPalette = require("src.render.GbcPalette")

    mod.content.screens:register("RepMonCustomizer", {
        new = function(game, mon)
            local Font = mod.ui.Font
            local G = love.graphics
            local self = { game = game, isOpaque = true }

            function self:update(dt)
                if game.input:wasPressed("b") or game.input:wasPressed("a") then
                    game.stack:pop()
                end
            end

            function self:draw()
                Font.drawBox(0, 0, 20, 18) -- full-screen GB frame
                Font.draw(mon.nickname or mon.name, 16, 16)
                Font.draw("Test menu", 8, 40)
                local image = Assets.image(Sprites.path(game.data, mon.name, "back"))
                local colors = {
                    {255, 0, 0}, {0, 0, 255}, {0, 255, 0}, {0, 0, 0}
                }

                G.setColor(1, 1, 1, 1)
                local function body()
                    G.draw(image, 96, 16, 0, 1, 1)
                end

                GbcPalette.with(colors, body)
            end

            return self
        end,
    })

    mod.hooks:wrap("ui.party.submenu", function(next, game, items, mon, ctx)
        mod.ui.insertBefore(items, "CANCEL", {
            label = "EDIT COLOR",
            onSelect = function() mod.ui.push(game, "RepMonCustomizer", mon)  end,
        })
        return next(game,items)
    end)
end