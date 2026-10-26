-- Texto que vem de fora (do cliente, de um erro) e vai para o log ou para uma resposta. Corta no
-- tamanho máximo e troca quebras de linha e caracteres de controle por espaço, para ninguém forjar
-- linhas de log (SPEC-001 R8). Percorre os bytes em vez de usar classes de padrão, que podem variar
-- no Kahlua.
local Text = {}

local FIRST_PRINTABLE_BYTE = 32
local DELETE_BYTE = 127

function Text.sanitize(value, maxLen)
    local text = tostring(value)
    if #text > maxLen then
        text = string.sub(text, 1, maxLen)
    end
    local chars = {}
    for i = 1, #text do
        local byte = string.byte(text, i)
        if byte < FIRST_PRINTABLE_BYTE or byte == DELETE_BYTE then
            chars[i] = " "
        else
            chars[i] = string.char(byte)
        end
    end
    return table.concat(chars)
end

return Text
