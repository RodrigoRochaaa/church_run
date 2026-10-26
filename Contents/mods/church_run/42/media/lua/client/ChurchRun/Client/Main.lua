-- Bootstrap do cliente: confere o catálogo, liga o cliente de comandos aos adaptadores e à UI
-- (CLAUDE.md §3.1) e registra os eventos.
local Commands = require "ChurchRun/protocol/commands"
local CommandClient = require "ChurchRun/Client/net/CommandClient"
local Clock = require "ChurchRun/Client/adapters/Clock"
local Log = require "ChurchRun/Client/adapters/Log"
local Net = require "ChurchRun/Client/adapters/Net"
local VersionMismatchDialog = require "ChurchRun/Client/ui/VersionMismatchDialog"

ChurchRun = ChurchRun or {}

local LOCAL_PLAYER_INDEX = 0

local catalogOk, catalogError = Commands.check(Commands.catalog)

if not catalogOk then
    Log.error("clientDisabled", { reason = catalogError })
else
    local client = CommandClient.new({
        clock = Clock,
        log = Log,
        transport = Net.send,
        onVersionMismatch = VersionMismatchDialog.show,
    })

    -- Pontos de entrada: um erro do mod é logado e não derruba o jogo (CLAUDE.md §6.2).
    local function onServerCommand(module, command, args)
        local ok, err = pcall(client.onServerCommand, client, module, command, args)
        if not ok then
            Log.error("clientError", { command = command, error = err })
        end
    end

    -- VERIFICAR B42: se o OnCreatePlayer do cliente dispara quando o servidor já aceita os pedidos
    -- do jogador (SPEC-001, tabela de API).
    local function onCreatePlayer(playerIndex)
        if playerIndex ~= LOCAL_PLAYER_INDEX then
            return
        end
        local ok, err = pcall(client.ping, client)
        if not ok then
            Log.error("clientError", { command = Commands.PING, error = err })
        end
    end

    Events.OnServerCommand.Add(onServerCommand)
    Events.OnCreatePlayer.Add(onCreatePlayer)

    -- Para o teste manual no console de debug: ChurchRun.client:ping()
    ChurchRun.client = client
end
