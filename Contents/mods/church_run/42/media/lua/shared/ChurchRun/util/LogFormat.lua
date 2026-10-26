-- Um formato só para as linhas de log do mod, igual no cliente e no servidor (SPEC-001, seção Log),
-- para o admin filtrar por evento. Os campos saem em ordem alfabética para a linha ser previsível.
local Text = require "ChurchRun/util/Text"

local LogFormat = {}

LogFormat.PREFIX = "[ChurchRun]"
LogFormat.MAX_TEXT_LEN = 64

local function sortedKeys(fields)
    local keys = {}
    for key in pairs(fields) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)
    return keys
end

function LogFormat.line(level, event, fields)
    local parts = { LogFormat.PREFIX, level, Text.sanitize(event, LogFormat.MAX_TEXT_LEN) }
    local values = fields or {}
    for _, key in ipairs(sortedKeys(values)) do
        local name = Text.sanitize(key, LogFormat.MAX_TEXT_LEN)
        parts[#parts + 1] = name .. "=" .. Text.sanitize(values[key], LogFormat.MAX_TEXT_LEN)
    end
    return table.concat(parts, " ")
end

return LogFormat
