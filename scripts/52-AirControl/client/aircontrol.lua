class 'AirControl'

function AirControl:__init()
    self.speed = 0.02

    if LocalPlayer:InVehicle() then
        self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
    end

    Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
end

function AirControl:LocalPlayerInput(args)
    if not LocalPlayer:GetValue("AirControl") then return end

    local vehicle = LocalPlayer:GetVehicle()

    if not vehicle then return end

    local class = vehicle:GetClass()
    if class and class == VehicleClass.Land then
        local vPos = vehicle:GetPosition()
        local ray = Physics:Raycast(vPos + Vector3(0, 0.5, 0), Vector3.Down, 0, 100)

        if vehicle:GetPosition().y > 205 and ray.distance >= 3 then
            local velocity = vehicle:GetAngularVelocity()
            local angle = vehicle:GetAngle()

            local localAngularVelocity = Vector3.Zero

            if args.input == Action.TurnLeft then
                localAngularVelocity.y = self.speed
            end

            if args.input == Action.TurnRight then
                localAngularVelocity.y = -self.speed
            end

            if args.input == Action.Accelerate then
                localAngularVelocity.x = -self.speed
            end

            if args.input == Action.Reverse then
                localAngularVelocity.x = self.speed
            end

            local globalAngularVelocity = angle * localAngularVelocity + velocity

            vehicle:SetAngularVelocity(globalAngularVelocity)
        end
    end
end

function AirControl:LocalPlayerEnterVehicle()
    if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
end

function AirControl:LocalPlayerExitVehicle()
    if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
end

local aircontrol = AirControl()