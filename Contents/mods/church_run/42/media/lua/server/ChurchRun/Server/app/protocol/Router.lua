-- Roteador dos pedidos do cliente (SPEC-001 R1 e R4 a R14): valida tudo antes de qualquer lógica e
-- só então chama o caso de uso do comando. Recusa sem resposta o que não merece resposta (comando
-- desconhecido, spam), para não devolver uma mensagem a cada pedido de um cliente malicioso.
local Commands = require "ChurchRun/protocol/commands"
local Schemas = require "ChurchRun/protocol/schemas"
local Version = require "ChurchRun/protocol/version"
local Text = require "ChurchRun/util/Text"
local RateLimiter = require "ChurchRun/Server/app/protocol/RateLimiter"
local RefusalLog = require "ChurchRun/Server/app/protocol/RefusalLog"

local Router = {}
Router.__index = Router

Router.SWEEP_INTERVAL_MS = 60000
Router.UNKNOWN_USER = "?"

-- deps: clock, log, net e players (ports), handlers (comando → função(ctx, args)) e catalog
-- (opcional; por padrão, o catálogo do mod).
function Router.new(deps)
    local self = setmetatable({}, Router)
    self.catalog = deps.catalog or Commands.catalog
    self.handlers = deps.handlers
    self.clock = deps.clock
    self.log = deps.log
    self.net = deps.net
    self.players = deps.players
    self.limiter = RateLimiter.new()
    self.refusals = RefusalLog.new(deps.log)
    self.nextSweepMs = 0
    return self
end

local function isCurrentVersion(args)
    return type(args) == "table" and args[Commands.VERSION_FIELD] == Version.PROTOCOL_VERSION
end

function Router:sweepIfDue(now)
    if now < self.nextSweepMs then
        return
    end
    self.limiter:sweep(now)
    self.refusals:sweep(now)
    self.nextSweepMs = now + Router.SWEEP_INTERVAL_MS
end

function Router:reject(player, command, reason, field)
    local args = { command = command, reason = reason }
    if field ~= nil and field ~= "" then
        args.field = field
    end
    self.net.sendToPlayer(player, Commands.REJECTED, args)
end

function Router:dispatch(player, user, command, args)
    local ctx = {
        username = user,
        log = self.log,
        reply = function(replyCommand, replyArgs)
            self.net.sendToPlayer(player, replyCommand, replyArgs)
        end,
    }
    local ok, err = pcall(self.handlers[command], ctx, args)
    if not ok then
        self.log.error("handlerError", { command = command, user = user, error = err })
        self:reject(player, command, Commands.REASON_INTERNAL_ERROR)
    end
end

function Router:handle(module, command, player, args)
    if module ~= Commands.MODULE then
        return
    end
    local now = self.clock.nowMs()
    local user = self.players.username(player) or Router.UNKNOWN_USER
    self:sweepIfDue(now)
    local def = Commands.lookup(self.catalog, command)
    if def == nil or def.direction ~= Commands.TO_SERVER then
        local name = Text.sanitize(command, Commands.MAX_NAME_LEN)
        self.refusals:record(user, now, "unknownCommand", { command = name })
        return
    end
    if not self.limiter:take(user, command, def.rateLimit, now) then
        self.refusals:record(user, now, "rateLimited", { command = command })
        return
    end
    if not isCurrentVersion(args) then
        self.refusals:record(user, now, "versionMismatch", { command = command })
        self.net.sendToPlayer(player, Commands.VERSION_MISMATCH, { serverVersion = Version.PROTOCOL_VERSION })
        return
    end
    local valid, err = Schemas.validate(def.schema, args, Commands.VERSION_FIELD)
    if not valid then
        local field = Text.sanitize(err.field, Commands.MAX_NAME_LEN)
        self.refusals:record(user, now, "invalidArgs", { command = command, field = field, problem = err.problem })
        self:reject(player, command, Commands.REASON_INVALID_ARGS, field)
        return
    end
    self:dispatch(player, user, command, args)
end

return Router
