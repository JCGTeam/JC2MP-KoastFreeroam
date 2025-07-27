class 'VehicleRadio'

function VehicleRadio:__init()
    self:UpdateKeyBinds()

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            title = "Магнитола: ",
            off = "Выключено"
        }
    end

    self.check = 0

    self.cooldown = 0.5
    self.cooltime = 0

    if LocalPlayer:InVehicle() then
        self.PreTickEvent = Events:Subscribe("PreTick", self, self.PreTick)
        self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
        self.KeyUpEvent = Events:Subscribe("KeyUp", self, self.KeyUp)
        self.ModuleUnloadEvent = Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("UpdateKeyBinds", self, self.UpdateKeyBinds)
    Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
end

function VehicleRadio:Lang()
    self.locStrings = {
        title = "Radio: ",
        off = "Disabled"
    }
end

function VehicleRadio:UpdateKeyBinds()
    local keyBinds = LocalPlayer:GetValue("KeyBinds")
    local bind = keyBinds and keyBinds["ToggleVehicleRadio"]

    self.expectedKey = bind and bind.type == "Key" and bind.value or 190
end

function VehicleRadio:LocalPlayerInput(args)
    if Game:GetSetting(GameSetting.GamepadInUse) == 1 then
        if args.input == Action.EquipLeftSlot then
            if Game:GetState() ~= GUIState.Game then return end

            if LocalPlayer:InVehicle() then
                local time = Client:GetElapsedSeconds()

                if time < self.cooltime then
                    return
                else
                    self:ToggleRadio()
                end

                self.cooltime = time + self.cooldown
                return false
            end
        end
    end
end

function VehicleRadio:KeyUp(args)
    if Game:GetState() ~= GUIState.Game then return end

    if args.key == self.expectedKey then
        if LocalPlayer:InVehicle() then
            self:ToggleRadio()
        end
    end
end

function VehicleRadio:ToggleRadio()
    if self.check <= 4 then
        self.check = self.check + 1
    end

    if self.check == 1 then
        if self.refresh then
            self:ModuleUnload()
        end

        self.refresh = true
        self.radio = true

        self.sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 25,
            sound_id = 86,
            position = Camera:GetPosition(),
            angle = Angle()
        })

        Game:ShowPopup(self.locStrings["title"] .. "Tom Main Theme", false)
    elseif self.check == 2 then
        if self.refresh then
            self:ModuleUnload()
        end

        self.radio = true

        self.sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 25,
            sound_id = 155,
            position = Camera:GetPosition(),
            angle = Angle()
        })

        Game:ShowPopup(self.locStrings["title"] .. "Fighting 01", false)
    elseif self.check == 3 then
        if self.refresh then
            self:ModuleUnload()
        end

        self.radio = true

        self.sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 25,
            sound_id = 154,
            position = Camera:GetPosition(),
            angle = Angle()
        })

        Game:ShowPopup(self.locStrings["title"] .. "Fighting 02", false)
    elseif self.check == 4 then
        if self.refresh then
            self:ModuleUnload()
        end

        self.refresh = nil
        self.radio = nil
        self.check = 0

        local locStrings = self.locStrings

        Game:ShowPopup(locStrings["title"] .. locStrings["off"], false)
    end
end

function VehicleRadio:PreTick()
    if self.radio then
        local inVehicle = LocalPlayer:InVehicle()

        if inVehicle then
            local cameraPos = Camera:GetPosition()

            self.sound:SetPosition(cameraPos)
            self.sound:SetParameter(0, Game:GetSetting(GameSetting.MusicVolume) / 100)
        end
    end
end

function VehicleRadio:LocalPlayerEnterVehicle()
    local locStrings = self.locStrings

    Game:ShowPopup(locStrings["title"] .. locStrings["off"], false)
    self.check = 0

    if not self.PreTickEvent then self.PreTickEvent = Events:Subscribe("PreTick", self, self.PreTick) end
    if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
    if not self.KeyUpEvent then self.KeyUpEvent = Events:Subscribe("KeyUp", self, self.KeyUp) end
    if not self.ModuleUnloadEvent then self.ModuleUnloadEvent = Events:Subscribe("ModuleUnload", self, self.ModuleUnload) end
end

function VehicleRadio:LocalPlayerExitVehicle()
    if self.radio then self:ModuleUnload() self.radio = nil end

    if self.PreTickEvent then Events:Unsubscribe(self.PreTickEvent) self.PreTickEvent = nil end
    if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
    if self.KeyUpEvent then Events:Unsubscribe(self.KeyUpEvent) self.KeyUpEvent = nil end
    if self.ModuleUnloadEvent then Events:Unsubscribe(self.ModuleUnloadEvent) self.ModuleUnloadEvent = nil end
end

function VehicleRadio:ModuleUnload()
    if self.radio then self.sound:Remove() self.sound = nil end
end

local vehicleradio = VehicleRadio()