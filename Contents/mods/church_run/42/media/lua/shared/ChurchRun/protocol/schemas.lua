-- Esquemas dos argumentos dos comandos e a validação deles (SPEC-001 R3 e R4.5). O servidor valida
-- tudo antes de qualquer lógica; o cliente usa o mesmo código só como ajuda (R12).
local Schemas = {}

Schemas.MAX_STRING_LEN = 256

Schemas.PROBLEM_NOT_TABLE = "notTable"
Schemas.PROBLEM_UNKNOWN_FIELD = "unknownField"
Schemas.PROBLEM_MISSING = "missing"
Schemas.PROBLEM_WRONG_TYPE = "wrongType"
Schemas.PROBLEM_NOT_FINITE = "notFinite"
Schemas.PROBLEM_NOT_INTEGER = "notInteger"
Schemas.PROBLEM_OUT_OF_RANGE = "outOfRange"
Schemas.PROBLEM_LENGTH = "length"
Schemas.PROBLEM_NOT_ALLOWED = "notAllowed"

local ARGS_FIELD = "args"
local EMPTY = {}

local function isFinite(value)
    -- NaN é o único valor diferente de si mesmo.
    return value == value and value ~= math.huge and value ~= -math.huge
end

local function isInteger(value)
    return type(value) == "number" and isFinite(value) and value == math.floor(value)
end

local function checkString(def, value)
    if type(value) ~= "string" then
        return Schemas.PROBLEM_WRONG_TYPE
    end
    if #value < (def.minLen or 0) or #value > def.maxLen then
        return Schemas.PROBLEM_LENGTH
    end
    return nil
end

local function checkNumber(def, value)
    if type(value) ~= "number" then
        return Schemas.PROBLEM_WRONG_TYPE
    end
    if not isFinite(value) then
        return Schemas.PROBLEM_NOT_FINITE
    end
    if def.type == "integer" and value ~= math.floor(value) then
        return Schemas.PROBLEM_NOT_INTEGER
    end
    if value < def.min or value > def.max then
        return Schemas.PROBLEM_OUT_OF_RANGE
    end
    return nil
end

local function checkBoolean(_, value)
    if type(value) ~= "boolean" then
        return Schemas.PROBLEM_WRONG_TYPE
    end
    return nil
end

local function checkEnum(def, value)
    if type(value) ~= "string" then
        return Schemas.PROBLEM_WRONG_TYPE
    end
    for _, allowed in ipairs(def.values) do
        if value == allowed then
            return nil
        end
    end
    return Schemas.PROBLEM_NOT_ALLOWED
end

local VALUE_CHECKS = {
    string = checkString,
    integer = checkNumber,
    number = checkNumber,
    boolean = checkBoolean,
    enum = checkEnum,
}

local function checkLengthDef(def)
    if not isInteger(def.maxLen) or def.maxLen < 1 or def.maxLen > Schemas.MAX_STRING_LEN then
        return false, "maxLen deve ser inteiro de 1 a " .. Schemas.MAX_STRING_LEN
    end
    if def.minLen ~= nil and (not isInteger(def.minLen) or def.minLen < 0 or def.minLen > def.maxLen) then
        return false, "minLen deve ser inteiro de 0 a maxLen"
    end
    return true
end

local function checkRangeDef(def)
    local numbers = type(def.min) == "number" and type(def.max) == "number"
    if not numbers or not isFinite(def.min) or not isFinite(def.max) or def.min > def.max then
        return false, "min e max devem ser números finitos, com min <= max"
    end
    return true
end

local function checkBooleanDef()
    return true
end

local function checkEnumDef(def)
    if type(def.values) ~= "table" or #def.values == 0 then
        return false, "enum precisa de uma lista de valores"
    end
    for _, allowed in ipairs(def.values) do
        if type(allowed) ~= "string" then
            return false, "os valores de enum devem ser texto"
        end
    end
    return true
end

local DEF_CHECKS = {
    string = checkLengthDef,
    integer = checkRangeDef,
    number = checkRangeDef,
    boolean = checkBooleanDef,
    enum = checkEnumDef,
}

-- Confere a definição de um campo; usado na conferência do catálogo, na carga.
function Schemas.checkFieldDef(def)
    if type(def) ~= "table" or DEF_CHECKS[def.type] == nil then
        return false, "tipo de campo desconhecido"
    end
    if def.optional ~= nil and type(def.optional) ~= "boolean" then
        return false, "optional deve ser booleano"
    end
    return DEF_CHECKS[def.type](def)
end

-- Devolve true, ou false e { field, problem }. skipField é um campo aceito sem conferência: o pv,
-- que o roteador confere antes (R4.4).
function Schemas.validate(schema, args, skipField)
    -- O jogo entrega nil quando a tabela de argumentos chega vazia.
    local values = args
    if values == nil then
        values = EMPTY
    end
    if type(values) ~= "table" then
        return false, { field = ARGS_FIELD, problem = Schemas.PROBLEM_NOT_TABLE }
    end
    for key, value in pairs(values) do
        if key ~= skipField then
            local def = schema[key]
            if def == nil then
                -- Para no primeiro campo desconhecido, sem percorrer o resto da tabela.
                return false, { field = key, problem = Schemas.PROBLEM_UNKNOWN_FIELD }
            end
            local problem = VALUE_CHECKS[def.type](def, value)
            if problem ~= nil then
                return false, { field = key, problem = problem }
            end
        end
    end
    for name, def in pairs(schema) do
        if not def.optional and values[name] == nil then
            return false, { field = name, problem = Schemas.PROBLEM_MISSING }
        end
    end
    return true
end

return Schemas
