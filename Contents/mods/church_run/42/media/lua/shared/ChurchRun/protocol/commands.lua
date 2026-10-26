-- Catálogo dos comandos de rede (SPEC-001 R2 e Contrato). Comando fora daqui não existe.
local Schemas = require "ChurchRun/protocol/schemas"

local Commands = {}

Commands.MODULE = "ChurchRun"
Commands.TO_SERVER = "toServer"
Commands.TO_CLIENT = "toClient"
-- Campo reservado com a versão do protocolo em todo pedido; o roteador confere antes do esquema (R5).
Commands.VERSION_FIELD = "pv"
Commands.MAX_NAME_LEN = 32
Commands.NONCE_MAX = 2147483647

Commands.PING = "ping"
Commands.PONG = "pong"
Commands.VERSION_MISMATCH = "versionMismatch"
Commands.REJECTED = "rejected"

Commands.REASON_INVALID_ARGS = "invalidArgs"
Commands.REASON_INTERNAL_ERROR = "internalError"

local NAME_PATTERN = "^[a-z][A-Za-z0-9]*$"

local NONCE = { type = "integer", min = 0, max = Commands.NONCE_MAX }
local PROTOCOL_VERSION = { type = "integer", min = 1, max = 1000 }

Commands.catalog = {
    [Commands.PING] = {
        direction = Commands.TO_SERVER,
        rateLimit = { burst = 3, perSecond = 0.2 },
        schema = { nonce = NONCE },
    },
    [Commands.PONG] = {
        direction = Commands.TO_CLIENT,
        schema = { nonce = NONCE },
    },
    [Commands.VERSION_MISMATCH] = {
        direction = Commands.TO_CLIENT,
        schema = { serverVersion = PROTOCOL_VERSION },
    },
    [Commands.REJECTED] = {
        direction = Commands.TO_CLIENT,
        schema = {
            command = { type = "string", minLen = 1, maxLen = Commands.MAX_NAME_LEN },
            reason = {
                type = "enum",
                values = { Commands.REASON_INVALID_ARGS, Commands.REASON_INTERNAL_ERROR },
            },
            field = { type = "string", minLen = 1, maxLen = Commands.MAX_NAME_LEN, optional = true },
        },
    },
}

function Commands.lookup(catalog, name)
    if type(name) ~= "string" then
        return nil
    end
    return catalog[name]
end

local function isValidName(name)
    return type(name) == "string" and #name <= Commands.MAX_NAME_LEN and string.find(name, NAME_PATTERN) ~= nil
end

local function checkRateLimit(limit)
    if type(limit) ~= "table" then
        return false, "comando toServer precisa de rateLimit"
    end
    local burst, perSecond = limit.burst, limit.perSecond
    local burstOk = type(burst) == "number" and burst >= 1 and burst == math.floor(burst)
    local refillOk = type(perSecond) == "number" and perSecond > 0 and perSecond < math.huge
    if not burstOk or not refillOk then
        return false, "rateLimit precisa de burst inteiro >= 1 e perSecond > 0"
    end
    return true
end

local function checkSchema(schema)
    if type(schema) ~= "table" then
        return false, "schema deve ser uma tabela"
    end
    for field, def in pairs(schema) do
        if not isValidName(field) then
            return false, "nome de campo inválido: " .. tostring(field)
        end
        if field == Commands.VERSION_FIELD then
            return false, "o campo " .. Commands.VERSION_FIELD .. " é reservado"
        end
        local ok, err = Schemas.checkFieldDef(def)
        if not ok then
            return false, field .. ": " .. err
        end
    end
    return true
end

local function checkCommand(name, def)
    if not isValidName(name) then
        return false, "nome de comando inválido"
    end
    if type(def) ~= "table" or (def.direction ~= Commands.TO_SERVER and def.direction ~= Commands.TO_CLIENT) then
        return false, "direção inválida"
    end
    if def.direction == Commands.TO_SERVER then
        local ok, err = checkRateLimit(def.rateLimit)
        if not ok then
            return false, err
        end
    end
    return checkSchema(def.schema)
end

-- Conferido na carga dos dois lados: um catálogo inválido desliga o mod com log, em vez de falhar
-- no meio do jogo.
function Commands.check(catalog)
    for name, def in pairs(catalog) do
        local ok, err = checkCommand(name, def)
        if not ok then
            return false, tostring(name) .. ": " .. err
        end
    end
    return true
end

return Commands
