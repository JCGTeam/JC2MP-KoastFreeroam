class 'Woet'

function Woet:__init()
    self.cooldown = 2
    self.cooltime = 0

    if LocalPlayer:InVehicle() then
        self:LocalPlayerEnterVehicle()
    end

    self:UpdateKeyBinds()

    Events:Subscribe("UpdateKeyBinds", self, self.UpdateKeyBinds)
    Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
end

function Woet:UpdateKeyBinds()
    local keyBinds = LocalPlayer:GetValue("KeyBinds")
    local woetBind = keyBinds and keyBinds["VehicleTricks"]
    local vehicleJumpBind = keyBinds and keyBinds["VehicleJump"]

    self.vehicleTricksKey = woetBind and woetBind.type == "Key" and woetBind.value or 9
    self.vehicleJumpKey = vehicleJumpBind and vehicleJumpBind.type == "Key" and vehicleJumpBind.value or 9
end

function Woet:SharedObjectValueChange(args)
    if args and args.object.__type ~= "LocalPlayer" then return end

    self.FreezeValue = LocalPlayer:GetValue("Freeze")
    self.EnhancedWoetValue = LocalPlayer:GetValue("EnhancedWoet")
end

function Woet:NetworkObjectValueChange(args)
    if args and args.object.__type ~= "LocalPlayer" then return end

    self.PassiveValue = LocalPlayer:GetValue("Passive")
    self.VehicleJumpValue = LocalPlayer:GetValue("VehicleJump")
end

function Woet:LocalPlayerEnterVehicle()
    if self.eventsLoaded then return end

    self:SharedObjectValueChange()
    self:NetworkObjectValueChange()

    self.SharedObjectValueChangeEvent = Events:Subscribe("SharedObjectValueChange", self, self.SharedObjectValueChange)
    self.NetworkObjectValueChangeEvent = Events:Subscribe("NetworkObjectValueChange", self, self.NetworkObjectValueChange)
    self.KeyUpEvent = Events:Subscribe("KeyUp", self, self.KeyUp)

    self.eventsLoaded = true
end

function Woet:LocalPlayerExitVehicle()
    if not self.eventsLoaded then return end

    Events:Unsubscribe(self.SharedObjectValueChangeEvent) self.SharedObjectValueChangeEvent = nil
    Events:Unsubscribe(self.NetworkObjectValueChangeEvent) self.NetworkObjectValueChangeEvent = nil
    Events:Unsubscribe(self.KeyUpEvent) self.KeyUpEvent = nil

    self.eventsLoaded = nil

    self.FreezeValue = nil
    self.EnhancedWoetValue = nil
    self.PassiveValue = nil
    self.VehicleJumpValue = nil
end

function Woet:KeyUp(args)
    if self.FreezeValue then return end
    if Game:GetState() ~= GUIState.Game then return end
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end
    if LocalPlayer:GetState() ~= PlayerState.InVehicle then return end

    local enhancedWoet = self.EnhancedWoetValue

    if enhancedWoet and args.key == self.vehicleTricksKey then
        if not self.PassiveValue then
            local vehicle = LocalPlayer:GetVehicle()

            if not IsValid(vehicle) then return end

            if enhancedWoet == "Roll" then
                local dir2 = vehicle:GetAngle() * Vector3(0, 0, -30)
                vehicle:SetAngularVelocity(dir2)
            elseif enhancedWoet == "Spin" then
                local dir2 = vehicle:GetAngle() * Vector3(0, -30, 0)
                vehicle:SetAngularVelocity(dir2)
            elseif enhancedWoet == "Flip" then
                local dir1 = vehicle:GetLinearVelocity() + Vector3(0, 35, 0)
                vehicle:SetLinearVelocity(dir1)

                local dir2 = vehicle:GetAngle() * Vector3(-30, 0, 0)
                vehicle:SetAngularVelocity(dir2)
            end
        end
    end

    if args.key == self.vehicleJumpKey then
        if self.VehicleJumpValue then
            local time = Client:GetElapsedSeconds()
            local vehicle = LocalPlayer:GetVehicle()

            if not IsValid(vehicle) then return end

            if time > self.cooltime then
                local dir1 = vehicle:GetLinearVelocity() + Vector3(0, 6.5, 0)
                vehicle:SetLinearVelocity(dir1)

                self.cooltime = time + self.cooldown
            end
        end
    end
end

local woet = Woet()