-- Caso de uso do ping (SPEC-001 R11): prova que o mod carregou nos dois lados.
local Commands = require "ChurchRun/protocol/commands"

local Ping = {}

function Ping.handle(ctx, args)
    ctx.log.info(Commands.PING, { user = ctx.username, nonce = args.nonce })
    ctx.reply(Commands.PONG, { nonce = args.nonce })
end

return Ping
