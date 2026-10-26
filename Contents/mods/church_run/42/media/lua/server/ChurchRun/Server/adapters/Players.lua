-- Identidade do jogador (port Players): o username do jogador que o servidor recebeu no evento
-- (SPEC-001 R6), nunca um nome vindo nos argumentos.
local Players = {}

function Players.username(player)
    if player == nil then
        return nil
    end
    return player:getUsername()
end

return Players
