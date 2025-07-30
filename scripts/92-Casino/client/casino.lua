class 'Casino'

function Casino:__init()
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

    self.rows = {}
    self.acceptButtons = {}
    self.requestButtons = {}
    self.sendedRequests = {}

    self.textSize = 13

    Network:Subscribe("TextBox", self, self.TextBox)
    Network:Subscribe("FinishCoinflip", self, self.FinishCoinflip)
    Network:Subscribe("EnableAccept", self, self.EnableAccept)
    Network:Subscribe("CreateLobby", self, self.CreateLobby)
    Network:Subscribe("DestroyLobby", self, self.DestroyLobby)
    Network:Subscribe("UpdateSecondStavka", self, self.UpdateSecondStavka)
    Network:Subscribe("UpdateReady", self, self.UpdateReady)
    Network:Subscribe("FinalReadyCoinflip", self, self.FinalReadyCoinflip)

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            title = "▧ Казино",
            largename = "$ $ $  Казино  $ $ $",
            search = "Поиск",
            balance = "Баланс: $",
            bet = "Ваша ставка:",
            secondbet = "Ставка ",
            makeBet = "$ Сделать ставку $",
            casinorequest = "Приглашение в казино",
            prequester = "Игрок: ",
            friend = "Друг",
            send = "Отправить ≫",
            accept = "Принять √",
            ready = "Готов",
            unready = "Не готов",
            waiting = "Ожидание ",
            quitlobby = "Покинуть комнату"
        }
    end

    self:CreateWindow()

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
    Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
    Events:Subscribe("LocalPlayerChat", self, self.LocalPlayerChat)
    Events:Subscribe("OpenCasinoMenu", self, self.OpenCasinoMenu)
    Events:Subscribe("CasinoMenuClosed", self, function() self:SetWindowVisible(false) end)

    -- self:AddPlayer( LocalPlayer )
    for player in Client:GetPlayers() do
        self:AddPlayer(player)
    end
end

function Casino:Lang()
    self.locStrings = {
        title = "▧ Casino",
        largename = "$ $ $  Casino  $ $ $",
        search = "Search",
        balance = "Balance: $",
        bet = "Your bet:",
        secondbet = "Bet from ",
        makeBet = "$ MAKE A BET $",
        casinorequest = "Casino invitation",
        prequester = "Player: ",
        friend = "Friend",
        send = "Send ≫",
        accept = "Accept √",
        ready = "Ready",
        unready = "Unready",
        waiting = "Waiting ",
        quitlobby = "Leave current room"
    }

    if self.window then
        local locStrings = self.locStrings

        self.window:SetTitle(locStrings["title"])
        self.largename:SetText(locStrings["largename"])
        self.coinflip.stavka_txt:SetText(locStrings["bet"] .. " $0")
        self.coinflip.okay:SetText(locStrings["makeBet"])
        self.coinflip.filter:SetToolTip(locStrings["search"])
    end
end

function Casino:TextBox(args)
    self.coinflip.messages:SetVisible(true)
    self.coinflip.messages:SetText(args.text)
    self.coinflip.messages:SizeToContents()

    if args.color then
        self.coinflip.messages:SetTextColor(args.color)

        local sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 20,
            sound_id = 20,
            position = LocalPlayer:GetPosition(),
            angle = Angle()
        })

        sound:SetParameter(0, 1)
    else
        self.coinflip.messages:SetTextColor(Color.White)
    end
end

function Casino:UpdateMoneyString(money)
    if money == nil then
        money = LocalPlayer:GetMoney()
    end

    self.coinflip.balance_txt:SetText(self.locStrings["balance"] .. formatNumber(money))
    self.coinflip.balance_txt:SizeToContents()
end

function Casino:LocalPlayerMoneyChange(args)
    self:UpdateMoneyString(args.new_money)
end

function Casino:LocalPlayerChat(args)
    local cmd_args = args.text:split(" ")

    if cmd_args[1] == "/casino" then
        self:OpenCasinoMenu()
    end
end

function Casino:SetWindowVisible(visible, sound)
    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end

    if self.activeWindow then
        self.coinflip.balance_txt:SetText(self.locStrings["balance"] .. formatNumber(LocalPlayer:GetMoney()))
        self.coinflip.balance_txt:SizeToContents()

        if LocalPlayer:GetValue("SystemFonts") then
            self.largename:SetFont(AssetLocation.SystemFont, "Impact")
            self.coinflip.balance_txt:SetFont(AssetLocation.SystemFont, "Impact")
            self.coinflip.stavka_txt:SetFont(AssetLocation.SystemFont, "Impact")
            self.coinflip.stavkaSecond_txt:SetFont(AssetLocation.SystemFont, "Impact")
            self.coinflip.messages:SetFont(AssetLocation.SystemFont, "Impact")
            self.coinflip.stavka_ok_btn:SetFont(AssetLocation.SystemFont, "Impact")
        end

        local rows = self.rows

        for p in Client:GetPlayers() do
            rows[p:GetId()]:SetTextColor(p:GetColor())
        end

        if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
        if not self.LocalPlayerMoneyChangeEvent then self.LLocalPlayerMoneyChangeEvent = Events:Subscribe("LocalPlayerMoneyChange", self, self.LocalPlayerMoneyChange) end
    else
        if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
        if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
        if self.LocalPlayerMoneyChangeEvent then Events:Unsubscribe(self.LocalPlayerMoneyChangeEvent) self.LocalPlayerMoneyChangeEvent = nil end
    end

    if sound then
        local effect = ClientEffect.Play(AssetLocation.Game, {
            effect_id = self.activeWindow and 382 or 383,

            position = Camera:GetPosition(),
            angle = Angle()
        })
    end
end

function Casino:Render()
    local is_visible = Game:GetState() == GUIState.Game
    local window = self.window
    local windowGetVisible = window:GetVisible()

    if windowGetVisible ~= is_visible then
        self.window:SetVisible(is_visible)
        Mouse:SetVisible(is_visible)
    end
end

function Casino:OpenCasinoMenu()
    if Game:GetState() ~= GUIState.Game then return end

    self:SetWindowVisible(not self.activeWindow, true)
end

function Casino:CreateWindow()
    local locStrings = self.locStrings

    self.window = Window.Create()
    self.window:SetSize(Vector2(700, 700))
    self.window:SetPositionRel(Vector2(0.75, 0.5) - self.window:GetSizeRel() / 2)
    self.window:SetTitle(locStrings["title"])
    self.window:SetVisible(false)
    self.window:Subscribe("WindowClosed", self, function() self:SetWindowVisible(false, true) end)

    local topAreaBackground = Rectangle.Create(self.window)
    topAreaBackground:SetPadding(Vector2.One * 2, Vector2.One * 2)
    topAreaBackground:SetDock(GwenPosition.Top)
    topAreaBackground:SetColor(Color(255, 150, 50))
    topAreaBackground:SetMargin(Vector2.Zero, Vector2(0, 10))

    local topArea = Rectangle.Create(topAreaBackground)
    topArea:SetPadding(Vector2(15, 15), Vector2(15, 15))
    topArea:SetDock(GwenPosition.Top)
    topArea:SetColor(Color(25, 25, 25))

    self.largename = Label.Create(topArea)
    self.largename:SetMargin(Vector2(), Vector2(0, -6))
    self.largename:SetDock(GwenPosition.Top)
    self.largename:SetAlignment(GwenPosition.CenterH)
    self.largename:SetTextSize(32)
    self.largename:SetTextColor(Color(255, 150, 50))
    self.largename:SetText(locStrings["largename"])
    self.largename:SizeToContents()

    topArea:SizeToChildren()
    topAreaBackground:SizeToChildren()

    self.coinflip = {}

    self.coinflip.scroll_control = ScrollControl.Create(self.window)
    self.coinflip.scroll_control:SetScrollable(false, true)
    self.coinflip.scroll_control:SetDock(GwenPosition.Fill)
    self.coinflip.scroll_control:SetVisible(false)

    self.coinflip.top = BaseWindow.Create(self.coinflip.scroll_control)
    self.coinflip.top:SetDock(GwenPosition.Top)
    self.coinflip.top:SetMargin(Vector2(5, 5), Vector2(5, 5))

    self.coinflip.balance_txt = Label.Create(self.coinflip.top)
    self.coinflip.balance_txt:SetTextColor(Color(251, 184, 41))
    self.coinflip.balance_txt:SetDock(GwenPosition.Left)
    self.coinflip.balance_txt:SetTextSize(20)

    self.coinflip.top:SetHeight(Render:GetTextHeight(self.coinflip.balance_txt:GetText(), self.coinflip.balance_txt:GetTextSize() + 2))

    self.coinflip.stavka_quitLobby_btn = Button.Create(self.coinflip.top)
    self.coinflip.stavka_quitLobby_btn:SetDock(GwenPosition.Right)
    self.coinflip.stavka_quitLobby_btn:SetText(locStrings["quitlobby"])
    self.coinflip.stavka_quitLobby_btn:SetWidth(Render:GetTextWidth(locStrings["quitlobby"], self.coinflip.stavka_quitLobby_btn:GetTextSize() + 2))
    self.coinflip.stavka_quitLobby_btn:SetVisible(false)
    self.coinflip.stavka_quitLobby_btn:Subscribe("Press", function() Network:Send("DestroyLobby", {secondPlayer = self.secondPlayer}) end)

    self.coinflip.stavka_txt = Label.Create(self.coinflip.scroll_control)
    self.coinflip.stavka_txt:SetDock(GwenPosition.Top)
    self.coinflip.stavka_txt:SetMargin(Vector2(5, 5), Vector2.Zero)
    self.coinflip.stavka_txt:SetText(locStrings["bet"] .. " $0")
    self.coinflip.stavka_txt:SetTextSize(15)
    self.coinflip.stavka_txt:SizeToContents()

    self.coinflip.stavkaSecond_txt = Label.Create(self.coinflip.scroll_control)
    self.coinflip.stavkaSecond_txt:SetDock(GwenPosition.Top)
    self.coinflip.stavkaSecond_txt:SetMargin(Vector2(5, 5), Vector2.Zero)
    self.coinflip.stavkaSecond_txt:SetTextSize(15)
    self.coinflip.stavkaSecond_txt:SetVisible(false)
    self.coinflip.stavkaSecond_txt:SizeToContents()

    self.coinflip.stavka = BaseWindow.Create(self.coinflip.scroll_control)
    self.coinflip.stavka:SetDock(GwenPosition.Top)
    self.coinflip.stavka:SetMargin(Vector2(5, 10), Vector2(5, 5))
    self.coinflip.stavka:SetHeight(35)

    self.coinflip.stavkaNumeric = Numeric.Create(self.coinflip.stavka)
    self.coinflip.stavkaNumeric:SetDock(GwenPosition.Fill)
    self.coinflip.stavkaNumeric:SetMargin(Vector2.Zero, Vector2(5, 0))
    self.coinflip.stavkaNumeric:SetTextSize(25)
    self.coinflip.stavkaNumeric:SetRange(0, CASINO_CONFIGURATION.COINFLIPLIMIT)
    self.coinflip.stavkaNumeric:Subscribe("TextChanged", self, self.UpdateStavkaButton)
    self.coinflip.stavkaNumeric:Subscribe("ReturnPressed", self, self.UpdateStavka)
    self.coinflip.stavkaNumeric:Subscribe("Focus", self, self.Focus)
    self.coinflip.stavkaNumeric:Subscribe("Blur", self, self.Blur)
    self.coinflip.stavkaNumeric:Subscribe("EscPressed", self, self.EscPressed)

    self.coinflip.stavka_ok_btn = Button.Create(self.coinflip.stavka)
    self.coinflip.stavka_ok_btn:SetDock(GwenPosition.Right)
    self.coinflip.stavka_ok_btn:SetText(">")
    self.coinflip.stavka_ok_btn:Subscribe("Press", self, self.UpdateStavka)

    self.coinflip.messages = Label.Create(self.coinflip.scroll_control)
    self.coinflip.messages:SetDock(GwenPosition.Top)
    self.coinflip.messages:SetAlignment(GwenPosition.CenterH)
    self.coinflip.messages:SetMargin(Vector2(0, 10), Vector2(0, 10))
    self.coinflip.messages:SetVisible(false)
    self.coinflip.messages:SetTextSize(20)

    --[[self.coinflip.bottomcontainer = BaseWindow.Create(self.coinflip.scroll_control)
	self.coinflip.bottomcontainer:SetDock(GwenPosition.Bottom)
	self.coinflip.bottomcontainer:SetSize(Vector2(0, 25))

	self.coinflip.multiply_tip = Label.Create(self.coinflip.bottomcontainer)
	self.coinflip.multiply_tip:SetDock(GwenPosition.Left)
	self.coinflip.multiply_tip:SetAlignment(GwenPosition.CenterV)
	self.coinflip.multiply_tip:SetText("Чем выше множитель, тем выше награда, но меньше шансов выиграть.")
	self.coinflip.multiply_tip:SizeToContents()

	self.coinflip.multiply_combobox = ComboBox.Create(self.coinflip.bottomcontainer)
	self.coinflip.multiply_combobox:SetDock(GwenPosition.Right)
	self.coinflip.multiply_combobox:SetSize(Vector2(40, 10))
	self.coinflip.multiply_combobox:AddItem("X1")
	self.coinflip.multiply_combobox:AddItem("X2")
	self.coinflip.multiply_combobox:AddItem("X3")
	self.coinflip.multiply_combobox:AddItem("X4")

	self.coinflip.multiply_text = Label.Create(self.coinflip.bottomcontainer)
	self.coinflip.multiply_text:SetDock(GwenPosition.Right)
	self.coinflip.multiply_text:SetAlignment(GwenPosition.CenterV)
	self.coinflip.multiply_text:SetText("МНОЖИТЕЛЬ: ")
	self.coinflip.multiply_text:SizeToContents()--]]

    self.coinflipmenu = true

    self.coinflip.scroll_control:SetVisible(true)

    self.coinflip.playerList = SortedList.Create(self.coinflip.scroll_control)
    self.coinflip.playerList:SetMargin(Vector2.Zero, Vector2(0, 4))
    self.coinflip.playerList:SetBackgroundVisible(false)
    self.coinflip.playerList:AddColumn("Игрок")
    self.coinflip.playerList:AddColumn("Приглашения", Render:GetTextWidth("Приглашения") + 10)
    self.coinflip.playerList:AddColumn("Запросы", Render:GetTextWidth("Запросы") + 10)
    self.coinflip.playerList:SetButtonsVisible(true)
    self.coinflip.playerList:SetDock(GwenPosition.Fill)

    self.coinflip.okay = Button.Create(self.coinflip.scroll_control)
    self.coinflip.okay:SetDock(GwenPosition.Bottom)
    self.coinflip.okay:SetHeight(35)
    self.coinflip.okay:SetText(locStrings["makeBet"])
    self.coinflip.okay:Subscribe("Press", self, self.ReadyCoinflip)

    self.coinflip.filter = TextBox.Create(self.coinflip.scroll_control)
    self.coinflip.filter:SetDock(GwenPosition.Bottom)
    self.coinflip.filter:SetMargin(Vector2(0, 5), Vector2(0, 5))
    self.coinflip.filter:SetHeight(25)
    self.coinflip.filter:SetToolTip(locStrings["search"])
    self.coinflip.filter:Subscribe("TextChanged", self, self.TextChanged)
    self.coinflip.filter:Subscribe("Focus", self, self.Focus)
    self.coinflip.filter:Subscribe("Blur", self, self.Blur)
    self.coinflip.filter:Subscribe("EscPressed", self, self.EscPressed)

    self:UpdateStavkaButton()
    self:UpdateStavka()
end

function Casino:UpdateStavkaButton()
    if self.coinflip.stavka_ok_btn and self.coinflip.okay then
        local stavkaValue = self.coinflip.stavkaNumeric:GetValue()

        if stavkaValue <= 0 or stavkaValue > CASINO_CONFIGURATION.COINFLIPLIMIT or LocalPlayer:GetMoney() < stavkaValue or string.find(stavkaValue, "%.") then
            self.coinflip.stavka_ok_btn:SetEnabled(false)
        else
            self.coinflip.stavkaNumeric:SetEnabled(true)
            self.coinflip.stavka_ok_btn:SetEnabled(true)
        end
    end
end

function Casino:UpdateStavka()
    local stavkaValue = self.coinflip.stavkaNumeric:GetValue()

    if stavkaValue <= 0 or stavkaValue > CASINO_CONFIGURATION.COINFLIPLIMIT or LocalPlayer:GetMoney() < stavkaValue or string.find(stavkaValue, "%.") then
        self.coinflip.okay:SetEnabled(false)
    else
        self.coinflip.messages:SetVisible(false)
        self.coinflip.okay:SetEnabled(true)

        Network:Send("UpdateStavka", {secondPlayer = self.secondPlayer, stavka = stavkaValue})
    end
end

function Casino:UpdateSecondStavka(secondStavka)
    if secondStavka then
        if self.secondPlayer then
            self.coinflip.stavkaSecond_txt:SetText(self.locStrings["secondbet"] .. self.secondPlayer:GetName() .. ": $" .. formatNumber(secondStavka))
            self.coinflip.stavkaSecond_txt:SizeToContents()
        end
    else
        self.coinflip.stavka_txt:SetText(self.locStrings["bet"] .. " $" .. formatNumber(self.coinflip.stavkaNumeric:GetText()))
        self.coinflip.stavka_txt:SizeToContents()
    end
end

function Casino:ReadyCoinflip()
    if self.secondPlayer then
        self.isReady = not self.isReady

        if (self.value or 0) < 2 then
            Network:Send("ReadyCoinflip", {secondPlayer = self.secondPlayer, isReady = self.isReady})
        else
            if self.secondPlayerFinalReady then
                self:StartCoinflip()
            else
                self.coinflip.okay:SetEnabled(false)
                self.coinflip.okay:SetText(self.locStrings["waiting"] .. self.secondPlayer:GetName() .. "…")

                Network:Send("FinalReadyCoinflip", {secondPlayer = self.secondPlayer})
            end
        end
    else
        self:StartCoinflip()
    end
end

function Casino:FinalReadyCoinflip()
    self.secondPlayerFinalReady = true
end

function Casino:StartCoinflip()
    if self.coinflip.stavkaNumeric then
        if self.secondPlayer then
            Network:Send("Coinflip", {secondPlayer = self.secondPlayer, stavka = self.coinflip.stavkaNumeric:GetValue()})
        else
            Network:Send("Coinflip", {stavka = self.coinflip.stavkaNumeric:GetValue()})
        end
    end
end

function Casino:FinishCoinflip()
    self.isReady = false
    self.secondPlayerFinalReady = nil
    self.value = 0

    local locStrings = self.locStrings

    if self.secondPlayer then
        self.coinflip.okay:SetText((self.isReady and locStrings["unready"] or locStrings["ready"]) .. " (" .. tostring(self.value) .. "/2)")
    else
        self.coinflip.okay:SetText(locStrings["makeBet"])
    end

    self.coinflip.okay:SetEnabled(true)

    self:UpdateStavkaButton()
end

function Casino:UpdateReady(args)
    if args.isReady then
        self.value = (self.value or 0) + 1
    else
        if self.value and self.value >= 1 then
            self.value = (self.value or 0) - 1
        end
    end

    local locStrings = self.locStrings

    if self.value < 2 then
        self.coinflip.okay:SetText((self.isReady and locStrings["unready"] or locStrings["ready"]) .. " (" .. tostring(self.value) .. "/2)")
    else
        self.coinflip.stavkaNumeric:SetEnabled(false)
        self.coinflip.stavka_ok_btn:SetEnabled(false)
        self.coinflip.okay:SetText(locStrings["makeBet"])
    end

    self:UpdateStavka()
end

function Casino:PlayerJoin(args)
    local player = args.player

    self:AddPlayer(player)
end

function Casino:PlayerQuit(args)
    local player = args.player
    local playerId = player:GetId()
    local rows = self.rows

    if player == self.secondPlayer then
        self:DestroyLobby()
    end

    if not rows[playerId] then return end

    self.coinflip.playerList:RemoveItem(rows[playerId])
    self.rows[playerId] = nil
end

--  Player adding
function Casino:CreateListButton(text, enabled, listItem)
    local button = Button.Create(listItem)
    button:SetText(text)
    button:SetTextSize(self.textSize)
    button:SetDock(GwenPosition.Fill)
    button:SetEnabled(enabled)

    return button
end

function Casino:AddPlayer(player)
    local playerName = player:GetName()
    local playerColor = player:GetColor()
    local playerId = player:GetId()

    local item = self.coinflip.playerList:AddItem(playerName)

    local locStrings = self.locStrings

    if LocalPlayer:IsFriend(player) then
        item:SetToolTip(locStrings["friend"])
    end

    local requestButton = self:CreateListButton(locStrings["send"], true, item)
    requestButton:Subscribe("Press", function() self:SendRequest(player) end)
    self.requestButtons[playerId] = requestButton

    local acceptButton = self:CreateListButton(locStrings["accept"], false, item)
    acceptButton:Subscribe("Press", function() self:AcceptRequest(player) end)
    self.acceptButtons[playerId] = acceptButton

    item:SetCellText(0, playerName)
    item:SetCellContents(1, requestButton)
    item:SetCellContents(2, acceptButton)
    item:SetTextColor(playerColor)
    item:SetDataObject("id", playerId)
    item:SetHeight(25)

    self.rows[playerId] = item
end

function Casino:SendRequest(player)
    Network:Send("SendRequest", {selectedplayer = player})

    local playerId = player:GetId()
    local requestButton = self.requestButtons[playerId]

    if requestButton then
        requestButton:SetEnabled(false)
    end
end

function Casino:AcceptRequest(player)
    local playerId = player:GetId()
    local acceptButton = self.acceptButtons[playerId]
    local requestButton = self.requestButtons[playerId]

    if acceptButton then
        self.sendedRequests[playerId] = nil
        acceptButton:SetEnabled(false)
    end

    if requestButton then
        requestButton:SetEnabled(true)
    end

    Network:Send("AcceptRequest", {selectedplayer = player})
end

function Casino:CreateLobby(args)
    local stavkaValue = 0

    self.firstPlayer = args.firstPlayer
    self.secondPlayer = args.secondPlayer

    self.value = 0

    local locStrings = self.locStrings
    local secondPlayerName = self.secondPlayer:GetName()

    self.coinflip.stavkaNumeric:SetValue(stavkaValue)
    self.coinflip.stavka_txt:SetText(locStrings["bet"] .. " $" .. formatNumber(stavkaValue))
    self.coinflip.stavkaSecond_txt:SetText(locStrings["secondbet"] .. secondPlayerName .. ": $" .. formatNumber(stavkaValue))
    self.coinflip.stavkaSecond_txt:SizeToContents()
    self.coinflip.messages:SetVisible(false)

    self.coinflip.stavkaSecond_txt:SetVisible(true)
    self.coinflip.stavka_quitLobby_btn:SetVisible(true)
    self.coinflip.okay:SetText(locStrings["ready"] .. " (0/2)")
    self.coinflip.okay:SetEnabled(false)

    self.coinflip.playerList:SetVisible(false)
    self.coinflip.filter:SetVisible(false)
end

function Casino:EnableAccept(requester)
    local playerId = requester:GetId()
    local acceptButton = self.acceptButtons[playerId]

    if acceptButton then
        acceptButton:SetEnabled(true)
        self.sendedRequests[playerId] = true
    end

    local locStrings = self.locStrings

    Events:Fire("SendNotification", {txt = locStrings["casinorequest"], image = "Information", subtxt = locStrings["prequester"] .. requester:GetName()})
end

function Casino:DestroyLobby()
    local locStrings = self.locStrings
    local stavkaValue = 0

    self.coinflip.stavkaNumeric:SetEnabled(true)
    self.coinflip.stavkaNumeric:SetValue(stavkaValue)
    self.coinflip.stavka_txt:SetText(locStrings["bet"] .. " $" .. formatNumber(stavkaValue))
    self.coinflip.messages:SetVisible(false)

    self.coinflip.stavkaSecond_txt:SetVisible(false)
    self.coinflip.stavka_quitLobby_btn:SetVisible(false)
    self.coinflip.okay:SetText(locStrings["makeBet"])
    self.coinflip.okay:SetEnabled(false)

    self.coinflip.playerList:SetVisible(true)
    self.coinflip.filter:SetVisible(true)

    if self.secondPlayer then
        local requestButton = self.requestButtons[self.secondPlayer:GetId()]

        if requestButton then
            requestButton:SetEnabled(true)
        end
    end

    self.firstPlayer = nil
    self.secondPlayer = nil

    self.value = nil
end

function Casino:LocalPlayerInput(args)
    if args.input == Action.GuiPause then
        self:SetWindowVisible(false)
    end

    if self.actions[args.input] then
        return false
    end
end

--  Player search
function Casino:TextChanged()
    local filter = self.coinflip.filter:GetText()

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

function Casino:Focus()
    Input:SetEnabled(false)
end

function Casino:Blur()
    Input:SetEnabled(true)
end

function Casino:EscPressed()
    self:Blur()
    self:SetWindowVisible(false)
end

local casino = Casino()