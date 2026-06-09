class 'AircraftsControl'

function AircraftsControl:__init()
    self.planeVehicles = {24, 30, 34, 39, 51, 59, 81, 85}

    -- self.yawLeftKey = 49
    -- self.yawRightKey = 51

    self.maxThrust = 0.2
    self.minThrust = 0.1
    self.currentThrust = 0
    self.maxReverseThrust = 0.2
    self.thrustIncreaseFactor = 1.05
    self.reverseMaxSpeed = 2
    -- self.yawThrust = 2

    local vehicle = LocalPlayer:GetVehicle()
    if vehicle and vehicle:GetDriver() == LocalPlayer and vehicle:GetClass() == VehicleClass.Air then
        if self:CheckList(self.planeVehicles, vehicle:GetModelId()) then
            if not self.eventsLoaded then
                self:SharedObjectValueChange()

                self.SharedObjectValueChangeEvent = Events:Subscribe("SharedObjectValueChange", self, self.SharedObjectValueChange)
                self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)

                self.eventsLoaded = true
            end
        end
    end

    Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
end

function AircraftsControl:LocalPlayerEnterVehicle(args)
    if args.is_driver then
        if args.vehicle:GetClass() == VehicleClass.Air then
            if self:CheckList(self.planeVehicles, args.vehicle:GetModelId()) then
                if not self.eventsLoaded then
                    self:SharedObjectValueChange()

                    self.SharedObjectValueChangeEvent = Events:Subscribe("SharedObjectValueChange", self, self.SharedObjectValueChange)
                    self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)

                    self.eventsLoaded = true
                end
            end
        end
    end
end

function AircraftsControl:LocalPlayerExitVehicle()
    if not self.eventsLoaded then return end

    Events:Unsubscribe(self.SharedObjectValueChangeEvent) self.SharedObjectValueChangeEvent = nil
    Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil

    self.eventsLoaded = nil

    self.FreezeValue = nil
end

function AircraftsControl:SharedObjectValueChange(args)
    if args and args.object.__type ~= "LocalPlayer" then return end

    self.FreezeValue = LocalPlayer:GetValue("Freeze")
end

function AircraftsControl:CheckThrust()
    self.currentThrust = self.currentThrust * self.thrustIncreaseFactor
    if self.currentThrust < self.minThrust then
        self.currentThrust = self.minThrust
    elseif self.currentThrust > self.maxThrust then
        self.currentThrust = self.maxThrust
    end

    self.ReverseThrust = self.currentThrust
    if self.ReverseThrust > self.maxReverseThrust then
        self.ReverseThrust = self.maxReverseThrust
    end
end

function AircraftsControl:LocalPlayerInput(args)
    if Game:GetState() ~= GUIState.Game then return end

    local vehicle = LocalPlayer:GetVehicle()

    if vehicle and LocalPlayer:InVehicle() then
        if self:CheckList(self.planeVehicles, vehicle:GetModelId()) then
            if not LocalPlayer:GetValue("Freeze") then
                local velocity = vehicle:GetLinearVelocity()
                local angle = vehicle:GetAngle()

                if args.input == Action.Handbrake then
                    self:CheckThrust()
                    local vector = Vector3(0, 0, self.ReverseThrust)
                    local reverseDirection = angle * vector
                    local speedInReverseDirection = velocity:Dot(reverseDirection)

                    if speedInReverseDirection <= self.reverseMaxSpeed then
                        vehicle:SetLinearVelocity(velocity + angle * vector)
                    end
                end

                --[[if Key:IsDown(self.yawLeftKey) then
					local vector = Vector3(-self.yawThrust, 0, 0)
					local reverseDirection = angle * vector
					local speedInReverseDirection = velocity:Dot(reverseDirection)

					if speedInReverseDirection <= 20 then
						vehicle:SetLinearVelocity(velocity + angle * vector)
					end
				end

				if Key:IsDown(self.yawRightKey) then
					local vector = Vector3(self.yawThrust, 0, 0)
					local reverseDirection = angle * vector
					local speedInReverseDirection = velocity:Dot(reverseDirection)

					if speedInReverseDirection <= 20 then
						vehicle:SetLinearVelocity(velocity + angle * vector)
					end
				end]] --
            end
        end
    end
end

function AircraftsControl:CheckList(tableList, modelID)
    for k, v in ipairs(tableList) do
        if v == modelID then
            return true
        end
    end
    return false
end

local aircraftscontrol = AircraftsControl()