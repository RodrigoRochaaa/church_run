-- Contratos (ports) que o app do servidor usa (CLAUDE.md §3.1). O Main.lua confere cada adaptador na
-- ligação e os testes conferem os falsos, para um port incompleto falhar na carga e não no meio do jogo.
local Ports = {}

Ports.contracts = {
    Clock = { "nowMs" },
    Log = { "info", "warn", "error", "audit" },
    Net = { "sendToPlayer", "sendToAll" },
    Players = { "username" },
    Storage = { "open" },
}

function Ports.check(name, impl)
    local contract = Ports.contracts[name]
    if contract == nil then
        return false, "unknown port: " .. tostring(name)
    end
    if type(impl) ~= "table" then
        return false, name .. ": missing implementation"
    end
    for _, fn in ipairs(contract) do
        if type(impl[fn]) ~= "function" then
            return false, name .. "." .. fn .. " not implemented"
        end
    end
    return true
end

return Ports
