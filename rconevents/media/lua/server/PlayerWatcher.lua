-- media/lua/server/PlayerWatcher.lua
if not isServer() then
    return
end

local PlayerWatcher = {
    known = {}, -- key -> info
    onJoinCbs = {},
    onLeaveCbs = {}
}

-- === Registration API ===
function PlayerWatcher.onJoin(cb)
    table.insert(PlayerWatcher.onJoinCbs, cb)
end

function PlayerWatcher.onLeave(cb)
    table.insert(PlayerWatcher.onLeaveCbs, cb)
end

local function _getOnlinePlayers()
    local arr = ArrayList.new()
    pcall(function()
        local tmp = getOnlinePlayers()
        if tmp then
            arr = tmp
        end
    end)
    return arr
end

-- Internal helpers
local function keyFor(p)
    local id = p:getOnlineID()
    if id == nil then
        id = tostring(p:getUsername() or "") .. ":" ..
                 tostring(p:getDescriptor() and p:getDescriptor():getForename() or "")
    end
    return tostring(id)
end

local function isBrandNewCharacter(p)
    local md = p:getModData()
    local hrs = p:getHoursSurvived() or 0
    if (md._seenByMyMod ~= true) and hrs < 0.05 then
        return true
    end
    return false
end

local function markSeen(p)
    local md = p:getModData()
    if md._seenByMyMod ~= true then
        md._seenByMyMod = true
        if p.transmitModData then
            p:transmitModData()
        end
    end
end

local function snapshotOnline()
    local arr = _getOnlinePlayers()
    local nowSet = {}
    for i = 0, arr:size() - 1 do
        local p = arr:get(i)
        local k = keyFor(p)
        nowSet[k] = p
    end
    return nowSet
end

local function handleTick()
    local current = snapshotOnline()

    -- Detect joins
    for k, p in pairs(current) do
        if PlayerWatcher.known[k] == nil then
            local username = tostring(p:getUsername() or "unknown")
            local steamID = p.getSteamID and tostring(p:getSteamID() or "") or ""
            local brandNew = isBrandNewCharacter(p)

            print(string.format("[PlayerWatcher] JOIN %s brandNew=%s", username, tostring(brandNew)))
            if brandNew then
                markSeen(p)
            end

            -- Store info
            PlayerWatcher.known[k] = {
                username = username,
                steamID = steamID,
                firstSeen = os.time()
            }

            -- Fire callbacks
            for _, cb in ipairs(PlayerWatcher.onJoinCbs) do
                local ok, err = pcall(cb, p, {
                    brandNew = brandNew
                })
                if not ok then
                    print("[PlayerWatcher] onJoin callback error: " .. tostring(err))
                end
            end
        end
    end

    -- Detect leaves
    for k, info in pairs(PlayerWatcher.known) do
        if current[k] == nil then
            print(string.format("[PlayerWatcher] LEAVE %s", info.username or "unknown"))
            PlayerWatcher.known[k] = nil
            for _, cb in ipairs(PlayerWatcher.onLeaveCbs) do
                local ok, err = pcall(cb, k, info)
                if not ok then
                    print("[PlayerWatcher] onLeave callback error: " .. tostring(err))
                end
            end
        end
    end
end

local function seedKnown()
    PlayerWatcher.known = {}
    local arr = _getOnlinePlayers()
    for i = 0, arr:size() - 1 do
        local p = arr:get(i)
        local k = keyFor(p)
        PlayerWatcher.known[k] = {
            username = tostring(p:getUsername() or "unknown"),
            steamID = p.getSteamID and tostring(p:getSteamID() or "") or "",
            firstSeen = os.time()
        }
    end
end

-- Init once server-side
local function init()
    seedKnown()
    Events.EveryOneMinute.Add(handleTick)
    -- Let's double check after a player dies
    Events.OnCharacterDeath.Add(function (character) 
        if not character then return end
        if not character.isZombie then return end
        if character:isZombie() then return end
        handleTick()
    end)
    handleTick()
end

Events.OnInitGlobalModData.Add(init)

-- Export
return PlayerWatcher
