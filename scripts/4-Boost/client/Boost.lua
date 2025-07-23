class 'Boost'

function Boost:__init()
    self.actions = {
        [3] = true,
        [4] = true,
        [5] = true,
        [6] = true,
        [11] = true,
        [12] = true,
        [13] = true,
        [14] = true,
        [17] = true,
        [18] = true,
        [105] = true,
        [137] = true,
        [138] = true,
        [139] = true,
        [51] = true,
        [52] = true,
        [16] = true
    }

    self.defaultLandBoost = true
    self.defaultBoatBoost = true
    self.defaultHeliBoost = true
    self.defaultPlaneBoost = true
    self.defaultTextEnabled = true
    self.defaultPadEnabled = true
    self.defaultBrakeEnabled = true
    self.defaultStrength = 80

    self.controllerAction = Action.VehicleFireLeft

    self.landBoost = self.defaultLandBoost
    self.boatBoost = self.defaultBoatBoost
    self.heliBoost = self.defaultHeliBoost
    self.planeBoost = self.defaultPlaneBoost
    self.textEnabled = self.defaultTextEnabled
    self.padEnabled = self.defaultPadEnabled
    self.brake = self.defaultBrakeEnabled
    self.strength = self.defaultStrength
    self.delta = 0

    self:UpdateKeyBinds()

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            press = "Нажмите ",
            orlb = " или LB",
            toboost = " для супер-ускорения. ",
            tobrake = " для мгновенной заморозки.",
            title = "Настройки супер-ускорения",
            opt1 = "Супер-ускорение для машин",
            opt2 = "Супер-ускорение для лодок",
            opt3 = "Супер-ускорение для вертолётов",
            opt4 = "Супер-ускорение для самолётов",
            opt5 = "Показывать подсказку",
            opt6 = "Разрешить использование геймпада",
            opt7 = "Мгновенная заморозка",
            opt8 = "Сила разгона"
        }
    end

    self.boats = {
        [5] = true,
        [6] = true,
        [16] = true,
        [19] = true,
        [25] = true,
        [27] = true,
        [28] = true,
        [38] = true,
        [45] = true,
        [50] = true,
        [53] = true,
        [69] = true,
        [80] = true,
        [88] = true
    }
    self.helis = {
        [3] = true,
        [14] = true,
        [37] = true,
        [57] = true,
        [62] = true,
        [64] = true,
        [65] = true,
        [67] = true
    }
    self.planes = {
        [24] = true,
        [30] = true,
        [34] = true,
        [39] = true,
        [51] = true,
        [59] = true,
        [81] = true,
        [85] = true
    }

    self.settingSub = Network:Subscribe("UpdateSettings", self, self.UpdateSettings)

    local vehicle = LocalPlayer:GetVehicle()
    if vehicle and vehicle:GetDriver() == LocalPlayer then
        self.RenderEvent = Events:Subscribe("Render", self, self.Render)
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("UpdateKeyBinds", self, self.UpdateKeyBinds)
    Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
    Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
end

function Boost:Lang()
    self.locStrings = {
        press = "Press ",
        orlb = " or LB",
        toboost = " to boost. ",
        tobrake = " to brake.",
        title = "Boost Settings",
        opt1 = "Land vehicles boost",
        opt2 = "Boats boost",
        opt3 = "Helicopters boost",
        opt4 = "Planes boost",
        opt5 = "Show tooltip",
        opt6 = "Allow gamepad usage",
        opt7 = "Instant brake",
        opt8 = "Boost strength"
    }
end

function Boost:UpdateKeyBinds()
    local keyBinds = LocalPlayer:GetValue("KeyBinds")
    local landBoostBind = keyBinds and keyBinds["VehicleLandBoost"]
    local planeBoostBind = keyBinds and keyBinds["VehiclePlaneBoost"]
    local brakeBind = keyBinds and keyBinds["VehicleBrake"]

    self.landBoostKey = landBoostBind and landBoostBind.type == "Key" and landBoostBind.value or 16
    self.planeBoostKey = planeBoostBind and planeBoostBind.type == "Key" and planeBoostBind.value or 81
    self.brakeKey = brakeBind and brakeBind.type == "Key" and brakeBind.value or 70

    self.landBoostStringKey = landBoostBind and landBoostBind.type == "Key" and landBoostBind.valueString or "Shift"
    self.planeBoostStringKey = planeBoostBind and planeBoostBind.type == "Key" and planeBoostBind.valueString or "Q"
    self.brakeStringKey = brakeBind and brakeBind.type == "Key" and brakeBind.valueString or "F"
end

function Boost:UpdateSettings(settings)
    Network:Unsubscribe(self.settingSub)
    self.settingSub = nil

    self.settings = settings

    Events:Subscribe("BoostSettings", self, self.BoostSettings)
end

function Boost:CreateWindow()
    if self.window then return end

    if self.settings then
        for setting, value in pairs(self.settings) do
            self[setting] = (setting == "strength") and value or value == 1
        end
    end

    local locStrings = self.locStrings

    self.window = Window.Create()
    self.window:SetSize(Vector2(250, 240))
    self.window:SetTitle(locStrings["title"])
    self.window:Subscribe("WindowClosed", function() self:SetWindowVisible(false) end)
    self:ResolutionChange()

    self:AddSetting(locStrings["opt1"], "landBoost", self.landBoost, self.defaultLandBoost)
    self:AddSetting(locStrings["opt2"], "boatBoost", self.boatBoost, self.defaultBoatBoost)
    self:AddSetting(locStrings["opt3"], "heliBoost", self.heliBoost, self.defaultHeliBoost)
    self:AddSetting(locStrings["opt4"], "planeBoost", self.planeBoost, self.defaultPlaneBoost)
    self:AddSetting(locStrings["opt5"], "textEnabled", self.textEnabled, self.defaultTextEnabled)
    self:AddSetting(locStrings["opt6"], "padEnabled", self.padEnabled, self.defaultPadEnabled)
    self:AddSetting(locStrings["opt7"], "brake", self.brake, self.defaultBrakeEnabled)

    local strength_text = Label.Create(self.window)
    strength_text:SetSize(Vector2(160, 32))
    strength_text:SetDock(GwenPosition.Top)
    strength_text:SetText(locStrings["opt8"])
    strength_text:SetAlignment(GwenPosition.CenterV)

    local strength_numeric = Numeric.Create(self.window)
    strength_numeric:SetSize(Vector2(160, 32))
    strength_numeric:SetDock(GwenPosition.Top)
    strength_numeric:SetRange(10, 100)
    strength_numeric:SetValue(self.strength)
    strength_numeric:Subscribe("Changed", function()
        self.strength = strength_numeric:GetValue()
        Network:Send("ChangeSetting", {
            setting = "strength",
            value = strength_numeric:GetValue()
        })
    end)

    Events:Subscribe("ResolutionChange", self, self.ResolutionChange)

    self.settings = nil
end

function Boost:SetWindowVisible(visible)
    self:CreateWindow()

    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end
end

function Boost:BoostSettings()
    self:SetWindowVisible(not self.activeWindow)
end

function Boost:LocalPlayerInput(args)
    if args.input == Action.GuiPause then
        self:SetWindowVisible(false)
    end

    if Game:GetState() ~= GUIState.Game then return end

    if self.activeWindow and self.actions[args.input] then
        return false
    end

    if self.padEnabled and args.input == self.controllerAction and LocalPlayer:GetWorld() == DefaultWorld and Game:GetSetting(GameSetting.GamepadInUse) == 1 then
        local vehicle = LocalPlayer:GetVehicle()

        if vehicle and (self:LandCheck(vehicle) or self:BoatCheck(vehicle) or self:HeliCheck(vehicle) or self:PlaneCheck(vehicle)) then
            self:Boost(vehicle)
        end
    end
end

function Boost:Render(args)
    local hinttimer = self.hinttimer

    if hinttimer and hinttimer:GetSeconds() >= 8 then
        self.fadeOutAnimation = Animation:Play(self.animationValue, 0, 0.15, easeIOnut, function(value) self.animationValue = value end, function() self.animationValue = nil end)
        self.hinttimer = nil
    end

    if not LocalPlayer:GetValue("Boost") then return end

    local gameState = Game:GetState()

    if gameState ~= GUIState.Game then return end
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    local vehicle = LocalPlayer:GetVehicle()

    if not vehicle then return end

    self.delta = args.delta
    local land = self:LandCheck(vehicle)
    local boat = self:BoatCheck(vehicle)
    local heli = self:HeliCheck(vehicle)
    local plane = self:PlaneCheck(vehicle)

    local vehBrake = LocalPlayer:GetValue("VehBrake")
    local freeze = LocalPlayer:GetValue("Freeze")

    if not (vehBrake or freeze) then
        if land or boat then
            local landBoostKey = self.landBoostKey

            if Key:IsDown(landBoostKey) then
                self:Boost(vehicle)
            end
        elseif heli or plane then
            local planeBoostKey = self.planeBoostKey

            if Key:IsDown(planeBoostKey) then
                self:Boost(vehicle)
            end
        end
    end

    local brake = self.brake

    if brake and not freeze then
        local brakeKey = self.brakeKey

        if Key:IsDown(brakeKey) then
            if not vehBrake then
                LocalPlayer:SetValue("VehBrake", true)
            end

            local vectorZero = Vector3.Zero
            vehicle:SetLinearVelocity(vectorZero)
            vehicle:SetAngularVelocity(vectorZero)

            local vPos = vehicle:GetPosition()
            local vAngle = vehicle:GetAngle()

            vehicle:SetPosition(vPos)
            vehicle:SetAngle(vAngle)
        elseif vehBrake then
            LocalPlayer:SetValue("VehBrake", nil)
        end
    end

    if LocalPlayer:GetValue("HiddenHUD") then return end

    local animationValue = self.animationValue

    if not animationValue then return end

    if self.textEnabled and (land or boat or heli or plane) then
        if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

        local locStrings = self.locStrings
        local lsPress = locStrings["press"]

        local text = lsPress
        if land or boat then
            text = text .. self.landBoostStringKey
        elseif heli or plane then
            text = text .. self.planeBoostStringKey
        end
        if self.padEnabled then
            text = text .. locStrings["orlb"]
        end
        text = text .. locStrings["toboost"]
        if brake then
            text = text .. lsPress .. self.brakeStringKey .. locStrings["tobrake"]
        end

        local textSize = 15
        local size = Render:GetTextSize(text, textSize)
        local pos = Vector2((Render.Width - size.x) / 2, math.lerp(Render.Height, Render.Height - size.y - 10, animationValue))
        local alpha = math.lerp(0, 255, animationValue)

        Render:DrawShadowedText(pos, text, Color(255, 255, 255, alpha), Color(0, 0, 0, alpha), textSize)
    end
end

function Boost:ResolutionChange()
    self.window:SetPositionRel(Vector2(0.5, 0.5) - self.window:GetSizeRel() / 2)
end

function Boost:AddSetting(text, setting, value, default)
    local checkBox = LabeledCheckBox.Create(self.window)
    checkBox:SetSize(Vector2(200, 20))
    checkBox:SetDock(GwenPosition.Top)
    checkBox:GetLabel():SetText(text)
    checkBox:GetCheckBox():SetChecked(value)
    checkBox:GetCheckBox():Subscribe("CheckChanged", function(box) self:UpdateSetting(setting, box:GetChecked(), default) end)
end

function Boost:UpdateSetting(setting, value, default)
    self[setting] = value

    -- Translate for DB
    if value == default then
        value = nil
    else
        value = value and 1 or 0
    end

    Network:Send("ChangeSetting", {setting = setting, value = value})
end

function Boost:Boost(vehicle)
    vehicle:SetLinearVelocity(vehicle:GetLinearVelocity() + vehicle:GetAngle() * Vector3(0, 0, -self.strength * self.delta))
end

function Boost:LandCheck(vehicle)
    local id = vehicle:GetModelId()
    local boost = LocalPlayer:GetValue("Boost")

    if not boost then return end

    if boost >= 1 then
        return self.landBoost and not (self.boats[id] or self.helis[id] or self.planes[id])
    end
end

function Boost:BoatCheck(vehicle)
    local boost = LocalPlayer:GetValue("Boost")

    if not boost then return end

    if boost >= 2 then
        return self.boatBoost and self.boats[vehicle:GetModelId()]
    end
end

function Boost:HeliCheck(vehicle)
    local boost = LocalPlayer:GetValue("Boost")

    if not boost then return end

    if boost >= 3 then
        return self.heliBoost and self.helis[vehicle:GetModelId()]
    end
end

function Boost:PlaneCheck(vehicle)
    local boost = LocalPlayer:GetValue("Boost")

    if not boost then return end

    if boost >= 3 then
        return self.planeBoost and self.planes[vehicle:GetModelId()]
    end
end

function Boost:LocalPlayerEnterVehicle(args)
    if not args.is_driver then return end

    if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end

    if self.fadeOutAnimation then
        Animation:Stop(self.fadeOutAnimation)
        self.fadeOutAnimation = nil
    end

    Animation:Play(0, 1, 0.15, easeIOnut, function(value) self.animationValue = value end)

    if not self.hinttimer then
        self.hinttimer = Timer()
    else
        self.hinttimer:Restart()
    end
end

function Boost:LocalPlayerExitVehicle()
    LocalPlayer:SetValue("VehBrake", nil)

    if self.animationValue then
        if self.RenderEvent then
            self.fadeOutAnimation = Animation:Play(self.animationValue, 0, 0.15, easeIOnut, function(value) self.animationValue = value end, function()
                self.animationValue = nil

                if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
            end)
        end
    else
        if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
    end
end

local boost = Boost()