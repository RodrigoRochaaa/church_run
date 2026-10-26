-- Funções de tabela para os dados salvos (SPEC-002 R5 e R10). As tabelas da Global ModData são
-- vivas: o jogo grava a própria tabela, então trocar o conteúdo precisa ser no lugar.
local Tables = {}

local PLAIN_TYPES = { string = true, number = true, boolean = true }

-- O Kahlua do B42 não tem next (CLAUDE.md §6.2), então a tabela vazia é conferida com pairs.
function Tables.isEmpty(tbl)
    for _ in pairs(tbl) do
        return false
    end
    return true
end

function Tables.deepCopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for key, item in pairs(value) do
        copy[Tables.deepCopy(key)] = Tables.deepCopy(item)
    end
    return copy
end

-- Troca o conteúdo de target pelo de source (copiado), mantendo a mesma tabela. As chaves são
-- removidas depois do laço, porque apagar durante o pairs é arriscado no Kahlua.
function Tables.replaceContents(target, source)
    local keys = {}
    for key in pairs(target) do
        keys[#keys + 1] = key
    end
    for _, key in ipairs(keys) do
        target[key] = nil
    end
    for key, item in pairs(source) do
        target[key] = Tables.deepCopy(item)
    end
end

local function isPlain(value, visiting)
    local kind = type(value)
    if PLAIN_TYPES[kind] then
        return true
    end
    if kind ~= "table" or visiting[value] then
        return false
    end
    visiting[value] = true
    for key, item in pairs(value) do
        local keyKind = type(key)
        if (keyKind ~= "string" and keyKind ~= "number") or not isPlain(item, visiting) then
            return false
        end
    end
    visiting[value] = nil
    return true
end

-- Só texto, número, booleano e tabelas desses tipos, sem ciclos: o que o save do jogo consegue gravar.
function Tables.isPlainData(value)
    return isPlain(value, {})
end

return Tables
