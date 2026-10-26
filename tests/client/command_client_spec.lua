local CommandClient = require "ChurchRun/Client/net/CommandClient"
local Version = require "ChurchRun/protocol/version"
local Fakes = require "fakes/Fakes"

local MODULE = "ChurchRun"

-- answer: função opcional que responde dentro do próprio envio, como em single player (R16).
local function newClient(answer)
    local t = { clock = Fakes.clock(1000), log = Fakes.log(), sent = {}, mismatches = {} }
    t.client = CommandClient.new({
        clock = t.clock,
        log = t.log,
        transport = function(command, args)
            t.sent[#t.sent + 1] = { command = command, args = args }
            if answer ~= nil then
                answer(t, command, args)
            end
        end,
        onVersionMismatch = function(serverVersion, clientVersion)
            t.mismatches[#t.mismatches + 1] = { serverVersion, clientVersion }
        end,
    })
    return t
end

describe("CommandClient (SPEC-001)", function()
    it("acrescenta o pv ao enviar, sem mexer nos argumentos da UI (R5)", function()
        local t = newClient()
        local args = { nonce = 3 }
        assert.is_true(t.client:send("ping", args))
        assert.are.same({ command = "ping", args = { nonce = 3, pv = Version.PROTOCOL_VERSION } }, t.sent[1])
        assert.is_nil(args.pv)
    end)

    it("não envia argumentos inválidos e registra o erro (CA11)", function()
        local t = newClient()
        assert.is_false(t.client:send("ping", { nonce = "x" }))
        assert.are.equal(0, #t.sent)
        assert.are.equal(1, t.log.count("invalidArgs"))
    end)

    it("não envia comando desconhecido nem comando que só o servidor manda", function()
        local t = newClient()
        assert.is_false(t.client:send("fooBar", {}))
        assert.is_false(t.client:send("pong", { nonce = 1 }))
        assert.are.equal(0, #t.sent)
    end)

    it("casa cada pong pelo nonce e registra o tempo de ida e volta (CA12)", function()
        local t = newClient()
        t.client:ping()
        t.client:ping()
        t.clock.advance(150)
        t.client:onServerCommand(MODULE, "pong", { nonce = t.sent[2].args.nonce })
        t.client:onServerCommand(MODULE, "pong", { nonce = t.sent[1].args.nonce })
        local pongs = t.log.all("pong")
        assert.are.equal(2, #pongs)
        assert.are.equal(150, pongs[1].fields.rttMs)
    end)

    it("ignora pong com nonce que o cliente não mandou (CA12)", function()
        local t = newClient()
        t.client:onServerCommand(MODULE, "pong", { nonce = 999 })
        assert.are.equal(0, t.log.count("pong"))
        assert.are.equal(1, t.log.count("unexpectedPong"))
    end)

    it("aceita o pong que chega dentro do próprio envio, como em single player (R16)", function()
        local t = newClient(function(context, command, args)
            if command == "ping" then
                context.client:onServerCommand(MODULE, "pong", { nonce = args.nonce })
            end
        end)
        t.client:ping()
        assert.are.equal(1, t.log.count("pong"))
    end)

    it("no versionMismatch, avisa uma vez e para de enviar (CA5)", function()
        local t = newClient()
        t.client:onServerCommand(MODULE, "versionMismatch", { serverVersion = 2 })
        t.client:onServerCommand(MODULE, "versionMismatch", { serverVersion = 2 })
        assert.are.same({ { 2, Version.PROTOCOL_VERSION } }, t.mismatches)
        t.client:ping()
        assert.are.equal(0, #t.sent)
        assert.are.equal(1, t.log.count("sendBlocked"))
    end)

    it("registra o rejected recebido", function()
        local t = newClient()
        t.client:onServerCommand(MODULE, "rejected", { command = "ping", reason = "invalidArgs", field = "nonce" })
        assert.are.equal("nonce", t.log.all("rejected")[1].fields.field)
    end)

    it("descarta resposta fora do esquema (R13)", function()
        local t = newClient()
        t.client:onServerCommand(MODULE, "pong", {})
        t.client:onServerCommand(MODULE, "pong", nil)
        assert.are.equal(2, t.log.count("invalidServerArgs"))
    end)

    it("ignora mensagens de outros módulos e comandos que o cliente não conhece", function()
        local t = newClient()
        t.client:onServerCommand("vehicle", "pong", { nonce = 1 })
        t.client:onServerCommand(MODULE, "ping", { nonce = 1 })
        assert.are.equal(0, t.log.count("pong"))
        assert.are.equal(1, t.log.count("unknownServerCommand"))
    end)

    it("não acumula pings sem resposta além do limite", function()
        local t = newClient()
        for _ = 1, CommandClient.MAX_PENDING_PINGS * 3 do
            t.client:ping()
        end
        assert.is_true(t.client:pendingPingCount() <= CommandClient.MAX_PENDING_PINGS)
    end)
end)
