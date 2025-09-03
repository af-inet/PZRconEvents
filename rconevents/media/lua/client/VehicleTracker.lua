if isServer() then
    return
end
-- ========================================================--
-- VehicleTracker.lua
-- Tracks when a player enters or exits a vehicle
-- ========================================================--
local ClientEvent = require("ClientEvent")

VehicleTracker = VehicleTracker or {}

-- Helper to get readable vehicle name
function VehicleTracker.getVehicleName(vehicle)
    if not vehicle then
        return "Unknown Vehicle"
    end
    -- Try to get script name
    local script = vehicle:getScript()
    if script then
        -- get the pretty name of the car.
        return Translator.getText("IGUI_VehicleName" .. script:getName())
    end
    return tostring(vehicle)
end

-- Called when a player enters a vehicle
function VehicleTracker.onEnterVehicle(player)
    if not player or not player:getVehicle() then
        return
    end
    local vehicle = player:getVehicle()
    local vehicleName = ""
    if vehicle then
        vehicleName = VehicleTracker.getVehicleName(vehicle)
    end
    local msg = string.format("[VehicleTracker] %s got in a %s! TEST", player:getUsername(), vehicleName)
    print(msg) -- Server console
    local data = {
        username = player:getUsername(),
        vehicleName = vehicleName
    }
    ClientEvent.send(ClientEvent.VEHICLE_ENTER, data)
end

-- Called when a player exits a vehicle
function VehicleTracker.onExitVehicle(player)
    if not player then
        return
    end
    local vehicle = player:getVehicle()
    local vehicleName = ""
    -- Some events fire *just before* leaving, so vehicle may still exist
    if vehicle then
        vehicleName = VehicleTracker.getVehicleName(vehicle)
    end
    local msg = string.format("[VehicleTracker] %s got out of %s!", player:getUsername(), vehicleName)
    print(msg)
    local data = {
        username = player:getUsername(),
        vehicleName = vehicleName
    }
    ClientEvent.send(ClientEvent.VEHICLE_EXIT, data)
end

-- ========================================================--
-- Event bindings
-- ========================================================--
Events.OnEnterVehicle.Add(VehicleTracker.onEnterVehicle)
Events.OnExitVehicle.Add(VehicleTracker.onExitVehicle)
