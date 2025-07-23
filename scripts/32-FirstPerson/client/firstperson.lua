class 'FirstPerson'

function FirstPerson:__init()
    self.enabled = false
    self.bikes = {
        [80] = true,
        [27] = true,
        [4] = true,
        [83] = true,
        [32] = true,
        [47] = true,
        [21] = true,
        [43] = true,
        [22] = true,
        [9] = true,
        [61] = true,
        [74] = true,
        [89] = true,
        [90] = true,
        [36] = true,
        [75] = true,
        [12] = true,
        [16] = true,
        [45] = true,
        [19] = true,
        [5] = true,
        [38] = true,
        [25] = true,
        [50] = true,
        [46] = true,
        [72] = true,
        [48] = true,
        [76] = true
    }

    self.bering = {[85] = true}
    self.aero = {[39] = true}

    self:UpdateKeyBinds()

    self.locStrings = {
        on = "Вид от 1-го лица включён",
        off = "Вид от 1-го лица отключён"
    }

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("UpdateKeyBinds", self, self.UpdateKeyBinds)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
    Events:Subscribe("KeyUp", self, self.KeyUp)
end

function FirstPerson:Lang()
    self.locStrings = {
        on = "First-person View Enabled",
        off = "First-person View Disabled"
    }
end

function FirstPerson:UpdateKeyBinds()
    local keyBinds = LocalPlayer:GetValue("KeyBinds")
    local bind = keyBinds and keyBinds["FirstPerson"]

    self.expectedKey = bind and bind.type == "Key" and bind.value or 117
end

function FirstPerson:LocalPlayerExitVehicle()
    if not self.enabled then return end

    Camera:SetFOV(0.8)
end

function FirstPerson:CalcView()
    if not self.enabled then return end
    if LocalPlayer:GetValue("SpectatorMode") then return end

    local position = LocalPlayer:GetBonePosition("ragdoll_Head")
    local vehicle = LocalPlayer:GetVehicle()

    if vehicle and LocalPlayer:InVehicle() then
        local vehicleModel = vehicle:GetModelId()

        if self.bering[vehicleModel] then
            position = vehicle:GetPosition() + (vehicle:GetAngle() * Vector3(0, 6.0, -9))
        elseif self.aero[vehicleModel] then
            position = vehicle:GetPosition() + (vehicle:GetAngle() * Vector3(0, 4.4, -10.5))
        end

        position = position + (Camera:GetAngle() * Vector3(0, 0, 0.3))

		Camera:SetFOV(self.bikes[vehicleModel] and 0.8 or 0.5)
    else
        position = position + (Camera:GetAngle() * Vector3(0, 0.2, 0.1))
    end

    Camera:SetPosition(position)
end

function FirstPerson:Active()
    if self.enabled then
        if self.EventCaclView then Events:Unsubscribe(self.EventCaclView) self.EventCaclView = nil end

        self.enabled = false
    else
        if not self.EventCaclView then self.EventCaclView = Events:Subscribe("CalcView", self, self.CalcView) end

        self.enabled = true
        Events:Fire("ZoomReset")
    end

    local locStrings = self.locStrings

    Events:Fire("CastCenterText", {text = (self.enabled and locStrings["on"] or locStrings["off"]), time = 2})
end

function FirstPerson:KeyUp(args)
    if Game:GetState() ~= GUIState.Game then return end
    if LocalPlayer:GetValue("SpectatorMode") then return end

    if args.key == self.expectedKey then
        self:Active()
    end
end

local firstperson = FirstPerson()