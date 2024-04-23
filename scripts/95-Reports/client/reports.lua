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

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.sendbuttonsending_txt = "Отправка..."
		self.messageSuccessfullySended_txt = "Ваше сообщение успешно отправлено!"
	end

	Events:Subscribe( "Lang", self, self.Lang )
    Events:Subscribe( "OpenReportMenu", self, self.OpenReportMenu )
	Events:Subscribe( "CloseReportMenu", self, self.CloseReportMenu )

    Network:Subscribe( "SuccessfullySended", self, self.SuccessfullySended )
end

function Reports:CreateWindow()
    self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.3, 0.4 ) )
	self.window:SetMinimumSize( Vector2( 500, 455 ) )
	self.window:SetPositionRel( Vector2( 0.8, 0.5 ) - self.window:GetSizeRel()/2 )
    self.window:SetTitle( "▧ Обратная связь" )
    self.window:SetVisible( false )
    self.window:Subscribe( "WindowClosed", self, self.ReportMenuClosed )

    self.titleLabel = Label.Create( self.window )
    self.titleLabel:SetText( "ОБРАТНАЯ СВЯЗЬ" )
    self.titleLabel:SetTextSize( 30 )
    self.titleLabel:SetDock( GwenPosition.Top )
    self.titleLabel:SetAlignment( GwenPosition.CenterH )
    self.titleLabel:SetMargin( Vector2( 10, 20 ), Vector2( 10, 10 ) )
    self.titleLabel:SizeToContents()

    self.messageLabel = Label.Create( self.window )
    self.messageLabel:SetText( "Введите послание:" )
    self.messageLabel:SetDock( GwenPosition.Top )
	self.messageLabel:SetMargin( Vector2( 5, 0 ), Vector2( 5, 0 ) )
    self.messageLabel:SizeToContents()

    self.messageTextBox = TextBoxMultiline.Create( self.window )
    self.messageTextBox:SetDock( GwenPosition.Top )
    self.messageTextBox:SetHeight( 50 )
    self.messageTextBox:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )
	self.messageTextBox:Subscribe( "TextChanged", self, self.ChangelLText )
    self.messageTextBox:Subscribe( "Focus", self, self.Focus )
    self.messageTextBox:Subscribe( "Blur", self, self.Blur )
	self.messageTextBox:Subscribe( "EscPressed", self, self.EscPressed )

	self.messageSymbolsLimitLabel = Label.Create( self.window )
	self.messageSymbolsLimitLabel:SetText( "0/" .. self.maxmessagesymbols )
	self.messageSymbolsLimitLabel:SetDock( GwenPosition.Top )
	self.messageSymbolsLimitLabel:SetAlignment( GwenPosition.Right )
	self.messageSymbolsLimitLabel:SetMargin( Vector2( 0, 0 ), Vector2( 10, 0 ) )
	self.messageSymbolsLimitLabel:SizeToContents()

	self.eMailLabel = Label.Create( self.window )
    self.eMailLabel:SetText( "Почта для связи: (необязательно)" )
    self.eMailLabel:SetDock( GwenPosition.Top )
	self.eMailLabel:SetMargin( Vector2( 5, 0 ), Vector2( 5, 0 ) )
    self.eMailLabel:SizeToContents()

    self.eMailTextBox = TextBox.Create( self.window )
    self.eMailTextBox:SetDock( GwenPosition.Top )
	self.eMailTextBox:SetHeight( 25 )
    self.eMailTextBox:SetMargin( Vector2( 5, 5 ), Vector2( 5, 20 ) )
	self.eMailTextBox:Subscribe( "TextChanged", self, self.ChangelLText )
    self.eMailTextBox:Subscribe( "Focus", self, self.Focus )
    self.eMailTextBox:Subscribe( "Blur", self, self.Blur )
	self.eMailTextBox:Subscribe( "EscPressed", self, self.EscPressed )

    self.categoryLabel = Label.Create( self.window )
    self.categoryLabel:SetText( "Категория:" )
    self.categoryLabel:SetDock( GwenPosition.Top )
	self.categoryLabel:SetMargin( Vector2( 5, 0 ), Vector2( 5, 0 ) )
    self.categoryLabel:SizeToContents()

    self.categoryComboBox = ComboBox.Create( self.window )
    self.categoryComboBox:SetDock( GwenPosition.Top )
    self.categoryComboBox:SetHeight( 25 )
    self.categoryComboBox:SetMargin( Vector2( 5, 5 ), Vector2( 5, 15 ) )
    self.categoryComboBox:AddItem( "Жалобы" )
	self.categoryComboBox:AddItem( "Пожелания" )
	self.categoryComboBox:AddItem( "Сообщить об ошибке" )
	self.categoryComboBox:AddItem( "Оффтоп" )

    self.sendButton = Button.Create( self.window )
    self.sendButton:SetDock( GwenPosition.Bottom )
    self.sendButton:SetText( self.sendbutton_txt )
    self.sendButton:SetHeight( 30 )
	self.sendButton:SetEnabled( false )
    self.sendButton:Subscribe( "Press", self, self.ReportSend )

	self.infoLabel = Label.Create( self.window )
    self.infoLabel:SetText( "Пожалуйста, не спамьте и не флудите сообщениями, а также не оскорбляйте администрацию. В случае нарушения, вы можете получить блокировку аккаунта на сервере!\n\nАльтернативные способы связи:\nDiscord - [empty_link]\nTelegram - t.me/koastreport_bot\nSteam - [empty_link]\nVK - [empty_link]" )
    self.infoLabel:SetDock( GwenPosition.Fill )
	self.infoLabel:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )
	self.infoLabel:SetWrap( true )
end

function Reports:Lang()
	self.sendbutton_txt = "SEND"
	self.sendbuttonsending_txt = "SENDING..."
	self.messageSuccessfullySended_txt = "Your message was successfully sent!"

	if self.window then
		self.window:SetTitle( "▧ Feedback" )
		self.titleLabel:SetText( "FEEDBACK" )
		self.messageLabel:SetText( "Enter your message:" )
		self.eMailLabel:SetText( "Contact E-Mail: (optional)" )
		self.categoryLabel:SetText( "Category:" )
		self.categoryComboBox:Clear()
		self.categoryComboBox:AddItem( "Complaints" )
		self.categoryComboBox:AddItem( "Wishes" )
		self.categoryComboBox:AddItem( "Report a bug" )
		self.categoryComboBox:AddItem( "Offtopic" )
		self.sendButton:SetText( self.sendbutton_txt )
		self.infoLabel:SetText( "Please do not spam or flood messages, and do not insult the administration. In case of violation, you can get your account blocked on the server!\n\nAlternative contact methods:\nDiscord - [empty_link]\nTelegram - t.me/koastreport_bot\nSteam - [empty_link]\nVK - [empty_link]" )
	end
end

function Reports:ReportSend()
	if self.messageTextBox:GetText():len() <= self.maxmessagesymbols then
		Network:Send( "SendReport", { reportmessage = self.messageTextBox:GetText(), reportemail = self.eMailTextBox:GetText(), category = self.categoryComboBox:GetSelectedItem():GetText() } )

		self.sendButton:SetEnabled( false )
		self.sendButton:SetText( self.sendbuttonsending_txt )

		self.sending = true
	end
end

function Reports:SuccessfullySended()
	self.sendButton:SetText( self.sendbutton_txt)

    self.messageTextBox:SetText( "" )
	self.eMailTextBox:SetText( "" )

	self:ReportMenuClosed()

	self.sending = nil

	Events:Fire( "CastCenterText", { text = self.messageSuccessfullySended_txt, time = 3, color = Color( 255, 255, 255 ) } )
end

function Reports:ChangelLText()
	self.messageSymbolsLimitLabel:SetText( self.messageTextBox:GetText():len() .. "/" .. self.maxmessagesymbols )

	if self.messageTextBox:GetText():len() >= self.maxmessagesymbols then
		self.messageSymbolsLimitLabel:SetTextColor( Color.Red )
		self.sendButton:SetEnabled( false )
	else
		self.messageSymbolsLimitLabel:SetTextColor( Color.White )
		if not self.sending then
			if self.eMailTextBox:GetText() ~= "" then
				if self.messageTextBox:GetText() ~= "" then
					if self.eMailTextBox:GetText():len() >= self.maxemailsymbols then
						self.sendButton:SetEnabled( false )
					else
						local isValidEmail = string.match( self.eMailTextBox:GetText(), "^[%w!#%$%%&'%+%-^_`{|}%.=%?~]+@[%w%-]+%.[%w%-]+$" )

						self.sendButton:SetEnabled( isValidEmail ~= nil )
					end
				else
					self.sendButton:SetEnabled( false )
				end
			else
				self.sendButton:SetEnabled( ( self.messageTextBox:GetText() ~= "" ) and true or false )
			end
		end
	end
end

function Reports:Focus()
	Input:SetEnabled( false )
end

function Reports:Blur()
	Input:SetEnabled( true )
end

function Reports:EscPressed()
	self:Blur()

	if self.window:GetVisible() == true then
		self:WindowClosed()
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

        self.window:SetVisible( true )
        Mouse:SetVisible( true )

		if LocalPlayer:GetValue( "SystemFonts" ) then
			self.titleLabel:SetFont( AssetLocation.SystemFont, "Impact" )
		end

        if not self.LocalPlayerInputEvent then
            self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
        end

		if not self.RenderEvent then
			self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
		end
    end
end

function Reports:CloseReportMenu()
	if Game:GetState() ~= GUIState.Game then return end
	if self.window:GetVisible() == true then
		self:WindowClosed()
	end
end

function Reports:LocalPlayerInput( args )
	if args.input == Action.GuiPause then
		if self.window:GetVisible() == true then
			self:WindowClosed()
		end
	end

	if self.actions[args.input] then
		return false
	end
end

function Reports:Render()
	local is_visible = Game:GetState() == GUIState.Game

	if self.window:GetVisible() ~= is_visible then
		self.window:SetVisible( is_visible )
	end

	Mouse:SetVisible( is_visible )
end

function Reports:WindowClosed()
    self.window:SetVisible( false )

    Mouse:SetVisible( false )

    if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end

function Reports:ReportMenuClosed()
	self:WindowClosed()

	local effect = ClientEffect.Create(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

reports = Reports()
