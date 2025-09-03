if isServer() then
    return
end
-- ========================================================--
-- SkillTracker.lua
-- Tracks when a player levels up a skill using AddXP
-- ========================================================--

local ClientEvent = require("ClientEvent")

SkillTracker = SkillTracker or {}

-- Table to store last known skill levels for each player
SkillTracker.playerSkills = {}

-- This make no sense, but I am seeing crashes where the player functions are set to nil,
-- even though in the same code path they were just called. I am assuming this is some kind of
-- race condition where the player object is deleted or something while we're using it.
-- So here is an awful hacky solution: check the player object looks normal before using it.
local function __isValid(player)
    if not player then
        return false
    end
    if not player.getUsername then
        return false
    end
    if not player.getPerkLevel then
        return false
    end
    if not player.getType then
        return false
    end
    return true
end

-- Initialize skill levels for a player when they join
function SkillTracker.initPlayer(player, username)
    if not __isValid(player) then
        return
    end
    local username = player:getUsername()
    SkillTracker.playerSkills[username] = {}

    for i = 0, PerkFactory.PerkList:size() - 1 do
        local perk = PerkFactory.PerkList:get(i)
        if not __isValid(player) then
            return
        end
        local level = player:getPerkLevel(perk)
        SkillTracker.playerSkills[username][perk:getType()] = level
    end
end

-- Hook into AddXP event
function SkillTracker.onAddXP(player, perk, amount)
    -- Not sure why this gets fired for 0 XP, but it does.
    if amount <= 0 or not perk then
        return
    end
    if not __isValid(player) then
        return
    end
    local username = player:getUsername()
    local perkType = perk:getType()

    print("SkillTracker " .. username)

    -- Initialize player if missing
    if not SkillTracker.playerSkills[username] then
        SkillTracker.initPlayer(player, username)
    end

    local oldLevel = SkillTracker.playerSkills[username][perkType] or 0
    if not __isValid(player) then
        return
    end
    local newLevel = player:getPerkLevel(perk)

    -- If the player has leveled up this perk
    if newLevel > oldLevel then
        SkillTracker.playerSkills[username][perkType] = newLevel
        SkillTracker.notifyLevelUp(player, perk, newLevel)
    end

    -- Uncomment to get XP notifications.
    -- local msg = string.format("[SkillTracker] %s has gained %d xp in %s!",
    --     player:getUsername(),
    --     amount,
    --     perk:getName())
    -- print(msg)
end

-- Notification handler
function SkillTracker.notifyLevelUp(player, perk, newLevel)
    local msg = string.format("[SkillTracker] %s has reached level %d in %s!", player:getUsername(), newLevel,
        perk:getName())
    local data = {
        username = player:getUsername(),
        newLevel = newLevel,
        perk = perk:getName()
    }
    ClientEvent.send(ClientEvent.SKILL_UP, data)
end

-- ========================================================--
-- Event bindings
-- ========================================================--

-- Track AddXP
Events.AddXP.Add(SkillTracker.onAddXP)

-- Initialize skills when a player is created
Events.OnCreatePlayer.Add(SkillTracker.initPlayer)
