--
-- Client bridge: forward client-only events to server
-- this is necessary because the server lua events have 
-- surprisingly little information.
--
local MOD = "RconEvents"

local function getRuntime()
    if isServer() then
        return "server"
    else
        return "client"
    end
end

local function send(kind, data)
    -- Forward this from the client to the server, ignore when running on the server
    if isServer() then
        return
    end
    data = data or {}
    data.kind = kind
    -- Keep payload tiny; the server can enrich it if needed
    sendClientCommand(MOD, "Evt", data)
end

local function _fullName(p)
    local desc = p:getDescriptor()
    return desc:getForename() .. " " .. desc:getSurname()
end

-- Fires when a local player dies.
-- https://pzwiki.net/wiki/OnPlayerDeath
-- player: IsoPlayer (JavaDoc) - The player who died.
Events.OnPlayerDeath.Add(function(p)
    print('[RconEvents:' .. getRuntime() .. '] DEBUG ' .. 'OnPlayerDeath')
    if not p then
        print("[RconEvents] WARN: OnPlayerDeath empty player.")
        return
    end
    send("OnPlayerDeath", {
        username = p:getUsername()
    })
end)

-- Fires after a local character gains perk XP, except when the XP source specifically requested not to.
-- https://pzwiki.net/wiki/AddXP
-- character: IsoGameCharacter (JavaDoc) - The character who gained the XP.
-- perk: PerkFactory.Perk (JavaDoc) - The perk XP was gained in.
-- amount: number - The amount of XP gained. This is the final value after all modifiers.
Events.AddXP.Add(function(p, perk, amount)
    print('RconEvents:' .. getRuntime() .. ' DEBUG ' .. 'AddXP')
    if not p then
        print("[RconEvents] WARN: AddXP empty player.")
        return
    end
    send("AddXP", {
        username = p:getUsername(),
        perk = perk:getName(),
        amount = amount
    })
end)

-- Fires whenever a zombie is hit by a character.
-- https://pzwiki.net/wiki/OnHitZombie
-- zombie: IsoZombie (JavaDoc) - The zombie that was hit.
-- attacker: IsoGameCharacter (JavaDoc) - The character that hit the zombie.
-- bodyPart: BodyPartType (JavaDoc) - The type of the body part that was hit.
-- weapon: HandWeapon (JavaDoc) - The weapon the zombie was hit with.
Events.OnHitZombie.Add(function(_, p, _, _)
    print('RconEvents:' .. getRuntime() .. ' DEBUG ' .. 'OnHitZombie')
    if not p then
        print("[RconEvents] WARN: OnHitZombie empty player.")
        return
    end
    send("OnHitZombie", {
        username = p:getUsername()
    })
end)

-- Fires every time a local player takes damage.
-- Bleeding bodyparts fire the event once per frame each.
-- It also fires when zombies are hit by weapons: this is the only case in which the event fires on the server.
-- https://pzwiki.net/wiki/OnPlayerGetDamage
-- character: IsoGameCharacter (JavaDoc) - The character who took damage.
-- damageType - The type of damage the character took.
-- "POISON"
-- "HUNGRY"
-- "SICK"
-- "BLEEDING"
-- "THIRST"
-- "HEAVYLOAD"
-- "INFECTION"
-- "LOWWEIGHT"
-- "FALLDOWN"
-- "WEAPONHIT"
-- "CARHITDAMAGE"
-- "CARCRASHDAMAGE"
-- damage: number - The damage that was taken.
Events.OnPlayerGetDamage.Add(function(p, damageType, damage)
    print('[RconEvents:' .. getRuntime() .. '] DEBUG ' .. 'OnPlayerGetDamage')
    if not p then
        print("[RconEvents] WARN: OnPlayerGetDamage empty OnPlayerGetDamage.")
        return
    end
    -- ignore if character is zombier
    if p:isZombie() then
        return
    end
    send("OnPlayerGetDamage", {
        username = p:getUsername(),
        damageType = damageType,
        damage = damage
    })
end)

-- OnCreatePlayer fires client-side when a local player object is created
-- https://pzwiki.net/wiki/OnCreatePlayer
-- playerNum: integer - The player number of the newly-spawned character
-- player: IsoPlayer (JavaDoc) - The new player object
Events.OnCreatePlayer.Add(function(playerIndex, p)
    print('[RconEvents:' .. getRuntime() .. '] DEBUG ' .. 'OnCreatePlayer')
    if not p then
        return
    end
    send("OnCreatePlayer", {
        username = p:getUsername()
    })
end)

-- https://pzwiki.net/wiki/OnCreateSurvivor
-- survivor: IsoSurvivor (JavaDoc) - The survior that was created.
Events.OnCreateSurvivor.Add(function(p)
    print('[RconEvents:' .. getRuntime() .. '] DEBUG ' .. 'OnCreateSurvivor')
    if not p then
        return
    end
    local newname = _fullName(p)
    send("OnCreateSurvivor", {
        newname = newname
    })
end)

-- https://pzwiki.net/wiki/OnSleepingTick
-- OnSleepingTick
-- playerNum: integer
-- timeOfDay: number
-- Events.OnSleepingTick.Add(function(playerNum, timeOfDay)
--     print('[RconEvents:' .. getRuntime() .. '] DEBUG ' .. 'OnSleepingTick')
--     send("OnSleepingTick", {
--         playerNum = playerNum,
--         time = timeOfDay
--     })
-- end)

-- https://pzwiki.net/wiki/OnEnterVehicle
Events.OnEnterVehicle.Add(function(p)
    print('[RconEvents:' .. getRuntime() .. '] DEBUG ' .. 'OnEnterVehicle')
    if not p then
        return
    end
    local v = p:getVehicle()
    if not v then
        return
    end
    local u = p:getUsername()
    local seat = v:getSeat(p)
    local id = v:getId() -- small int id
    local key = tostring(id) .. ":" .. tostring(seat)
    send("OnEnterVehicle", {
        username = u,
        vehicleId = id,
        seat = seat
    })
end)
