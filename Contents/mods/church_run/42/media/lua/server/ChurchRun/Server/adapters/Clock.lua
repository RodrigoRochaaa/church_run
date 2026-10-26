-- Relógio real do servidor (port Clock). O relógio do jogo não serve para o rate limit: um minuto de
-- jogo dura cerca de 2,5 s reais (SPEC-001 R7).
local Clock = {}

function Clock.nowMs()
    return getTimestampMs()
end

return Clock
