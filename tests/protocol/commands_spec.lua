local Commands = require "ChurchRun/protocol/commands"

local function clientCommand(schema)
    return { direction = Commands.TO_CLIENT, schema = schema or {} }
end

describe("Commands (SPEC-001 R2)", function()
    it("o catálogo do mod passa na conferência", function()
        local ok, err = Commands.check(Commands.catalog)
        assert.is_true(ok, err)
    end)

    it("todo comando toServer do catálogo tem rate limit", function()
        for name, def in pairs(Commands.catalog) do
            if def.direction == Commands.TO_SERVER then
                assert.is_table(def.rateLimit, name)
            end
        end
    end)

    it("recusa nome fora do padrão camelCase ou longo demais", function()
        assert.is_false(Commands.check({ ["Bad-Name"] = clientCommand() }))
        assert.is_false(Commands.check({ [string.rep("a", Commands.MAX_NAME_LEN + 1)] = clientCommand() }))
    end)

    it("recusa comando toServer sem rate limit", function()
        assert.is_false(Commands.check({ hello = { direction = Commands.TO_SERVER, schema = {} } }))
    end)

    it("recusa rate limit sem burst inteiro ou sem reposição", function()
        local noRefill = { direction = Commands.TO_SERVER, rateLimit = { burst = 3, perSecond = 0 }, schema = {} }
        local fractional = { direction = Commands.TO_SERVER, rateLimit = { burst = 1.5, perSecond = 1 }, schema = {} }
        assert.is_false(Commands.check({ hello = noRefill }))
        assert.is_false(Commands.check({ hello = fractional }))
    end)

    it("recusa direção desconhecida", function()
        assert.is_false(Commands.check({ hello = { direction = "sideways", schema = {} } }))
    end)

    it("recusa o campo reservado pv no esquema (R5)", function()
        assert.is_false(Commands.check({ hello = clientCommand({ pv = { type = "integer", min = 1, max = 2 } }) }))
    end)

    it("recusa campo com definição inválida", function()
        assert.is_false(Commands.check({ hello = clientCommand({ name = { type = "string" } }) }))
    end)

    it("lookup só acha nomes de texto que estão no catálogo", function()
        assert.is_nil(Commands.lookup(Commands.catalog, 42))
        assert.is_nil(Commands.lookup(Commands.catalog, "naoExiste"))
        assert.are.equal(Commands.catalog.ping, Commands.lookup(Commands.catalog, "ping"))
    end)
end)
