local Text = require "ChurchRun/util/Text"

describe("Text.sanitize (SPEC-001 R8)", function()
    it("corta no tamanho máximo", function()
        assert.are.equal("abc", Text.sanitize("abcdef", 3))
    end)

    it("troca quebras de linha e caracteres de controle por espaço", function()
        assert.are.equal("a b c d", Text.sanitize("a\nb\rc\0d", 10))
    end)

    it("converte valores que não são texto", function()
        assert.are.equal("12", Text.sanitize(12, 10))
        assert.are.equal("nil", Text.sanitize(nil, 10))
    end)
end)
