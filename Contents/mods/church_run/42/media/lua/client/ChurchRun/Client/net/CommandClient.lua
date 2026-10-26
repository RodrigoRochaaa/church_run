-- Cliente de comandos (SPEC-001 R5 e R11 a R13): confere os pedidos com o mesmo esquema do servidor,
-- acrescenta a versão do protocolo e trata as respostas. A UI fala com o servidor só por aqui.
local Commands = require "ChurchRun/protocol/commands"
local Schemas = require "ChurchRun/protocol/schemas"
local Version = require "ChurchRun/protocol/version"

local CommandClient = {}
CommandClient.__index = CommandClient

CommandClient.MAX_PENDING_PINGS = 8

-- deps: clock e log (adaptadores do cliente), transport (função(command, args) que envia) e
-- onVersionMismatch (função(serverVersion, clientVersion), ligada à UI pelo Main.lua).
function CommandClient.new(deps)
    local self = setmetatable({}, CommandClient)
    self.catalog = deps.catalog or Commands.catalog
    self.clock = deps.clock
    self.log = deps.log
    self.transport = deps.transport
    self.onVersionMismatch = deps.onVersionMismatch
    self.blocked = false
    self.nextNonce = 1
    self.pendingPings = {}
    self.pendingCount = 0
    return self
end

function CommandClient:send(command, args)
    if self.blocked then
        self.log.warn("sendBlocked", { command = command })
        return false
    end
    local def = Commands.lookup(self.catalog, command)
    if def == nil or def.direction ~= Commands.TO_SERVER then
        self.log.error("unknownCommand", { command = command })
        return false
    end
    local ok, err = Schemas.validate(def.schema, args)
    if not ok then
        self.log.error("invalidArgs", { command = command, field = err.field, problem = err.problem })
        return false
    end
    local payload = {}
    for key, value in pairs(args or {}) do
        payload[key] = value
    end
    payload[Commands.VERSION_FIELD] = Version.PROTOCOL_VERSION
    self.transport(command, payload)
    return true
end

function CommandClient:ping()
    local nonce = self.nextNonce
    self.nextNonce = nonce % Commands.NONCE_MAX + 1
    if self.pendingCount >= CommandClient.MAX_PENDING_PINGS then
        self.pendingPings = {}
        self.pendingCount = 0
    end
    -- Registra antes de enviar: em single player a resposta chega dentro do próprio envio (R16).
    self.pendingPings[nonce] = self.clock.nowMs()
    self.pendingCount = self.pendingCount + 1
    if not self:send(Commands.PING, { nonce = nonce }) then
        self.pendingPings[nonce] = nil
        self.pendingCount = self.pendingCount - 1
    end
end

function CommandClient:pendingPingCount()
    return self.pendingCount
end

local function handlePong(self, args)
    local sentMs = self.pendingPings[args.nonce]
    if sentMs == nil then
        self.log.warn("unexpectedPong", { nonce = args.nonce })
        return
    end
    self.pendingPings[args.nonce] = nil
    self.pendingCount = self.pendingCount - 1
    self.log.info(Commands.PONG, { nonce = args.nonce, rttMs = self.clock.nowMs() - sentMs })
end

local function handleVersionMismatch(self, args)
    if self.blocked then
        return
    end
    self.blocked = true
    self.log.error(Commands.VERSION_MISMATCH, { server = args.serverVersion, client = Version.PROTOCOL_VERSION })
    self.onVersionMismatch(args.serverVersion, Version.PROTOCOL_VERSION)
end

local function handleRejected(self, args)
    self.log.warn(Commands.REJECTED, { command = args.command, reason = args.reason, field = args.field })
end

local HANDLERS = {
    [Commands.PONG] = handlePong,
    [Commands.VERSION_MISMATCH] = handleVersionMismatch,
    [Commands.REJECTED] = handleRejected,
}

function CommandClient:onServerCommand(module, command, args)
    if module ~= Commands.MODULE then
        return
    end
    local def = Commands.lookup(self.catalog, command)
    if def == nil or def.direction ~= Commands.TO_CLIENT then
        self.log.warn("unknownServerCommand", { command = command })
        return
    end
    local ok, err = Schemas.validate(def.schema, args)
    if not ok then
        self.log.warn("invalidServerArgs", { command = command, field = err.field, problem = err.problem })
        return
    end
    local handler = HANDLERS[command]
    if handler ~= nil then
        handler(self, args)
    end
end

return CommandClient
