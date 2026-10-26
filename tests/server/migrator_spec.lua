local Migrator = require "ChurchRun/Server/migrations/Migrator"

-- Migrações de teste: v1 → v2 acrescenta "level"; v2 → v3 renomeia "level" para "tier".
local function v1ToV2(data)
    data.level = 1
    return true, data
end

local function v2ToV3(data)
    data.tier = data.level
    data.level = nil
    return true, data
end

local STEPS = {
    { from = 1, to = 2, run = v1ToV2 },
    { from = 2, to = 3, run = v2ToV3 },
}

describe("Migrator.checkSteps (SPEC-002 R7)", function()
    it("aceita passos contínuos até a versão atual", function()
        assert.is_true(Migrator.checkSteps(3, STEPS))
        assert.is_true(Migrator.checkSteps(1, {}))
    end)

    it("acusa buraco na lista (CA7)", function()
        local withGap = { { from = 1, to = 2, run = v1ToV2 }, { from = 3, to = 4, run = v2ToV3 } }
        assert.is_false(Migrator.checkSteps(4, withGap))
    end)

    it("acusa passo repetido (CA7)", function()
        local repeated = { { from = 1, to = 2, run = v1ToV2 }, { from = 1, to = 2, run = v1ToV2 } }
        assert.is_false(Migrator.checkSteps(3, repeated))
    end)

    it("acusa lista que não chega à versão atual ou passo sem função", function()
        assert.is_false(Migrator.checkSteps(4, STEPS))
        assert.is_false(Migrator.checkSteps(2, { { from = 1, to = 2 } }))
    end)
end)

describe("Migrator.migrate (SPEC-002 R5, R7, R10)", function()
    it("aplica os passos em ordem sobre uma cópia (CA3)", function()
        local original = { schemaVersion = 1, name = "x" }
        local ok, result = Migrator.migrate(original, 3, STEPS)
        assert.is_true(ok)
        assert.are.same({ schemaVersion = 3, name = "x", tier = 1 }, result.data)
        assert.are.same({ { from = 1, to = 2 }, { from = 2, to = 3 } }, result.applied)
        assert.are.same({ schemaVersion = 1, name = "x" }, original)
    end)

    it("falha sem tocar no original quando um passo recusa (CA4)", function()
        local failing = {
            { from = 1, to = 2, run = v1ToV2 },
            { from = 2, to = 3, run = function() return false, "dados ruins" end },
        }
        local original = { schemaVersion = 1 }
        local ok, err = Migrator.migrate(original, 3, failing)
        assert.is_false(ok)
        assert.truthy(string.find(err, "dados ruins", 1, true))
        assert.are.same({ schemaVersion = 1 }, original)
    end)

    it("falha quando um passo lança erro", function()
        local broken = { { from = 1, to = 2, run = function() error("bug") end } }
        assert.is_false(Migrator.migrate({ schemaVersion = 1 }, 2, broken))
    end)

    it("falha quando um passo devolve algo que o save não grava (CA8)", function()
        local withFunction = {
            {
                from = 1,
                to = 2,
                run = function(data)
                    data.fn = function() end
                    return true, data
                end,
            },
        }
        assert.is_false(Migrator.migrate({ schemaVersion = 1 }, 2, withFunction))
    end)
end)
