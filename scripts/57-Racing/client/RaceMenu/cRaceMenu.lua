class("RaceMenu")

-- Static constants

RaceMenu.command = "/racemenu"

RaceMenu.requestLimitSeconds = 3.5
RaceMenu.requestLimitCount = 5

-- Helps with requesting courses and votes only once.
RaceMenu.cache = {}

RaceMenu.allowedActions = {
	Action.Accelerate ,
	Action.Reverse ,
	Action.TurnLeft ,
	Action.TurnRight ,
	Action.HeliForward ,
	Action.HeliBackward ,
	Action.HeliRollLeft ,
	Action.HeliRollRight ,
	Action.HeliIncAltitude ,
	Action.HeliDecAltitude ,
	Action.PlaneIncTrust ,
	Action.PlaneDecTrust ,
	Action.PlanePitchUp ,
	Action.PlanePitchDown ,
	Action.PlaneTurnLeft ,
	Action.PlaneTurnRight ,
	Action.MoveForward ,
	Action.MoveBackward ,
	Action.MoveLeft ,
	Action.MoveRight ,
	Action.ParachuteOpenClose ,
	Action.Jump ,
}

RaceMenu.groupBoxColor = Color.FromHSV(150, 0.06, 0.775)

-- Static functions

RaceMenu.CreateGroupBox = function(...)
    local groupBox = GroupBox.Create(...)
    groupBox:SetMargin(Vector2(4, 7), Vector2(4, 4))
    groupBox:SetPadding(Vector2(1, 7), Vector2(1, 3))
    groupBox:SetTextColor(RaceMenu.groupBoxColor)
    groupBox:SetTextSize(24)

    return groupBox
end

-- Instance functions

function RaceMenu:__init()
    EGUSM.SubscribeUtility.__init(self)
    TabManager.__init(self)

    RaceMenu.instance = self

    self.size = Vector2(736, 472)
    self.isEnabled = false
    -- These two help with limiting network requests. Used in PostTick.
    self.requestTimers = {}
    self.requests = {}
    self.addonArea = nil

    self:CreateWindow()
    self:AddTab(HomeTab)
    self:AddTab(SettingsTab)
    self:AddTab(StatsTab)

    self:EventSubscribe("ControlDown")
    self:EventSubscribe("LocalPlayerInput")
    self:EventSubscribe("LocalPlayerChat")
    self:EventSubscribe("PostTick")
    Events:Subscribe("EnableRaceMenu", self, self.EventActivate)
end

function RaceMenu:CreateWindow()
    self.window = Window.Create("RaceMenu")
    self.window:SetTitle("▧ Гонки")
    self.window:SetSize(self.size)
    self.window:SetPosition(Render.Size / 2 - self.size / 2) -- Center of screen.
    self.window:SetVisible(self.isEnabled)
    self.window:Subscribe("WindowClosed", self, self.WindowClosed)

    self:CreateTabControl(self.window)
    self.tabControl:SetDock(GwenPosition.Fill)
end

function RaceMenu:SetEnabled(enabled)
    if self.isEnabled == enabled then return end

    self.isEnabled = enabled

    self.window:SetVisible(self.isEnabled)

    if self.isEnabled then
        self:ActivateCurrentTab()
        self.window:BringToFront()

        Events:Fire("RaceMenuOpened")
    else
        self:DeactivateCurrentTab()

        Events:Fire("RaceMenuClosed")
    end

    local effect = ClientEffect.Play(AssetLocation.Game, {
        effect_id = self.isEnabled and 382 or 383,

        position = Camera:GetPosition(),
        angle = Angle()
    })

    Mouse:SetVisible(self.isEnabled)
end

function RaceMenu:AddRequest(networkName, arg)
    if arg == nil then arg = "." end

    table.insert(self.requests, {networkName, arg})
end

-- Gwen events

function RaceMenu:WindowClosed()
    self:SetEnabled(false)
end

-- Events

function RaceMenu:ControlDown(control)
    if control.name == "Открыть меню гонок" and inputSuspensionValue == 0 then
        self:SetEnabled(not self.isEnabled)
    end
end

function RaceMenu:LocalPlayerInput(args)
    if self.isEnabled == false then
        return true
    end

    if inputSuspensionValue > 0 then
        return false
    end

    for index, action in ipairs(RaceMenu.allowedActions) do
        if args.input == action then
            return true
        end
    end

    if self.isEnabled then
        if args.input == Action.GuiPause then
            self:SetEnabled(false)
        end
    end

    return false
end

function RaceMenu:LocalPlayerChat(args)
    if args.text:lower() == "/" .. settings.command then
        self:SetEnabled(not self.isEnabled)
        return false
    end

    return true
end

function RaceMenu:PostTick()
    -- Force the mouse to be visible if we're visible.
    if self.isEnabled then
        Mouse:SetVisible(true)
    end

    -- Process network requests.
    if #self.requests > 0 then
        -- Expire any old timers.
        for n = #self.requestTimers, 1, -1 do
            if self.requestTimers[n]:GetSeconds() > RaceMenu.requestLimitSeconds then
                table.remove(self.requestTimers, n)
            end
        end

        if #self.requestTimers >= RaceMenu.requestLimitCount then return end

        table.insert(self.requestTimers, Timer())

        local request = self.requests[1]
        Network:Send(request[1], request[2])

        table.remove(self.requests, 1)
    end
end

function RaceMenu:EventActivate()
    self:SetEnabled(not self.isEnabled)
end