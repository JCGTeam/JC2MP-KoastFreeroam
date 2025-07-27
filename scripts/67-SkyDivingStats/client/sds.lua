class 'SkydivingStats'

function SkydivingStats:__init()
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
    self.unit = 1

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            ms = "м/с",
            kmh = "км/ч",
            mph = "миль",
            nameFo = " м",
            nameFi = " секунд",
            title = "Настройка спидометра",
            enabled = "Включено"
        }
    end

    self.flight_timer = Timer()
    self.last_state = 0

    self.text_size = TextSize.VeryLarge
    self.x_offset = 1

    if not LocalPlayer:InVehicle() then
        self.RenderEvent = Events:Subscribe("Render", self, self.Render)
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("PostTick", self, self.PostTick)
    Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)

    Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
    Events:Subscribe("OpenSkydivingStatsMenu", self, self.ToggleWindowVisible)
end

function SkydivingStats:LocalPlayerEnterVehicle()
    if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
end

function SkydivingStats:LocalPlayerExitVehicle()
    if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
end

function SkydivingStats:Lang()
    self.locStrings = {
        ms = "m/s",
        kmh = "km/h",
        mph = "mph",
        nameFo = " m",
        nameFi = " seconds",
        title = "Skydiving Settings",
        enabled = "Enabled"
    }
end

function SkydivingStats:CreateWindow()
    if self.window then return end

    local locStrings = self.locStrings

    self.window = Window.Create()
    self.window:SetSize(Vector2(300, 70))
    self.window:SetPosition((Render.Size - self.window:GetSize()) / 2)
    self.window:SetTitle(locStrings["title"])
    self.window:Subscribe("WindowClosed", function() self:SetWindowVisible(false) end)

    self.widgets = {}

    local enabled_checkbox = LabeledCheckBox.Create(self.window)
    enabled_checkbox:SetSize(Vector2(300, 20))
    enabled_checkbox:SetDock(GwenPosition.Top)
    enabled_checkbox:GetLabel():SetText(locStrings["enabled"])
    enabled_checkbox:GetCheckBox():SetChecked(self.enabled)
    enabled_checkbox:GetCheckBox():Subscribe("CheckChanged", function() self.enabled = enabled_checkbox:GetCheckBox():GetChecked() end)

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

function SkydivingStats:SetWindowVisible(visible)
    self:CreateWindow()

    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end
end

function SkydivingStats:GetMultiplier()
    if self.unit == 0 then
        return 1
    elseif self.unit == 1 then
        return 3.6
    elseif self.unit == 2 then
        return 2.237
    end
end

function SkydivingStats:GetUnitString()
    local locStrings = self.locStrings

    if self.unit == 0 then
        return locStrings["ms"]
    elseif self.unit == 1 then
        return locStrings["kmh"]
    elseif self.unit == 2 then
        return locStrings["mph"]
    end
end

function SkydivingStats:DrawText(text, textTw)
    local text_clr = Color.White
    local text_clr2 = Color.DarkGray
    local text_shadow = Color(0, 0, 0, 100)
    local text_size = self.text_size

    Render:DrawText(Vector3(2, 2, 1), text .. textTw, text_shadow, text_size)
    Render:DrawText(Vector3.Zero, text, text_clr, text_size)
    Render:DrawText(Vector3.Zero + Vector3(Render:GetTextWidth(text, text_size), 0, 0), textTw, text_clr2, text_size)
end

function SkydivingStats:DrawSpeedometer(t)
    local speed = LocalPlayer:GetLinearVelocity():Length()
    local text_size = self.text_size

    if not self.average_speed then
        self.average_speed = speed
    else
        self.average_speed = (self.average_speed + speed) / 2
    end

    local text = string.format("%.02f", speed * self:GetMultiplier())
    local textTw = " " .. self:GetUnitString()
    local text_vsize = Render:GetTextSize(text, text_size)
    local text_vsize_3d = Vector3(text_vsize.x, text_vsize.y, 0)
    local ang = Camera:GetAngle()

    local right = Copy(t)
    local pi = math.pi
    local x_offset = self.x_offset
    local rad = math.rad(30)

    right:Translate(Vector3(x_offset, -0.4, -5))
    right:Rotate(Angle(pi - rad, 0, pi))
    right:Scale(0.002)

    Render:SetTransform(right)

    self:DrawText(text, textTw)
end

function SkydivingStats:DrawAngle(t)
    local angle = math.deg(LocalPlayer:GetAngle().pitch)
    local text_size = self.text_size

    if self.average_angle == nil then
        self.average_angle = angle
    else
        self.average_angle = (self.average_angle + angle) / 2
    end

    local text = string.format("%.02f", angle)
    local textTw = string.format(" \176")
    local text_vsize = Render:GetTextSize(text, text_size)
    local text_vsize_3d = Vector3(text_vsize.x, text_vsize.y, 0)
    local ang = Camera:GetAngle()

    local right = Copy(t)
    local pi = math.pi
    local x_offset = self.x_offset
    local rad = math.rad(30)

    right:Translate(Vector3(x_offset, -0.6, -5))
    right:Rotate(Angle(pi - rad, 0, pi))
    right:Scale(0.002)

    Render:SetTransform(right)

    self:DrawText(text, textTw)
end

function SkydivingStats:DrawDistance(t)
    local pos = LocalPlayer:GetBonePosition("ragdoll_Spine")
    local dir = LocalPlayer:GetAngle() * Vector3(0, -1, 1)
    local text_size = self.text_size

    local distance = pos.y - (math.max(200, Physics:GetTerrainHeight(pos)))

    local locStrings = self.locStrings
    local text = string.format("%.02f", distance)
    local textTw = locStrings["nameFo"]
    local text_vsize = Render:GetTextSize(text, text_size)
    local text_vsize_3d = Vector3(text_vsize.x, text_vsize.y, 0)
    local ang = Camera:GetAngle()

    local right = Copy(t)
    local pi = math.pi
    local x_offset = self.x_offset
    local rad = math.rad(30)

    right:Translate(Vector3(x_offset, -0.8, -5))
    right:Rotate(Angle(pi - rad, 0, pi))
    right:Scale(0.002)

    Render:SetTransform(right)

    self:DrawText(text, textTw)
end

function SkydivingStats:DrawTimer(t)
    local locStrings = self.locStrings
    local text = string.format("%.02f", self.flight_timer:GetSeconds())
    local textTw = locStrings["nameFi"]
    local text_size = self.text_size
    local text_vsize = Render:GetTextSize(text, text_size)
    local text_vsize_3d = Vector3(text_vsize.x, text_vsize.y, 0)
    local ang = Camera:GetAngle()

    local right = Copy(t)
    local pi = math.pi
    local x_offset = self.x_offset
    local rad = math.rad(30)

    right:Translate(Vector3(x_offset, -0.2, -5))
    right:Rotate(Angle(pi - rad, 0, pi))
    right:Scale(0.002)

    Render:SetTransform(right)

    self:DrawText(text, textTw)
end

function SkydivingStats:Render()
    if not self.enabled or LocalPlayer:GetValue("HiddenHUD") then return end
    if Game:GetState() ~= GUIState.Game then return end
    if LocalPlayer:GetValue("SpectatorMode") then return end

    local bs = LocalPlayer:GetBaseState()

    if bs ~= AnimationState.SSkydive and bs ~= AnimationState.SSkydiveDash then return end

    Render:SetFont(AssetLocation.Disk, "Archivo.ttf")

    local t = Transform3()
    local cameraPos = Camera:GetPosition()
    local cameraAngle = Camera:GetAngle()

    t:Translate(cameraPos)
    t:Rotate(cameraAngle)

    self:DrawSpeedometer(t)
    self:DrawAngle(t)
    self:DrawDistance(t)
    self:DrawTimer(t)
end

function SkydivingStats:PostTick()
    if not self.enabled or LocalPlayer:GetValue("HiddenHUD") then return end

    local bs = LocalPlayer:GetBaseState()

    if bs == self.last_bs then return end

    if not LocalPlayer:GetValue("IsPigeonMod") then
        self.flight_timer:Restart()
    end

    self.last_bs = bs
end

function SkydivingStats:ToggleWindowVisible()
    self:SetWindowVisible(not self.activeWindow)
end

function SkydivingStats:LocalPlayerInput(args)
    if args.input == Action.GuiPause then
        self:SetWindowVisible(false)
    end

    if self.activeWindow and Game:GetState() == GUIState.Game then
        if self.actions[args.input] then
            return false
        end
    end
end

local skydivingstats = SkydivingStats()