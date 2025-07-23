class 'News'

function News:__init()
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
    self.window:SetSizeRel(Vector2(0.57, 0.86))
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
        self.window:SetTitle("ⓘ Новости")

        Network:Send("GetNews", {
            file = "newsRU.txt"
        })
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("OpenNewsMenu", self, self.OpenNewsMenu)
    Events:Subscribe("CloseNewsMenu", self, function() self:SetWindowVisible(false) end)
    Events:Subscribe("NewsAddItem", self, self.AddItem)
    Events:Subscribe("NewsRemoveItem", self, self.RemoveItem)

    Network:Subscribe("LoadNews", self, self.AddItem)
end

function News:Lang()
    self.window:SetTitle("ⓘ News")

    Network:Send("GetNews", {
        file = "newsEN.txt"
    })
end

function News:SetWindowVisible(visible, sound)
    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end

    if self.activeWindow then
        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalHelpInput) end
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

function News:OpenNewsMenu()
    self:SetWindowVisible(not self.activeWindow, true)
end

function News:Render()
    local gameState =  Game:GetState()
    local is_visible = gameState ~= GUIState.PDA
    local window = self.window
    local windowGetVisible = window:GetVisible()

    if windowGetVisible ~= is_visible then
        self.window:SetVisible(is_visible)
        Mouse:SetVisible(is_visible)
    end
end

function News:LocalHelpInput(args)
    if self.activeWindow and Game:GetState() == GUIState.Game then
        if args.input == Action.GuiPause then
            self:SetWindowVisible(false)
        end

        if self.actions[args.input] then
            return false
        end
    end
end

function News:AddItem(args)
    if label ~= nil then
        self:RemoveItem()
    end

    local page = self.window

    local scroll_control = ScrollControl.Create(page)
    scroll_control:SetMargin(Vector2(10, 15), Vector2(10, 15))
    scroll_control:SetScrollable(false, true)
    scroll_control:SetDock(GwenPosition.Fill)

    label = Label.Create(scroll_control)

    label:SetPadding(Vector2.Zero, Vector2(14, 0))
    label:SetText(args.text)
    label:SetTextSize(15)
    label:SizeToContents()
    label:SetTextColor(Color(155, 205, 255))
    label:SetWrap(true)

    label:Subscribe("Render", function(label) label:SetWidth(label:GetParent():GetWidth()) end)
end

function News:RemoveItem()
    if not label then return end

    label:Remove()
    label = nil
end

local news = News()