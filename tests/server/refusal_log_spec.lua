local RefusalLog = require "ChurchRun/Server/app/protocol/RefusalLog"
local Fakes = require "fakes/Fakes"

local function recordMany(refusals, user, times, startMs, stepMs)
    for i = 1, times do
        refusals:record(user, startMs + (i - 1) * stepMs, "invalidArgs", { command = "ping" })
    end
end

describe("RefusalLog (SPEC-001 R8)", function()
    it("grava no máximo 10 linhas por jogador por minuto (CA8)", function()
        local log = Fakes.log()
        recordMany(RefusalLog.new(log), "ana", 100, 0, 100)
        assert.are.equal(RefusalLog.MAX_LINES_PER_WINDOW, log.count("invalidArgs"))
    end)

    it("toda linha é de auditoria e leva o username", function()
        local log = Fakes.log()
        recordMany(RefusalLog.new(log), "ana", 1, 0, 0)
        assert.are.equal("AUDIT", log.last().level)
        assert.are.equal("ana", log.last().fields.user)
    end)

    it("a primeira linha do minuto seguinte informa as suprimidas (CA8)", function()
        local log = Fakes.log()
        local refusals = RefusalLog.new(log)
        recordMany(refusals, "ana", 100, 0, 100)
        refusals:record("ana", 60000, "invalidArgs", { command = "ping" })
        assert.are.equal(90, log.last().fields.suppressed)
    end)

    it("as contas de jogadores diferentes não se misturam", function()
        local log = Fakes.log()
        local refusals = RefusalLog.new(log)
        recordMany(refusals, "ana", 20, 0, 10)
        recordMany(refusals, "bia", 1, 500, 0)
        assert.are.equal("bia", log.last().fields.user)
        assert.is_nil(log.last().fields.suppressed)
    end)

    it("a varredura registra as suprimidas de quem parou e libera a memória (R14)", function()
        local log = Fakes.log()
        local refusals = RefusalLog.new(log)
        recordMany(refusals, "ana", 12, 0, 10)
        refusals:sweep(60000)
        assert.are.equal("refusalsSuppressed", log.last().event)
        assert.are.equal(2, log.last().fields.suppressed)
        assert.are.equal(0, refusals:count())
    end)

    it("a varredura mantém a janela de quem ainda está no minuto", function()
        local refusals = RefusalLog.new(Fakes.log())
        recordMany(refusals, "ana", 1, 30000, 0)
        refusals:sweep(60000)
        assert.are.equal(1, refusals:count())
    end)
end)
