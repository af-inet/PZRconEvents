--========================================================--
-- LocationTracker.lua
-- Roughly describe where a player is (e.g., "Riverside")
--========================================================--

LocationResolver = LocationResolver or {}
LocationResolver._regions = {}

function LocationResolver.addRectRegion(name, x1, y1, x2, y2)
    if not name then return end
    local rx1, ry1 = math.min(x1,x2), math.min(y1,y2)
    local rx2, ry2 = math.max(x1,x2), math.max(y1,y2)
    table.insert(LocationResolver._regions, { name = name, data = {x1=rx1,y1=ry1,x2=rx2,y2=ry2} })
end

local function _pointInRect(x, y, r)
    return x >= r.x1 and x <= r.x2 and y >= r.y1 and y <= r.y2
end

local function _findCustomRegionAt(x, y)
    for _, r in ipairs(LocationResolver._regions) do
        if _pointInRect(x, y, r.data) then
            return r.name
        end
    end
    return nil
end

function LocationResolver.resolve(player)
    if not player then return nil end
    local x, y = player:getX(), player:getY()
    local cellX, cellY = math.floor(x / 300), math.floor(y / 300)  -- 300 world units ≈ 1 cell

    local rName = _findCustomRegionAt(x, y)
    if rName then
        return rName
    end

    return nil
end

LocationResolver.addRectRegion("March Ridge", 9700, 12470, 10579, 13199)
LocationResolver.addRectRegion("Louisville", 11700, 750, 14699, 3899)
LocationResolver.addRectRegion("Muldraugh", 10540, 9240, 11217, 10696)
LocationResolver.addRectRegion("Rosewood", 7900, 11140, 8604, 12139)
LocationResolver.addRectRegion("Riverside", 6000, 5035, 6899, 5669)
LocationResolver.addRectRegion("West Point", 10820, 6500, 12389, 7469)

return LocationResolver
