-- Balde de fichas por jogador e por comando (SPEC-001 R7 e R14). O tempo vem de fora (relógio
-- real, em ms), para o teste controlar.
local Tables = require "ChurchRun/util/Tables"

local RateLimiter = {}
RateLimiter.__index = RateLimiter

local MS_PER_SECOND = 1000

function RateLimiter.new()
    return setmetatable({ buckets = {} }, RateLimiter)
end

local function refill(bucket, now)
    local elapsedSeconds = math.max(0, now - bucket.updatedMs) / MS_PER_SECOND
    bucket.tokens = math.min(bucket.limit.burst, bucket.tokens + elapsedSeconds * bucket.limit.perSecond)
    bucket.updatedMs = now
end

function RateLimiter:take(user, command, limit, now)
    local userBuckets = self.buckets[user]
    if userBuckets == nil then
        userBuckets = {}
        self.buckets[user] = userBuckets
    end
    local bucket = userBuckets[command]
    if bucket == nil then
        bucket = { tokens = limit.burst, updatedMs = now, limit = limit }
        userBuckets[command] = bucket
    else
        refill(bucket, now)
    end
    if bucket.tokens < 1 then
        return false
    end
    bucket.tokens = bucket.tokens - 1
    return true
end

-- Balde cheio não guarda informação: some, e com ele a memória de quem parou ou saiu. As chaves são
-- removidas depois do laço, porque apagar durante o pairs é arriscado no Kahlua.
function RateLimiter:sweep(now)
    local emptyUsers = {}
    for user, userBuckets in pairs(self.buckets) do
        local fullBuckets = {}
        for command, bucket in pairs(userBuckets) do
            refill(bucket, now)
            if bucket.tokens >= bucket.limit.burst then
                fullBuckets[#fullBuckets + 1] = command
            end
        end
        for _, command in ipairs(fullBuckets) do
            userBuckets[command] = nil
        end
        if Tables.isEmpty(userBuckets) then
            emptyUsers[#emptyUsers + 1] = user
        end
    end
    for _, user in ipairs(emptyUsers) do
        self.buckets[user] = nil
    end
end

function RateLimiter:count()
    local total = 0
    for _, userBuckets in pairs(self.buckets) do
        for _ in pairs(userBuckets) do
            total = total + 1
        end
    end
    return total
end

return RateLimiter
