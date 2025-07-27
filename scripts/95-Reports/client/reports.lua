class 'Reports'

function Reports:__init()
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

    self.maxmessagesymbols = 500
    self.maxemailsymbols = 50

    self.sendbutton_txt = "Отправить"

    self:CreateWindow()

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            sendbuttonsending = "Отправка...",
            messageSuccessfullySended = "Ваше сообщение успешно отправлено!"
        }
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("LocalPlayerChat", self, self.LocalPlayerChat)
    Events:Subscribe("OpenReportMenu", self, self.OpenReportMenu)
    Events:Subscribe("CloseReportMenu", self, self.CloseReportMenu)

    Network:Subscribe("SuccessfullySended", self, self.SuccessfullySended)
end

function Reports:CreateWindow()
    self.window = Window.Create()
    self.window:SetSizeRel(Vector2(0.3, 0.4))
    self.window:SetMinimumSize(Vector2(500, 455))
    self.window:SetPositionRel(Vector2(0.8, 0.5) - self.window:GetSizeRel() / 2)
    self.window:SetTitle("▧ Обратная связь")
    self.window:SetVisible(false)
    self.window:Subscribe("WindowClosed", self, self.ReportMenuClosed)

    self.scroll = ScrollControl.Create(self.window)
    self.scroll:SetDock(GwenPosition.Fill)
    self.scroll:SetScrollable(false, true)

    self.titleLabel = Label.Create(self.scroll)
    self.titleLabel:SetText("ОБРАТНАЯ СВЯЗЬ")
    self.titleLabel:SetTextSize(30)
    self.titleLabel:SetDock(GwenPosition.Top)
    self.titleLabel:SetAlignment(GwenPosition.CenterH)
    local margin = Vector2(10, 20)
    self.titleLabel:SetMargin(margin, margin)
    self.titleLabel:SizeToContents()

    self.messageLabel = Label.Create(self.scroll)
    self.messageLabel:SetText("Введите послание:")
    self.messageLabel:SetDock(GwenPosition.Top)
    local margin = Vector2(5, 0)
    self.messageLabel:SetMargin(margin, margin)
    self.messageLabel:SizeToContents()

    self.messageTextBox = TextBoxMultiline.Create(self.scroll)
    self.messageTextBox:SetDock(GwenPosition.Top)
    self.messageTextBox:SetHeight(50)
    local margin = Vector2(5, 5)
    self.messageTextBox:SetMargin(margin, margin)
    self.messageTextBox:Subscribe("TextChanged", self, self.ChangelLText)
    self.messageTextBox:Subscribe("Focus", self, self.Focus)
    self.messageTextBox:Subscribe("Blur", self, self.Blur)
    self.messageTextBox:Subscribe("EscPressed", self, self.EscPressed)

    self.messageSymbolsLimitLabel = Label.Create(self.scroll)
    self.messageSymbolsLimitLabel:SetText("0/" .. self.maxmessagesymbols)
    self.messageSymbolsLimitLabel:SetDock(GwenPosition.Top)
    self.messageSymbolsLimitLabel:SetAlignment(GwenPosition.Right)
    self.messageSymbolsLimitLabel:SetMargin(Vector2.Zero, Vector2(10, 0))
    self.messageSymbolsLimitLabel:SizeToContents()

    self.eMailLabel = Label.Create(self.scroll)
    self.eMailLabel:SetText("Почта для связи: (необязательно)")
    self.eMailLabel:SetDock(GwenPosition.Top)
    self.eMailLabel:SetMargin(Vector2(5, 0), Vector2(5, 0))
    self.eMailLabel:SizeToContents()

    self.eMailTextBox = TextBox.Create(self.scroll)
    self.eMailTextBox:SetDock(GwenPosition.Top)
    self.eMailTextBox:SetHeight(25)
    self.eMailTextBox:SetMargin(Vector2(5, 5), Vector2(5, 20))
    self.eMailTextBox:Subscribe("TextChanged", self, self.ChangelLText)
    self.eMailTextBox:Subscribe("Focus", self, self.Focus)
    self.eMailTextBox:Subscribe("Blur", self, self.Blur)
    self.eMailTextBox:Subscribe("EscPressed", self, self.EscPressed)

    self.categoryLabel = Label.Create(self.scroll)
    self.categoryLabel:SetText("Категория:")
    self.categoryLabel:SetDock(GwenPosition.Top)
    local margin = Vector2(5, 0)
    self.categoryLabel:SetMargin(margin, margin)
    self.categoryLabel:SizeToContents()

    self.categoryComboBox = ComboBox.Create(self.scroll)
    self.categoryComboBox:SetDock(GwenPosition.Top)
    self.categoryComboBox:SetHeight(25)
    self.categoryComboBox:SetMargin(Vector2(5, 5), Vector2(5, 15))
    self.categoryComboBox:AddItem("Жалобы")
    self.categoryComboBox:AddItem("Пожелания")
    self.categoryComboBox:AddItem("Сообщить об ошибке")
    self.categoryComboBox:AddItem("Оффтоп")

    self.sendButton = Button.Create(self.window)
    self.sendButton:SetDock(GwenPosition.Bottom)
    self.sendButton:SetText(self.sendbutton_txt)
    self.sendButton:SetHeight(30)
    self.sendButton:SetEnabled(false)
    self.sendButton:Subscribe("Press", self, self.ReportSend)

    self.infoLabel = Label.Create(self.scroll)
    self.infoLabel:SetText("Пожалуйста, не спамьте и не флудите сообщениями, а также не оскорбляйте администрацию. В случае нарушения, вы можете получить блокировку аккаунта на сервере!\n\nАльтернативные способы связи:\nDiscord - t.me/koastfreeroam/197 (ссылка+способ восстановления работы Discord)\nTelegram - t.me/koastreport_bot\nSteam - steamcommunity.com/groups/koastfreeroam")
    self.infoLabel:SetDock(GwenPosition.Fill)
    self.infoLabel:SetMargin(Vector2(5, 5), Vector2(5, 5))
    self.infoLabel:SetWrap(true)
    self.infoLabel:Subscribe("PostRender", function() self.infoLabel:SizeToContents() end)
end

function Reports:Lang()
    self.sendbutton_txt = "SEND"

    self.locStrings = {
        sendbuttonsending = "SENDING...",
        messageSuccessfullySended = "Your message was successfully sent!"
    }

    if self.window then
        self.window:SetTitle("▧ Feedback")
        self.titleLabel:SetText("FEEDBACK")
        self.messageLabel:SetText("Enter your message:")
        self.eMailLabel:SetText("Contact E-Mail: (optional)")
        self.categoryLabel:SetText("Category:")
        self.categoryComboBox:Clear()
        self.categoryComboBox:AddItem("Complaints")
        self.categoryComboBox:AddItem("Wishes")
        self.categoryComboBox:AddItem("Report a bug")
        self.categoryComboBox:AddItem("Offtopic")
        self.sendButton:SetText(self.sendbutton_txt)
        self.infoLabel:SetText("Please do not spam or flood messages, and do not insult the administration. In case of violation, you can get your account blocked on the server!\n\nAlternative contact methods:\nDiscord - discord.me/koastfreeroam\nTelegram - t.me/koastreport_bot\nSteam - steamcommunity.com/groups/koastfreeroam")
    end
end

function Reports:ReportSend()
    if self.messageTextBox:GetText():len() <= self.maxmessagesymbols then
        Network:Send("SendReport", {reportmessage = self.messageTextBox:GetText(), reportemail = self.eMailTextBox:GetText(), category = self.categoryComboBox:GetSelectedItem():GetText()})

        self.sendButton:SetEnabled(false)
        self.sendButton:SetText(self.locStrings["sendbuttonsending"])

        self.sending = true
    end
end

function Reports:SuccessfullySended()
    self.sendButton:SetText(self.sendbutton_txt)

    self.messageTextBox:SetText("")
    self.eMailTextBox:SetText("")

    self:ReportMenuClosed()

    self.sending = nil

    Events:Fire("CastCenterText", {text = self.locStrings["messageSuccessfullySended"], time = 3, color = Color(255, 255, 255)})
end

function Reports:ChangelLText()
    self.messageSymbolsLimitLabel:SetText(self.messageTextBox:GetText():len() .. "/" .. self.maxmessagesymbols)

    if self.messageTextBox:GetText():len() >= self.maxmessagesymbols then
        self.messageSymbolsLimitLabel:SetTextColor(Color.Red)
        self.sendButton:SetEnabled(false)
    else
        self.messageSymbolsLimitLabel:SetTextColor(Color.White)
        if not self.sending then
            if self.eMailTextBox:GetText() ~= "" then
                if self.messageTextBox:GetText() ~= "" then
                    if self.eMailTextBox:GetText():len() >= self.maxemailsymbols then
                        self.sendButton:SetEnabled(false)
                    else
                        local isValidEmail = string.match(self.eMailTextBox:GetText(), "^[%w!#%$%%&'%+%-^_`{|}%.=%?~]+@[%w%-]+%.[%w%-]+$")

                        self.sendButton:SetEnabled(isValidEmail ~= nil)
                    end
                else
                    self.sendButton:SetEnabled(false)
                end
            else
                self.sendButton:SetEnabled((self.messageTextBox:GetText() ~= "") and true or false)
            end
        end
    end
end

function Reports:Focus()
    Input:SetEnabled(false)
end

function Reports:Blur()
    Input:SetEnabled(true)
end

function Reports:EscPressed()
    self:Blur()

    if self.window:GetVisible() then
        self:WindowClosed()
    end
end

function Reports:LocalPlayerChat(args)
    local cmd_args = args.text:split(" ")

    if cmd_args[1] == "/report" then
        self:OpenReportMenu()
    end
end

function Reports:OpenReportMenu()
    if Game:GetState() ~= GUIState.Game then return end

    if self.window:GetVisible() then
        self:WindowClosed()
    else
        local effect = ClientEffect.Play(AssetLocation.Game, {
            effect_id = 382,

            position = Camera:GetPosition(),
            angle = Angle()
        })

        self.window:SetVisible(true)
        Mouse:SetVisible(true)

        if LocalPlayer:GetValue("SystemFonts") then
            self.titleLabel:SetFont(AssetLocation.SystemFont, "Impact")
        end

        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
        if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
    end
end

function Reports:CloseReportMenu()
    if self.window:GetVisible() then
        self:WindowClosed()
    end
end

function Reports:LocalPlayerInput(args)
    if args.input == Action.GuiPause then
        if self.window:GetVisible() then
            self:WindowClosed()
        end
    end

    if self.actions[args.input] then
        return false
    end
end

function Reports:Render()
    local is_visible = Game:GetState() == GUIState.Game
    local window = self.window
    local windowGetVisible = window:GetVisible()

    if windowGetVisible ~= is_visible then
        self.window:SetVisible(is_visible)
        Mouse:SetVisible(is_visible)
    end
end

function Reports:WindowClosed()
    self.window:SetVisible(false)

    Mouse:SetVisible(false)

    if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
    if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
end

function Reports:ReportMenuClosed()
    self:WindowClosed()

    local effect = ClientEffect.Create(AssetLocation.Game, {
        effect_id = 383,

        position = Camera:GetPosition(),
        angle = Angle()
    })
end

local reports = Reports()