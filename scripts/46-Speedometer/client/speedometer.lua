class 'Speedometer'

function Speedometer:__init()
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

    self.enabled = true
    self.peredacha = false
    self.bottom_aligned = false
    self.center_aligned = false
    self.speedFill = true
    self.unit = 1
    self.position = LocalPlayer:GetPosition()

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            ms = "м/с",
            kmh = "км/ч",
            mph = "миль",
            title = "Настройка спидометра",
            enabled = "Включено",
            gear = "Показывать передачу",
            onscreenmode = "Экранный режим",
            firstpersonmode = "Режим от 1-го лица"
        }
    end

    self.speedScale = 120
    self.speedFactor = 3.6

    self.speed_text_size = TextSize.Gigantic
    self.unit_text_size = TextSize.Huge

    self.bHealth = Color(100, 100, 100)
    self.zHealth = Color(255, 150, 150)
    self.fHealth = Color(100, 150, 100)
    self.text_shadow = Color(0, 0, 0, 100)

    if LocalPlayer:InVehicle() then
        self.PreTickEvent = Events:Subscribe("PreTick", self, self.PreTick)
        self.RenderEvent = Events:Subscribe("Render", self, self.Render)
        self.GameRenderEvent = Events:Subscribe("Render", self, self.GameRender)

        self.animationValue = 1
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)

    Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
    Events:Subscribe("OpenSpeedometerMenu", self, self.ToggleWindowVisible)
end

function Speedometer:LocalPlayerEnterVehicle()
    if not self.PreTickEvent then self.PreTickEvent = Events:Subscribe("PreTick", self, self.PreTick) end
    if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
    if not self.GameRenderEvent then self.GameRenderEvent = Events:Subscribe("Render", self, self.GameRender) end

    self.animationValue = 1
    -- Animation:Play( 0, 1, 0.25, easeInOut, function( value ) self.animationValue = value end )
end

function Speedometer:LocalPlayerExitVehicle()
    if self.PreTickEvent then Events:Unsubscribe(self.PreTickEvent) self.PreTickEvent = nil end
    if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
    if self.GameRenderEvent then Events:Unsubscribe(self.GameRenderEvent) self.GameRenderEvent = nil end

    self.animationValue = nil
end

function Speedometer:Lang()
    self.locStrings = {
        ms = "m/s",
        kmh = "km/h",
        mph = "mph",
        title = "Speedometer Settings",
        enabled = "Enabled",
        gear = "Show current gear",
        onscreenmode = "On-screen mode",
        firstpersonmode = "First-person mode"
    }
end

function Speedometer:CreateWindow()
    if self.window then return end

    local locStrings = self.locStrings

    self.window = Window.Create()
    self.window:SetSize(Vector2(300, 135))
    self.window:SetPosition((Render.Size - self.window:GetSize()) / 2)
    self.window:SetTitle(locStrings["title"])
    self.window:Subscribe("WindowClosed", self, function() self:SetWindowVisible(false) end)

    self.widgets = {}

    local enabled_checkbox = LabeledCheckBox.Create(self.window)
    local peredacha_checkbox = LabeledCheckBox.Create(self.window)
    local bottom_checkbox = LabeledCheckBox.Create(self.window)
    local center_checkbox = LabeledCheckBox.Create(self.window)

    enabled_checkbox:SetSize(Vector2(300, 20))
    enabled_checkbox:SetDock(GwenPosition.Top)
    enabled_checkbox:GetLabel():SetText(locStrings["enabled"])
    enabled_checkbox:GetCheckBox():SetChecked(self.enabled)
    enabled_checkbox:GetCheckBox():Subscribe("CheckChanged", function() self.enabled = enabled_checkbox:GetCheckBox():GetChecked() end)

    peredacha_checkbox:SetSize(Vector2(300, 20))
    peredacha_checkbox:SetDock(GwenPosition.Top)
    peredacha_checkbox:GetLabel():SetText(locStrings["gear"])
    peredacha_checkbox:GetCheckBox():SetChecked(self.peredacha)
    peredacha_checkbox:GetCheckBox():Subscribe("CheckChanged", function() self.peredacha = peredacha_checkbox:GetCheckBox():GetChecked() end)

    bottom_checkbox:SetSize(Vector2(300, 20))
    bottom_checkbox:SetDock(GwenPosition.Top)
    bottom_checkbox:GetLabel():SetText(locStrings["onscreenmode"])
    bottom_checkbox:GetCheckBox():SetChecked(self.bottom_aligned)
    bottom_checkbox:GetCheckBox():Subscribe("CheckChanged", function()
        self.bottom_aligned = bottom_checkbox:GetCheckBox():GetChecked()

        if self.bottom_aligned then
            self.speed_text_size = TextSize.VeryLarge
            self.unit_text_size = TextSize.Large
        else
            self.speed_text_size = TextSize.Gigantic
            self.unit_text_size = TextSize.Huge
        end

        if self.bottom_aligned then
            center_checkbox:GetCheckBox():SetChecked(false)
        end
    end)

    center_checkbox:SetSize(Vector2(300, 20))
    center_checkbox:SetDock(GwenPosition.Top)
    center_checkbox:GetLabel():SetText(locStrings["firstpersonmode"])
    center_checkbox:GetCheckBox():SetChecked(self.center_aligned)
    center_checkbox:GetCheckBox():Subscribe("CheckChanged", function()
        self.center_aligned = center_checkbox:GetCheckBox():GetChecked()

        if self.center_aligned then
            bottom_checkbox:GetCheckBox():SetChecked(false)
        end
    end)

    local rbc = RadioButtonController.Create(self.window)
    rbc:SetSize(Vector2(300, 20))
    rbc:SetDock(GwenPosition.Top)

    local units = {locStrings["ms"], locStrings["kmh"], locStrings["mph"]}
    for i, v in ipairs(units) do
        local option = rbc:AddOption(v)
        option:SetSize(Vector2(100, 20))
        option:SetDock(GwenPosition.Left)

        if i - 1 == self.unit then
            option:Select()
        end

        option:GetRadioButton():Subscribe("Checked", function() self.unit = i - 1 end)
    end
end

function Speedometer:SetWindowVisible(visible)
    self:CreateWindow()

    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end
end

function Speedometer:GetSpeed(vehicle)
    local speed = vehicle:GetLinearVelocity():Length()

    if self.unit == 0 then
        return speed
    elseif self.unit == 1 then
        return speed * 3.6
    elseif self.unit == 2 then
        return speed * 2.237
    end
end

function Speedometer:GetUnitString()
    local locStrings = self.locStrings

    if self.unit == 0 then
        return locStrings["ms"]
    elseif self.unit == 1 then
        return locStrings["kmh"]
    elseif self.unit == 2 then
        return locStrings["mph"]
    end
end

function Speedometer:DrawShadowedText3(pos, text, colour, size, scale)
    if not scale then scale = 1.0 end
    if not size then size = TextSize.Default end

    local shadow_colour = Color(0, 0, 0, 150)
    shadow_colour = shadow_colour * 0.4

    Render:DrawText(pos + Vector3(5, 5, 3), text, shadow_colour, size, scale)
    Render:DrawText(pos, text, colour, size, scale)
end

function Speedometer:DrawShadowedText2(pos, text, colour, size, scale)
    if not scale then scale = 1.0 end
    if not size then size = TextSize.Default end

    local shadow_colour = Color(0, 0, 0, 255)
    shadow_colour = shadow_colour * 0.4

    Render:DrawShadowedText(pos, text, colour, shadow_colour, size, scale)
end

function Speedometer:PreTick()
    if LocalPlayer:InVehicle() then
        self.position = LocalPlayer:GetPosition()
    end
end

function Speedometer:Render()
    if Game:GetState() ~= GUIState.Game or not self.enabled or LocalPlayer:GetValue("HiddenHUD") then return end
    if not self.bottom_aligned then return end
    if not LocalPlayer:InVehicle() then return end

    Render:SetFont(AssetLocation.Disk, "Archivo.ttf")

    local vehicle = LocalPlayer:GetVehicle()

    local speed = self:GetSpeed(vehicle)
    local speed_text = string.format("%.f", speed)
    local speed_text_size = self.speed_text_size
    local speed_size = Render:GetTextSize(speed_text, speed_text_size)

    local vehicleAngle = vehicle:GetAngle()
    local vehicleVelocity = -vehicleAngle * vehicle:GetLinearVelocity()
    local currentGear = vehicle:GetTransmission():GetGear()

    local gearString = "1"
    local peredacha = self.peredacha

    if peredacha then
        if currentGear >= 4 then
            gearString = tostring(currentGear)
        elseif currentGear == 3 then
            gearString = "3"
        elseif currentGear == 2 then
            gearString = "2"
        elseif vehicleVelocity.z > 1 then
            gearString = "R"
        end
    end

    local unit_text = self:GetUnitString()
    local unit_text_size = self.unit_text_size
    local unit_size = Render:GetTextSize(unit_text, unit_text_size)
    local pi = math.pi
    local angle = vehicleAngle * Angle(pi, 0, pi)
    local vHelath = vehicle:GetHealth()

    local factor = math.clamp(vHelath - 0.4, 0.0, 0.6) * 2.5

    local vehBrake = LocalPlayer:GetValue("VehBrake")

    local fHealth = self.fHealth
    local zHealth = self.zHealth
    local bHealth = self.bHealth
    local col = math.lerp(vehBrake and bHealth or zHealth, vehBrake and bHealth or fHealth, factor)
    local textcol = col

    local text_col = Color.White
    local text_size = speed_size + Vector2(unit_size.x + 16, 0)
    local text_shadow = self.text_shadow

    local speed_position = Vector2(Render.Width / 2, Render.Height)

    speed_position.y = speed_position.y - (speed_size.y + 40)
    speed_position.x = speed_position.x - (text_size.x / 2)

    local unit_position = Vector2()

    unit_position.x = speed_position.x + speed_size.x + 10
    unit_position.y = speed_position.y + ((speed_size.y - unit_size.y) / 2)

    self:DrawShadowedText2(speed_position, speed_text, textcol, speed_text_size)
    self:DrawShadowedText2(unit_position, unit_text, text_col, unit_text_size)

    local bar_len = 300
    local bar_start = (Render.Width - bar_len) / 2

    local bar_pos = Vector2(bar_start, speed_position.y + text_size.y)
    local final_pos = Vector2(bar_len, 6)
    if peredacha then
        self:DrawShadowedText2(bar_pos - Vector2(30, 20), gearString, text_col, unit_text_size)
    end

    bar_len = bar_len * vHelath
    Render:FillArea(bar_pos, final_pos, text_shadow)
    Render:FillArea(bar_pos, Vector2(bar_len, 5), col)
end

function Speedometer:GameRender()
    if Game:GetState() ~= GUIState.Game or not self.enabled or LocalPlayer:GetValue("HiddenHUD") then return end
    if self.bottom_aligned then return end
    if not LocalPlayer:InVehicle() then return end

    Render:SetFont(AssetLocation.Disk, "Archivo.ttf")

    local vehicle = LocalPlayer:GetVehicle()

    local speed = self:GetSpeed(vehicle)
    local speed_text = string.format("%.f", speed)
    local speed_text_size = self.speed_text_size
    local speed_size = Render:GetTextSize(speed_text, speed_text_size)

    local vehicleAngle = vehicle:GetAngle()
    local vehicleVelocity = -vehicleAngle * vehicle:GetLinearVelocity()
    local currentGear = vehicle:GetTransmission():GetGear()

    local gearString = "1"
    local peredacha = self.peredacha

    if peredacha then
        if currentGear >= 4 then
            gearString = tostring(currentGear)
        elseif currentGear == 3 then
            gearString = "3"
        elseif currentGear == 2 then
            gearString = "2"
        elseif vehicleVelocity.z > 1 then
            gearString = "R"
        end
    end

    local unit_text = self:GetUnitString()
    local unit_text_size = self.unit_text_size
    local unit_size = Render:GetTextSize(unit_text, unit_text_size)
    local pi = math.pi
    local angle = vehicleAngle * Angle(pi, 0, pi)
    local vHelath = vehicle:GetHealth()

    local factor = math.clamp(vHelath - 0.4, 0.0, 0.6) * 2.5

    local vehBrake = LocalPlayer:GetValue("VehBrake")

    local fHealth = self.fHealth
    local zHealth = self.zHealth
    local bHealth = self.bHealth
    local animationValue = self.animationValue
    local alpha = math.lerp(0, 255, animationValue)

    local zHealthCol = Color(zHealth.r, zHealth.g, zHealth.b, alpha)
    local fHealthCol = Color(fHealth.r, fHealth.g, fHealth.b, alpha)
    local bHealthCol = Color(bHealth.r, bHealth.g, bHealth.b, alpha)
    local col = math.lerp(vehBrake and bHealthCol or zHealthCol, vehBrake and bHealthCol or fHealthCol, factor)
    local textcol = col

    local text_col = Color(255, 255, 255, alpha)
    local text_size = speed_size + Vector2(unit_size.x + 24, 0)
    local text_shadow = self.text_shadow
    local text_shadow_col = Color(text_shadow.r, text_shadow.g, text_shadow.b, math.lerp(0, text_shadow.a, animationValue))

    local t = Transform3()

    if self.center_aligned then
        local pos_3d = vehicle:GetPosition()
        pos_3d.y = LocalPlayer:GetBonePosition("ragdoll_Head").y

        local scale = 1

        t:Translate(pos_3d)
        t:Scale(0.0050 * scale)
        t:Rotate(angle)
        t:Translate(Vector3(0, 0, 2000))
        t:Translate(-Vector3(text_size.x, text_size.y, 0) / 2)
    else
        local pos_3d = self.position
        angle = angle * Angle(-math.rad(20), 0, 0)

        local scale = math.clamp(Camera:GetPosition():Distance(pos_3d), 0, 500)
        scale = scale / 20

        t = Transform3()
        t:Translate(pos_3d)
        t:Scale(0.0050 * scale)
        t:Rotate(angle)
        t:Translate(Vector3(text_size.x + 50, text_size.y, -250) * -1.5)
    end

    Render:SetTransform(t)

    self:DrawShadowedText3(Vector3.Zero, speed_text, textcol, speed_text_size)
    self:DrawShadowedText3(Vector3(speed_size.x + 24, (speed_size.y - unit_size.y) / 2, 0), unit_text, text_col, unit_text_size)

    local bar_pos = Vector3(0, text_size.y + 4, 0)
    local bar_len = text_size.x * vHelath
    if peredacha then
        self:DrawShadowedText3(Vector3(bar_pos.x - 60, (speed_size.y - unit_size.y) / 0.5, 0), gearString, text_col, unit_text_size)
    end

    Render:FillArea(bar_pos + Vector3(1, 1, 4), Vector3(bar_len, 16, 0), col)
    Render:FillArea(bar_pos + Vector3(1, 1, 3), Vector3(text_size.x, 20, 0), text_shadow_col)
    Render:FillArea(bar_pos, Vector3(bar_len, 16, 0), col)
end

function Speedometer:ToggleWindowVisible()
    self:SetWindowVisible(not self.activeWindow)
end

function Speedometer:LocalPlayerInput(args)
    if args.input == Action.GuiPause then
        self:SetWindowVisible(false)
    end

    if self.activeWindow and Game:GetState() == GUIState.Game then
        if self.actions[args.input] then
            return false
        end
    end
end

local speedometer = Speedometer()