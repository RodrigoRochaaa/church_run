-- Aviso de versão de protocolo diferente (SPEC-001 R5). Só mostra a mensagem: quem bloqueia os
-- envios é o CommandClient.
local VersionMismatchDialog = {}

VersionMismatchDialog.WIDTH = 420
VersionMismatchDialog.HEIGHT = 160
VersionMismatchDialog.TEXT_KEY = "UI_ChurchRun_VersionMismatch"

function VersionMismatchDialog.show(serverVersion, clientVersion)
    local core = getCore()
    local x = core:getScreenWidth() / 2 - VersionMismatchDialog.WIDTH / 2
    local y = core:getScreenHeight() / 2 - VersionMismatchDialog.HEIGHT / 2
    local text = getText(VersionMismatchDialog.TEXT_KEY, tostring(serverVersion), tostring(clientVersion))
    local modal = ISModalDialog:new(x, y, VersionMismatchDialog.WIDTH, VersionMismatchDialog.HEIGHT, text, false)
    modal:initialise()
    modal:addToUIManager()
end

return VersionMismatchDialog
