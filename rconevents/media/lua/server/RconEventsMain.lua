-- server only mod
if not isServer() then
    return
end

require 'LuaCommands/LuaCommands';
require 'RconEventsUtils.lua'

local ClientEvent = require("ClientEvent")
local RconEventsQueue = require("RconEventsQueue")
local PlayerWatcher = require("PlayerWatcher")
local LocationTracker = require("LocationTracker")

local CMD_NAME = 'rconevents'

local Q = RconEventsQueue:new()

local DEBUG = true

local function DEBUGLOG(msg)
    if DEBUG then
        print('[RconEvents:' .. _getRuntime() .. '] DEBUG ' .. msg)
    end
end

local function onServerCommandPeak()
    local lines = Q:peak()
    local response = _tableToString(lines)
    return response
end

local function onServerCommandFlush()
    local lines = Q:flush()
    local response = _tableToString(lines)
    return response
end

local function onServerCommand(author, args)
    local sub = args[1] and args[1]:lower() or ""
    if not sub then
        return
    end

    DEBUGLOG('onServerCommand:' .. sub)

    if sub == "peak" then
        return onServerCommandPeak()
    elseif sub == "flush" then
        return onServerCommandFlush()
    else
        return "Usage: rconevents <peak|flush>"
    end
end

PlayerWatcher.onJoin(function(player, data)
    local msg = _formatJoinedMessage(player)
    DEBUGLOG(msg)
    Q:push(msg)
end)

PlayerWatcher.onLeave(function(key, info)
    local msg = (info.username or key) .. " has left."
    DEBUGLOG(msg)
    Q:push(msg)
end)

LuaCommands.register(CMD_NAME, function(author, command, args)
    if isServer() then
        return onServerCommand(author, args)
    else
        return "Not supported in SP."
    end
end)

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

    if kind == ClientEvent.SKILL_UP then
        local p = player
        local fname = _fullName(p)
        local msg = string.format('%s (%s) has reached level %d in %s!', uname, fname, args.newLevel, args.perk)
        DEBUGLOG(msg)
        Q:push(msg)
    elseif kind == ClientEvent.VEHICLE_ENTER then
        local p = player
        local fname = _fullName(p)
        local msg = string.format('%s (%s) entered vehicle', uname, fname)
        -- if we have the vehicle name, include that in the message
        if args.vehicleName and args.vehicleName ~= "" then
            msg = msg .. " " .. args.vehicleName
        end
        msg = msg .. "."
        DEBUGLOG(msg)
        Q:push(msg)
    elseif kind == ClientEvent.VEHICLE_EXIT then
        local p = player
        local fname = _fullName(p)
        local msg = string.format('%s (%s) exited vehicle.', uname, fname)
        DEBUGLOG(msg)
        Q:push(msg)
    else
        print("[RconEvents] DEBUG unknown event: " .. kind)
    end
end)

-- Fires when any character dies, including zombies and players regardless of whether they are local.
-- https://pzwiki.net/wiki/OnCharacterDeath
-- character: IsoGameCharacter (JavaDoc) - The character who died.
Events.OnCharacterDeath.Add(function(p)
    if p:isZombie() then
        return -- We don't care about zombies, only about players.
    end
    local msg = _formatDeathMessage(p)
    DEBUGLOG(msg)
    Q:push(msg)
end)

print("Registered LuaCommand: " .. CMD_NAME);

