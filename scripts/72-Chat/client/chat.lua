class 'BetterChat'

function BetterChat:__init()
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
        [16] = true,
        [35] = true,
        [71] = true
    }

    Events:Subscribe("OpenChatMenu", self, self.OpenChatMenu)
    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("Render", self, self.Render)

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            tiptext = "Двигайте мышь, чтобы изменить позицию чата | Нажмите ЛКМ, чтобы применить изменения",
            tGlobal = "Общий",
            tLocal = "Локальный",
            tClan = "Клан",
            tPrefix = "Префикс",
            chatmode = "Режим чата: ",
            chatsetingswindow = "Настройка чата",
            changechatpos = "Настроить позицию",
            restorechatpos = "Сбросить позицию",
            showconnects = "Показывать подключения:",
            sc_cb_1 = "Всех",
            sc_cb_2 = "Друзей",
            sc_cb_3 = "Никого"
        }
    end

    self.chatheight = Render:GetTextHeight("A") * 14.2

    self.chatmodelist = ComboBox.Create()
    self.chatmodelist:SetTextSize(14)
    self.chatmodelist:SetSize(Vector2(Render:GetTextWidth("A") * 8.5, Render:GetTextHeight(self.chatmodelist:GetText(), 14) * 1.5))
    self.chatmodelist:SetVisible(false)

    self.customchatpos = Chat:GetPosition()

    Network:Subscribe("ApplyChatPos", self, self.ApplyChatPos)
end

function BetterChat:Lang()
    self.locStrings = {
        tiptext = "Move mouse to change chat position | Click LMB to apply changes",
        tGlobal = "Global",
        tLocal = "Local",
        tClan = "Clan",
        tPrefix = "Prefix",
        chModeMsg = "Chat mode changed to ",
        chatmode = "Chat mode: ",
        chatsetingswindow = "Chat Settings",
        changechatpos = "Change position",
        restorechatpos = "Reset position",
        showconnects = "Show connections:",
        sc_cb_1 = "Everyone",
        sc_cb_2 = "Friends",
        sc_cb_3 = "Nobody"
    }
end

function BetterChat:CreateChatModeListItems()
    self.chatmodelist:AddItem(self.locStrings["tGlobal"], self.locStrings["tGlobal"])
    self.chatmodelist:AddItem(self.locStrings["tLocal"], self.locStrings["tLocal"])
    if LocalPlayer:GetValue("ClanTag") then
        self.chatmodelist:AddItem(self.locStrings["tClan"], self.locStrings["tClan"])
    end
    if LocalPlayer:GetValue("Tag") or LocalPlayer:GetValue("NT_TagName") then
        self.chatmodelist:AddItem(self.locStrings["tPrefix"], self.locStrings["tPrefix"])
    end

    local chatMode = LocalPlayer:GetValue("ChatMode")
    if chatMode == 0 then
        self.chatmodelist:SelectItemByName(self.locStrings["tGlobal"])
    elseif chatMode == 1 then
        self.chatmodelist:SelectItemByName(self.locStrings["tLocal"])
    elseif chatMode == 2 then
        self.chatmodelist:SelectItemByName(self.locStrings["tClan"])
    elseif chatMode == 3 then
        self.chatmodelist:SelectItemByName(self.locStrings["tPrefix"])
    end
end

function BetterChat:ApplyChatPos(args)
    self.customchatpos = Vector2(args.sqlchatposX, args.sqlchatposY)
    Chat:SetPosition(self.customchatpos)
    if not self.ResolutionChangeEvent then self.ResolutionChangeEvent = Events:Subscribe("ResolutionChange", self, self.ResolutionChange) end
end

function BetterChat:LocalPlayerInput(args)
    if args.input == Action.GuiPause then
        self:CloseWindow()
    end

    if self.actions[args.input] then
        return false
    end
end

function BetterChat:OpenChatMenu()
    if not self.window then
        self.window = Window.Create()
        self.window:SetSize(Vector2(270, 155))
        self.window:SetPosition((Render.Size - self.window:GetSize()) / 2)
        self.window:SetTitle(self.locStrings["chatsetingswindow"])
        self.window:Subscribe("WindowClosed", self, self.CloseWindow)
        Mouse:SetVisible(true)

        local possettbutton = Button.Create(self.window)
        possettbutton:SetDock(GwenPosition.Top)
        possettbutton:SetHeight(30)
        possettbutton:SetMargin(Vector2(0, 2), Vector2(0, 5))
        possettbutton:SetText(self.locStrings["changechatpos"])
        possettbutton:Subscribe("Press", self, self.ChatPosChanger)

        local resetbutton = Button.Create(self.window)
        resetbutton:SetDock(GwenPosition.Top)
        resetbutton:SetHeight(30)
        resetbutton:SetMargin(Vector2.Zero, Vector2(0, 10))
        resetbutton:SetText(self.locStrings["restorechatpos"])
        resetbutton:Subscribe("Press", self, self.ChatPosReset)
        self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)

        local joinmessages_btn = Label.Create(self.window)
        joinmessages_btn:SetText(self.locStrings["showconnects"])
        joinmessages_btn:SetDock(GwenPosition.Top)
        joinmessages_btn:SetMargin(Vector2.Zero, Vector2(0, 5))
        joinmessages_btn:SizeToContents()

        self.joinmessages_cb = ComboBox.Create(self.window)
        self.joinmessages_cb:SetDock(GwenPosition.Top)
        self.joinmessages_cb:SetHeight(25)
        self.joinmessages_cb:AddItem(self.locStrings["sc_cb_1"], "0")
        self.joinmessages_cb:AddItem(self.locStrings["sc_cb_2"], "1")
        self.joinmessages_cb:AddItem(self.locStrings["sc_cb_3"], "2")

        local visibleJoinMessages = LocalPlayer:GetValue("VisibleJoinMessages")
        if visibleJoinMessages then
            self.joinmessages_cb:SelectItemByName(tostring(visibleJoinMessages))
        end
    else
        self:CloseWindow()
    end
end

function BetterChat:CloseWindow()
    Mouse:SetVisible(false)
    if self.window then
        self.window:Remove()
        self.window = nil

        Network:Send("ChangeChatSettings", {joinmessagesmode = tonumber(self.joinmessages_cb:GetSelectedItem():GetName())})

        self.joinmessages_cb:Remove()
        self.joinmessages_cb = nil

        Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil
    end
end

function BetterChat:ChatPosChanger()
    if not self.controlstipSh then
        local systemFonts = LocalPlayer:GetValue("SystemFonts")

        self.controlstipSh = Label.Create()
        self.controlstipSh:SetText(self.locStrings["tiptext"])
        self.controlstipSh:SetTextSize(20)
        self.controlstipSh:SetTextColor(Color.Black)
        if systemFonts then
            self.controlstipSh:SetFont(AssetLocation.SystemFont, "Impact")
        end
        self.controlstipSh:SizeToContents()
        self.controlstipSh:SetPosition(Vector2((Render.Size.x / 2) - (Render:GetTextSize(self.locStrings["tiptext"], 20).x / 2), 60))

        self.controlstip = Label.Create()
        self.controlstip:SetText(self.locStrings["tiptext"])
        self.controlstip:SetTextSize(20)
        if systemFonts then
            self.controlstip:SetFont(AssetLocation.SystemFont, "Impact")
        end
        self.controlstip:SizeToContents()
        self.controlstip:SetPosition(self.controlstipSh:GetPosition() - Vector2.One)
    end

    self.window:SetVisible(false)

    if not self.MouseUpEvent then
        self.MouseUpEvent = Events:Subscribe("MouseUp", self, self.MouseUp)
        self.MouseMoveEvent = Events:Subscribe("MouseMove", self, self.MouseMove)
    end
end

function BetterChat:MouseMove()
    Chat:SetPosition(Mouse:GetPosition())
end

function BetterChat:MouseUp(args)
    if args.button == 1 then
        if self.controlstipSh then
            self.controlstipSh:Remove()
            self.controlstipSh = nil
            self.controlstip:Remove()
            self.controlstip = nil
        end

        self.customchatpos = Mouse:GetPosition()
        Network:Send("SaveChatPos", {chatpos = self.customchatpos})
        self.window:SetVisible(true)

        if not self.ResolutionChangeEvent then self.ResolutionChangeEvent = Events:Subscribe("ResolutionChange", self, self.ResolutionChange)end

        if self.MouseUpEvent then
            Events:Unsubscribe(self.MouseUpEvent) self.MouseUpEvent = nil
            Events:Unsubscribe(self.MouseMoveEvent) self.MouseMoveEvent = nil
        end
    end
end

function BetterChat:ResolutionChange()
    Chat:SetPosition(self.customchatpos)
end

function BetterChat:ChatPosReset()
    Chat:ResetPosition()
    Network:Send("ResetChatPos")

    if self.ResolutionChangeEvent then Events:Unsubscribe(self.ResolutionChangeEvent) self.ResolutionChangeEvent = nil end
end

function BetterChat:Render()
    if Chat:GetActive() then
        if LocalPlayer:GetValue("SystemFonts") then
            Render:SetFont(AssetLocation.SystemFont, "Impact")
            self.chatmodelist:SetFont(AssetLocation.SystemFont, "Impact")
        end

        local chatPos = Chat:GetPosition()
        local textSize = 14

        local textWidth = Render:GetTextWidth(self.locStrings["chatmode"], textSize)
        local textHeight = Render:GetTextHeight(self.locStrings["chatmode"], textSize)

        local textPos = Vector2(chatPos.x, chatPos.y - textHeight - self.chatheight)

        -- Render:FillArea( Vector2( textPos.x - 4, textPos.y - textHeight / 2 ), Vector2( textWidth + self.chatmodelist:GetSize().x, textHeight * 2), Color( 10, 10, 10, 85 ) )

        self.chatmodelist:SetPosition(Vector2(textPos.x + textWidth + 1, textPos.y - textHeight / 5))

        Render:DrawShadowedText(textPos, self.locStrings["chatmode"], Color(215, 215, 215), Color(25, 25, 25, 150), textSize)

        if not self.chatactive then
            self.chatmodelist:Clear()
            self:CreateChatModeListItems()

            self.chatmodelist:SetVisible(true)
            self.chatactive = true
        end
    else
        if self.chatactive then
            self.chatmodelist:Clear()

            self.chatmodelist:SetVisible(false)
            self.chatactive = false
        end
    end

    if self.chatmodelist:GetVisible() then
        local selectedItem = self.chatmodelist:GetSelectedItem():GetText()

        if selectedItem == self.locStrings["tGlobal"] then
            self.toggle = 0
        elseif selectedItem == self.locStrings["tLocal"] then
            self.toggle = 1
        elseif selectedItem == self.locStrings["tClan"] then
            self.toggle = 2
        elseif selectedItem == self.locStrings["tPrefix"] then
            self.toggle = 3
        end

        Network:Send("Toggle", self.toggle)
    end
end

local betterchat = BetterChat()