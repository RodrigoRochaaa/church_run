local Tables = require "ChurchRun/util/Tables"

describe("Tables (SPEC-002 R5, R10)", function()
    it("deepCopy copia em profundidade e as cópias são independentes", function()
        local original = { a = 1, nested = { b = { 2, 3 } } }
        local copy = Tables.deepCopy(original)
        assert.are.same(original, copy)
        copy.nested.b[1] = 99
        assert.are.equal(2, original.nested.b[1])
    end)

    it("replaceContents troca o conteúdo mantendo a mesma tabela", function()
        local target = { old = true, keep = 1 }
        local source = { keep = 2, new = { x = 1 } }
        Tables.replaceContents(target, source)
        assert.are.same({ keep = 2, new = { x = 1 } }, target)
        source.new.x = 5
        assert.are.equal(1, target.new.x)
    end)

    it("isPlainData aceita texto, número, booleano e tabelas desses tipos", function()
        assert.is_true(Tables.isPlainData({ a = "x", b = 1, c = true, d = { 1, 2, { e = "f" } } }))
    end)

    it("isPlainData recusa funções, chaves de tabela e ciclos", function()
        assert.is_false(Tables.isPlainData({ fn = function() end }))
        assert.is_false(Tables.isPlainData({ [{}] = 1 }))
        local cyclic = {}
        cyclic.self = cyclic
        assert.is_false(Tables.isPlainData(cyclic))
    end)
end)
