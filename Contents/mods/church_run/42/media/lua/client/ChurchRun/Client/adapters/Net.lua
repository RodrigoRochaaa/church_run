-- Envio dos pedidos do cliente (transport do CommandClient). O jogador do pedido é o local; o
-- servidor identifica quem pediu pelo próprio evento (SPEC-001 R6).
local Commands = require "ChurchRun/protocol/commands"

local Net = {}

function Net.send(command, args)
    sendClientCommand(getPlayer(), Commands.MODULE, command, args)
end

return Net
