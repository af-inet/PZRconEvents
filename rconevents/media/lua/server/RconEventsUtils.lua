function _getRuntime()
    if isServer() then
        return "server"
    else
        return "client"
    end
end

function _fullName(p)
    local desc = p:getDescriptor()
    return desc:getForename() .. " " .. desc:getSurname()
end

function _pronoun(p)
    if p:isFemale() then
        return "She"
    else
        return "He"
    end
end

-- pretty print our traits
function _sumTraits(p)
    local s = ""
    if p:getTraits():size() == 0 then
        return nil
    end
    for i = 0, p:getTraits():size() - 1 do
        local v = p:getTraits():get(i)
        -- the first entry does not need a comma
        if i == 0 then
            s = s .. v
        else
            s = s .. ", " .. v
        end
    end
    return s
end

function _isBitten(p)
    local bodyParts = p:getBodyDamage():getBodyParts()
    for i = 0, BodyPartType.ToIndex(BodyPartType.MAX) - 1 do
        local bodyPart = bodyParts:get(i);
        if bodyPart:bitten() then
            return true
        end
    end
    return false
end

function _tableToString(t)
    local str = ""
    for _, e in ipairs(t) do
        str = str .. e .. "\n"
    end
    return str
end

function _formatDeathMessage(p)
    local msg = ""
    local uname = p:getUsername()
    local fname = _fullName(p)
    local hours = p:getHoursSurvived()
    local k = p:getZombieKills()
    local pronoun = _pronoun(p)
    local desc = _sumTraits(p)
    local bit = _isBitten(p)

    local msg = string.format('%s (%s) has died.', uname, fname)
    msg = msg .. string.format(' %s survived for %.3f hours, and had %d kills.', pronoun, hours, k)

    -- only add summarized traits if they had any traits.
    if desc then
        msg = msg .. ' Their traits were: ' .. desc .. '.'
    end

    if bit then
        msg = msg .. " They were bitten."
    end
    return msg
end

function _formatJoinedMessage(p)
    local msg = ""
    local uname = p:getUsername()
    local fname = _fullName(p)
    local hours = p:getHoursSurvived()
    local k = p:getZombieKills()
    local pronoun = _pronoun(p)
    local desc = _sumTraits(p)
    local bit = _isBitten(p)

    local msg = string.format('%s (%s) has joined.', uname, fname)
    msg = msg .. string.format(' %s has survived for %.3f hours, and has %d kills.', pronoun, hours, k)

    -- only add summarized traits if they had any traits.
    if desc then
        msg = msg .. ' Their traits are: ' .. desc .. '.'
    end

    if bit then
        msg = msg .. " They are bitten."
    end
    return msg
end

