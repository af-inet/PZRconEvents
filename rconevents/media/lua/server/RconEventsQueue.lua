-- RconEventsQueue.lua
local RconEventsQueue = {}
RconEventsQueue.__index = RconEventsQueue

-- Constructor
function RconEventsQueue:new(maxSize, maxElements)
    local instance = {
        maxSize = maxSize or 4096,
        maxElements = maxElements or 100,
        queue = {},
        currentSize = 0 -- track total "size" of elements
    }
    setmetatable(instance, RconEventsQueue)
    return instance
end

-- Internal: get element size (can adjust logic if "size" is more complex than #string)
local function getElementSize(element)
    if type(element) == "string" then
        return #element
    elseif type(element) == "table" then
        return #tostring(element) -- fallback
    else
        return #tostring(element)
    end
end

-- Push an element into the queue
function RconEventsQueue:push(element)
    local elementSize = getElementSize(element)

    -- Handle maxSize enforcement
    if self.maxSize ~= -1 then
        while self.currentSize + elementSize > self.maxSize and #self.queue > 0 do
            local removed = table.remove(self.queue, 1)
            self.currentSize = self.currentSize - getElementSize(removed)
        end
    end

    -- Handle maxElements enforcement
    if self.maxElements ~= -1 then
        while #self.queue >= self.maxElements do
            local removed = table.remove(self.queue, 1)
            self.currentSize = self.currentSize - getElementSize(removed)
        end
    end

    -- Insert new element
    table.insert(self.queue, element)
    self.currentSize = self.currentSize + elementSize
end

-- Flush (clear all elements)
function RconEventsQueue:flush()
    local data = self.queue
    self.queue = {}
    self.currentSize = 0
    return data
end

-- Peek all elements
function RconEventsQueue:peak()
    return self.queue
end

return RconEventsQueue
