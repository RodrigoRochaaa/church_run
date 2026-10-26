local Schemas = require "ChurchRun/protocol/schemas"

local PV = "pv"
local NONCE_SCHEMA = { nonce = { type = "integer", min = 0, max = 2147483647 } }

local function failure(schema, args)
    local ok, err = Schemas.validate(schema, args, PV)
    assert.is_false(ok)
    return err
end

describe("Schemas.validate (SPEC-001 R3, R4.5)", function()
    it("aceita argumentos que batem com o esquema e ignora o pv", function()
        assert.is_true(Schemas.validate(NONCE_SCHEMA, { pv = 1, nonce = 5 }, PV))
    end)

    it("recusa texto onde o esquema pede inteiro (CA3)", function()
        local err = failure(NONCE_SCHEMA, { pv = 1, nonce = "abc" })
        assert.are.equal("nonce", err.field)
        assert.are.equal(Schemas.PROBLEM_WRONG_TYPE, err.problem)
    end)

    it("recusa fração (CA3)", function()
        assert.are.equal(Schemas.PROBLEM_NOT_INTEGER, failure(NONCE_SCHEMA, { pv = 1, nonce = 1.5 }).problem)
    end)

    it("recusa número fora da faixa (CA3)", function()
        assert.are.equal(Schemas.PROBLEM_OUT_OF_RANGE, failure(NONCE_SCHEMA, { pv = 1, nonce = -1 }).problem)
    end)

    it("recusa NaN e infinito (CA3)", function()
        assert.are.equal(Schemas.PROBLEM_NOT_FINITE, failure(NONCE_SCHEMA, { pv = 1, nonce = 0 / 0 }).problem)
        assert.are.equal(Schemas.PROBLEM_NOT_FINITE, failure(NONCE_SCHEMA, { pv = 1, nonce = math.huge }).problem)
    end)

    it("recusa campo obrigatório ausente (CA3)", function()
        local err = failure(NONCE_SCHEMA, { pv = 1 })
        assert.are.equal("nonce", err.field)
        assert.are.equal(Schemas.PROBLEM_MISSING, err.problem)
    end)

    it("recusa campo desconhecido (CA3)", function()
        local err = failure(NONCE_SCHEMA, { pv = 1, nonce = 1, x = 1 })
        assert.are.equal("x", err.field)
        assert.are.equal(Schemas.PROBLEM_UNKNOWN_FIELD, err.problem)
    end)

    it("recusa chave numérica, como uma lista enviada no lugar dos campos", function()
        local err = failure(NONCE_SCHEMA, { pv = 1, nonce = 1, [1] = "a" })
        assert.are.equal(1, err.field)
        assert.are.equal(Schemas.PROBLEM_UNKNOWN_FIELD, err.problem)
    end)

    it("trata args nil como tabela vazia, porque o jogo entrega nil quando ela chega vazia", function()
        assert.is_true(Schemas.validate({}, nil, PV))
        assert.are.equal("nonce", failure(NONCE_SCHEMA, nil).field)
    end)

    it("recusa args que não são tabela", function()
        local err = failure(NONCE_SCHEMA, "texto")
        assert.are.equal("args", err.field)
        assert.are.equal(Schemas.PROBLEM_NOT_TABLE, err.problem)
    end)

    it("valida texto, número, booleano, enum e campo opcional", function()
        local schema = {
            name = { type = "string", minLen = 2, maxLen = 4 },
            ratio = { type = "number", min = 0, max = 1 },
            flag = { type = "boolean" },
            mode = { type = "enum", values = { "a", "b" } },
            note = { type = "string", maxLen = 8, optional = true },
        }
        assert.is_true(Schemas.validate(schema, { name = "abc", ratio = 0.5, flag = true, mode = "b" }, PV))

        local tooLong = { name = "abcde", ratio = 0.5, flag = true, mode = "b" }
        assert.are.equal(Schemas.PROBLEM_LENGTH, failure(schema, tooLong).problem)

        local badEnum = { name = "abc", ratio = 0.5, flag = true, mode = "c" }
        assert.are.equal(Schemas.PROBLEM_NOT_ALLOWED, failure(schema, badEnum).problem)

        local badFlag = { name = "abc", ratio = 0.5, flag = "sim", mode = "a" }
        assert.are.equal(Schemas.PROBLEM_WRONG_TYPE, failure(schema, badFlag).problem)
    end)
end)

describe("Schemas.checkFieldDef (SPEC-001 R3)", function()
    it("aceita definições válidas", function()
        assert.is_true(Schemas.checkFieldDef({ type = "string", maxLen = 32 }))
        assert.is_true(Schemas.checkFieldDef({ type = "integer", min = 0, max = 10 }))
        assert.is_true(Schemas.checkFieldDef({ type = "number", min = -1, max = 1, optional = true }))
        assert.is_true(Schemas.checkFieldDef({ type = "boolean" }))
        assert.is_true(Schemas.checkFieldDef({ type = "enum", values = { "a" } }))
    end)

    it("recusa texto sem maxLen ou acima do limite", function()
        assert.is_false(Schemas.checkFieldDef({ type = "string" }))
        assert.is_false(Schemas.checkFieldDef({ type = "string", maxLen = Schemas.MAX_STRING_LEN + 1 }))
        assert.is_false(Schemas.checkFieldDef({ type = "string", minLen = 5, maxLen = 4 }))
    end)

    it("recusa número sem faixa ou com faixa invertida", function()
        assert.is_false(Schemas.checkFieldDef({ type = "integer", min = 0 }))
        assert.is_false(Schemas.checkFieldDef({ type = "number", min = 2, max = 1 }))
        assert.is_false(Schemas.checkFieldDef({ type = "number", min = 0, max = math.huge }))
    end)

    it("recusa enum vazio, tipo desconhecido e optional que não é booleano", function()
        assert.is_false(Schemas.checkFieldDef({ type = "enum", values = {} }))
        assert.is_false(Schemas.checkFieldDef({ type = "table" }))
        assert.is_false(Schemas.checkFieldDef({ type = "boolean", optional = "sim" }))
    end)
end)
