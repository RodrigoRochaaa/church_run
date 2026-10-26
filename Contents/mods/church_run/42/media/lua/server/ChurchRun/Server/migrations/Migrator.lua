-- Migrações de esquema, passo a passo e tudo-ou-nada (SPEC-002 R5 e R7). Roda sobre uma cópia: quem
-- chamou só troca os dados originais se todos os passos derem certo.
local Tables = require "ChurchRun/util/Tables"

local Migrator = {}

-- steps: lista de { from = N, to = N + 1, run = função(dados) -> true, dados | false, erro }, cobrindo
-- da v1 até a versão atual, sem buraco nem repetição.
function Migrator.checkSteps(current, steps)
    if type(steps) ~= "table" or #steps ~= current - 1 then
        return false, "expected " .. (current - 1) .. " migration steps"
    end
    for i, step in ipairs(steps) do
        local valid = type(step) == "table" and step.from == i and step.to == i + 1 and type(step.run) == "function"
        if not valid then
            return false, "step " .. i .. " must migrate v" .. i .. " to v" .. (i + 1)
        end
    end
    return true
end

local function runStep(step, data)
    local label = "v" .. step.from .. "->v" .. step.to
    -- O pcall faz um bug numa migração virar modo seguro, e não um servidor que não sobe.
    local called, ok, result = pcall(step.run, data)
    if not called then
        return false, "migration " .. label .. " raised: " .. tostring(ok)
    end
    if not ok then
        return false, "migration " .. label .. " refused: " .. tostring(result)
    end
    if type(result) ~= "table" or not Tables.isPlainData(result) then
        return false, "migration " .. label .. " returned data the save cannot store"
    end
    result.schemaVersion = step.to
    return true, result
end

-- Devolve true e { data, applied }, ou false e o erro. Não altera `data`.
function Migrator.migrate(data, current, steps)
    local working = Tables.deepCopy(data)
    local applied = {}
    for version = data.schemaVersion, current - 1 do
        local step = steps[version]
        local ok, result = runStep(step, working)
        if not ok then
            return false, result
        end
        working = result
        applied[#applied + 1] = { from = step.from, to = step.to }
    end
    return true, { data = working, applied = applied }
end

return Migrator
