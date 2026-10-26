-- Rede do servidor (port Net). Em single player, sendServerCommand não volta ao cliente local, então
-- a resposta é entregue por triggerEvent (SPEC-001 R16). VERIFICAR B42 em jogo: a conclusão vem das
-- classes do 42.21.0.
local Commands = require "ChurchRun/protocol/commands"

local Net = {}

local SERVER_COMMAND_EVENT = "OnServerCommand"

-- game: as funções do jogo; os testes passam uma tabela falsa.
function Net.new(game)
    local api = game or {
        isClient = isClient,
        isServer = isServer,
        sendServerCommand = sendServerCommand,
        triggerEvent = triggerEvent,
    }
    local net = {}

    local function isSinglePlayer()
        return not api.isClient() and not api.isServer()
    end

    function net.sendToPlayer(player, command, args)
        if isSinglePlayer() then
            api.triggerEvent(SERVER_COMMAND_EVENT, Commands.MODULE, command, args)
        else
            api.sendServerCommand(player, Commands.MODULE, command, args)
        end
    end

    function net.sendToAll(command, args)
        if isSinglePlayer() then
            api.triggerEvent(SERVER_COMMAND_EVENT, Commands.MODULE, command, args)
        else
            api.sendServerCommand(Commands.MODULE, command, args)
        end
    end

    return net
end

return Net
