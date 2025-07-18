class "PM"

function PM:__init(player)
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
    self.dmoode = false
    self.maxmessagesymbols = 300

    self.messages = {}
    self.GUI = {}
    self.GUI.window = Window.Create()
    self.GUI.window:SetSizeRel(Vector2(0.4, 0.5))
    self.GUI.window:SetMinimumSize(Vector2(600, 442))
    self.GUI.window:SetPositionRel(Vector2(0.7, 0.5) - self.GUI.window:GetSizeRel() / 2)
    self.GUI.window:SetTitle("[▼] Личные Сообщения")
    self.GUI.window:SetVisible(self.activeWindow)

    self.GUI.labelP = Label.Create(self.GUI.window)
    self.GUI.labelP:SetDock(GwenPosition.Left)
    self.GUI.labelP:SetWidthRel(0.4)

    self.GUI.list = SortedList.Create(self.GUI.labelP)
    self.GUI.list:SetDock(GwenPosition.Fill)
    self.GUI.list:AddColumn("Игрок")
    self.GUI.list:Subscribe("RowSelected", self, self.loadMessages)

    self.GUI.filter = TextBox.Create(self.GUI.labelP)
    self.GUI.filter:SetDock(GwenPosition.Bottom)
    self.GUI.filter:SetHeight(32)
    self.GUI.filter:SetMargin(Vector2(0, 4), Vector2())
    self.GUI.filter:Subscribe("TextChanged", self, self.TextChanged)
    self.GUI.filter:Subscribe("Focus", self, self.Focus)
    self.GUI.filter:Subscribe("Blur", self, self.Blur)
    self.GUI.filter:Subscribe("EscPressed", self, self.EscPressed)

    self.GUI.PMMessagesControlLabel = Label.Create(self.GUI.window)
    self.GUI.PMMessagesControlLabel:SetDock(GwenPosition.Top)
    self.GUI.PMMessagesControlLabel:SetHeight(25)
    self.GUI.PMMessagesControlLabel:SetMargin(Vector2(10, 5), Vector2(5, 5))

    self.GUI.labelM = Label.Create(self.GUI.PMMessagesControlLabel)
    self.GUI.labelM:SetDock(GwenPosition.Left)
    self.GUI.labelM:SetAlignment(GwenPosition.CenterV)
    self.GUI.labelM:SetText("Переписка:")
    self.GUI.labelM:SetTextSize(14)
    self.GUI.labelM:SizeToContents()

    self.GUI.clear = Button.Create(self.GUI.PMMessagesControlLabel)
    self.GUI.clear:SetDock(GwenPosition.Right)
    self.GUI.clear:SetText("Очистить")
    self.GUI.clear:SetSize(Vector2(Render:GetTextWidth(self.GUI.clear:GetText()), 25))
    self.GUI.clear:SetTextHoveredColor(Color(255, 150, 150))
    self.GUI.clear:Subscribe("Press", self, self.clearMessage)

    self.GUI.PMDistrub = Button.Create(self.GUI.PMMessagesControlLabel)
    self.GUI.PMDistrub:SetDock(GwenPosition.Right)
    self.GUI.PMDistrub:SetMargin(Vector2.Zero, Vector2(5, 0))
    self.GUI.PMDistrub:SetText("Не беспокоить")
    self.GUI.PMDistrub:SetSize(Vector2(Render:GetTextWidth(self.GUI.PMDistrub:GetText()), 25))
    if LocalPlayer:GetValue("PMDistrub") then
        local btnColor = Color(255, 150, 150)
        self.GUI.PMDistrub:SetTextNormalColor(btnColor)
        self.GUI.PMDistrub:SetTextHoveredColor(btnColor)
    else
        local btnColor = Color.White
        self.GUI.PMDistrub:SetTextNormalColor(btnColor)
        self.GUI.PMDistrub:SetTextHoveredColor(btnColor)
    end
    self.GUI.PMDistrub:Subscribe("Press", self, self.ToggleDistrub)

    self.GUI.drawLine = Rectangle.Create(self.GUI.window)
    self.GUI.drawLine:SetDock(GwenPosition.Top)
    self.GUI.drawLine:SetMargin(Vector2(10, 0), Vector2(10, 0))
    self.GUI.drawLine:SetHeight(1)
    self.GUI.drawLine:SetColor(Color.White)

    self.GUI.PMMessagesScroll = ScrollControl.Create(self.GUI.window)
    self.GUI.PMMessagesScroll:SetDock(GwenPosition.Fill)
    self.GUI.PMMessagesScroll:SetScrollable(false, true)
    self.GUI.PMMessagesScroll:SetMargin(Vector2(10, 8), Vector2(5, 5))

    self.GUI.messagesLabel = Label.Create(self.GUI.PMMessagesScroll)
    self.GUI.messagesLabel:SetText("")
    self.GUI.messagesLabel:SetDock(GwenPosition.Fill)
    self.GUI.messagesLabel:SetWrap(true)

    self.GUI.PMMessageTypingLabel = Label.Create(self.GUI.window)
    self.GUI.PMMessageTypingLabel:SetDock(GwenPosition.Bottom)
    self.GUI.PMMessageTypingLabel:SetHeightRel(0.065)
    self.GUI.PMMessageTypingLabel:SetMargin(Vector2(10, 0), Vector2(5, 5))

    self.GUI.message = TextBox.Create(self.GUI.PMMessageTypingLabel)
    self.GUI.message:SetText("")
    self.GUI.message:SetDock(GwenPosition.Fill)
    self.GUI.message:SetMargin(Vector2(0, 2), Vector2(5, 2))
    self.GUI.message:Subscribe("ReturnPressed", self, self.sendMessage)
    self.GUI.message:Subscribe("TextChanged", self, self.ChangelLText)
    self.GUI.message:Subscribe("Focus", self, self.Focus)
    self.GUI.message:Subscribe("Blur", self, self.Blur)
    self.GUI.message:Subscribe("EscPressed", self, self.EscPressed)

    self.GUI.send = Button.Create(self.GUI.PMMessageTypingLabel)
    self.GUI.send:SetText(">")
    self.GUI.send:SetDock(GwenPosition.Right)
    self.GUI.send:SetWidth(70)
    self.GUI.send:Subscribe("Press", self, self.sendMessage)

    self.GUI.labelL = Label.Create(self.GUI.window)
    self.GUI.labelL:SetText("0/" .. self.maxmessagesymbols)
    self.GUI.labelL:SetDock(GwenPosition.Bottom)
    self.GUI.labelL:SetMargin(Vector2(10, 0), Vector2.Zero)
    self.GUI.labelL:SizeToContents()

    self.GUI.window:Subscribe("WindowClosed", self, function() self:SetWindowVisible(false, true) end)
    self.playerToRow = {}

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            tag = "[Сообщения] ",
            friend = "Друг",
            newmsg = "Новое сообщение!",
            sendermsg = "Игрок: ",
            limit = "Вы привысили допустимый лимит!",
            playeroffline = "Игрок не в сети!",
            playernotselected = "Игрок не выбран!",
            clearmessages = "Сообщения очищены."
        }

        if self.GUI.window then
            self.GUI.filter:SetToolTip("Поиск")
        end
    end

    -- self:addPlayerToList( LocalPlayer )
    for player in Client:GetPlayers() do
        self:addPlayerToList(player)
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("PlayerJoin", self, self.playerJoin)
    Events:Subscribe("PlayerQuit", self, self.playerQuit)
    Events:Subscribe("OpenGuiPm", self, self.OpenGuiPm)
    Events:Subscribe("CloseGuiPm", self, function() self:SetWindowVisible(false) end)
    Network:Subscribe("PM.notification", self, self.notification)
    Network:Subscribe("PM.addMessage", self, self.addMessage)
end

function PM:Lang()
    self.locStrings = {
        tag = "[Messages] ",
        friend = "Friend",
        newmsg = "New message!",
        sendermsg = "Sender: ",
        limit = "You have exceeded the allowed limit!",
        playeroffline = "Player is offline!",
        playernotselected = "Player not selected!",
        clearmessages = "Messages cleared."
    }

    if self.GUI.window then
        self.GUI.window:SetTitle("[▼] Private Messages")
        self.GUI.labelM:SetText("Messages:")
        self.GUI.clear:SetText("Clear")
        self.GUI.PMDistrub:SetText("Do not disturb")
        self.GUI.filter:SetToolTip("Search")
    end
end

function PM:SetWindowVisible(visible, sound)
    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.GUI.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end

    if self.activeWindow then
        for p in Client:GetPlayers() do
            local playerColor = p:GetColor()
            self.playerToRow[p:GetId()]:SetTextColor(playerColor)
        end

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

function PM:Render()
    local is_visible = Game:GetState() == GUIState.Game

    if self.GUI.window:GetVisible() ~= is_visible then
        self.GUI.window:SetVisible(is_visible)
        Mouse:SetVisible(is_visible)
    end
end

function PM:ChangelLText()
    local len = self.GUI.message:GetText():len()

    self.GUI.labelL:SetText(len .. "/" .. self.maxmessagesymbols)

    local limit = len <= self.maxmessagesymbols
    self.GUI.labelL:SetTextColor(limit and Color.White or Color.Red)
    self.GUI.send:SetEnabled(limit)
end

function PM:OpenGuiPm()
    if Game:GetState() ~= GUIState.Game then return end

    self:SetWindowVisible(not self.activeWindow, true)
end

function PM:ToggleDistrub()
    self.dmoode = not LocalPlayer:GetValue("PMDistrub")
    Network:Send("ChangePmMode", {dvalue = self.dmoode})
    if LocalPlayer:GetValue("PMDistrub") then
        local btnColor = Color.White
        self.GUI.PMDistrub:SetTextNormalColor(btnColor)
        self.GUI.PMDistrub:SetTextHoveredColor(btnColor)
    else
        local btnColor = Color(255, 150, 150)
        self.GUI.PMDistrub:SetTextNormalColor(btnColor)
        self.GUI.PMDistrub:SetTextHoveredColor(btnColor)
    end
end

function PM:LocalPlayerInput(args)
    if self.GUI.window:GetVisible() and Game:GetState() == GUIState.Game then
        if args.input == Action.GuiPause then
            self:SetWindowVisible(false)
        end

        if self.actions[args.input] then
            return false
        end
    end
end

function PM:TextChanged()
    local filter = self.GUI.filter:GetText()

    if filter:len() > 0 then
        for k, v in pairs(self.playerToRow) do
            v:SetVisible(playerNameContains(v:GetCellText(0), filter))
        end
    else
        for k, v in pairs(self.playerToRow) do
            v:SetVisible(true)
        end
    end
end

function PM:Focus()
    Input:SetEnabled(false)
end

function PM:Blur()
    Input:SetEnabled(true)
end

function PM:EscPressed()
    self:Blur()
    self:SetWindowVisible(false)
end

function PM:addPlayerToList(player)
    local item = self.GUI.list:AddItem(player:GetName())
    local color = player:GetColor()

    if LocalPlayer:IsFriend(player) then
        item:SetToolTip(self.locStrings["friend"])
    end

    item:SetTextColor(color)
    item:SetVisible(true)
    item:SetDataObject("id", player)
    self.playerToRow[player:GetId()] = item
end

function PM:playerJoin(args)
    self:addPlayerToList(args.player)
end

function PM:playerQuit(args)
    local pId = args.player:GetId()

    if self.playerToRow[pId] then
        self.GUI.list:RemoveItem(self.playerToRow[pId])
        self.playerToRow[pId] = nil
    end
end

function PM:loadMessages()
    local row = self.GUI.list:GetSelectedRow()

    if row then
        local player = row:GetDataObject("id")
        local pId = player:GetId()

        self.GUI.messagesLabel:SetText("")
        if self.messages[tostring(pId)] then
            for index, msg in ipairs(self.messages[tostring(pId)]) do
                if IsValid(msg) then
                    if index > 1 then
                        self.GUI.messagesLabel:SetText(self.GUI.messagesLabel:GetText() .. "\n" .. tostring(msg))
                    else
                        self.GUI.messagesLabel:SetText(tostring(msg))
                    end
                end
            end
        end
        self.GUI.messagesLabel:SizeToContents()
    end
end

function PM:notification(args)
    Events:Fire("SendNotification", {txt = self.locStrings["newmsg"], image = "Information", subtxt = self.locStrings["sendermsg"] .. args.msgsender})
end

function PM:addMessage(data)
    if data.player then
        local pId = data.player:GetId()

        if not self.messages[tostring(pId)] then
            self.messages[tostring(pId)] = {}
        end

        local row = self.GUI.list:GetSelectedRow()

        if row then
            local player = row:GetDataObject("id")

            if player and data.player == player then
                if #self.messages[tostring(pId)] > 0 then
                    self.GUI.messagesLabel:SetText(self.GUI.messagesLabel:GetText() .. "\n" .. tostring(data.text))
                else
                    self.GUI.messagesLabel:SetText(tostring(data.text))
                end
                self.GUI.messagesLabel:SizeToContents()
            end
        end

        table.insert(self.messages[tostring(pId)], data.text)
    end
end

function PM:sendMessage()
    local row = self.GUI.list:GetSelectedRow()

    if row then
        local player = row:GetDataObject("id")

        if player then
            local text = self.GUI.message:GetText()
            if self.GUI.message:GetText():len() <= self.maxmessagesymbols then
                if text ~= "" then
                    Network:Send("PM.send", {player = player, text = text})
                    self.GUI.message:SetText("")
                    self.GUI.message:Focus()
                end
            else
                Chat:Print(self.locStrings["tag"], Color.White, self.locStrings["limit"], Color.DarkGray)
            end
        else
            Chat:Print(self.locStrings["tag"], Color.White, self.locStrings["playeroffline"], Color.DarkGray)
        end
    else
        Chat:Print(self.locStrings["tag"], Color.White, self.locStrings["playernotselected"], Color.DarkGray)
    end
end

function PM:clearMessage()
    self.GUI.messagesLabel:SetText(self.locStrings["clearmessages"])
end

Events:Subscribe("ModuleLoad", function()
    PM()
end)