-- Lint do church_run (CLAUDE.md §3.4 e §6). Rode `luacheck .` na raiz do repositório.
std = "lua51"
max_line_length = 120
globals = { "ChurchRun" }
exclude_files = { "tests/fixtures/**" }

-- API do jogo: só em adapters/ e nos Main.lua. A lista cresce conforme os adaptadores precisarem.
local PZ_API = {
    "Events",
    "ModData",
    "getPlayer",
    "getSpecificPlayer",
    "getOnlinePlayers",
    "getPlayerFromUsername",
    "sendClientCommand",
    "sendServerCommand",
    "isClient",
    "isServer",
    "getTimestampMs",
    "getGameTime",
    "getScriptManager",
    "instanceItem",
    "writeLog",
    "getText",
    "getCore",
}

-- Exceção da UI (CLAUDE.md §3.4): só classes de interface e funções de texto e tela.
local PZ_UI_API = {
    "ISPanel",
    "ISButton",
    "ISLabel",
    "ISCollapsableWindow",
    "ISModalDialog",
    "ISRichTextPanel",
    "UIFont",
    "getText",
    "getCore",
    "getTextManager",
}

files["Contents/**/adapters/**/*.lua"] = { read_globals = PZ_API }
files["Contents/**/Main.lua"] = { read_globals = PZ_API }
files["Contents/**/ui/**/*.lua"] = { read_globals = PZ_UI_API }
files["tests/**/*.lua"] = { std = "+busted" }
