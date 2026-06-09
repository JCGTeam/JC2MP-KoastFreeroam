class 'VehiclesInstantBoom'

function VehiclesInstantBoom:__init()
    self.last_check = 0
    self.health_threshold = 0.055

    Events:Subscribe("PostTick", self, self.PostTick)
end

function VehiclesInstantBoom:PostTick()
    local current_time = Server:GetElapsedSeconds()

    if current_time - self.last_check < 0.5 then return end

    self.last_check = current_time

    for p in DefaultWorld:GetPlayers() do
        local v = p:GetVehicle()

        if IsValid(v) and p:GetValue("PVPMode") then
            local vHealth = v:GetHealth()

            if vHealth > 0 and vHealth <= self.health_threshold then
                v:SetHealth(0)
            end
        end
    end
end

local vehiclesinstantboom = VehiclesInstantBoom()