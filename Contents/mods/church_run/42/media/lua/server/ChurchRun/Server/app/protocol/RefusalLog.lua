-- Auditoria das recusas (CLAUDE.md §4, SPEC-001 R8), com teto por jogador: sem ele, um cliente
-- mandando lixo enche o log do servidor.
local RefusalLog = {}
RefusalLog.__index = RefusalLog

RefusalLog.MAX_LINES_PER_WINDOW = 10
RefusalLog.WINDOW_MS = 60000

function RefusalLog.new(log)
    return setmetatable({ log = log, windows = {} }, RefusalLog)
end

local function copy(fields)
    local result = {}
    for key, value in pairs(fields) do
        result[key] = value
    end
    return result
end

function RefusalLog:record(user, now, event, fields)
    local window = self.windows[user]
    if window == nil or now - window.startMs >= RefusalLog.WINDOW_MS then
        local carried = window ~= nil and window.suppressed or 0
        window = { startMs = now, lines = 0, suppressed = carried }
        self.windows[user] = window
    end
    if window.lines >= RefusalLog.MAX_LINES_PER_WINDOW then
        window.suppressed = window.suppressed + 1
        return
    end
    window.lines = window.lines + 1
    local line = copy(fields)
    line.user = user
    if window.suppressed > 0 then
        line.suppressed = window.suppressed
        window.suppressed = 0
    end
    self.log.audit(event, line)
end

-- Janela vencida some da memória; se ainda havia recusas suprimidas, a contagem vai para o log antes.
function RefusalLog:sweep(now)
    local expired = {}
    for user, window in pairs(self.windows) do
        if now - window.startMs >= RefusalLog.WINDOW_MS then
            expired[#expired + 1] = user
        end
    end
    for _, user in ipairs(expired) do
        local window = self.windows[user]
        if window.suppressed > 0 then
            self.log.audit("refusalsSuppressed", { user = user, suppressed = window.suppressed })
        end
        self.windows[user] = nil
    end
end

function RefusalLog:count()
    local total = 0
    for _ in pairs(self.windows) do
        total = total + 1
    end
    return total
end

return RefusalLog
