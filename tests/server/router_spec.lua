local Router = require "ChurchRun/Server/app/protocol/Router"
local Commands = require "ChurchRun/protocol/commands"
local Schemas = require "ChurchRun/protocol/schemas"
local Version = require "ChurchRun/protocol/version"
local Ping = require "ChurchRun/Server/app/protocol/Ping"
local Fakes = require "fakes/Fakes"

local MODULE = Commands.MODULE
local PV = Version.PROTOCOL_VERSION

local function newRouter(handlers)
    local t = {
        clock = Fakes.clock(0),
        log = Fakes.log(),
        net = Fakes.net(),
        players = Fakes.players(),
    }
    t.router = Router.new({
        clock = t.clock,
        log = t.log,
        net = t.net,
        players = t.players,
        handlers = handlers or { ping = Ping.handle },
    })
    return t
end

local function countingHandlers()
    local calls = { count = 0 }
    local handlers = {
        ping = function(ctx, args)
            calls.count = calls.count + 1
            Ping.handle(ctx, args)
        end,
    }
    return handlers, calls
end

describe("Router (SPEC-001)", function()
    local ana = Fakes.player("ana")
    local bia = Fakes.player("bia")

    it("responde pong ao ping válido e registra o ping com o username (CA1)", function()
        local t = newRouter()
        t.router:handle(MODULE, "ping", ana, { pv = PV, nonce = 7 })
        assert.are.same({ { player = ana, command = "pong", args = { nonce = 7 } } }, t.net.sent)
        assert.are.equal("ana", t.log.all("ping")[1].fields.user)
    end)

    it("ignora mensagens de outros módulos, sem log nem resposta (R1)", function()
        local t = newRouter()
        t.router:handle("vehicle", "ping", ana, { pv = PV, nonce = 7 })
        assert.are.equal(0, #t.net.sent)
        assert.are.equal(0, #t.log.lines)
    end)

    it("ignora comando desconhecido, com log e sem resposta (CA2)", function()
        local handlers, calls = countingHandlers()
        local t = newRouter(handlers)
        t.router:handle(MODULE, "fooBar", ana, { pv = PV })
        assert.are.equal(0, calls.count)
        assert.are.equal(0, #t.net.sent)
        assert.are.equal(1, t.log.count("unknownCommand"))
    end)

    it("trata como desconhecido um comando toClient vindo do cliente (R4.2)", function()
        local t = newRouter()
        t.router:handle(MODULE, "pong", ana, { pv = PV, nonce = 1 })
        assert.are.equal(0, #t.net.sent)
        assert.are.equal(1, t.log.count("unknownCommand"))
    end)

    it("recusa argumentos inválidos com rejected e sem chamar o handler (CA3)", function()
        local badArgs = {
            { args = { pv = PV, nonce = "abc" }, field = "nonce" },
            { args = { pv = PV, nonce = 1.5 }, field = "nonce" },
            { args = { pv = PV, nonce = -1 }, field = "nonce" },
            { args = { pv = PV, nonce = 0 / 0 }, field = "nonce" },
            { args = { pv = PV }, field = "nonce" },
            { args = { pv = PV, nonce = 1, x = 1 }, field = "x" },
        }
        for _, case in ipairs(badArgs) do
            local handlers, calls = countingHandlers()
            local t = newRouter(handlers)
            t.router:handle(MODULE, "ping", ana, case.args)
            assert.are.equal(0, calls.count)
            local expected = { command = "ping", reason = Commands.REASON_INVALID_ARGS, field = case.field }
            assert.are.same({ { player = ana, command = "rejected", args = expected } }, t.net.sent)
            assert.are.equal(1, t.log.count("invalidArgs"))
        end
    end)

    it("responde versionMismatch e não executa quando o pv difere, falta ou args é nil (CA4)", function()
        for _, args in ipairs({ { pv = PV + 1, nonce = 1 }, { nonce = 1 }, false }) do
            local handlers, calls = countingHandlers()
            local t = newRouter(handlers)
            t.router:handle(MODULE, "ping", ana, args or nil)
            assert.are.equal(0, calls.count)
            local expected = { serverVersion = PV }
            assert.are.same({ { player = ana, command = "versionMismatch", args = expected } }, t.net.sent)
            assert.are.equal(1, t.log.count("versionMismatch"))
        end
    end)

    it("descarta sem resposta o que passa do rate limit (CA6)", function()
        local t = newRouter()
        for nonce = 1, 5 do
            t.router:handle(MODULE, "ping", ana, { pv = PV, nonce = nonce })
        end
        assert.are.equal(3, #t.net.sent)
        assert.are.equal(2, t.log.count("rateLimited"))
        t.clock.advance(5000)
        t.router:handle(MODULE, "ping", ana, { pv = PV, nonce = 6 })
        assert.are.equal(4, #t.net.sent)
    end)

    it("um jogador no limite não atrapalha outro (CA7)", function()
        local t = newRouter()
        for nonce = 1, 4 do
            t.router:handle(MODULE, "ping", ana, { pv = PV, nonce = nonce })
        end
        t.router:handle(MODULE, "ping", bia, { pv = PV, nonce = 9 })
        assert.are.same({ player = bia, command = "pong", args = { nonce = 9 } }, t.net.sent[#t.net.sent])
    end)

    it("grava no máximo 10 recusas por minuto do mesmo jogador (CA8)", function()
        local t = newRouter()
        for _ = 1, 100 do
            t.router:handle(MODULE, "fooBar", ana, { pv = PV })
        end
        assert.are.equal(10, t.log.count("unknownCommand"))
    end)

    it("corta e limpa no log o nome de um comando desconhecido (CA9)", function()
        local t = newRouter()
        local name = string.rep("x", 500) .. "\n[ChurchRun] INFO forjado"
        t.router:handle(MODULE, name, ana, { pv = PV })
        local logged = t.log.all("unknownCommand")[1].fields.command
        assert.are.equal(Commands.MAX_NAME_LEN, #logged)
        assert.is_nil(string.find(logged, "\n", 1, true))
    end)

    it("erro no handler vira internalError, e o pedido seguinte é atendido (CA10)", function()
        local calls = 0
        local handlers = {
            ping = function(ctx, args)
                calls = calls + 1
                if calls == 1 then
                    error("boom")
                end
                Ping.handle(ctx, args)
            end,
        }
        local t = newRouter(handlers)
        t.router:handle(MODULE, "ping", ana, { pv = PV, nonce = 1 })
        t.router:handle(MODULE, "ping", ana, { pv = PV, nonce = 2 })
        local expected = { command = "ping", reason = Commands.REASON_INTERNAL_ERROR }
        assert.are.same({ player = ana, command = "rejected", args = expected }, t.net.sent[1])
        assert.are.same({ player = ana, command = "pong", args = { nonce = 2 } }, t.net.sent[2])
        assert.are.equal(1, t.log.count("handlerError"))
    end)

    it("toda resposta enviada bate com o esquema do catálogo (R13)", function()
        local t = newRouter()
        t.router:handle(MODULE, "ping", ana, { pv = PV, nonce = 1 })
        t.router:handle(MODULE, "ping", ana, { pv = PV, nonce = "x" })
        t.router:handle(MODULE, "ping", ana, { pv = PV + 1, nonce = 1 })
        assert.are.equal(3, #t.net.sent)
        for _, message in ipairs(t.net.sent) do
            local def = Commands.catalog[message.command]
            assert.are.equal(Commands.TO_CLIENT, def.direction)
            assert.is_true(Schemas.validate(def.schema, message.args))
        end
    end)

    it("varre os baldes parados no máximo uma vez por minuto (CA13)", function()
        local t = newRouter()
        t.router:handle(MODULE, "ping", ana, { pv = PV, nonce = 1 })
        t.clock.advance(Router.SWEEP_INTERVAL_MS)
        t.router:handle(MODULE, "ping", bia, { pv = PV, nonce = 1 })
        assert.are.equal(1, t.router.limiter:count())
    end)

    it("com os dados indisponíveis, só o ping é atendido (SPEC-002 R6, CA5)", function()
        local catalog = {
            ping = Commands.catalog.ping,
            buy = {
                direction = Commands.TO_SERVER,
                rateLimit = { burst = 3, perSecond = 1 },
                schema = { item = { type = "string", maxLen = 8 } },
            },
        }
        local bought = 0
        local net = Fakes.net()
        local router = Router.new({
            catalog = catalog,
            clock = Fakes.clock(0),
            log = Fakes.log(),
            net = net,
            players = Fakes.players(),
            dataReady = function()
                return false
            end,
            handlers = {
                ping = Ping.handle,
                buy = function()
                    bought = bought + 1
                end,
            },
        })
        router:handle(MODULE, "buy", ana, { pv = PV, item = "x" })
        router:handle(MODULE, "ping", ana, { pv = PV, nonce = 1 })
        assert.are.equal(0, bought)
        local expected = { command = "buy", reason = Commands.REASON_SERVER_DATA_UNAVAILABLE }
        assert.are.same({ player = ana, command = "rejected", args = expected }, net.sent[1])
        assert.are.same({ player = ana, command = "pong", args = { nonce = 1 } }, net.sent[2])
    end)

    it("usa um nome padrão quando o jogo não informa o username", function()
        local t = newRouter()
        t.router:handle(MODULE, "ping", Fakes.player(nil), { pv = PV, nonce = 1 })
        assert.are.equal(Router.UNKNOWN_USER, t.log.all("ping")[1].fields.user)
    end)
end)
