class 'Bank'

function Bank:__init()
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

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            title = "▧ Отправить деньги",
            amounttosend = "Укажите отправляемую сумму:",
            send = "Отправить",
            friend = "Друг",
            search = "Поиск",
            player = "Игрок",
            balance = "Баланс: $",
            playernotselected = "Игрок не выбран!"
        }
    end

    self.rows = {}
    self:CreateWindow()

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
    Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
    Events:Subscribe("OpenSendMoneyMenu", self, self.OpenSendMoneyMenu)
    Events:Subscribe("CloseSendMoney", self, function() self:SetWindowVisible(false) end)
    Events:Subscribe("LocalPlayerMoneyChange", self, self.MoneyChange)

    self.timer = Timer()
    self.message_size = TextSize.VeryLarge

    -- self:AddPlayer( LocalPlayer )
    for player in Client:GetPlayers() do
        self:AddPlayer(player)
    end
end

function Bank:Lang()
    self.locStrings = {
        title = "▧ Send Money",
        amounttosend = "Specify the amount to be sent:",
        send = "Send",
        friend = "Friend",
        search = "Search",
        player = "Player",
        balance = "Balance: $",
        playernotselected = "Player is not selected!"
    }

    if self.plist then
        local locStrings = self.locStrings

        self.plist.window:SetTitle(locStrings["title"])
        self.plist.balance:SetText(locStrings["balance"] .. formatNumber(LocalPlayer:GetMoney()))
        self.plist.text:SetText(locStrings["amounttosend"])
        self.plist.okay:SetText(locStrings["send"])
        self.plist.filter:SetToolTip(locStrings["send"])
    end
end

function Bank:SetWindowVisible(visible, sound)
    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.plist.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end

    if self.activeWindow then
        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
        if not self.WindowRenderEvent then self.WindowRenderEvent = Events:Subscribe("Render", self, self.WindowRender) end

        local rows = self.rows

        for p in Client:GetPlayers() do
            rows[p:GetId()]:SetTextColor(p:GetColor())
        end

        if LocalPlayer:GetValue("SystemFonts") then
            if self.plist.balance then
                self.plist.balance:SetFont(AssetLocation.SystemFont, "Impact")
            end
        end
    else
        if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
        if self.WindowRenderEvent then Events:Unsubscribe(self.WindowRenderEvent) self.WindowRenderEvent = nil end
    end

    if sound then
        local effect = ClientEffect.Play(AssetLocation.Game, {
            effect_id = self.activeWindow and 382 or 383,

            position = Camera:GetPosition(),
            angle = Angle()
        })
    end
end

function Bank:OpenSendMoneyMenu()
    self:SetWindowVisible(not self.activeWindow, true)
end

function Bank:CreateWindow()
    self.plist = {}

    local locStrings = self.locStrings

    self.plist.window = Window.Create()
    self.plist.window:SetSizeRel(Vector2(0.25, 0.42))
    self.plist.window:SetMinimumSize(Vector2(370, 240))
    self.plist.window:SetPositionRel(Vector2(0.85, 0.5) - self.plist.window:GetSizeRel() / 2)
    self.plist.window:SetVisible(self.activeWindow)
    self.plist.window:SetTitle(locStrings["title"])
    self.plist.window:Subscribe("WindowClosed", self, function() self:SetWindowVisible(false, true) end)

    self.plist.balance = Label.Create(self.plist.window)
    self.plist.balance:SetDock(GwenPosition.Top)
    self.plist.balance:SetMargin(Vector2(5, 5), Vector2(5, 5))
    self.plist.balance:SetTextSize(20)
    self.plist.balance:SetText(locStrings["balance"] .. formatNumber(LocalPlayer:GetMoney()))
    self.plist.balance:SetTextColor(Color(251, 184, 41))
    self.plist.balance:SizeToContents()

    self.plist.text = Label.Create(self.plist.window)
    self.plist.text:SetDock(GwenPosition.Top)
    self.plist.text:SetMargin(Vector2(5, 5), Vector2(5, 5))
    self.plist.text:SetText(locStrings["amounttosend"])
    self.plist.text:SizeToContents()

    self.plist.moneytosend = Numeric.Create(self.plist.window)
    self.plist.moneytosend:SetDock(GwenPosition.Top)
    self.plist.moneytosend:SetMargin(Vector2(5, 5), Vector2(5, 5))
    self.plist.moneytosend:SetHeight(20)
    self.plist.moneytosend:SetRange(0, BANK_CONFIGURATION.SENDLIMIT)
    self.plist.moneytosend:Subscribe("Focus", self, self.Focus)
    self.plist.moneytosend:Subscribe("Blur", self, self.Blur)
    self.plist.moneytosend:Subscribe("EscPressed", self, self.EscPressed)

    self.plist.playerList = SortedList.Create(self.plist.window)
    self.plist.playerList:SetMargin(Vector2.Zero, Vector2(0, 4))
    self.plist.playerList:SetBackgroundVisible(false)
    self.plist.playerList:AddColumn(locStrings["player"])
    self.plist.playerList:SetButtonsVisible(true)
    self.plist.playerList:SetDock(GwenPosition.Fill)

    self.plist.okay = Button.Create(self.plist.window)
    self.plist.okay:SetDock(GwenPosition.Bottom)
    self.plist.okay:SetHeight(35)
    self.plist.okay:SetText(locStrings["send"])
    self.plist.okay:Subscribe("Press", self, self.SendToPlayer)

    self.plist.filter = TextBox.Create(self.plist.window)
    self.plist.filter:SetDock(GwenPosition.Bottom)
    self.plist.filter:SetMargin(Vector2(0, 5), Vector2(0, 5))
    self.plist.filter:SetHeight(25)
    self.plist.filter:SetToolTip(locStrings["search"])
    self.plist.filter:Subscribe("TextChanged", self, self.TextChanged)
    self.plist.filter:Subscribe("Focus", self, self.Focus)
    self.plist.filter:Subscribe("Blur", self, self.Blur)
    self.plist.filter:Subscribe("EscPressed", self, self.EscPressed)
end

function Bank:PlayerJoin(args)
    local player = args.player

    self:AddPlayer(player)
end

function Bank:PlayerQuit(args)
    local player = args.player
    local playerId = player:GetId()
    local rows = self.rows

    if not rows[playerId] then return end

    self.plist.playerList:RemoveItem(rows[playerId])
    self.rows[playerId] = nil
end

function Bank:AddPlayer(player)
    local playerName = player:GetName()
    local playerColor = player:GetColor()
    local playerId = player:GetId()

    local item = self.plist.playerList:AddItem(playerName)

    if LocalPlayer:IsFriend(player) then
        item:SetToolTip(self.locStrings["friend"])
    end

    item:SetTextColor(playerColor)
    item:SetDataObject("id", playerId)

    self.rows[playerId] = item
end

function Bank:SendToPlayer()
    local row = self.plist.playerList:GetSelectedRow()

    if row then
        Network:Send("SendMoney", {selectedplayer = row:GetDataObject("id"), money = self.plist.moneytosend:GetValue()})
    else
        Events:Fire("CastCenterText", {text = self.locStrings["playernotselected"], time = 2, color = Color(255, 0, 0)})
    end

    self:SetWindowVisible(false)
end

function Bank:LocalPlayerInput(args)
    if args.input == Action.GuiPause then
        self:SetWindowVisible(false)
    end

    if self.actions[args.input] then
        return false
    end
end

function Bank:WindowRender()
    local is_visible = Game:GetState() == GUIState.Game
    local window = self.plist.window
    local windowGetVisible = window:GetVisible()

    if windowGetVisible ~= is_visible then
        self.plist.window:SetVisible(is_visible)
        Mouse:SetVisible(is_visible)
    end
end

--  Player search
function Bank:TextChanged()
    local filter = self.plist.filter:GetText()

    if filter:len() > 0 then
        for k, v in pairs(self.rows) do
            v:SetVisible(playerNameContains(v:GetCellText(0), filter))
        end
    else
        for k, v in pairs(self.rows) do
            v:SetVisible(true)
        end
    end
end

function Bank:Focus()
    Input:SetEnabled(false)
end

function Bank:Blur()
    Input:SetEnabled(true)
end

function Bank:EscPressed()
    self:Blur()
    self:SetWindowVisible(false)
end

function Bank:Render()
    local message = self.message

    if not message then return end

    local message_timer = self.message_timer

    if message_timer then
        local message_timer_seconds = message_timer:GetSeconds()

        if message_timer_seconds >= 5 then
            self.fadeOutAnimation = Animation:Play(self.animationValue, 0, 0.75, easeIOnut, function(value) self.animationValue = value end, function()
                self.message_timer = nil
                self.message = nil
                self.submessage = nil
                self.color = nil
                self.animationValue = nil
                self.posY = nil
                self.fadeOutAnimation = nil

                if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
            end)

            self.message_timer = nil
        end
    end

    if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

    local size = 25
    local pos = Vector2((Render.Size.x / 2) - (Render:GetTextSize(message .. " | " .. self.submessage, size).x / 2), math.lerp(110, 100, self.posY))
    local color = self.color
    local shadowColor = Color(0, 0, 0, 100)

    local animationValue = self.animationValue
    local textColor = Color(color.r, color.g, color.b, math.lerp(0, color.a, animationValue))
    local textShadow = Color(shadowColor.r, shadowColor.g, shadowColor.b, math.lerp(0, shadowColor.a, animationValue))

    Render:DrawShadowedText(pos, message .. " | " .. self.submessage, textColor, textShadow, size)
end

function Bank:MoneyChange(args)
    if not args.new_money then
        args.new_money = LocalPlayer:GetMoney()
    end

    self.plist.balance:SetText(self.locStrings["balance"] .. formatNumber(args.new_money))

    if Game:GetState() ~= GUIState.Game then return end

    if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end

    -- Very unlikely you'll be able to get any money in the first 2 seconds!
    local diff = args.new_money - args.old_money
    if diff ~= 0 and self.timer:GetSeconds() > 2 then
        if self.fadeOutAnimation then Animation:Stop(self.fadeOutAnimation) self.fadeOutAnimation = nil end

        Animation:Play(0, 1, 0.2, easeIOnut, function(value) self.animationValue = value self.posY = value end)

        self.message_timer = Timer()
        self.message = (diff > 0 and "+" or "-") .. " $" .. formatNumber(math.abs(diff))
        self.submessage = self.locStrings["balance"] .. formatNumber(args.new_money)
        self.color = diff > 0 and Color(251, 184, 41) or Color.OrangeRed
    end
end

local bank = Bank()