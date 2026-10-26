local LogFormat = require "ChurchRun/util/LogFormat"

describe("LogFormat.line (SPEC-001, Log)", function()
    it("monta prefixo, nível, evento e campos em ordem alfabética", function()
        local line = LogFormat.line("AUDIT", "invalidArgs", { user = "ana", field = "nonce" })
        assert.are.equal("[ChurchRun] AUDIT invalidArgs field=nonce user=ana", line)
    end)

    it("aceita evento sem campos", function()
        assert.are.equal("[ChurchRun] INFO serverReady", LogFormat.line("INFO", "serverReady"))
    end)

    it("não deixa um valor quebrar a linha (CA9)", function()
        local line = LogFormat.line("AUDIT", "unknownCommand", { command = "x\n[ChurchRun] INFO forjado" })
        assert.is_nil(string.find(line, "\n", 1, true))
    end)
end)
