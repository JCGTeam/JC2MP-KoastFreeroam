class 'VehicleEjectBlocker'

function VehicleEjectBlocker:__init()
    Events:Subscribe("LocalPlayerEjectVehicle", self, self.LocalPlayerEjectVehicle)
end

function VehicleEjectBlocker:LocalPlayerEjectVehicle()
    if not LocalPlayer:GetValue("VehicleEjectBlocker") then return end
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    if LocalPlayer:GetPosition().y > 200.5 then
        return false
    end
end

local vehicleejectblocker = VehicleEjectBlocker()