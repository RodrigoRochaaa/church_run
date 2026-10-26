local RateLimiter = require "ChurchRun/Server/app/protocol/RateLimiter"

local PING_LIMIT = { burst = 3, perSecond = 0.2 }

local function takeMany(limiter, user, times, now)
    local passed = 0
    for _ = 1, times do
        if limiter:take(user, "ping", PING_LIMIT, now) then
            passed = passed + 1
        end
    end
    return passed
end

describe("RateLimiter (SPEC-001 R7, R14)", function()
    it("deixa passar o burst e descarta o resto no mesmo segundo (CA6)", function()
        local limiter = RateLimiter.new()
        assert.are.equal(3, takeMany(limiter, "ana", 5, 1000))
    end)

    it("repõe uma ficha a cada 5 s (CA6)", function()
        local limiter = RateLimiter.new()
        takeMany(limiter, "ana", 3, 0)
        assert.is_false(limiter:take("ana", "ping", PING_LIMIT, 0))
        assert.is_true(limiter:take("ana", "ping", PING_LIMIT, 5000))
        assert.is_false(limiter:take("ana", "ping", PING_LIMIT, 5000))
    end)

    it("cada jogador tem o próprio balde (CA7)", function()
        local limiter = RateLimiter.new()
        takeMany(limiter, "ana", 3, 0)
        assert.is_false(limiter:take("ana", "ping", PING_LIMIT, 0))
        assert.is_true(limiter:take("bia", "ping", PING_LIMIT, 0))
    end)

    it("cada comando tem o próprio balde", function()
        local limiter = RateLimiter.new()
        takeMany(limiter, "ana", 3, 0)
        assert.is_true(limiter:take("ana", "other", PING_LIMIT, 0))
    end)

    it("não quebra se o relógio voltar", function()
        local limiter = RateLimiter.new()
        takeMany(limiter, "ana", 3, 10000)
        assert.is_false(limiter:take("ana", "ping", PING_LIMIT, 5000))
    end)

    it("a varredura remove baldes cheios e mantém os que estão em uso (CA13)", function()
        local limiter = RateLimiter.new()
        takeMany(limiter, "ana", 1, 0)
        takeMany(limiter, "bia", 3, 50000)
        limiter:sweep(60000)
        assert.are.equal(1, limiter:count())
    end)
end)
