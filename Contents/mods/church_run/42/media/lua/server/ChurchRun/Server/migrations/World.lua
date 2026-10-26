-- Esquema de ChurchRun_World (SPEC-002 R9). Versão nova = CURRENT + 1, um passo novo em steps e o
-- teste desse passo, no mesmo PR (R3).
local World = {}

World.CURRENT = 1

World.steps = {}

function World.initial(nowMs)
    return { schemaVersion = World.CURRENT, createdAtMs = nowMs, bootCount = 0 }
end

return World
