local MOD = "RconEvents"

ClientEvent = ClientEvent or {}

ClientEvent.SKILL_UP = "SKILL_UP"
ClientEvent.VEHICLE_ENTER = "VEHICLE_ENTER"
ClientEvent.VEHICLE_EXIT = "VEHICLE_EXIT"

function ClientEvent.send(kind, data)
    if isServer() then
        print("[RconEvents] WARN ClientEvent.send called on server!")
        return
    end
    data = data or {}
    data.kind = kind
    sendClientCommand(MOD, "Evt", data)
end

return ClientEvent
