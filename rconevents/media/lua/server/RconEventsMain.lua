-- server only mod
if not isServer() then
    return
end

require 'LuaCommands/LuaCommands';
require 'RconEventsUtils.lua'

local RconEventsQueue = require("RconEventsQueue")
local PlayerWatcher = require("PlayerWatcher")

local CMD_NAME = 'rconevents'

local Q = RconEventsQueue:new()

local DEBUG = true

local function DEBUGLOG(msg)
    if DEBUG then
        print('[RconEvents:' .. _getRuntime() .. '] DEBUG ' .. msg)
    end
end

-- Fires when any character dies, including zombies and players regardless of whether they are local.
-- https://pzwiki.net/wiki/OnCharacterDeath
-- character: IsoGameCharacter (JavaDoc) - The character who died.
Events.OnCharacterDeath.Add(function(p)
    DEBUGLOG('OnCharacterDeath')
    if p:isZombie() then
        DEBUGLOG('OnCharacterDeath zombie')
        return -- We don't care about zombies, only about players.
    end
    local msg = _formatDeathMessage(p)
    DEBUGLOG('OnCharacterDeath' .. msg)
    Q:push(msg)
end)

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
    local msg = player:getUsername() .. " has joined."
    Q:push(msg)
end)

PlayerWatcher.onLeave(function(key, info)
    local msg = (info.username or key) .. " has left."
    Q:push(msg)
end)

LuaCommands.register(CMD_NAME, function(author, command, args)
    if isServer() then
        return onServerCommand(author, args)
    else
        return "Not supported in SP."
    end
end)

print("Registered LuaCommand: " .. CMD_NAME);
