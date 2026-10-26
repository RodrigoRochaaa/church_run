-- Ports falsos para os testes (CLAUDE.md §7). Cada um guarda o que recebeu, para o teste conferir.
local Fakes = {}

function Fakes.clock(startMs)
    local clock = { now = startMs or 0 }

    function clock.nowMs()
        return clock.now
    end

    function clock.advance(ms)
        clock.now = clock.now + ms
    end

    return clock
end

function Fakes.log()
    local log = { lines = {} }

    local function writer(level)
        return function(event, fields)
            log.lines[#log.lines + 1] = { level = level, event = event, fields = fields or {} }
        end
    end

    log.info = writer("INFO")
    log.warn = writer("WARN")
    log.error = writer("ERROR")
    log.audit = writer("AUDIT")

    function log.all(event)
        local found = {}
        for _, line in ipairs(log.lines) do
            if line.event == event then
                found[#found + 1] = line
            end
        end
        return found
    end

    function log.count(event)
        return #log.all(event)
    end

    function log.last()
        return log.lines[#log.lines]
    end

    return log
end

function Fakes.net()
    local net = { sent = {} }

    function net.sendToPlayer(player, command, args)
        net.sent[#net.sent + 1] = { player = player, command = command, args = args }
    end

    function net.sendToAll(command, args)
        net.sent[#net.sent + 1] = { player = "*", command = command, args = args }
    end

    return net
end

function Fakes.players()
    local players = {}

    function players.username(player)
        return player.username
    end

    return players
end

function Fakes.player(username)
    return { username = username }
end

-- Como a Global ModData: open devolve sempre a mesma tabela viva da chave, criada vazia na primeira vez.
function Fakes.storage(tables)
    local storage = { tables = tables or {} }

    function storage.open(key)
        local data = storage.tables[key]
        if data == nil then
            data = {}
            storage.tables[key] = data
        end
        return data
    end

    return storage
end

return Fakes
