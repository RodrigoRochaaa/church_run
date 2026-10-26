local Ports = require "ChurchRun/Server/ports/Ports"
local Fakes = require "fakes/Fakes"

describe("Ports (CLAUDE.md §3.1)", function()
    it("os falsos dos testes implementam os ports", function()
        assert.is_true(Ports.check("Clock", Fakes.clock()))
        assert.is_true(Ports.check("Log", Fakes.log()))
        assert.is_true(Ports.check("Net", Fakes.net()))
        assert.is_true(Ports.check("Players", Fakes.players()))
        assert.is_true(Ports.check("Storage", Fakes.storage()))
    end)

    it("acusa a função que falta", function()
        local ok, err = Ports.check("Log", { info = function() end })
        assert.is_false(ok)
        assert.truthy(string.find(err, "warn", 1, true))
    end)

    it("acusa implementação ausente e port desconhecido", function()
        assert.is_false(Ports.check("Clock", nil))
        assert.is_false(Ports.check("Banana", {}))
    end)
end)
