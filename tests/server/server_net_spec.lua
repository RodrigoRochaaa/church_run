local Net = require "ChurchRun/Server/adapters/Net"

local function fakeGame(isClient, isServer)
    local game = { calls = {} }

    function game.isClient()
        return isClient
    end

    function game.isServer()
        return isServer
    end

    function game.sendServerCommand(...)
        game.calls[#game.calls + 1] = { fn = "sendServerCommand", args = { ... } }
    end

    function game.triggerEvent(...)
        game.calls[#game.calls + 1] = { fn = "triggerEvent", args = { ... } }
    end

    return game
end

describe("adaptador de rede do servidor (SPEC-001 R1, R16)", function()
    it("no multiplayer, responde ao jogador por sendServerCommand", function()
        local game = fakeGame(false, true)
        Net.new(game).sendToPlayer("p1", "pong", { nonce = 1 })
        local expected = { fn = "sendServerCommand", args = { "p1", "ChurchRun", "pong", { nonce = 1 } } }
        assert.are.same(expected, game.calls[1])
    end)

    it("no multiplayer, envia para todos sem jogador", function()
        local game = fakeGame(false, true)
        Net.new(game).sendToAll("pong", { nonce = 1 })
        assert.are.same({ fn = "sendServerCommand", args = { "ChurchRun", "pong", { nonce = 1 } } }, game.calls[1])
    end)

    it("em single player, entrega a resposta por triggerEvent (CA16)", function()
        local game = fakeGame(false, false)
        local net = Net.new(game)
        net.sendToPlayer("p1", "pong", { nonce = 1 })
        net.sendToAll("pong", { nonce = 2 })
        local toPlayer = { fn = "triggerEvent", args = { "OnServerCommand", "ChurchRun", "pong", { nonce = 1 } } }
        local toAll = { fn = "triggerEvent", args = { "OnServerCommand", "ChurchRun", "pong", { nonce = 2 } } }
        assert.are.same({ toPlayer, toAll }, game.calls)
    end)
end)
