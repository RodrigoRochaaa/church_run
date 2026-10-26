local WorldStore = require "ChurchRun/Server/app/storage/WorldStore"
local WorldMigrations = require "ChurchRun/Server/migrations/World"
local Tables = require "ChurchRun/util/Tables"
local Fakes = require "fakes/Fakes"

local KEY = WorldStore.KEY
local BACKUP_KEY = WorldStore.BACKUP_KEY

local function newStore(storage, migrations, clock)
    local t = { storage = storage or Fakes.storage(), log = Fakes.log(), clock = clock or Fakes.clock(5000) }
    t.store = WorldStore.new({
        storage = t.storage,
        clock = t.clock,
        log = t.log,
        migrations = migrations or WorldMigrations,
    })
    return t
end

-- Versão de teste com 3 esquemas, para exercitar migrações reais de ponta a ponta.
local function testMigrations(secondStep)
    return {
        CURRENT = 3,
        initial = WorldMigrations.initial,
        steps = {
            {
                from = 1,
                to = 2,
                run = function(data)
                    data.level = 1
                    return true, data
                end,
            },
            secondStep or {
                from = 2,
                to = 3,
                run = function(data)
                    data.tier = data.level
                    data.level = nil
                    return true, data
                end,
            },
        },
    }
end

describe("WorldStore (SPEC-002)", function()
    it("cria os dados v1 num mundo novo (CA1)", function()
        local t = newStore()
        assert.is_true(t.store:load())
        local data = t.storage.tables[KEY]
        assert.are.same({ schemaVersion = 1, createdAtMs = 5000, bootCount = 1 }, data)
        assert.are.equal(1, t.log.count("storage.created"))
        assert.are.equal(1, t.log.count("storage.loaded"))
        assert.is_true(t.store:isReady())
    end)

    it("num reinício, bootCount sobe e createdAtMs não muda (CA2)", function()
        local storage = Fakes.storage()
        newStore(storage).store:load()
        local clock = Fakes.clock(999999)
        local t = newStore(storage, nil, clock)
        assert.is_true(t.store:load())
        assert.are.equal(2, storage.tables[KEY].bootCount)
        assert.are.equal(5000, storage.tables[KEY].createdAtMs)
        assert.are.equal(0, t.log.count("storage.created"))
    end)

    it("migra dados antigos, guarda o backup e registra cada passo (CA3)", function()
        local old = { schemaVersion = 1, createdAtMs = 10, bootCount = 4 }
        local storage = Fakes.storage({ [KEY] = old })
        local t = newStore(storage, testMigrations())
        assert.is_true(t.store:load())
        assert.are.same({ schemaVersion = 3, createdAtMs = 10, bootCount = 5, tier = 1 }, storage.tables[KEY])
        assert.are.equal(old, storage.tables[KEY])
        assert.are.same({ schemaVersion = 1, createdAtMs = 10, bootCount = 4 }, storage.tables[BACKUP_KEY])
        assert.are.equal(2, t.log.count("storage.migrated"))
    end)

    it("migração que falha deixa dados e backup intactos e liga o modo seguro (CA4)", function()
        local failing = { from = 2, to = 3, run = function() return false, "quebrou" end }
        local storage = Fakes.storage({
            [KEY] = { schemaVersion = 1, createdAtMs = 10, bootCount = 4 },
            [BACKUP_KEY] = { schemaVersion = 0, note = "antigo" },
        })
        local t = newStore(storage, testMigrations(failing))
        assert.is_false(t.store:load())
        assert.are.same({ schemaVersion = 1, createdAtMs = 10, bootCount = 4 }, storage.tables[KEY])
        assert.are.same({ schemaVersion = 0, note = "antigo" }, storage.tables[BACKUP_KEY])
        assert.are.equal(1, t.log.count("storage.safeMode"))
        assert.is_false(t.store:isReady())
    end)

    it("dados de versão mais nova ligam o modo seguro sem gravar nada (CA5)", function()
        local storage = Fakes.storage({ [KEY] = { schemaVersion = 9, x = 1 } })
        local t = newStore(storage)
        assert.is_false(t.store:load())
        assert.are.same({ schemaVersion = 9, x = 1 }, storage.tables[KEY])
        assert.is_nil(storage.tables[BACKUP_KEY])
        local safeMode = t.log.all("storage.safeMode")[1]
        assert.are.equal(9, safeMode.fields.found)
        assert.are.equal(1, safeMode.fields.supported)
    end)

    it("tabela com dados e sem schemaVersion liga o modo seguro e preserva tudo (CA6)", function()
        local storage = Fakes.storage({ [KEY] = { foo = 1 } })
        local t = newStore(storage)
        assert.is_false(t.store:load())
        assert.are.same({ foo = 1 }, storage.tables[KEY])
    end)

    it("lista de migrações inválida liga o modo seguro sem abrir os dados (CA7)", function()
        local broken = { CURRENT = 3, initial = WorldMigrations.initial, steps = {} }
        local storage = Fakes.storage({ [KEY] = { schemaVersion = 1 } })
        local t = newStore(storage, broken)
        assert.is_false(t.store:load())
        assert.are.same({ schemaVersion = 1 }, storage.tables[KEY])
        assert.are.equal("invalidMigrations", t.log.all("storage.safeMode")[1].fields.reason)
    end)

    it("antes da carga, os dados não estão prontos (R6)", function()
        assert.is_false(newStore().store:isReady())
    end)
end)

describe("migrações do mundo (SPEC-002 R9, R10)", function()
    it("a versão atual é a 1 e não tem passos", function()
        assert.are.equal(1, WorldMigrations.CURRENT)
        assert.are.equal(0, #WorldMigrations.steps)
    end)

    it("os valores iniciais só têm tipos simples (CA8)", function()
        local initial = WorldMigrations.initial(123)
        assert.is_true(Tables.isPlainData(initial))
        assert.are.same({ schemaVersion = 1, createdAtMs = 123, bootCount = 0 }, initial)
    end)
end)
