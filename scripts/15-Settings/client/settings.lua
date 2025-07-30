class 'Settings'

function Settings:__init()
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
        [16] = true,
        [114] = true,
        [115] = true,
        [117] = true,
        [51] = true,
        [52] = true,
        [116] = true
    }

    self.permissions = {
        ["Creator"] = true,
        ["GlAdmin"] = true,
        ["Admin"] = true,
        ["AdminD"] = true,
        ["ModerD"] = true,
        ["Organizer"] = true,
        ["Parther"] = true,
        ["VIP"] = true
    }

    self.debug_permissions = {
        ["Creator"] = true,
        ["GlAdmin"] = true
    }

    self.SkyImage2 = Image.Create(AssetLocation.Resource, "Sky2")
    self.SkyImage3 = Image.Create(AssetLocation.Resource, "Sky3")
    self.SkyImage5 = Image.Create(AssetLocation.Resource, "Sky5")
    self.SkyImage6 = Image.Create(AssetLocation.Resource, "Sky6")
    self.SkyImage7 = Image.Create(AssetLocation.Resource, "Sky6")

    self.AnimeImage1 = Image.Create(AssetLocation.Resource, "Anime1")
    self.AnimeImage2 = Image.Create(AssetLocation.Resource, "Anime2")

    self.actvCH = LocalPlayer:GetValue("CustomCrosshair")
    self.actvSn = false

    self.aim = true

    self.textSize = 15
    self.textSize2 = self.textSize - 1

    self:Lang(LocalPlayer:GetValue("Lang") or "RU")

    self.bindMenu = BindMenu.Create(self.locStrings)
    self.bindMenu:SetVisible(false)
    self.binds = {
        {id = "ServerMenu", key = "B", loc = "servermenu"},
        {id = "ActionsMenu", key = "V", loc = "actionsmenu"},
        {id = "QuickTP", key = "J", loc = "quicktpmenu"},
        {id = "PlayersList", key = "F5", loc = "playerslist"},
        {id = "ServerMap", key = "F2", loc = "servermap"},
        {id = "Wingsuit", key = "Q", loc = "option18"},
        {id = "TuningMenu", key = "N", loc = "tuningmenu"},
        {id = "Freecam", key = "O", loc = "freecam"},
        {id = "OpenGates", key = "L", loc = "opengates"},
        {id = "FirstPerson", key = "F6", loc = "firstperson"},
        {id = "ToggleVehicleRadio", key = "OemPeriod", loc = "toggleradio"},
        {id = "VehicleJump", key = "Tab", loc = "option25"},
        {id = "VehicleLandBoost", key = "Shift", loc = "vehiclelandboost"},
        {id = "VehiclePlaneBoost", key = "Q", loc = "vehicleplaneboost"},
        {id = "VehicleBrake", key = "F", loc = "vehiclebrake"},
        {id = "VerticalTakeoff", key = "Z", loc = "verticaltakeoff"},
        {id = "AutopilotMenu", key = "R", loc = "autopilotmenu"},
        {id = "Respawn", key = "R", loc = "respawn"},
        {id = "ToggleServerUI", key = "F11", loc = "toggleserverui"},
        {id = "VehicleTricks", key = "Y", loc = "vehicletricks"}
    }

    self.bindControls = {}

    for _, bind in ipairs(self.binds) do
        self.bindControls[bind.id] = self.bindMenu:AddControl(bind.id, bind.key)
    end

    self.bindMenu:RequestSettings()

    self:UpdateKeyBinds()

    Network:Subscribe("ResetDone", self, self.ResetDone)
    Network:Subscribe("UpdateStats", self, self.UpdateStats)
    Network:Subscribe("UpdatePromocodes", self, self.UpdatePromocodes)

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("UpdateKeyBinds", self, self.UpdateKeyBinds)
    Events:Subscribe("LoadUI", self, self.LoadUI)
    Events:Subscribe("GameLoad", self, self.GameLoad)
    Events:Subscribe("GameRender", self, self.GameRender)
    Events:Subscribe("OpenSettingsMenu", self, self.OpenSettingsMenu)
    Events:Subscribe("CloseSettingsMenu", self, self.CloseSettingsMenu)
    Events:Subscribe("KeyUp", self, self.KeyUp)

    self:GameLoad()
end

function Settings:Lang(lang)
    self.locStrings = locStrings[lang]
end

function Settings:UpdateKeyBinds()
    local keyBinds = LocalPlayer:GetValue("KeyBinds")
    local toggleServerUIBind = keyBinds and keyBinds["ToggleServerUI"]
    local vehicleTricksBind = keyBinds and keyBinds["VehicleTricks"]

    self.expectedKey = toggleServerUIBind and toggleServerUIBind.type == "Key" and toggleServerUIBind.value or 122
    self.stringKey = toggleServerUIBind and toggleServerUIBind.type == "Key" and toggleServerUIBind.valueString or "F11"
    self.vehicleTricksStringKey = vehicleTricksBind and vehicleTricksBind.type == "Key" and vehicleTricksBind.valueString or "Y"
end

function Settings:LoadUI()
    self:GameLoad()
end

function Settings:CreateWindow()
    if self.window then return end

    local locStrings = self.locStrings

    self.window = Window.Create()
    self.window:SetSizeRel(Vector2(0.5, 0.5))
    self.window:SetMinimumSize(Vector2(680, 442))
    self.window:SetPositionRel(Vector2(0.73, 0.5) - self.window:GetSizeRel() / 2)
    self.window:SetTitle(locStrings["title"])
    self.window:Subscribe("WindowClosed", self, function() self:SetWindowVisible(false, true) end)

    local tab = TabControl.Create(self.window)
    tab:SetDock(GwenPosition.Fill)

    local widgets = BaseWindow.Create(self.window)
    tab:AddPage(locStrings["main"], widgets)

    local scroll_control = ScrollControl.Create(widgets)
    scroll_control:SetScrollable(false, true)
    scroll_control:SetDock(GwenPosition.Fill)
    scroll_control:SetMargin(Vector2(5, 5), Vector2(5, 5))

    local subcategory6 = Label.Create(scroll_control)
    subcategory6:SetDock(GwenPosition.Top)
    subcategory6:SetMargin(Vector2(0, 4), Vector2(0, 4))
    subcategory6:SetText(locStrings["subcategory6"])
    subcategory6:SizeToContents()

    local option1 = self:OptionCheckBox(scroll_control, locStrings["option1"], LocalPlayer:GetValue("ClockVisible") or false)
    option1:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 1, boolean = not LocalPlayer:GetValue("ClockVisible")}) end)

    local option2 = self:OptionCheckBox(scroll_control, locStrings["option2"], LocalPlayer:GetValue("ClockPendosFormat") or false)
    option2:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 2, boolean = not LocalPlayer:GetValue("ClockPendosFormat")}) end)

    local option3 = self:OptionCheckBox(scroll_control, locStrings["option3"], LocalPlayer:GetValue("PassiveModeVisible") or false)
    option3:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 4, boolean = not LocalPlayer:GetValue("PassiveModeVisible")}) end)
    option3:SetMargin(Vector2(0, 20), Vector2.Zero)

    self.option4 = self:OptionCheckBox(scroll_control, locStrings["option4"], LocalPlayer:GetValue("JesusModeVisible") or false)
    self.option4:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 5, boolean = not LocalPlayer:GetValue("JesusModeVisible")}) end)

    local option5 = self:OptionCheckBox(scroll_control, locStrings["option5"], LocalPlayer:GetValue("BestRecordVisible") or false)
    option5:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 3, boolean = not LocalPlayer:GetValue("BestRecordVisible")}) end)
    option5:SetMargin(Vector2(0, 20), Vector2.Zero)

    local option6 = self:OptionCheckBox(scroll_control, locStrings["option6"], LocalPlayer:GetValue("KillFeedVisible") or false)
    option6:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 6, boolean = not LocalPlayer:GetValue("KillFeedVisible")}) end)

    local option7 = self:OptionCheckBox(scroll_control, locStrings["option7"], LocalPlayer:GetValue("ChatTipsVisible") or false)
    option7:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 7, boolean = not LocalPlayer:GetValue("ChatTipsVisible")}) end)
    option7:SetMargin(Vector2(0, 20), Vector2.Zero)

    local option8 = self:OptionCheckBox(scroll_control, locStrings["option8"], LocalPlayer:GetValue("ChatBackgroundVisible") or false)
    option8:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 8, boolean = not LocalPlayer:GetValue("ChatBackgroundVisible")}) end)

    local option9 = self:OptionCheckBox(scroll_control, locStrings["option9"], LocalPlayer:GetValue("PlayersMarkersVisible") or false)
    option9:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 9, boolean = not LocalPlayer:GetValue("PlayersMarkersVisible")}) end)
    option9:SetMargin(Vector2(0, 20), Vector2.Zero)

    local option10 = self:OptionCheckBox(scroll_control, locStrings["option10"], LocalPlayer:GetValue("JobsMarkersVisible") or false)
    option10:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 10, boolean = not LocalPlayer:GetValue("JobsMarkersVisible")}) end)

    local option11 = self:OptionCheckBox(scroll_control, locStrings["option11"], self.aim)
    option11:GetCheckBox():Subscribe("CheckChanged", self, self.ToggleAim)
    option11:SetMargin(Vector2(0, 20), Vector2.Zero)

    local option12 = self:OptionCheckBox(scroll_control, locStrings["option12"], LocalPlayer:GetValue("CustomCrosshair") or false)
    option12:GetCheckBox():Subscribe("CheckChanged", function()
        self.actvCH = not LocalPlayer:GetValue("CustomCrosshair")
        self:GameLoad()
        Network:Send("UpdateParameters", {parameter = 11, boolean = not LocalPlayer:GetValue("CustomCrosshair")})
	end)

    local option13 = self:OptionCheckBox(scroll_control, locStrings["option13"], LocalPlayer:GetValue("LongerGrappleVisible") or false)
    option13:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 13, boolean = not LocalPlayer:GetValue("LongerGrappleVisible")}) end)

    local option15 = self:OptionCheckBox(scroll_control, locStrings["option15"], LocalPlayer:GetValue("JobsVisible") or false)
    option15:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 14, boolean = not LocalPlayer:GetValue("JobsVisible")}) end)
    option15:SetMargin(Vector2(0, 20), Vector2.Zero)

    local option24 = self:OptionCheckBox(scroll_control, locStrings["option24"], LocalPlayer:GetValue("OpenDoorsTipsVisible") or false)
    option24:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", { parameter = 20, boolean = not LocalPlayer:GetValue("OpenDoorsTipsVisible")}) end)

    local option14 = self:OptionCheckBox(scroll_control, locStrings["option14"], LocalPlayer:GetValue("JetHUD") or false)
    option14:GetCheckBox():Subscribe("CheckChanged", function() Events:Fire("JHudActive") Network:Send("UpdateParameters", {parameter = 12, boolean = not LocalPlayer:GetValue("JetHUD")}) end)
    option14:SetMargin(Vector2(0, 20), Vector2.Zero)

    local bkpanelsContainer = BaseWindow.Create(widgets)
    bkpanelsContainer:SetVisible(true)
    bkpanelsContainer:SetDock(GwenPosition.Right)
    bkpanelsContainer:SetWidth(310)

    local scroll_bkpanels = ScrollControl.Create(bkpanelsContainer)
    scroll_bkpanels:SetScrollable(false, true)
    scroll_bkpanels:SetDock(GwenPosition.Fill)
    scroll_bkpanels:SetMargin(Vector2(5, 0), Vector2(5, 0))

    self.hidetexttip = Label.Create(bkpanelsContainer)
    self.hidetexttip:SetDock(GwenPosition.Bottom)
    self.hidetexttip:SetMargin(Vector2(5, 5), Vector2(5, 4))

    self.hidetext = Label.Create(bkpanelsContainer)
    self.hidetext:SetVisible(LocalPlayer:GetValue("HiddenHUD") or false)
    self.hidetext:SetTextColor(Color.Yellow)
    self.hidetext:SetDock(GwenPosition.Bottom)
    self.hidetext:SetMargin(Vector2(5, 5), Vector2(5, 0))
    self.hidetext:SetText(locStrings["hidetext"])
    self.hidetext:SizeToContents()

    local textSize = self.textSize
    local textSize2 = self.textSize2

    local btnHeight = 30

    local button = Button.Create(scroll_bkpanels)
    button:SetHeight(btnHeight)
    button:SetText(locStrings["buttonBoost"])
    button:SetTextSize(textSize2)
    button:SetDock(GwenPosition.Top)
    button:SetMargin(Vector2(0, 3), Vector2(0, 3))
    button:Subscribe("Press", self, function() Events:Fire("BoostSettings") end)

    local button = Button.Create(scroll_bkpanels)
    button:SetHeight(btnHeight)
    button:SetText(locStrings["buttonSpeedo"])
    button:SetTextSize(textSize2)
    button:SetDock(GwenPosition.Top)
    button:SetMargin(Vector2(0, 3), Vector2(0, 3))
    button:Subscribe("Press", self, function() Events:Fire("OpenSpeedometerMenu") end)

    local button = Button.Create(scroll_bkpanels)
    button:SetHeight(btnHeight)
    button:SetText(locStrings["buttonSDS"])
    button:SetTextSize(textSize2)
    button:SetDock(GwenPosition.Top)
    button:SetMargin(Vector2(0, 3), Vector2(0, 3))
    button:Subscribe("Press", self, function() Events:Fire("OpenSkydivingStatsMenu") end)

    local button = Button.Create(scroll_bkpanels)
    button:SetHeight(btnHeight)
    button:SetText(locStrings["buttonTags"])
    button:SetTextSize(textSize2)
    button:SetDock(GwenPosition.Top)
    button:SetMargin(Vector2(0, 3), Vector2(0, 3))
    button:Subscribe("Press", self, function() Events:Fire("OpenNametagsMenu") end)

    local button = Button.Create(scroll_bkpanels)
    button:SetHeight(btnHeight)
    button:SetText(locStrings["buttonChatSett"])
    button:SetTextSize(textSize2)
    button:SetDock(GwenPosition.Top)
    button:SetMargin(Vector2(0, 3), Vector2(0, 3))
    button:Subscribe("Press", self, function() Events:Fire("OpenChatMenu") self:SetWindowVisible(false, true) end)

    local subcategory = Label.Create(scroll_bkpanels)
    subcategory:SetDock(GwenPosition.Top)
    subcategory:SetMargin(Vector2(0, 10), Vector2(0, 4))
    subcategory:SetText(locStrings["subcategory"])
    subcategory:SizeToContents()

    self.buttonSPOff = Button.Create(scroll_bkpanels)
    self.buttonSPOff:SetHeight(btnHeight)
    self.buttonSPOff:SetText(locStrings["buttonSPOff"])
    self.buttonSPOff:SetTextSize(textSize2)
    self.buttonSPOff:SetDock(GwenPosition.Top)
    self.buttonSPOff:SetMargin(Vector2(0, 3), Vector2(0, 3))
    self.buttonSPOff:Subscribe("Press", self, function() Network:Send("SPOff") end)

    local powers = BaseWindow.Create(self.window)
    tab:AddPage(locStrings["abilities"], powers)

    local bkpanelsContainer = BaseWindow.Create(powers)
    bkpanelsContainer:SetVisible(true)
    bkpanelsContainer:SetDock(GwenPosition.Bottom)
    bkpanelsContainer:SetMargin(Vector2(5, 5), Vector2(5, 5))
    bkpanelsContainer:SetHeight(80)

    local scroll_control = ScrollControl.Create(powers)
    scroll_control:SetScrollable(false, true)
    scroll_control:SetDock(GwenPosition.Fill)
    scroll_control:SetMargin(Vector2(5, 5), Vector2(5, 5))

    local option17 = self:OptionCheckBox(scroll_control, locStrings["option17"], LocalPlayer:GetValue("VehicleEjectBlocker") or false)
    option17:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 16, boolean = not LocalPlayer:GetValue("VehicleEjectBlocker")}) end)

    local option26 = self:OptionCheckBox(scroll_control, locStrings["option26"], LocalPlayer:GetValue("AirControl") or false)
    option26:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 22, boolean = not LocalPlayer:GetValue("AirControl")}) end)

    local option23 = self:OptionCheckBox(scroll_control, locStrings["option23"], LocalPlayer:GetValue("DriftPhysics") or false)
    option23:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 19, boolean = not LocalPlayer:GetValue("DriftPhysics")}) end)

    local option25 = self:OptionCheckBox(scroll_control, locStrings["option25"], LocalPlayer:GetValue("VehicleJump") or false)
    option25:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 21, boolean = not LocalPlayer:GetValue("VehicleJump") }) end)

    local option19 = self:OptionCheckBox(scroll_control, locStrings["option19"], LocalPlayer:GetValue("HydraulicsEnabled") or false)
    option19:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 18, boolean = not LocalPlayer:GetValue("HydraulicsEnabled")}) end)

    local option18 = self:OptionCheckBox(scroll_control, locStrings["option18"], LocalPlayer:GetValue("WingsuitEnabled") or false)
    option18:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 17, boolean = not LocalPlayer:GetValue("WingsuitEnabled")}) end)
    option18:SetMargin(Vector2(0, 20), Vector2.Zero)

    self.buttonLH = LabeledCheckBox.Create(scroll_control)
    if LocalPlayer:GetValue("LongerGrapple") then
        self.buttonLH:GetLabel():SetText(locStrings["longerGrapple"] .. " (" .. LocalPlayer:GetValue("LongerGrapple") .. "м)")
        self.buttonLH:GetLabel():SetEnabled(true)
        self.buttonLH:GetCheckBox():SetEnabled(true)
    else
        self.buttonLH:GetLabel():SetText(locStrings["longerGrapple"] .. " (150м) | [НЕДОСТУПНО]")
        self.buttonLH:GetLabel():SetEnabled(false)
        self.buttonLH:GetCheckBox():SetEnabled(false)
    end
    self.buttonLH:GetLabel():SetTextSize(textSize)
    self.buttonLH:SetDock(GwenPosition.Top)
    self.buttonLH:GetCheckBox():SetChecked(LocalPlayer:GetValue("LongerGrappleEnabled") or false)
    self.buttonLH:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 15, boolean = not LocalPlayer:GetValue("LongerGrappleEnabled")}) end)

    self.flipbutton = LabeledCheckBox.Create(bkpanelsContainer)
    self.spinbutton = LabeledCheckBox.Create(bkpanelsContainer)
    self.rollbutton = LabeledCheckBox.Create(bkpanelsContainer)

    self.rollbutton:GetCheckBox():SetEnabled(false)
    self.rollbutton:SetDock(GwenPosition.Bottom)
    self.rollbutton:GetLabel():SetText(locStrings["rollbutton"])
    self.rollbutton:GetCheckBox():SetChecked(LocalPlayer:GetValue("EnhancedWoet") == "Roll")
    self.rollbutton:GetCheckBox():Subscribe("CheckChanged", function()
        if self.rollbutton:GetCheckBox():GetChecked() then
            LocalPlayer:SetValue("EnhancedWoet", "Roll")

            self.spinbutton:GetCheckBox():SetChecked(false)
            self.flipbutton:GetCheckBox():SetChecked(false)
        else
            if LocalPlayer:GetValue("EnhancedWoet") == "Roll" then
                LocalPlayer:SetValue("EnhancedWoet", nil)
            end
        end
    end)

    self.spinbutton:GetCheckBox():SetEnabled(false)
    self.spinbutton:SetDock(GwenPosition.Bottom)
    self.spinbutton:GetLabel():SetText(locStrings["spinbutton"])
    self.spinbutton:GetCheckBox():SetChecked(LocalPlayer:GetValue("EnhancedWoet") == "Spin")
    self.spinbutton:GetCheckBox():Subscribe("CheckChanged", function()
        if self.spinbutton:GetCheckBox():GetChecked() then
            LocalPlayer:SetValue("EnhancedWoet", "Spin")

            self.rollbutton:GetCheckBox():SetChecked(false)
            self.flipbutton:GetCheckBox():SetChecked(false)
        else
            if LocalPlayer:GetValue("EnhancedWoet") == "Spin" then
                LocalPlayer:SetValue("EnhancedWoet", nil)
            end
        end
    end)

    self.flipbutton:GetCheckBox():SetEnabled(false)
    self.flipbutton:SetDock(GwenPosition.Bottom)
    self.flipbutton:GetLabel():SetText(locStrings["flipbutton"])
    self.flipbutton:GetCheckBox():SetChecked(LocalPlayer:GetValue("EnhancedWoet") == "Flip")
    self.flipbutton:GetCheckBox():Subscribe("CheckChanged", function()
        if self.flipbutton:GetCheckBox():GetChecked() then
            LocalPlayer:SetValue("EnhancedWoet", "Flip")

            self.rollbutton:GetCheckBox():SetChecked(false)
            self.spinbutton:GetCheckBox():SetChecked(false)
        else
            if LocalPlayer:GetValue("EnhancedWoet") == "Flip" then
                LocalPlayer:SetValue("EnhancedWoet", nil)
            end
        end
    end)

    self.subcategory3 = Label.Create(bkpanelsContainer)
    self.subcategory3:SetDock(GwenPosition.Bottom)
    self.subcategory3:SetMargin(Vector2.Zero, Vector2(0, 5))

    local bkpanelsContainer = BaseWindow.Create(powers)
    bkpanelsContainer:SetVisible(true)
    bkpanelsContainer:SetDock(GwenPosition.Right)
    bkpanelsContainer:SetWidth(310)

    local scroll_bkpanels = ScrollControl.Create(bkpanelsContainer)
    scroll_bkpanels:SetScrollable(false, true)
    scroll_bkpanels:SetDock(GwenPosition.Fill)
    scroll_bkpanels:SetMargin(Vector2(5, 0), Vector2(5, 0))

    self.jpviptip = Label.Create(scroll_bkpanels)
    self.jpviptip:SetVisible(true)
    self.jpviptip:SetTextColor(Color.DarkGray)
    self.jpviptip:SetDock(GwenPosition.Top)
    self.jpviptip:SetMargin(Vector2(0, 3), Vector2(0, 5))
    self.jpviptip:SetText(locStrings["jpviptip"])
    self.jpviptip:SizeToContents()

    self.buttonJP = Button.Create(scroll_bkpanels)
    self.buttonJP:SetEnabled(false)
    self.buttonJP:SetHeight(btnHeight)
    self.buttonJP:SetText(locStrings["buttonJP"])
    self.buttonJP:SetTextSize(textSize2)
    self.buttonJP:SetDock(GwenPosition.Top)
    self.buttonJP:SetMargin(Vector2(0, 3), Vector2(0, 5))
    self.buttonJP:Subscribe("Press", self, self.GetJetpack)

    self.subcategory2 = Label.Create(scroll_bkpanels)
    self.subcategory2:SetVisible(false)
    self.subcategory2:SetDock(GwenPosition.Top)
    self.subcategory2:SetMargin(Vector2(0, 10), Vector2(0, 5))
    self.subcategory2:SetText(locStrings["subcategory2"])
    self.subcategory2:SizeToContents()

    local weathertabsContainer = BaseWindow.Create(scroll_bkpanels)
    weathertabsContainer:SetVisible(true)
    weathertabsContainer:SetDock(GwenPosition.Top)
    weathertabsContainer:SetHeight(btnHeight)

    self.button = Button.Create(weathertabsContainer)
    self.button:SetVisible(false)
    self.button:SetText(locStrings["button"])
    self.button:SetTextSize(textSize)
    self.button:SetDock(GwenPosition.Left)
    self.button:Subscribe("Press", self, function() self:ChangeWeather(0, self.button:GetText()) end)

    self.buttonTw = Button.Create(weathertabsContainer)
    self.buttonTw:SetVisible(false)
    self.buttonTw:SetText(locStrings["buttonTw"])
    self.buttonTw:SetTextSize(textSize)
    self.buttonTw:SetDock(GwenPosition.Fill)
    self.buttonTw:SetMargin(Vector2(5, 0), Vector2(5, 0))
    self.buttonTw:Subscribe("Press", self, function() self:ChangeWeather(1, self.buttonTw:GetText()) end)

    self.buttonTh = Button.Create(weathertabsContainer)
    self.buttonTh:SetVisible(false)
    self.buttonTh:SetText(locStrings["buttonTh"])
    self.buttonTh:SetTextSize(textSize)
    self.buttonTh:SetDock(GwenPosition.Right)
    self.buttonTh:Subscribe("Press", self, function() self:ChangeWeather(2, self.buttonTh:GetText()) end)

    local keybinds = BaseWindow.Create(self.window)
    tab:AddPage(locStrings["keybinds"], keybinds)

    local keybindsContainer = BaseWindow.Create(keybinds)
    keybindsContainer:SetDock(GwenPosition.Fill)
    keybindsContainer:SetMargin(Vector2(5, 5), Vector2(5, 5))

    for _, bind in ipairs(self.binds) do
        local control = self.bindControls[bind.id]

        if control then
            control:SetText(locStrings[bind.loc])
        end
    end

    self.bindMenu:SetParent(keybindsContainer)
    self.bindMenu:SetDock(GwenPosition.Fill)
    self.bindMenu:SetColumns(self.locStrings)
    self.bindMenu:SetResetText(locStrings["reset"])
    self.bindMenu:SetVisible(true)

    local bottomContainer = BaseWindow.Create(keybindsContainer)
    bottomContainer:SetDock(GwenPosition.Bottom)
    bottomContainer:SetMargin(Vector2(0, 10), Vector2(0, 0))

    local subcategory = Label.Create(bottomContainer)
    subcategory:SetDock(GwenPosition.Fill)
    subcategory:SetAlignment(GwenPosition.CenterV)
    subcategory:SetText(locStrings["keybindswarning"])
    subcategory:SetTextColor(Color(200, 200, 200))

    local button = Button.Create(bottomContainer)
    button:SetText(locStrings["resetall"])
    button:SetSize(Vector2(button:GetTextWidth() + 15, 25))
    button:SetDock(GwenPosition.Right)
    button:Subscribe("Press", self, function() self.bindMenu:ResetAllControls() end)

    bottomContainer:SetHeight(button:GetHeight())

    local nickcolor = BaseWindow.Create(self.window)
    tab:AddPage(locStrings["nickcolor"], nickcolor)

    local tab_control = TabControl.Create(nickcolor)
    tab_control:SetDock(GwenPosition.Fill)

    local lpColor = LocalPlayer:GetColor()

    local subcategory = Label.Create(nickcolor)
    subcategory:SetDock(GwenPosition.Top)
    subcategory:SetMargin(Vector2(5, 10), Vector2.Zero)
    subcategory:SetText(locStrings["subcategory4"])
    subcategory:SizeToContents()

    local nicknameColorPreview = Label.Create(nickcolor)
    nicknameColorPreview:SetText(LocalPlayer:GetName())
    nicknameColorPreview:SetTextSize(textSize2)
    nicknameColorPreview:SetTextColor(lpColor)
    nicknameColorPreview:SetDock(GwenPosition.Top)
    nicknameColorPreview:SetMargin(Vector2(5, 0), Vector2(0, 4))
    nicknameColorPreview:SizeToContents()

    local pColorPicker = HSVColorPicker.Create(tab_control)
    pColorPicker:SetColor(lpColor)
    pColorPicker:SetDock(GwenPosition.Fill)
    pColorPicker:Subscribe("ColorChanged", function()
        nicknameColorPreview:SetTextColor(lpColor)
        lpColor = pColorPicker:GetColor()
    end)

    local setPlayerColorBtn = Button.Create(nickcolor)
    setPlayerColorBtn:SetText(locStrings["setPlayerColorBtn"])
    local btnColor = Color.LightGreen
    setPlayerColorBtn:SetTextHoveredColor(btnColor)
    setPlayerColorBtn:SetTextPressedColor(btnColor)
    setPlayerColorBtn:SetTextSize(textSize)
    setPlayerColorBtn:SetHeight(btnHeight)
    setPlayerColorBtn:SetDock(GwenPosition.Bottom)
    setPlayerColorBtn:SetMargin(Vector2(0, 5), Vector2.Zero)
    setPlayerColorBtn:Subscribe("Up", function()
        Network:Send("SetPlyColor", {pcolor = lpColor})

        local sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 20,
            sound_id = 22,
            position = LocalPlayer:GetPosition(),
            angle = Angle()
        })

        sound:SetParameter(0, 1)

        Game:FireEvent("bm.savecheckpoint.go")
    end)

    local skyOptions = BaseWindow.Create(self.window)
    tab:AddPage(locStrings["sky"], skyOptions)

    local scroll_control = ScrollControl.Create(skyOptions)
    scroll_control:SetScrollable(false, true)
    scroll_control:SetDock(GwenPosition.Fill)
    scroll_control:SetMargin(Vector2(5, 5), Vector2(5, 5))

    local skyOption4 = LabeledCheckBox.Create(scroll_control)
    local skyOption = LabeledCheckBox.Create(scroll_control)
    local skyOption2 = LabeledCheckBox.Create(scroll_control)
    local skyOption3 = LabeledCheckBox.Create(scroll_control)
    local skyOption5 = LabeledCheckBox.Create(scroll_control)
    local skyOption6 = LabeledCheckBox.Create(scroll_control)
    local skyOptionRnb = LabeledCheckBox.Create(scroll_control)

    skyOption:SetDock(GwenPosition.Top)
    skyOption:GetLabel():SetText(locStrings["skyOption"])
    skyOption:GetLabel():SetTextSize(textSize)
    skyOption:GetCheckBox():Subscribe("CheckChanged", function() self.skyTw = skyOption:GetCheckBox():GetChecked() end)

    skyOption2:SetDock(GwenPosition.Top)
    skyOption2:GetLabel():SetText(locStrings["skyOption2"])
    skyOption2:GetLabel():SetTextSize(textSize)
    skyOption2:GetCheckBox():Subscribe("CheckChanged", function() self.skyFi = skyOption2:GetCheckBox():GetChecked() end)

    skyOption3:SetDock(GwenPosition.Top)
    skyOption3:GetLabel():SetText(locStrings["skyOption3"])
    skyOption3:GetLabel():SetTextSize(textSize)
    skyOption3:GetCheckBox():Subscribe("CheckChanged", function() self.skyTh = skyOption3:GetCheckBox():GetChecked() end)

    skyOption4:SetDock(GwenPosition.Top)
    skyOption4:GetLabel():SetText(locStrings["skyOption4"])
    skyOption4:GetLabel():SetTextSize(textSize)
    skyOption4:GetCheckBox():Subscribe("CheckChanged", function() self.skySi = skyOption4:GetCheckBox():GetChecked() end)

    skyOption5:SetDock(GwenPosition.Top)
    skyOption5:GetLabel():SetText(locStrings["skyOption5"])
    skyOption5:GetLabel():SetTextSize(textSize)
    skyOption5:GetCheckBox():Subscribe("CheckChanged", function()
        self.skySe = skyOption5:GetCheckBox():GetChecked()

        if self.skySe then
            self.timer = Timer()
        else
            self.timer = nil
        end
    end)

    skyOption6:SetDock(GwenPosition.Top)
    skyOption6:GetLabel():SetText(locStrings["skyOption6"])
    skyOption6:GetLabel():SetTextSize(textSize)
    skyOption6:GetCheckBox():Subscribe("CheckChanged", function() self.skyColor = skyOption6:GetCheckBox():GetChecked() end)

    local tab_control = TabControl.Create(scroll_control)
    tab_control:SetDock(GwenPosition.Fill)

    self.toneS1Picker = HSVColorPicker.Create()
    tab_control:AddPage(locStrings["color"], self.toneS1Picker)
    tab_control:SetMargin(Vector2(0, 5), Vector2(0, 5))
    self.toneS1Picker:SetDock(GwenPosition.Fill)

    skyOptionRnb:SetDock(GwenPosition.Bottom)
    skyOptionRnb:GetLabel():SetText(locStrings["skyOptionRnb"])
    skyOptionRnb:GetLabel():SetTextSize(13)
    skyOptionRnb:GetCheckBox():Subscribe("CheckChanged", function()
        self.skyRainbow = skyOptionRnb:GetCheckBox():GetChecked()

        if self.skyRainbow then
            self.rT = Timer()
        else
            self.rT = nil
        end
    end)

    local stats = BaseWindow.Create(self.window)
    local statsText = locStrings["infoandstats"]
    tab:AddPage(statsText, stats)
    tab:Subscribe("TabSwitch", function()
        if tab:GetCurrentTab():GetText() == statsText then
            Network:Send("RequestStats")
        end
    end)

    local scroll_control = ScrollControl.Create(stats)
    scroll_control:SetScrollable(false, true)
    scroll_control:SetDock(GwenPosition.Fill)
    scroll_control:SetMargin(Vector2(5, 5), Vector2(5, 5))

    self.subcategory7 = GroupBox.Create(scroll_control)
    self.subcategory7:SetDock(GwenPosition.Top)
    self.subcategory7:SetMargin(Vector2(0, 4), Vector2(0, 4))
    self.subcategory7:SetText(locStrings["subcategory7"])

    local accountInfo = BaseWindow.Create(self.subcategory7)
    accountInfo:SetDock(GwenPosition.Fill)
    accountInfo:SetMargin(Vector2(110, 4), Vector2(0, 4))

    self.statsName = Label.Create(accountInfo)
    self.statsName:SetDock(GwenPosition.Top)
    self.statsName:SetText(LocalPlayer:GetName())
    self.statsName:SetTextSize(20)

    self.accountInfoText = Label.Create(accountInfo)
    self.accountInfoText:SetDock(GwenPosition.Fill)
    self.accountInfoText:SetText("…")

    local avatar = ImagePanel.Create(self.subcategory7)
    avatar:SetSize(Vector2(100, 100))
    avatar:SetPosition(Vector2(0, 4))
    avatar:SetImage(LocalPlayer:GetAvatar(2))

    self.statsName:SizeToContents()
    self.accountInfoText:SizeToContents()
    self.subcategory7:SetHeight((self.statsName:GetSize().y + 4 * 4) + (self.accountInfoText:GetSize().y + 4 * 4))

    self.subcategory8 = GroupBox.Create(scroll_control)
    self.subcategory8:SetDock(GwenPosition.Top)
    self.subcategory8:SetMargin(Vector2(0, 4), Vector2(0, 4))
    self.subcategory8:SetText(locStrings["subcategory8"])

    self.moreInfoText = Label.Create(self.subcategory8)
    self.moreInfoText:SetDock(GwenPosition.Fill)
    self.moreInfoText:SetText("…")

    self.moreInfoText:SizeToContents()
    self.subcategory8:SetHeight((self.moreInfoText:GetSize().y + 4 * 4))

    self.subcategory9 = GroupBox.Create(scroll_control)
    self.subcategory9:SetDock(GwenPosition.Top)
    self.subcategory9:SetMargin(Vector2(0, 4), Vector2(0, 4))
    self.subcategory9:SetText(locStrings["subcategory9"])

    self.statsText = Label.Create(self.subcategory9)
    self.statsText:SetDock(GwenPosition.Fill)
    self.statsText:SetText("…")
    self.statsText:SizeToContents()

    self.subcategory9:SetHeight((self.statsText:GetSize().y + 4 * 4))

    local promocodes = BaseWindow.Create(self.window)
    local promocodesText = locStrings["promocodes"]
    tab:AddPage(promocodesText, promocodes)
    tab:Subscribe("TabSwitch", function()
        if tab:GetCurrentTab():GetText() == promocodesText then
            Network:Send("RequestPromocodes")
        end
    end)

    local scroll_control = ScrollControl.Create(promocodes)
    scroll_control:SetScrollable(false, true)
    scroll_control:SetDock(GwenPosition.Fill)
    scroll_control:SetMargin(Vector2(5, 5), Vector2(5, 5))

    local subcategory = GroupBox.Create(scroll_control)
    subcategory:SetDock(GwenPosition.Top)
    subcategory:SetMargin(Vector2(0, 4), Vector2(0, 4))
    subcategory:SetText(locStrings["subcategory10"])
    subcategory:SetHeight((Render:GetTextHeight("", textSize - 4) + btnHeight) * 4.75)

    self.subcategory11 = Label.Create(subcategory)
    self.subcategory11:SetDock(GwenPosition.Top)
    self.subcategory11:SetMargin(Vector2(0, 4), Vector2(0, 4))

    self.subcategory12 = Label.Create(subcategory)
    self.subcategory12:SetDock(GwenPosition.Top)
    self.subcategory12:SetMargin(Vector2(0, 4), Vector2(0, 4))
    self.subcategory12:SetText(locStrings["subcategory12"])
    self.subcategory12:SizeToContents()

    self.invitePromocode = TextBox.Create(subcategory)
    self.invitePromocode:SetDock(GwenPosition.Top)
    self.invitePromocode:SetMargin(Vector2(0, 4), Vector2(0, 8))
    self.invitePromocode:SetHeight(btnHeight)
    self.invitePromocode:SetToolTip(locStrings["invitePromocode"])
    self.invitePromocode:Subscribe("Focus", self, self.Focus)
    self.invitePromocode:Subscribe("Blur", self, self.Blur)
    self.invitePromocode:Subscribe("EscPressed", self, self.EscPressed)
    self.invitePromocode:Subscribe("TextChanged", function() self.invitePromocode:SetText(self.invitePromocodeText or "") end)

    self.togglePromocodeBtn = Button.Create(subcategory)
    self.togglePromocodeBtn:SetVisible(false)
    self.togglePromocodeBtn:SetText(locStrings["togglePromocodeBtn"])
    self.togglePromocodeBtn:SetTextSize(textSize)
    self.togglePromocodeBtn:SetDock(GwenPosition.Top)
    self.togglePromocodeBtn:SetMargin(Vector2(0, 4), Vector2(0, 8))
    self.togglePromocodeBtn:SetHeight(btnHeight)
    self.togglePromocodeBtn:Subscribe("Press", function() Network:Send("GeneratePromocode") end)

    self.getInvitationsBonusBtn = Button.Create(subcategory)
    self.getInvitationsBonusBtn:SetEnabled(false)
    self.getInvitationsBonusBtn:SetTextSize(textSize)
    self.getInvitationsBonusBtn:SetDock(GwenPosition.Top)
    self.getInvitationsBonusBtn:SetMargin(Vector2(0, 4), Vector2(0, 4))
    self.getInvitationsBonusBtn:SetHeight(btnHeight)
    local btnColor = Color.Yellow
    self.getInvitationsBonusBtn:SetTextHoveredColor(btnColor)
    self.getInvitationsBonusBtn:SetTextPressedColor(btnColor)
    self.getInvitationsBonusBtn:SetText("…")
    self.getInvitationsBonusBtn:Subscribe("Press", function()
        Network:Send("GetInvitationPromocodesReward")
        Network:Send("RequestPromocodes")
    end)

    self.getInviteBonusBtn = Button.Create(subcategory)
    self.getInviteBonusBtn:SetEnabled(false)
    self.getInviteBonusBtn:SetText(locStrings["getInviteBonusBtn"])
    self.getInviteBonusBtn:SetTextSize(textSize)
    self.getInviteBonusBtn:SetDock(GwenPosition.Top)
    self.getInviteBonusBtn:SetHeight(btnHeight)
    local btnColor = Color.Yellow
    self.getInviteBonusBtn:SetTextHoveredColor(btnColor)
    self.getInviteBonusBtn:SetTextPressedColor(btnColor)
    self.getInviteBonusBtn:Subscribe("Press", function()
        Network:Send("ActivateInvitationPromocode")
        Network:Send("RequestPromocodes")
    end)

    local subcategory = GroupBox.Create(scroll_control)
    subcategory:SetDock(GwenPosition.Top)
    subcategory:SetMargin(Vector2(0, 4), Vector2(0, 4))
    subcategory:SetHeight((Render:GetTextHeight("", textSize - 8) + 85))
    subcategory:SetText(locStrings["subcategory13"])

    self.promocode = TextBox.Create(subcategory)
    self.promocode:SetDock(GwenPosition.Top)
    self.promocode:SetMargin(Vector2(0, 4), Vector2(0, 8))
    self.promocode:SetHeight(btnHeight)
    self.promocode:SetText("")
    self.promocode:Subscribe("Focus", self, self.Focus)
    self.promocode:Subscribe("Blur", self, self.Blur)
    self.promocode:Subscribe("EscPressed", self, self.EscPressed)
    self.promocode_color = self.promocode:GetTextColor()
    self.promocode:Subscribe("TextChanged", function()
        self.promocode:SetTextColor(self.promocode_color)
        self.getBonusBtn:SetEnabled(self.promocode:GetText() ~= "" and true or false)
    end)

    self.getBonusBtn = Button.Create(subcategory)
    self.getBonusBtn:SetEnabled(false)
    self.getBonusBtn:SetText(locStrings["activatePromocode"])
    self.getBonusBtn:SetTextSize(textSize)
    self.getBonusBtn:SetDock(GwenPosition.Top)
    self.getBonusBtn:SetHeight(btnHeight)
    self.getBonusBtn:SetText(locStrings["activatePromocode"])
    self.getBonusBtn:Subscribe("Press", function() Events:Fire("ApplyPromocode", {type = 0, name = self.promocode:GetText()}) end)

    --[[
    local tag = LocalPlayer:GetValue("Tag")

    if self.debug_permissions[tag] then
        local debug = BaseWindow.Create(self.window)
        tab:AddPage("DEBUG", debug)

        local scroll_control = ScrollControl.Create(debug)
        scroll_control:SetScrollable(false, true)
        scroll_control:SetDock(GwenPosition.Fill)
        scroll_control:SetMargin(Vector2(5, 5), Vector2(5, 5))

        self.option20 = self:OptionCheckBox(scroll_control, locStrings["option20"], LocalPlayer:GetValue("DEBUGShowOSD") or false)
        self.option20:GetCheckBox():Subscribe("CheckChanged", function() LocalPlayer:SetValue("DEBUGShowOSD", not LocalPlayer:GetValue("DEBUGShowOSD")) end)

        self.option21 = self:OptionCheckBox(scroll_control, locStrings["option21"], LocalPlayer:GetValue("DEBUGShowPlayerInfo") or false)
        self.option21:GetCheckBox():Subscribe("CheckChanged", function() LocalPlayer:SetValue("DEBUGShowPlayerInfo", not LocalPlayer:GetValue("DEBUGShowPlayerInfo")) end)

        self.option22 = self:OptionCheckBox(scroll_control, locStrings["option22"], LocalPlayer:GetValue("DEBUGShowVehicleInfo") or false)
        self.option22:GetCheckBox():Subscribe("CheckChanged", function() LocalPlayer:SetValue("DEBUGShowVehicleInfo", not LocalPlayer:GetValue("DEBUGShowVehicleInfo")) end)

        local subcategory = Label.Create(scroll_control)
        subcategory:SetDock(GwenPosition.Top)
        subcategory:SetMargin(Vector2(0, 10), Vector2(0, 4))
        subcategory:SetText(locStrings["subcategory5"])
        subcategory:SizeToContents()

        local consoleCommand = TextBox.Create(scroll_control)
        consoleCommand:SetDock(GwenPosition.Top)
        consoleCommand:Subscribe("ReturnPressed", self, function() Network:Send("RunConsoleCommand", consoleCommand:GetText()) consoleCommand:SetText("") end)
        consoleCommand:Subscribe("Focus", self, self.Focus)
        consoleCommand:Subscribe("Blur", self, self.Blur)
        consoleCommand:Subscribe("EscPressed", self, self.EscPressed)

        local subcategory = Label.Create(scroll_control)
        subcategory:SetText("FireEvent:")
        subcategory:SetDock(GwenPosition.Top)
        subcategory:SetMargin(Vector2(0, 10), Vector2(0, 4))

        local customFireEvent = TextBox.Create(scroll_control)
        customFireEvent:SetDock(GwenPosition.Top)
        customFireEvent:Subscribe("ReturnPressed", self, function() Game:FireEvent(customFireEvent:GetText()) customFireEvent:SetText("") end)
        customFireEvent:Subscribe("Focus", self, self.Focus)
        customFireEvent:Subscribe("Blur", self, self.Blur)
        customFireEvent:Subscribe("EscPressed", self, self.EscPressed)
    end
	]] --

    Events:Subscribe("PromocodeFound", function() self.promocode:SetTextColor(Color.Green) self.getBonusBtn:SetText("Промокод активирован!") end)
    Events:Subscribe("PromocodeNotFound", function() self.promocode:SetTextColor(Color.Red) self.getBonusBtn:SetText(locStrings["activatePromocode"]) end)
end

function Settings:Focus()
    Input:SetEnabled(false)
end

function Settings:Blur()
    Input:SetEnabled(true)
end

function Settings:EscPressed()
    self:Blur()
    self:CloseSettingsMenu()
end

function Settings:ChangeWeather(value, name)
    Events:Fire("CastCenterText", {text = self.locStrings["setweather"] .. name, time = 2})
    Network:Send("SetWeather", {severity = value})

    self:SetWindowVisible(false, true)
end

function Settings:OptionCheckBox(tab, title, checked)
    local checkbox = LabeledCheckBox.Create(tab)
    checkbox:GetLabel():SetText(title)
    checkbox:GetLabel():SetTextSize(self.textSize)

    checkbox:SetDock(GwenPosition.Top)
    if checked then
        checkbox:GetCheckBox():SetChecked(checked)
    end

    return checkbox
end

function Settings:GameRender()
    local lpWorld = LocalPlayer:GetWorld()

    if lpWorld ~= DefaultWorld then return end

    if self.skyFi then self.SkyImage5:SetSize(Render.Size) self.SkyImage5:Draw() end

    if self.skyColor then
        if self.skyRainbow and self.rT then
            local h = (0.01 * self.rT:GetMilliseconds()) * 5
            local color = Color.FromHSV(h % 360, 1, 1)

            Render:FillArea(Vector2.Zero, Render.Size, color + Color(0, 0, 0, 100))
        else
            Render:FillArea(Vector2.Zero, Render.Size, self.toneS1Picker:GetColor() + Color(0, 0, 0, 100))
        end
    end

    if self.skyTw then self.SkyImage2:SetSize(Render.Size) self.SkyImage2:Draw() end
    if self.skySi then self.SkyImage6:SetSize(Render.Size) self.SkyImage6:Draw() end

    if self.skySe then
        self.SkyImage7:SetSize(Render.Size) self.SkyImage7:Draw()

        local speed = 1
        local timer = self.timer

        if timer then
            local timerSeconds = timer:GetSeconds()

            if timerSeconds <= speed then
                self.SkyImage7 = self.AnimeImage1
            else
                self.SkyImage7 = self.AnimeImage2
            end

            if timerSeconds >= speed * 2 then
                self.timer:Restart()
            end
        end
    end

    if self.skyTh then self.SkyImage3:SetSize(Render.Size) self.SkyImage3:Draw() end
end

function Settings:GameLoad()
    Events:Fire("GetOption", {actCH = self.actvCH})
end

function Settings:UpdateStats(args)
    self.statsName:SetTextColor(LocalPlayer:GetColor())

    local locStrings = self.locStrings

    if not self.accountInfoTextRenderEvent then
        local steamId = LocalPlayer:GetSteamId()
        local joinDate = tostring(LocalPlayer:GetValue("JoinDate") or "?")
        local country = tostring(LocalPlayer:GetValue("Country"))

        self.accountInfoTextRenderEvent = self.accountInfoText:Subscribe("Render", function()
            self.accountInfoText:SetText(
                "Steam ID: " .. tostring(steamId) .. " / Steam64 ID: " .. tostring(steamId.id) ..
				locStrings["accountInfo1"] .. joinDate ..
				locStrings["accountInfo2"] .. self:ConvertSecondsToTimeFormat(LocalPlayer:GetValue("TotalTime") or "0") ..
				locStrings["accountInfo3"] .. country ..
				locStrings["accountInfo4"] .. tostring(LocalPlayer:GetValue("PlayerLevel")) ..
				locStrings["accountInfo5"] .. formatNumber(LocalPlayer:GetMoney())
			)
        end)
    end

    self.statsName:SizeToContents()
    self.accountInfoText:SizeToContents()
    self.subcategory7:SetHeight((self.statsName:GetSize().y + 4 * 4) + (self.accountInfoText:GetSize().y + 4 * 4))

    if not self.moreInfoTextRenderEvent then
        local pId = tostring(LocalPlayer:GetId())

        self.moreInfoTextRenderEvent = self.moreInfoText:Subscribe("Render", function()
            local vehicle = LocalPlayer:GetVehicle()

            self.moreInfoText:SetText(
				locStrings["accountInfo6"] .. self:ConvertSecondsToTimeFormat(LocalPlayer:GetValue("SessionTime") or "0") ..
				locStrings["accountInfo7"] .. tostring(LocalPlayer:GetValue("ClanTag") or locStrings["unknown"]) ..
				locStrings["accountInfo8"] .. pId .. locStrings["accountInfo9"] .. "rgba(" .. tostring(LocalPlayer:GetColor()) .. ")" ..
				locStrings["accountInfo10"] .. args.modelId ..
				locStrings["accountInfo11"] .. (vehicle and tostring(vehicle) .. " (ID: " .. tostring(vehicle:GetModelId()) .. ")" or locStrings["onfoot"])
			)
        end)
    end

    self.moreInfoText:SizeToContents()
    self.subcategory8:SetHeight((self.moreInfoText:GetSize().y + 4 * 4))

    if not self.statsTextRenderEvent then
        local defaultValue = 0

        self.statsTextRenderEvent = self.statsText:Subscribe("Render", function()
            self.statsText:SetText(
				locStrings["accountInfo12"] .. tostring(LocalPlayer:GetValue("ChatMessagesCount") or defaultValue) ..
				locStrings["accountInfo13"] .. tostring(LocalPlayer:GetValue("KillsCount") or defaultValue) ..
				locStrings["accountInfo14"] .. tostring(LocalPlayer:GetValue("CollectedResourceItemsCount") or defaultValue) ..
				locStrings["accountInfo15"] .. tostring(LocalPlayer:GetValue("CompletedTasksCount") or defaultValue) ..
				locStrings["accountInfo16"] .. tostring(LocalPlayer:GetValue("CompletedDailyTasksCount") or defaultValue) ..
				locStrings["accountInfo17"] .. tostring(LocalPlayer:GetValue("MaxRecordInBestDrift") or defaultValue) ..
				locStrings["accountInfo18"] .. tostring(LocalPlayer:GetValue("MaxRecordInBestTetris") or defaultValue) ..
				locStrings["accountInfo19"] .. tostring(LocalPlayer:GetValue("MaxRecordInBestFlight") or defaultValue) ..
				locStrings["accountInfo20"] .. tostring(LocalPlayer:GetValue("RaceWinsCount") or defaultValue) ..
				locStrings["accountInfo21"] .. tostring(LocalPlayer:GetValue("TronWinsCount") or defaultValue) ..
				locStrings["accountInfo22"] .. tostring(LocalPlayer:GetValue("KingHillWinsCount") or defaultValue) ..
				locStrings["accountInfo23"] .. tostring(LocalPlayer:GetValue("DerbyWinsCount") or defaultValue) ..
				locStrings["accountInfo24"] .. tostring(LocalPlayer:GetValue("PongWinsCount") or defaultValue) ..
				locStrings["accountInfo25"] .. tostring(LocalPlayer:GetValue("VictorinsCorrectAnswers") or defaultValue)
			)
        end)
    end

    self.statsText:SizeToContents()
    self.subcategory9:SetHeight((self.statsText:GetSize().y + 4 * 4))
end

function Settings:UpdatePromocodes(args)
    local locStrings = self.locStrings

    self.subcategory11:SetText(
		locStrings["uses"] .. tostring(LocalPlayer:GetValue("PromoCodeUses") or 0) .. " | " ..
		locStrings["activations"] .. tostring(LocalPlayer:GetValue("PromoCodeActivations") or 0) .. "\n" ..
		locStrings["promocodeGenerationDate"] .. tostring(LocalPlayer:GetValue("PromoCodeCreationDate") or locStrings["unknown"])
	)
    self.subcategory11:SizeToContents()

    self.invitePromocodeText = LocalPlayer:GetValue("PromoCodeName")
    if self.invitePromocodeText then
        self.invitePromocode:SetText(self.invitePromocodeText)
        self.togglePromocodeBtn:SetVisible(false)
        self.invitePromocode:SetVisible(not self.togglePromocodeBtn:GetVisible())
    else
        self.invitePromocode:SetText("")
        self.togglePromocodeBtn:SetVisible(true)
        self.invitePromocode:SetVisible(not self.togglePromocodeBtn:GetVisible())
    end

    local isActive = LocalPlayer:GetValue("PromoCodeRewards") and tonumber(LocalPlayer:GetValue("PromoCodeRewards")) >= 1
    self.getInvitationsBonusBtn:SetEnabled(isActive and true or false)

    self.getInvitationsBonusBtn:SetText(locStrings["getInvitationsBonus"] .. " ($" .. formatNumber((LocalPlayer:GetValue("PromoCodeRewards") or 0) * InviteBonuses.Bonus1) .. ")")

    self.getInviteBonusBtn:SetEnabled(LocalPlayer:GetValue("ActivePromocode") and true or false)
end

function Settings:LocalPlayerInput(args)
    if args.input == Action.GuiPause then
        self:SetWindowVisible(false)
    end

    if self.actions[args.input] then
        return false
    end
end

function Settings:OpenSettingsMenu()
    if Game:GetState() ~= GUIState.Game then return end

    self:SetWindowVisible(not self.activeWindow, true)
end

function Settings:CloseSettingsMenu()
    if Game:GetState() ~= GUIState.Game then return end

    if self.window and self.window:GetVisible() then
        self:SetWindowVisible(false)
    end
end

function Settings:Render()
    local is_visible = Game:GetState() == GUIState.Game
    local window = self.window
    local windowGetVisible = window:GetVisible()

    if windowGetVisible ~= is_visible then
        self.window:SetVisible(is_visible)
        Mouse:SetVisible(is_visible)
    end
end

function Settings:SetWindowVisible(visible, sound)
    self:CreateWindow()

    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end

    if self.activeWindow then
        self.option4:SetVisible(LocalPlayer:GetValue("JesusModeEnabled") and true or false)

        local locStrings = self.locStrings

        self.hidetexttip:SetText(locStrings["press"] .. " " .. self.stringKey .. " " .. locStrings["totoggleui"])
        self.hidetexttip:SizeToContents()

        self.subcategory3:SetText(locStrings["vehicletricks2"] .. self.vehicleTricksStringKey .. locStrings["vehicletricks3"])
        self.subcategory3:SizeToContents()

        local longerGrapple = LocalPlayer:GetValue("LongerGrapple")
        if longerGrapple then
            self.buttonLH:GetLabel():SetText(locStrings["longerGrapple"] .. " (" .. longerGrapple .. locStrings["meters"] .. ")")
            self.buttonLH:GetLabel():SetEnabled(true)
            self.buttonLH:GetCheckBox():SetEnabled(true)
        else
            self.buttonLH:GetLabel():SetText(locStrings["longerGrapple"] .. " (150" .. locStrings["meters"] .. ") | " .. locStrings["unavailable"])
            self.buttonLH:GetLabel():SetEnabled(false)
            self.buttonLH:GetCheckBox():SetEnabled(false)
        end

        local tag = LocalPlayer:GetValue("Tag")

        if self.permissions[tag] then
            local pWorld = LocalPlayer:GetWorld() == DefaultWorld

            self.subcategory2:SetVisible(true)
            self.button:SetVisible(true)
            self.buttonTw:SetVisible(true)
            self.buttonTh:SetVisible(true)

            self.button:SetEnabled(pWorld)
            self.buttonTw:SetEnabled(pWorld)
            self.buttonTh:SetEnabled(pWorld)

            self.rollbutton:GetCheckBox():SetEnabled(true)
            self.spinbutton:GetCheckBox():SetEnabled(true)
            self.flipbutton:GetCheckBox():SetEnabled(true)

            self.buttonJP:SetEnabled(pWorld)
            self.jpviptip:SetVisible(false)

            self.subcategory2:SetPosition(Vector2(self.window:GetSize().x - 350, 50))

            local pos_y = self.subcategory2:GetPosition().y + 20
            self.button:SetPosition(Vector2(self.subcategory2:GetPosition().x, pos_y))
            self.buttonTw:SetPosition(Vector2(self.button:GetPosition().x + 105, pos_y))
            self.buttonTh:SetPosition(Vector2(self.buttonTw:GetPosition().x + 105, pos_y))
        else
            self.buttonJP:SetEnabled(false)
            self.jpviptip:SetVisible(true)

            self.subcategory2:SetPosition(Vector2(self.window:GetSize().x - 350, 70))

            local pos_y = self.subcategory2:GetPosition().y + 20
            self.button:SetPosition(Vector2(self.subcategory2:GetPosition().x, pos_y))
            self.buttonTw:SetPosition(Vector2(self.button:GetPosition().x + 105, pos_y))
            self.buttonTh:SetPosition(Vector2(self.buttonTw:GetPosition().x + 105, pos_y))
        end

        Network:Send("RequestStats")

        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
        if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
    else
        if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
        if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
    end

    if sound then
        local effect = ClientEffect.Play(AssetLocation.Game, {
            effect_id = self.activeWindow and 382 or 383,

            position = Camera:GetPosition(),
            angle = Angle()
        })
    end
end

function Settings:ToggleAim()
    self.aim = not self.aim

    if self.aim then
        if self.NoAimRenderEvent then Events:Unsubscribe(self.NoAimRenderEvent) self.NoAimRenderEvent = nil end

        Game:FireEvent("gui.aim.show")
        self.actvCH = self.before
        self.before = nil
        self:GameLoad()
    else
        if not self.NoAimRenderEvent then self.NoAimRenderEvent = Events:Subscribe("Render", self, self.NoAim) end

        if self.actvCH then
            self.actvCH = false
            self.before = true
            self:GameLoad()
        end
    end
end

function Settings:NoAim()
    Game:FireEvent("gui.aim.hide")
end

function Settings:GetJetpack()
    Events:Fire("UseJetpack")
    self:SetWindowVisible(false, true)
end

function Settings:ResetDone()
    self.buttonSPOff:SetEnabled(false)
    self.buttonSPOff:SetText(self.locStrings["posreset"])
end

function Settings:KeyUp(args)
    if Game:GetState() ~= GUIState.Game then return end

    if args.key == self.expectedKey then
        local hiddenHUD = LocalPlayer:GetValue("HiddenHUD")

        if self.hidetext then
            self.hidetext:SetVisible(not hiddenHUD)
        end

        LocalPlayer:SetValue("HiddenHUD", not hiddenHUD)

        self:GameLoad()
    end
end

function Settings:ConvertSecondsToTimeFormat(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local seconds = seconds % 60
    return string.format(self.locStrings["timeFormat"], hours, minutes, seconds)
end

local settings = Settings()