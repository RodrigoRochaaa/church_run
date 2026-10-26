-- Bootstrap do servidor: confere o catálogo e os ports, liga os adaptadores ao app (CLAUDE.md §3.1)
-- e registra os eventos. Roda no servidor dedicado e em single player.
local Commands = require "ChurchRun/protocol/commands"
local Version = require "ChurchRun/protocol/version"
local Ports = require "ChurchRun/Server/ports/Ports"
local Router = require "ChurchRun/Server/app/protocol/Router"
local Ping = require "ChurchRun/Server/app/protocol/Ping"
local WorldStore = require "ChurchRun/Server/app/storage/WorldStore"
local WorldMigrations = require "ChurchRun/Server/migrations/World"
local Clock = require "ChurchRun/Server/adapters/Clock"
local Log = require "ChurchRun/Server/adapters/Log"
local Net = require "ChurchRun/Server/adapters/Net"
local Players = require "ChurchRun/Server/adapters/Players"
local Storage = require "ChurchRun/Server/adapters/Storage"

ChurchRun = ChurchRun or {}

local function checkWiring(ports)
    local ok, err = Commands.check(Commands.catalog)
    if not ok then
        return false, err
    end
    for name, impl in pairs(ports) do
        ok, err = Ports.check(name, impl)
        if not ok then
            return false, err
        end
    end
    return true
end

local ports = { Clock = Clock, Log = Log, Net = Net.new(), Players = Players, Storage = Storage }
local wired, wiringError = checkWiring(ports)

if not wired then
    Log.error("serverDisabled", { reason = wiringError })
else
    local worldStore = WorldStore.new({
        storage = ports.Storage,
        clock = ports.Clock,
        log = ports.Log,
        migrations = WorldMigrations,
    })

    local router = Router.new({
        clock = ports.Clock,
        log = ports.Log,
        net = ports.Net,
        players = ports.Players,
        handlers = { [Commands.PING] = Ping.handle },
        dataReady = function()
            return worldStore:isReady()
        end,
    })

    -- Pontos de entrada: um erro do mod é logado e não derruba o servidor (CLAUDE.md §6.2). Se a carga
    -- falhar, os dados ficam indisponíveis e o roteador só atende o ping (SPEC-002 R6).
    local function onInitGlobalModData()
        local ok, err = pcall(worldStore.load, worldStore)
        if not ok then
            Log.error("storageError", { error = err })
        end
    end

    local function onClientCommand(module, command, player, args)
        local ok, err = pcall(router.handle, router, module, command, player, args)
        if not ok then
            Log.error("routerError", { command = command, error = err })
        end
    end

    Events.OnInitGlobalModData.Add(onInitGlobalModData)
    Events.OnClientCommand.Add(onClientCommand)
    Log.info("serverReady", { protocol = Version.PROTOCOL_VERSION })
end
