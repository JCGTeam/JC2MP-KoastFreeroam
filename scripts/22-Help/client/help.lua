class 'Help'

function Help:__init()
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

    self.activeWindow = false

    self.window = Window.Create()
    self.window:SetSizeRel(Vector2(0.58, 0.7))
    self.window:SetPositionRel(Vector2(0.69, 0.5) - self.window:GetSizeRel() / 2)
    self.window:SetVisible(self.activeWindow)
    self.window:Subscribe("WindowClosed", self, function() self:SetWindowVisible(false, true) end)

    self.tab_control = TabControl.Create(self.window)
    self.tab_control:SetDock(GwenPosition.Fill)
    self.tab_control:SetTabStripPosition(GwenPosition.Top)

    self.tabs = {}

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.window:SetTitle("ⓘ Помощь")
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("LocalPlayerChat", self, self.LocalPlayerChat)
    Events:Subscribe("OpenHelpMenu", self, self.OpenHelpMenu)
    Events:Subscribe("CloseHelpMenu", self, function() self:SetWindowVisible(false) end)
    Events:Subscribe("HelpAddItem", self, self.AddItem)
    Events:Subscribe("HelpRemoveItem", self, self.RemoveItem)

    Console:Subscribe("help", self, self.GetConsoleHelp)
end

function Help:Lang()
    self.window:SetTitle("ⓘ Help")
end

function Help:SetWindowVisible(visible, sound)
    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end

    if self.activeWindow then
        Network:Send("Save")

        Events:Fire("LoadAdminsTab")

        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalHelpInput) end
        if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
    else
        Events:Fire("UnloadAdminsTab")

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

function Help:LocalPlayerChat(args)
    local cmd_args = args.text:split(" ")

    if cmd_args[1] == "/help" or cmd_args[1] == "/rules" then
        self:OpenHelpMenu()
    end
end

function Help:OpenHelpMenu()
    self:SetWindowVisible(not self.activeWindow, true)
end

function Help:LocalHelpInput(args)
    if self.activeWindow and Game:GetState() == GUIState.Game then
        if args.input == Action.GuiPause then
            self:SetWindowVisible(false)
        end

        if self.actions[args.input] then
            return false
        end
    end
end

function Help:Render()
    local is_visible = Game:GetState() ~= GUIState.PDA

    if self.window:GetVisible() ~= is_visible then
        self.window:SetVisible(is_visible)
        Mouse:SetVisible(is_visible)
    end
end

function Help:AddItem(args)
    if self.tabs[args.name] ~= nil then
        self:RemoveItem(args)
    end

    local tab_button = self.tab_control:AddPage(args.name)

    local page = tab_button:GetPage()

    local scroll_control = ScrollControl.Create(page)
    scroll_control:SetMargin(Vector2(5, 5), Vector2(5, 5))
    scroll_control:SetScrollable(false, true)
    scroll_control:SetDock(GwenPosition.Fill)

    local label = Label.Create(scroll_control)

    label:SetPadding(Vector2.Zero, Vector2(14, 0))
    label:SetText(args.text)
    label:SetTextSize(15)
    label:SizeToContents()
    label:SetTextColor(Color(155, 205, 255))
    label:SetWrap(true)

    label:Subscribe("Render", function(label) label:SetWidth(label:GetParent():GetWidth()) end)

    self.tabs[args.name] = tab_button
end

function Help:RemoveItem(args)
    if not self.tabs[args.name] then return end

    self.tabs[args.name]:GetPage():Remove()
    self.tab_control:RemovePage(self.tabs[args.name])
    self.tabs[args.name] = nil
end

function Help:GetConsoleHelp()
    print(
		"Console commands:\n" .. "JC2:MP commands:\n" .. "  reconnect - reconnect to the server.\n" ..
		"  disconnect - disconnect from the server.\n" .. "  quit/exit - quit the game.\n" ..
		"  clear - clear console window.\n" ..
		"  gui_hide_fps (0/1) - show/hide the framerate from the top right.\n" ..
		"  gui_hide_logo (0/1) - show/hide the version number from the top right.\n" ..
		"  r_fontscale (scale) - changes the scale of all text rendered, default is 1.\n" ..
		"  profiler_sample (seconds) - get server modules consumption.\n" .. "Server commands:\n" ..
		"  font <default/server> - toggle server font."
	)
end

local help = Help()