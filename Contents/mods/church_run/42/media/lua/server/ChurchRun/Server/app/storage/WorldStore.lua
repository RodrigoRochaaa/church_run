-- Carga do estado global (SPEC-002 R4 a R9; ADR-002): cria, confere a versão, migra ou entra em modo
-- seguro. Em modo seguro nada é gravado, e o roteador só atende o ping (R6).
local Migrator = require "ChurchRun/Server/migrations/Migrator"
local Tables = require "ChurchRun/util/Tables"

local WorldStore = {}
WorldStore.__index = WorldStore

WorldStore.KEY = "ChurchRun_World"
WorldStore.BACKUP_KEY = "ChurchRun_World_backup"
WorldStore.SAFE_MODE_HINT = "update the mod or restore ChurchRun_World_backup"

-- deps: storage, clock e log (ports) e migrations (CURRENT, steps e initial).
function WorldStore.new(deps)
    local self = setmetatable({}, WorldStore)
    self.storage = deps.storage
    self.clock = deps.clock
    self.log = deps.log
    self.migrations = deps.migrations
    self.ready = false
    return self
end

function WorldStore:isReady()
    return self.ready
end

function WorldStore:enterSafeMode(reason, fields)
    self.ready = false
    local line = Tables.deepCopy(fields or {})
    line.key = WorldStore.KEY
    line.reason = reason
    line.hint = WorldStore.SAFE_MODE_HINT
    self.log.error("storage.safeMode", line)
    return false
end

local function isPositiveInteger(value)
    return type(value) == "number" and value >= 1 and value == math.floor(value)
end

function WorldStore:migrate(live)
    local ok, result = Migrator.migrate(live, self.migrations.CURRENT, self.migrations.steps)
    if not ok then
        return false, "migrationFailed", { error = result }
    end
    Tables.replaceContents(self.storage.open(WorldStore.BACKUP_KEY), live)
    Tables.replaceContents(live, result.data)
    for _, step in ipairs(result.applied) do
        self.log.info("storage.migrated", { key = WorldStore.KEY, from = step.from, to = step.to })
    end
    return true
end

function WorldStore:prepare(live)
    local current = self.migrations.CURRENT
    if next(live) == nil then
        Tables.replaceContents(live, self.migrations.initial(self.clock.nowMs()))
        self.log.info("storage.created", { key = WorldStore.KEY, schemaVersion = current })
        return true
    end
    local version = live.schemaVersion
    if not isPositiveInteger(version) then
        return false, "noSchemaVersion", { found = tostring(version) }
    end
    if version > current then
        return false, "newerSchema", { found = version, supported = current }
    end
    if version < current then
        return self:migrate(live)
    end
    return true
end

function WorldStore:load()
    local stepsOk, stepsErr = Migrator.checkSteps(self.migrations.CURRENT, self.migrations.steps)
    if not stepsOk then
        return self:enterSafeMode("invalidMigrations", { error = stepsErr })
    end
    local live = self.storage.open(WorldStore.KEY)
    local ok, reason, fields = self:prepare(live)
    if not ok then
        return self:enterSafeMode(reason, fields)
    end
    live.bootCount = (live.bootCount or 0) + 1
    self.ready = true
    self.log.info("storage.loaded", {
        key = WorldStore.KEY,
        schemaVersion = live.schemaVersion,
        bootCount = live.bootCount,
        createdAtMs = live.createdAtMs,
    })
    return true
end

return WorldStore
