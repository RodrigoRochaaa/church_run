-- Lint do church_run (CLAUDE.md §3.4 e §6). Rode `luacheck .` na raiz do repositório.

-- Só o que o Kahlua do B42 tem de fato: BaseLib, StringLib, TableLib, MathLib, OsLib e CoroutineLib do
-- projectzomboid.jar, mais o stdlib.lua da instalação (conferido no 42.21.0). Faltam, por exemplo, next
-- e xpcall; com este std o lint acusa o uso antes de o jogo quebrar (CLAUDE.md §6.2).
stds.kahlua = {
    read_globals = {
        "assert", "error", "getmetatable", "ipairs", "pairs", "pcall", "print", "rawequal", "rawget",
        "rawset", "require", "select", "setmetatable", "tonumber", "tostring", "type", "unpack",
        string = {
            fields = {
                "byte", "char", "find", "format", "gmatch", "gsub", "len", "lower", "match", "rep",
                "reverse", "sub", "upper",
            },
        },
        table = { fields = { "concat", "insert", "remove", "sort" } },
        math = {
            fields = {
                "abs", "acos", "asin", "atan", "atan2", "ceil", "cos", "cosh", "deg", "exp", "floor",
                "fmod", "frexp", "huge", "ldexp", "log", "log10", "max", "min", "modf", "pi", "pow",
                "rad", "sin", "sinh", "sqrt", "tan", "tanh",
            },
        },
        os = { fields = { "date", "difftime", "time" } },
        coroutine = { fields = { "create", "resume", "running", "status", "wrap", "yield" } },
    },
}

std = "kahlua"
max_line_length = 120
globals = { "ChurchRun" }
exclude_files = { "tests/fixtures/**" }
-- Argumento que começa com _ é de propósito não usado (ex.: callbacks com assinatura fixa).
ignore = { "212/_.*" }

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
    "triggerEvent",
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
-- Os testes rodam no Lua 5.1 completo (busted), não no Kahlua.
files["tests/**/*.lua"] = { std = "lua51+busted" }
