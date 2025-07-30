local config, units, settings, planes, airports = config, units, settings, planes, airports
local abs, deg, rad = math.abs, math.deg, math.rad
local acos, asin, atan2 = math.acos, math.asin, math.atan2
local min, lerp, clamp = math.min, math.lerp, math.clamp
local huge = math.huge

local Vector2, Vector3, Angle, Input, Action = Vector2, Vector3, Angle, Input, Action
local Render = Render

class 'Autopilot'

function Autopilot:__init()
    self.drawTarget = true -- Whether to draw a target indicator for target-hold
    self.drawApproach = true -- Whether to draw a path for approach-hold

    self.twoKeys = false -- If false then panel toggle button toggles both the panel and mouse
    self.mouseToggleButton = "M"

    local vehicle = LocalPlayer:GetVehicle()
    if vehicle and vehicle:GetDriver() == LocalPlayer then
        local model = vehicle:GetModelId()
        if planes[model] and planes[model].available then
            self.vehicle = vehicle
            self.model = model
        end
    end

    self:InitGUI()
    self:UpdateKeyBinds()

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("UpdateKeyBinds", self, self.UpdateKeyBinds)
    Events:Subscribe("ModuleLoad", self, self.WindowResize)
    Events:Subscribe("ResolutionChange", self, self.ResolutionChange)
    Events:Subscribe("LocalPlayerEnterVehicle", self, self.EnterPlane)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.ExitPlane)
    Events:Subscribe("EntityDespawn", self, self.PlaneDespawn)

    if LocalPlayer:InVehicle() then
        local vehicle = LocalPlayer:GetVehicle()

        if vehicle:GetClass() == VehicleClass.Air then
            self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.InputBlock)
            self.InputPollEvent = Events:Subscribe("InputPoll", self, self.Input)
            self.KeyUpEvent = Events:Subscribe("KeyUp", self, self.PanelOpen)
            self.GameRenderEvent = Events:Subscribe("GameRender", self, self.DrawApproach)
            self.RenderEvent = Events:Subscribe("Render", self, self.Render)
        end
    end
end

function Autopilot:Lang()
    self.namept = "Press " .. self.stringKey .. " to enable autopilot panel."
end

function Autopilot:UpdateKeyBinds()
    local keyBinds = LocalPlayer:GetValue("KeyBinds")
    local bind = keyBinds and keyBinds["AutopilotMenu"]

    self.expectedKey = bind and bind.type == "Key" and bind.value or 82
    self.stringKey = bind and bind.type == "Key" and bind.valueString or "R"

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.namept = "Нажмите " .. self.stringKey .. " чтобы включить автопилот."
    end
end

function Autopilot:InitGUI()
    self.text_scale = 0.03

    local gui = {}

    gui.window = Window.Create()
    gui.position = Vector2(0.63, 0.04)
    gui.size = Vector2(0.28, 0.28)
    gui.button_size = Vector2(0.22, 0.095)
    gui.button_position = Vector2(0, 0.105)
    gui.label_size = Vector2(0.16, gui.button_size.y)
    gui.slider_size = Vector2(0.31, gui.button_size.y)

    gui.window:SetTitle("▧ Автопилот")
    gui.window:SetVisible(false)
    gui.window:SetSizeRel(gui.size)
    gui.window:SetPositionRel(gui.position)

    gui.line = Rectangle.Create(gui.window)
    gui.line:SetColor(Color(64, 64, 64))

    gui.st = {}

    gui.st.window = Window.Create()
    gui.st.window:SetSizeRel(gui.size)
    gui.st.window:SetPosition(gui.window:GetPosition() + Vector2(0, gui.window:GetHeight()))

    gui.st.window:SetTitle("")
    gui.st.window:SetVisible(false)
    gui.st.window:SetClosable(false)

    for k in pairs(units) do -- Units settings
        if #units[k] > 1 then
            gui.st[k] = {}
            gui.st[k].label = Label.Create(gui.st.window)
            gui.st[k].label:SetText(k:sub(1, 1):upper() .. k:sub(2))
            for i, v in ipairs(units[k]) do
                gui.st[k][i] = LabeledRadioButton.Create(gui.st.window)
                gui.st[k][i]:GetLabel():SetText(v[1])
                gui.st[k][i]:GetLabel():SetMouseInputEnabled(false)
                gui.st[k][i]:GetRadioButton():Subscribe("Checked", function(args)
                    settings[k] = i
                    for _, w in ipairs(gui.st[k]) do
                        if w ~= gui.st[k][i] then
                            w:GetRadioButton():SetChecked(false)
                        end
                    end
                end)
            end
            gui.st[k][settings[k]]:GetRadioButton():SetChecked(true)
        end
    end

    gui.st.ap = {}
    gui.st.ap.gain = {}
    gui.st.ap.input = {}

    gui.st.ap.gain.label = Label.Create(gui.st.window)
    gui.st.ap.gain.label:SetText("Сила")

    gui.st.ap.input.label = Label.Create(gui.st.window)
    gui.st.ap.input.label:SetText("Вход")

    gui.ap = {}

    for i in ipairs(config) do -- Main GUI window
        table.insert(gui.ap, {})
        local v = gui.ap[#gui.ap]

        v.button = Button.Create(gui.window)
        v.button:SetText(config[i].name)
        v.button:SetToggleable(true)
        v.button:SetTextPressedColor(Color.LightGreen)

        if config[i].setting then
            v.label = Label.Create(gui.window)
            v.slider = HorizontalSlider.Create(gui.window)
            v.slider:SetRange(config[i].min_setting, config[i].max_setting)
            v.slider:Subscribe("ValueChanged", function(args)
                config[i].setting = args:GetValue()
            end)

            if config[i].step then
                v.slider:SetClampToNotches(true)
                v.slider:SetNotchCount((config[i].max_setting - config[i].min_setting) / config[i].step)
            end

            v.inc = Button.Create(gui.window)
            v.dec = Button.Create(gui.window)
            v.inc:SetText("+")
            v.dec:SetText("-")
            v.inc:Subscribe("Press", function()
                if config[i].setting < config[i].max_setting then
                    config[i].setting = config[i].setting + (config[i].step or 1)
                end
            end)
            v.dec:Subscribe("Press", function()
                if config[i].setting > config[i].min_setting then
                    config[i].setting = config[i].setting - (config[i].step or 1)
                end
            end)

            v.quick = Button.Create(gui.window)
            v.quick:SetText(config[i].quick)

            table.insert(gui.st.ap, {})
            local k = #gui.st.ap
            local w = gui.st.ap[k]
            gui.st.ap[k] = Label.Create(gui.st.window)
            gui.st.ap[k]:SetText(config[i].name)
            gui.st.ap.gain[k] = TextBoxNumeric.Create(gui.st.window)
            gui.st.ap.gain[k]:SetNegativeAllowed(false)
            gui.st.ap.gain[k]:SetText(tostring(config[i].gain))
            gui.st.ap.gain[k]:Subscribe("TextChanged", function() config[i].gain = tonumber(gui.st.ap.gain[k]:GetText()) or 0 end)
            if config[i].input then
                gui.st.ap.input[k] = TextBoxNumeric.Create(gui.st.window)
                gui.st.ap.input[k]:SetNegativeAllowed(false)
                gui.st.ap.input[k]:SetText(tostring(config[i].input))
                gui.st.ap.input[k]:Subscribe("TextChanged", function() config[i].input = tonumber(gui.st.ap.input[k]:GetText()) or 0 end)
            end
        end
    end

    gui.ap[1].button:Subscribe("ToggleOn", self, self.AutopilotOn)
    gui.ap[2].button:Subscribe("ToggleOn", self, self.RollHoldOn)
    gui.ap[3].button:Subscribe("ToggleOn", self, self.PitchHoldOn)
    gui.ap[4].button:Subscribe("ToggleOn", self, self.HeadingHoldOn)
    gui.ap[5].button:Subscribe("ToggleOn", self, self.AlitudeHoldOn)
    gui.ap[6].button:Subscribe("ToggleOn", self, self.SpeedHoldOn)
    gui.ap[7].button:Subscribe("ToggleOn", self, self.WaypointHoldOn)
    gui.ap[8].button:Subscribe("ToggleOn", self, self.ApproachHoldOn)
    gui.ap[9].button:Subscribe("ToggleOn", self, self.TargetHoldOn)
    gui.ap[10].button:Subscribe("ToggleOn", self, self.SettingsOn)

    gui.ap[1].button:Subscribe("ToggleOff", self, self.AutopilotOff)
    gui.ap[2].button:Subscribe("ToggleOff", self, self.RollHoldOff)
    gui.ap[3].button:Subscribe("ToggleOff", self, self.PitchHoldOff)
    gui.ap[4].button:Subscribe("ToggleOff", self, self.HeadingHoldOff)
    gui.ap[5].button:Subscribe("ToggleOff", self, self.AltitudeHoldOff)
    gui.ap[6].button:Subscribe("ToggleOff", self, self.SpeedHoldOff)
    gui.ap[7].button:Subscribe("ToggleOff", self, self.WaypointHoldOff)
    gui.ap[8].button:Subscribe("ToggleOff", self, self.ApproachHoldOff)
    gui.ap[9].button:Subscribe("ToggleOff", self, self.TargetHoldOff)
    gui.ap[10].button:Subscribe("ToggleOff", self, self.SettingsOff)

    gui.ap[2].quick:Subscribe("Press", self, self.RollHoldQuick)
    gui.ap[3].quick:Subscribe("Press", self, self.PitchHoldQuick)
    gui.ap[4].quick:Subscribe("Press", self, self.HeadingHoldQuick)
    gui.ap[5].quick:Subscribe("Press", self, self.AltitudeHoldQuick)
    gui.ap[6].quick:Subscribe("Press", self, self.SpeedHoldQuick)

    gui.window:Subscribe("Render", self, self.WindowUpdate)
    gui.window:Subscribe("Resize", self, self.WindowResize)
    gui.window:Subscribe("WindowClosed", self, self.Close)
    gui.st.window:Subscribe("Resize", self, self.WindowResize)

    self.gui = gui
end

function Autopilot:KeyDown(args)
    if args.key == VirtualKey.Escape then
        self.gui.window:SetVisible(false)
        self:SettingsOff()
        Mouse:SetVisible(false)
    end
end

function Autopilot:RollHoldQuick()
    config[2].setting = 0
    self:RollHoldOn()
end

function Autopilot:PitchHoldQuick()
    config[3].setting = 0
    self:PitchHoldOn()
end

function Autopilot:HeadingHoldQuick()
    config[4].setting = self.vehicle:GetHeading()
    self:HeadingHoldOn()
end

function Autopilot:AltitudeHoldQuick()
    config[5].setting = self.vehicle:GetAltitude()
    self:AlitudeHoldOn()
end

function Autopilot:SpeedHoldQuick()
    config[6].setting = planes[self.model].cruise_speed
    self:SpeedHoldOn()
end

function Autopilot:AutopilotOn()
    config[1].on = true
end

function Autopilot:RollHoldOn()
    if not self.scanning then
        self:AutopilotOn()
        config[2].on = true
    end
end

function Autopilot:PitchHoldOn()
    if not self.scanning then
        self:AutopilotOn()
        config[3].on = true
    end
end

function Autopilot:HeadingHoldOn()
    if not self.scanning then
        self:RollHoldOn()
        config[4].on = true
    end
end

function Autopilot:AlitudeHoldOn()
    if not self.scanning and not config[9].on then
        self:PitchHoldOn()
        config[5].on = true
    end
end

function Autopilot:SpeedHoldOn()
    if not self.scanning then
        self:AutopilotOn()
        config[6].on = true
    end
end

function Autopilot:WaypointHoldOn()
    local waypoint, marker = Waypoint:GetPosition()

    if marker then
        self:ApproachHoldOff()
        self:TargetHoldOff()
        self:HeadingHoldOn()
        config[7].on = true
    else
        Events:Fire("CastCenterText", {text = "Точку не поставил", time = 4, color = Color.LightGreen})
        return
    end
end

function Autopilot:ApproachHoldOn()
    self:AutopilotOn()
    self:SpeedHoldOff()
    self:WaypointHoldOff()
    self:TargetHoldOff()
    config[8].on = true
    self.scanning = true
    self.approach_timer = Timer()
    Events:Fire("CastCenterText", {text = "Сканирование взлетно-посадочных полос…", time = 4, color = Color.LightGreen})
    return
end

function Autopilot:TargetHoldOn()
    self:AutopilotOn()
    self:SpeedHoldOff()
    self:WaypointHoldOff()
    self:ApproachHoldOff()
    config[9].on = true
    self.scanning = true
    self.target_timer = Timer()
    Events:Fire("CastCenterText", {text = "Сканирование целей…", time = 4, color = Color.LightGreen})
    return
end

function Autopilot:SettingsOn()
    self:WindowResize()
    config[10].on = true
    self.gui.st.window:SetVisible(true)
end

function Autopilot:AutopilotOff()
    self:ApproachHoldOff()
    self:TargetHoldOff()
    self:AltitudeHoldOff()
    self:WaypointHoldOff()
    self:HeadingHoldOff()
    self:PitchHoldOff()
    self:RollHoldOff()
    self:SpeedHoldOff()
    config[1].on = false
end

function Autopilot:RollHoldOff()
    if not (config[7].on or config[4].on) then
        config[2].on = false
    end
end

function Autopilot:PitchHoldOff()
    if not (config[5].on or config[9].on or config[8].on) then
        config[3].on = false
    end
end

function Autopilot:HeadingHoldOff()
    if not (config[7].on or config[9].on or config[8].on) then
        config[4].on = false
        self:RollHoldOff()
    end
end

function Autopilot:AltitudeHoldOff()
    if not config[8].on then
        config[5].on = false
        self:PitchHoldOff()
    end
end

function Autopilot:SpeedHoldOff()
    if not (config[9].on or config[8].on) then
        config[6].on = false
    end
end

function Autopilot:WaypointHoldOff()
    if config[7].on then
        config[7].on = false
        if not config[8].on then
            self:HeadingHoldOff()
        end
    end
end

function Autopilot:ApproachHoldOff()
    if config[8].on then
        config[8].on = false
        self.scanning = nil
        self.approach = nil
        self.flare = nil
        if not config[7].on then
            self:HeadingHoldOff()
        end
        self:AltitudeHoldOff()
        self:SpeedHoldOff()
    end
end

function Autopilot:TargetHoldOff()
    if config[9].on then
        config[9].on = false
        self.scanning = nil
        self.target = nil
        self:HeadingHoldOff()
        self:PitchHoldOff()
        self:SpeedHoldOff()
    end
end

function Autopilot:SettingsOff()
    config[10].on = false
    self.gui.st.window:SetVisible(false)
end

function Autopilot:PanelOpen(args)
    if LocalPlayer:GetWorld() ~= DefaultWorld then
        return
    end
    if self.twoKeys then
        if args.key == self.expectedKey and self.vehicle then
            self.gui.window:SetVisible(not self.gui.window:GetVisible())
            self:SettingsOff()
        end
        if args.key == string.byte(self.mouseToggleButton) and self.vehicle then
            Mouse:SetVisible(not Mouse:GetVisible())
        end
    else
        if args.key == self.expectedKey and self.vehicle then
            self.gui.window:SetVisible(not self.gui.window:GetVisible())
            self:SettingsOff()
            Mouse:SetVisible(self.gui.window:GetVisible())

            local effect = ClientEffect.Play(AssetLocation.Game, {
                effect_id = self.gui.window:GetVisible() and 382 or 383,

                position = Camera:GetPosition(),
                angle = Angle()
            })
        end
    end
end

function Autopilot:Close()
    self.gui.window:SetVisible(not self.gui.window:GetVisible())
    self:SettingsOff()
    Mouse:SetVisible(self.gui.window:GetVisible())

    local effect = ClientEffect.Play(AssetLocation.Game, {
        effect_id = self.gui.window:GetVisible() and 382 or 383,

        position = Camera:GetPosition(),
        angle = Angle()
    })
end

function Autopilot:InputBlock(args) -- Subscribed to LocalPlayerInput
    local i = args.input

    if Mouse:GetVisible() then
        if i == 3 or i == 4 or i == 5 or i == 6 or i == 138 or i == 139 then
            return false
        end
    end

    if config[2].on then
        if i == 60 or i == 61 then
            return false
        end
    end

    if config[3].on then
        if i == 58 or i == 59 then
            return false
        end
    end

    if config[6].on then
        if i == 64 or i == 65 then
            return false
        end
    end
end

function Autopilot:ResolutionChange() -- Subscribe to ResolutionChange
    local gui = self.gui

    gui.window:SetSizeRel(gui.size)
    gui.window:SetPositionRel(gui.position)
    gui.st.window:SetSize(gui.window:GetSize())
    gui.st.window:SetPosition(gui.window:GetPosition() + Vector2(0, gui.window:GetHeight()))
    self:WindowResize()
end

function Autopilot:WindowResize() -- Subscribed to ModuleLoad and Window Resize
    local gui = self.gui
    local window_size = self.gui.window:GetSize()
    local text_size = window_size:Length() * self.text_scale

    for i = 1, 6 do
        gui.ap[i].button:SetPositionRel(gui.button_position * (i - 1))
    end

    gui.ap[7].button:SetPositionRel(gui.button_position * 7)
    gui.ap[8].button:SetPositionRel(Vector2(gui.button_position.x + gui.button_size.x * 1.05, gui.button_position.y * 7))
    gui.ap[9].button:SetPositionRel(Vector2(gui.button_position.x + gui.button_size.x * 2.10, gui.button_position.y * 7))
    gui.ap[10].button:SetPositionRel(Vector2(gui.button_position.x + gui.button_size.x * 3.41, gui.button_position.y * 7))

    gui.line:SetPositionRel(gui.button_position * 6.35)
    gui.line:SetSizeRel(Vector2(window_size.x, gui.button_size.y * 0.2))

    for i, v in pairs(gui.ap) do
        v.button:SetSizeRel(gui.button_size)
        v.button:SetTextSize(text_size)

        if config[i].setting then
            v.label:SetSizeRel(gui.label_size)
            v.label:SetTextSize(text_size)
            v.label:SetPositionRel(v.button:GetPositionRel() + Vector2(v.button:GetWidthRel() * 1.06, v.button:GetHeightRel() * 0.2))

            v.slider:SetSizeRel(gui.slider_size)
            v.slider:SetPositionRel(v.label:GetPositionRel() + Vector2(v.label:GetWidthRel(), v.label:GetHeightRel() * -0.3))

            v.dec:SetSizeRel(Vector2(gui.button_size.x / 3.5, gui.button_size.y))
            v.dec:SetTextSize(text_size)
            v.dec:SetPositionRel(v.button:GetPositionRel() + Vector2(v.button:GetWidthRel() * 3.2, 0))

            v.inc:SetSizeRel(Vector2(gui.button_size.x / 3.5, gui.button_size.y))
            v.inc:SetTextSize(text_size)
            v.inc:SetPositionRel(v.dec:GetPositionRel() + Vector2(0.065, 0))

            v.quick:SetSizeRel(Vector2(gui.button_size.x / 1.5, gui.button_size.y))
            v.quick:SetTextSize(text_size)
            v.quick:SetPositionRel(v.inc:GetPositionRel() + Vector2(0.065, 0))
        end
    end

    local column1 = 0.03
    local column2 = 0.25
    local column3 = 0.50
    local column4 = 0.72
    local column5 = 0.85

    gui.st.window:SetSize(window_size)
    gui.st.window:SetPosition(gui.window:GetPosition() + Vector2(0, gui.window:GetHeight()))

    gui.st.distance.label:SetPositionRel(Vector2(column1, 0.08))
    gui.st.distance.label:SetTextSize(text_size)
    gui.st.distance.label:SizeToContents()
    for i, v in ipairs(gui.st.distance) do
        v:SetPositionRel(Vector2(column1, 0.2 + (i - 1) * 0.1))
        v:GetLabel():SetTextSize(text_size)
        v:GetLabel():SizeToContents()
    end

    gui.st.speed.label:SetPositionRel(Vector2(column2, 0.08))
    gui.st.speed.label:SetTextSize(text_size)
    gui.st.speed.label:SizeToContents()
    for i, v in ipairs(gui.st.speed) do
        v:SetPositionRel(Vector2(column2, 0.2 + (i - 1) * 0.1))
        v:GetLabel():SetTextSize(text_size)
        v:GetLabel():SizeToContents()
    end

    for i, v in ipairs(gui.st.ap) do
        v:SetPositionRel(Vector2(column3, 0.2 + (i - 1) * 0.1 + 0.02))
        v:SetTextSize(text_size)
        v:SizeToContents()
    end

    gui.st.ap.gain.label:SetPositionRel(Vector2(column4, 0.08))
    gui.st.ap.gain.label:SetTextSize(text_size)
    gui.st.ap.gain.label:SizeToContents()

    for i, v in ipairs(gui.st.ap.gain) do
        v:SetPositionRel(Vector2(column4, 0.2 + (i - 1) * 0.1))
        v:SetTextSize(text_size)
        v:SetWidth(text_size * 3)
        v:SetHeight(text_size * 1.5)
    end

    gui.st.ap.input.label:SetPositionRel(Vector2(column5, 0.08))
    gui.st.ap.input.label:SetTextSize(text_size)
    gui.st.ap.input.label:SizeToContents()

    for i, v in pairs(gui.st.ap.input) do
        if type(i) == "number" then
            v:SetPositionRel(Vector2(column5, 0.2 + (i - 1) * 0.1))
            v:SetTextSize(text_size)
            v:SetWidth(text_size * 3)
            v:SetHeight(text_size * 1.5)
        end
    end

    self.text_size = text_size
end

function Autopilot:WindowUpdate() -- Subscribed to Window Render
    for k, v in pairs(self.gui.ap) do
        v.button:SetToggleState(config[k].on)

        if config[k].setting then
            v.label:SetText(string.format("%i%s", config[k].setting * units[config[k].units][settings[config[k].units]][2], units[config[k].units][settings[config[k].units]][1]))
            v.slider:SetValue(config[k].setting)
        end
    end
end

function Autopilot:EnterPlane(args)
    if args.is_driver then
        if args.vehicle:GetClass() == VehicleClass.Air then
            local model = args.vehicle:GetModelId()

            if planes[model] and planes[model].available then
                self:AutopilotOff()
                self.vehicle = args.vehicle
                self.model = model

                if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.InputBlock) end
                if not self.InputPollEvent then self.InputPollEvent = Events:Subscribe("InputPoll", self, self.Input) end
                if not self.KeyUpEvent then self.KeyUpEvent = Events:Subscribe("KeyUp", self, self.PanelOpen) end
                if not self.KeyDownEvent then self.KeyDownEvent = Events:Subscribe("KeyDown", self, self.KeyDown) end
                if not self.GameRenderEvent then self.GameRenderEvent = Events:Subscribe("GameRender", self, self.DrawApproach) end
                if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end

                if self.fadeOutAnimation then Animation:Stop(self.fadeOutAnimation) self.fadeOutAnimation = nil end

                Animation:Play(0, 1, 0.15, easeIOnut, function(value) self.animationValue = value end)

                if not self.hinttimer then
                    self.hinttimer = Timer()
                else
                    self.hinttimer:Restart()
                end
            end
        end
    end
end

function Autopilot:ExitPlane()
    if self.vehicle then
        self:Disable()

        if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
        if self.InputPollEvent then Events:Unsubscribe(self.InputPollEvent) self.InputPollEvent = nil end
        if self.KeyUpEvent then Events:Unsubscribe(self.KeyUpEvent) self.KeyUpEvent = nil end
        if self.KeyDownEvent then Events:Unsubscribe(self.KeyDownEvent) self.KeyDownEvent = nil end
        if self.GameRenderEvent then Events:Unsubscribe(self.GameRenderEvent) self.GameRenderEvent = nil end

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
end

function Autopilot:PlaneDespawn(args)
    if args.entity.__type == "Vehicle" and self.vehicle and self.vehicle == args.entity then
        self:Disable()
    end
end

function Autopilot:Disable()
    self:AutopilotOff()
    self.vehicle = nil
    self.model = nil
    self.gui.window:SetVisible(false)
    self.gui.st.window:SetVisible(false)
    Mouse:SetVisible(false)
end

function Autopilot:Input() -- Subscribed to InputPoll
    if Game:GetState() ~= GUIState.Game or not IsValid(self.vehicle) then return end

    for i = 2, 9 do
        if config[i].on then
            if i == 2 then
                self:RollHold()
            elseif i == 3 then
                self:PitchHold()
            elseif i == 4 then
                self:HeadingHold()
            elseif i == 5 then
                self:AltitudeHold()
            elseif i == 6 then
                self:SpeedHold()
            elseif i == 7 then
                self:WaypointHold()
            elseif i == 8 then
                self:ApproachHold()
            elseif i == 9 then
                self:TargetHold()
            end
        end
    end
end

function Autopilot:RollHold()
    local roll = self.vehicle:GetRoll()

    local input = abs(roll - config[2].setting) * config[2].gain
    if input > config[2].input then
        input = config[2].input
    end

    if config[2].setting < roll then
        Input:SetValue(Action.PlaneTurnRight, input)
    elseif config[2].setting > roll then
        Input:SetValue(Action.PlaneTurnLeft, input)
    end
end

function Autopilot:PitchHold()
    local pitch = self.vehicle:GetPitch()

    local input = abs(pitch - config[3].setting) * config[3].gain
    if input > config[3].input then
        input = config[3].input
    end

    -- Deactivates if the plane is banked too far left or right.
    local abs_roll = abs(self.vehicle:GetRoll())

    if abs_roll < 60 then
        if config[3].setting > pitch then
            Input:SetValue(Action.PlanePitchUp, input)
        elseif config[3].setting < pitch then
            Input:SetValue(Action.PlanePitchDown, input)
        end
    elseif abs_roll > 120 then
        if config[3].setting > pitch then
            Input:SetValue(Action.PlanePitchDown, input)
        elseif config[3].setting < pitch then
            Input:SetValue(Action.PlanePitchUp, input)
        end
    end
end

function Autopilot:HeadingHold()
    local heading = self.vehicle:GetHeading()

    config[2].setting = DegreesDifference(config[4].setting, heading) * config[4].gain

    if config[2].setting > config[4].input then
        config[2].setting = config[4].input
    elseif config[2].setting < -config[4].input then
        config[2].setting = -config[4].input
    end
end

function Autopilot:AltitudeHold()
    config[3].setting = (config[5].setting - self.vehicle:GetAltitude() + config[5].bias) * config[5].gain

    if config[3].setting > config[5].input then
        config[3].setting = config[5].input
    elseif config[3].setting < -config[5].input then
        config[3].setting = -config[5].input
    end
end

function Autopilot:SpeedHold()
    local air_speed = self.vehicle:GetAirSpeed()

    local input = abs(air_speed - config[6].setting) * config[6].gain
    if input > config[6].input then
        input = config[6].input
    end

    if air_speed < config[6].setting and not config[8].on then
        Input:SetValue(Action.PlaneIncTrust, input)
    elseif air_speed > config[6].setting then
        Input:SetValue(Action.PlaneDecTrust, input)
    end
end

function Autopilot:WaypointHold()
    local waypoint, marker = Waypoint:GetPosition()
    if not marker then return self:WaypointHoldOff() end
    self:FollowTargetXZ(waypoint)
end

function Autopilot:ApproachHold()
    if not self.approach and self.approach_timer:GetMilliseconds() > 1000 then
        local position = self.vehicle:GetPosition()
        local runway_name
        local runway_direction
        local airport_name
        local nearest_marker
        local nearest_marker_distance = huge

        for airport, runways in pairs(airports) do
            for runway in pairs(runways) do
                local near_marker = airports[airport][runway].near_marker
                local far_marker = airports[airport][runway].far_marker
                local distance = Vector3.DistanceSqr(position, near_marker)

                if distance < airports[airport][runway].glide_length ^ 2 and distance < nearest_marker_distance then
                    if deg(acos(Vector3.Dot(self.vehicle:GetAngle() * Vector3.Forward, (near_marker - position):Normalized()))) < 0.5 * planes[self.model].cone_angle then
                        if deg(acos(Vector3.Dot(Angle(atan2(far_marker.x - near_marker.x, far_marker.z - near_marker.z), rad(airports[airport][runway].glide_pitch), 0) * Vector3.Forward, (position - near_marker):Normalized()))) < 0.5 * airports[airport][runway].cone_angle then
                            nearest_marker_distance = distance
                            nearest_marker = near_marker
                            airport_name = airport
                            runway_name = runway
                            runway_direction = YawToHeading(deg(atan2(far_marker.x - near_marker.x, far_marker.z - near_marker.z)))
                        end
                    end
                end
            end
        end

        if nearest_marker then
            self.scanning = nil
            self:HeadingHoldOn()
            self:AlitudeHoldOn()
            self:SpeedHoldOn()
            Events:Fire("CastCenterText", {text = "Подход к " .. airport_name .. " RWY" .. runway_name .. " установке.", time = 4, color = Color.LightGreen})
            self.approach = {
                near_marker = airports[airport_name][runway_name].near_marker,
                far_marker = airports[airport_name][runway_name].far_marker,
                angle = Angle(rad(HeadingToYaw(runway_direction)), rad(airports[airport_name][runway_name].glide_pitch), 0),
                sweep_yaw = Angle(rad(airports[airport_name][runway_name].cone_angle / 2), 0, 0),
                glide_length = airports[airport_name][runway_name].glide_length
            }
            self.flare = nil
            return
        end

        self.approach_timer:Restart()
    end

    local approach = self.approach

    if approach then
        local position = self.vehicle:GetPosition()

        if not self.flare then
            local distance = Vector3.Distance(approach.near_marker, position)
            if distance > planes[self.model].flare_distance then
                approach.farpoint = approach.near_marker + approach.angle * Vector3.Forward * distance
                config[5].setting = approach.farpoint.y - 200 - config[5].bias
                config[6].setting = min(lerp(planes[self.model].landing_speed, planes[self.model].cruise_speed, distance / planes[self.model].slow_distance), planes[self.model].cruise_speed)
                approach.target = lerp(approach.near_marker, approach.farpoint, 0.5)
                self:FollowTargetXZ(approach.target)
            else
                self.flare = true
                self:AltitudeHoldOff()
                self:PitchHoldOn()
                approach.target = approach.far_marker
                config[3].setting = planes[self.model].flare_pitch
                config[6].setting = planes[self.model].landing_speed
            end
        else
            local distance = Vector3.Distance(approach.far_marker, position)
            local length = Vector3.Distance(approach.far_marker, approach.near_marker)
            config[6].setting = min(lerp(0, planes[self.model].landing_speed, distance / length), planes[self.model].landing_speed)
            self:FollowTargetXZ(approach.target)
        end
    end
end

function Autopilot:DrawApproach() -- Subscribed to GameRender
    if config[8].on and self.drawApproach then
        local approach = self.approach

        if approach then
            Render:DrawLine(approach.near_marker, approach.near_marker + approach.angle * Vector3.Forward * approach.glide_length, Color.LightGreen)
            Render:DrawLine(approach.near_marker, approach.near_marker + approach.angle * approach.sweep_yaw * Vector3.Forward * approach.glide_length, Color.Cyan)
            Render:DrawLine(approach.near_marker, approach.near_marker + approach.angle * -approach.sweep_yaw * Vector3.Forward * self.approach.glide_length, Color.Cyan)
        end
    end
end

function Autopilot:TargetHold()
    if not self.target and self.target_timer:GetMilliseconds() > 1000 then
        local vehicle = self.vehicle
        local position = vehicle:GetPosition()
        local nearest_target = nil
        local nearest_target_distance = huge
        local vehicles = Client:GetVehicles()

        for target in vehicles do
            if IsValid(target) and target:GetClass() == VehicleClass.Air and target ~= vehicle and
                target:GetDriver() then
                local target_position = target:GetPosition()
                local target_distance = Vector3.DistanceSqr(position, target_position)

                if target_distance < nearest_target_distance then
                    if deg(acos(Vector3.Dot(vehicle:GetAngle() * Vector3.Forward, (target_position - position):Normalized()))) < 0.5 * planes[self.model].cone_angle then
                        nearest_target = target
                        nearest_target_distance = target_distance
                    end
                end
            end
        end

        if nearest_target then
            self.scanning = nil
            Events:Fire("CastCenterText", {text = "Цель: " .. tostring(nearest_target:GetDriver()), time = 4, color = Color.LightGreen})
            self.target = {vehicle = nearest_target, follow_distance = 100}
            self:SpeedHoldOn()
            self:HeadingHoldOn()
            self:PitchHoldOn()
        end

        self.target_timer:Restart()
    end

    local target = self.target

    if target then
        if not IsValid(target.vehicle) or not target.vehicle:GetDriver() then
            Events:Fire("CastCenterText", {text = "Цель потеряна!", time = 4, color = Color.LightGreen})
            return self:TargetHoldOff()
        end

        target.position = target.vehicle:GetPosition()
        target.distance = Vector3.Distance(target.position, LocalPlayer:GetPosition())
        local bias = target.distance / target.follow_distance

        config[6].setting = clamp(bias * target.vehicle:GetLinearVelocity():Length() * 3.6, config[6].min_setting, config[6].max_setting)

        self:FollowTargetXZ(target.position)
        self:FollowTargetY(target.position)
    end
end

function Autopilot:Render()
    local hinttimer = self.hinttimer

    if hinttimer and hinttimer:GetSeconds() >= 7 then
        self.fadeOutAnimation = Animation:Play(self.animationValue, 0, 0.15, easeIOnut, function(value) self.animationValue = value end, function() self.animationValue = nil end)

        self.hinttimer = nil
    end

    if Game:GetState() ~= GUIState.Game then return end

    if config[9].on and self.drawTarget then
        local target = self.target

        if target and IsValid(target.vehicle) then
            Render:SetFont(AssetLocation.Disk, "Roboto.ttf")

            local name = target.vehicle:GetName()
            local model = target.vehicle:GetModelId()
            local center = Render:WorldToScreen(target.position + target.vehicle:GetAngle() * Vector3.Up * 2)

            local n = Render.Height * self.text_scale
            local m = 0.75 * n
            local color = Color.LightGreen

            Render:DrawLine(center + Vector2(-n, -m), center + Vector2(-n, m), color)
            Render:DrawLine(center + Vector2(-m, n), center + Vector2(m, n), color)
            Render:DrawLine(center + Vector2(n, m), center + Vector2(n, -m), color)
            Render:DrawLine(center + Vector2(m, -n), center + Vector2(-m, -n), color)

            local distance_string = string.format("%i%s", target.distance * units.distance[settings.distance][2], units.distance[settings.distance][1])
            Render:DrawText(center + Vector2(n * 1.25, -0.3 * Render:GetTextHeight(distance_string, 1.2 * self.text_size)), distance_string, color, 1.2 * self.text_size)
        end
    end

    if LocalPlayer:GetValue("HiddenHUD") then return end
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    local animationValue = self.animationValue

    if not animationValue then return end

    if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

    local boost = LocalPlayer:GetValue("Boost")
    local text = self.namept
    local textSize = 14
    local size = Render:GetTextSize(text, textSize)
    local pos = Vector2((Render.Width - size.x) / 2, math.lerp(boost and (Render.Height - size.y - 10) or Render.Height, Render.Height - size.y - (boost and 17 + size.y or 10), animationValue))
    local alpha = math.lerp(0, 255, animationValue)

    Render:DrawShadowedText(pos, text, Color(255, 255, 255, alpha), Color(0, 0, 0, alpha), textSize)
end

function Autopilot:FollowTargetXZ(target_position) -- Heading-hold must be on
    local position = self.vehicle:GetPosition()
    local dx = position.x - target_position.x
    local dz = position.z - target_position.z
    config[4].setting = YawToHeading(deg(atan2(dx, dz)))
end

function Autopilot:FollowTargetY(target_position) -- Pitch-hold must be on
    local position = self.vehicle:GetPosition()
    local dy = position.y - target_position.y
    local distance = Vector3.Distance(position, target_position)
    config[3].setting = deg(asin(-dy / distance))
end

autopilot = Autopilot()