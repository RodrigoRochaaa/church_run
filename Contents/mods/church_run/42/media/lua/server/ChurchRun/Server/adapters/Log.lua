-- Log do servidor (port Log). Tudo vai para o console do servidor; as linhas de auditoria também vão
-- para um arquivo próprio pelo writeLog (CLAUDE.md §4).
local LogFormat = require "ChurchRun/util/LogFormat"

local Log = {}

Log.AUDIT_LOGGER = "ChurchRun"

local function write(level, event, fields)
    local line = LogFormat.line(level, event, fields)
    print(line)
    return line
end

function Log.info(event, fields)
    write("INFO", event, fields)
end

function Log.warn(event, fields)
    write("WARN", event, fields)
end

function Log.error(event, fields)
    write("ERROR", event, fields)
end

function Log.audit(event, fields)
    local line = write("AUDIT", event, fields)
    -- VERIFICAR B42: onde o writeLog grava o arquivo (esperado: Zomboid/Logs) e se existe em single
    -- player. O pcall impede que uma falha do log de arquivo derrube o pedido.
    pcall(writeLog, Log.AUDIT_LOGGER, line)
end

return Log
