--
-- RconEvents using LuaCommands (requires the Java patch + workshop mod).
-- The goal is to expose rcon commands which give you information about what's
-- happening on the server.
-- This way we can poll this rcon command and send relevant discord notifications.
--
require 'LuaCommands/LuaCommands';
local ServerUtils = require 'ExtraCommands/ServerUtils';

local CMD_NAME = 'rconevents';

-- Event queues + trackers (same as before).
-- 4096 
local MAX_EVENTS = 100
-- I don't know how many bytes are used in RCON messages, so let's leave a buffer zone of 256 bytes.
local CUSHION_BYTES = 256
local MAX_BYTES = 4096 - CUSHION_BYTES
local eventQueue = {}
local eventQueueBytes = 0
local lastSkill = {}
local lastStatus = {}

local function getRuntime()
    if isServer() then
        return "server"
    else
        return "client"
    end
end

-- keep a list of events that haven't been flushed yet.
-- we limit the size and number of the eventQueue to avoid issues with RCON packet size.
local function pushEvent(line)

    -- if the event queue has too many bytes, start forgetting earlier events
    if eventQueueBytes + string.len(line) > MAX_BYTES then
        for i = 1, 10 do
            -- remove a line from the eventQueue and track bytes
            local removed = table.remove(eventQueue, 1)
            eventQueueBytes = eventQueueBytes - string.len(removed)
            if eventQueueBytes + string.len(line) <= MAX_BYTES then
                break -- we have enough space now.
            end
        end
    end

    -- if we are STILL over the limit after removing lines, let's just give up for now, this is a problem.
    if eventQueueBytes + string.len(line) > MAX_BYTES then
        print("[RconEvents:" .. getRuntime() .. "] WARN " ..
                  "there is not enough space in the eventQueue, dropping events...")
        print(line)
        return
    end

    table.insert(eventQueue, line)

    eventQueueBytes = eventQueueBytes + string.len(line)
    if #eventQueue > MAX_EVENTS then
        -- remove a line from the eventQueue and track bytes
        local removed = table.remove(eventQueue, 1)
        eventQueueBytes = eventQueueBytes - string.len(removed)
    end
end

local function getRuntime()
    if isServer() then
        return "server"
    else
        return "client"
    end
end

local function formatDeathMessage(p)
    return string.format("%s died")
end

local function _readEvents()
    local str = ""
    for _, e in ipairs(eventQueue) do
        str = str .. e .. "\n"
    end
    return str
end

local function _fullName(p)
    local desc = p:getDescriptor()
    return desc:getForename() .. " " .. desc:getSurname()
end

-- pretty print our traits
local function sumTraits(p)
    local s = ""
    if p:getTraits():size() == 0 then
        return "none"
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

local function _pronoun(p)
    if p:isFemale() then
        return "She"
    else
        return "He"
    end
end

local function _isBitten(p)
    local bodyParts = p:getBodyDamage():getBodyParts();
    for i = 0, BodyPartType.ToIndex(BodyPartType.MAX) - 1 do
        local bodyPart = bodyParts:get(i);
        if bodyPart:bitten() then
            return true
        end
    end
    return false
end

local function _wasBittenMsg(p)
    if _isBitten(p) then
        return " They were bitten."
    end
    return ""
end

-- Server and Client side
-- Events.EveryOneMinute.Add(function()
--     print("[RconEvents:" .. getRuntime() .. "] DEBUG " .. "EveryOneMinute")
-- end)

-- TODO:
-- Is the player driving?
-- isSeatedInVehicle()

-- Receive client-forwarded events
Events.OnClientCommand.Add(function(module, command, player, args)
    if module ~= "RconEvents" or command ~= "Evt" then
        return
    end
    if not player or type(args) ~= "table" then
        return
    end

    local uname = player:getUsername() or "unknown"
    local kind = tostring(args.kind or "unknown")

    if uname == "unknown" then
        print("[RconEvents] DEBUG unknown username for " .. kind .. " event")
        return
    end

    if kind == "OnPlayerDeath" then
        local p = player
        local fname = _fullName(p)
        local hours = p:getHoursSurvived()
        local k = p:getZombieKills()
        local pronoun = _pronoun(p)
        local desc = sumTraits(p)
        local wasbitten = _wasBittenMsg(p)
        pushEvent(string.format(
            '%s (%s) has died. %s survived for %.2f hours, and had %d kills. Their traits were: %s.%s', -- hey
            uname, fname, pronoun, hours, k, desc, wasbitten))
    elseif kind == "AddXP" then
        local p = player
        local fname = _fullName(p)
        pushEvent(string.format('%s (%s) gained %.2f %s xp.', uname, fname, args.amount, args.perk))
    elseif kind == "OnHitZombie" then
        local p = player
        local fname = _fullName(p)
        pushEvent(string.format('%s (%s) is fighting a zombie.', uname, fname))
    elseif kind == "OnPlayerGetDamage" then
        local p = player
        local fname = _fullName(p)
        pushEvent(string.format('%s (%s) suffered %.2f %s.', uname, fname, args.damage, args.damageType))
    elseif kind == "OnCreatePlayer" then
        local p = player
        local fname = _fullName(p)
        pushEvent(string.format('%s (%s) has joined.', uname, fname))
    elseif kind == "OnCreateSurvivor" then
        local p = player
        local desc = sumTraits(p)
        pushEvent(string.format('%s has joined as a new survivor "%s" with the traits: %s.', uname, args.newname, desc))
    elseif kind == "OnEnterVehicle" then
        local p = player
        local fname = _fullName(p)
        pushEvent(string.format('%s (%s) got in a vehicle.', uname, fname))
    else
        print("[RconEvents] DEBUG unknown event: " .. kind)
    end
end)

-- ===== Command Handler =====
local function onServerCommand(author, args)
    local sub = args[1] and args[1]:lower() or ""

    if sub == "readevents" then
        print('[RconEvents:' .. getRuntime() .. '] DEBUG ' .. 'onServerCommand:readevents')
        return _readEvents()
    elseif sub == "popevents" then
        print('[RconEvents:' .. getRuntime() .. '] DEBUG ' .. 'onServerCommand:popevent')
        local s = _readEvents()
        eventQueue = {}
        return s
    elseif sub == "playercount" then
        local n = getOnlinePlayers():size()
        return tostring(n)
    elseif sub == "lastskillleveled" then
        local out = {}
        for u, s in pairs(lastSkill) do
            table.insert(out, u .. ":" .. (s or "unknown"))
        end
        return table.concat(out, "; ")
    elseif sub == "gettime" then
        local gt = getGameTime()
        return string.format("%d/%d/%d %02d:%02d", gt:getDay(), gt:getMonth() + 1, gt:getYear(), gt:getHour(),
            gt:getMinutes())
    elseif sub == "getplayerstatus" then
        local list = getOnlinePlayers()
        local out = {}
        for i = 0, list:size() - 1 do
            local p = list:get(i)
            local uname = p:getUsername()
            table.insert(out, uname .. " is " .. (lastStatus[uname] or "idle"))
        end
        return table.concat(out, "; ")
    else
        return "Usage: rconevents <ReadEvents|PopEvents|PlayerCount|LastSkillLeveled|GetTime|GetPlayerStatus>"
    end
end

-- Register the command.
LuaCommands.register(CMD_NAME, function(author, command, args)
    if isServer() then
        return onServerCommand(author, args)
    else
        return "Not supported in SP."
    end
end)

print("Registered LuaCommand: " .. CMD_NAME);
