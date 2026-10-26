-- Relógio real do cliente: mede o tempo de ida e volta do ping (SPEC-001 R11).
local Clock = {}

function Clock.nowMs()
    return getTimestampMs()
end

return Clock
