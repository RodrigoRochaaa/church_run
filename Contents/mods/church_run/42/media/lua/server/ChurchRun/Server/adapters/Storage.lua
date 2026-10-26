-- Persistência do servidor (port Storage): a tabela viva da Global ModData de uma chave (SPEC-002 R1 e
-- R2). O jogo grava essas tabelas junto com o mundo (R8); getOrCreate é o que o vanilla 42.21.0 usa.
local Storage = {}

function Storage.open(key)
    return ModData.getOrCreate(key)
end

return Storage
