-- Log do cliente: vai para o console do jogo (console.txt), no mesmo formato do servidor.
local LogFormat = require "ChurchRun/util/LogFormat"

local Log = {}

local function write(level, event, fields)
    print(LogFormat.line(level, event, fields))
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

return Log
