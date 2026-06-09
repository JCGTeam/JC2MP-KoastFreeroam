class 'AirControl'

function AirControl:__init()
    if LocalPlayer:InVehicle() then
        self:LocalPlayerEnterVehicle()
    end

    Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
end

function AirControl:NetworkObjectValueChange(args)
    if args and args.object.__type ~= "LocalPlayer" then return end

    self.AirControlValue = LocalPlayer:GetValue("AirControl")
end

function AirControl:LocalPlayerInput(args)
    if not self.AirControlValue then return end

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
    if self.eventsLoaded then return end

    self.speed = 0.02

    self:NetworkObjectValueChange()

    self.NetworkObjectValueChangeEvent = Events:Subscribe("NetworkObjectValueChange", self, self.NetworkObjectValueChange)
    self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)

    self.eventsLoaded = true
end

function AirControl:LocalPlayerExitVehicle()
    if not self.eventsLoaded then return end

    Events:Unsubscribe(self.NetworkObjectValueChangeEvent) self.NetworkObjectValueChangeEvent = nil
    Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil

    self.eventsLoaded = nil
    self.speed = nil

    self.AirControlValue = nil
end

local aircontrol = AirControl()