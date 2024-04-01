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

    self.coinflipimage = Image.Create( AssetLocation.Resource, "CoinFlipICO" )

	Network:Subscribe( "TextBox", self, self.TextBox )

	self.size = Vector2( 736, 472 )
    self:CreateWindow()

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	end

	Events:Subscribe( "Lang", self, self.Lang )
    Events:Subscribe( "OpenCasinoMenu", self, self.OpenCasinoMenu )
	Events:Subscribe( "CasinoMenuClosed", self, self.WindowClosed )
	Events:Subscribe( "LocalPlayerMoneyChange", self, self.LocalPlayerMoneyChange )
end

function Casino:Lang()
	if self.window then
		self.window:SetTitle( "▧ Casino" )
		self.largeName:SetText( "Casino" )
		self.coinflip.stavka_txt:SetText( "Your bet:" )
		self.coinflip.stavka_ok_btn:SetText( "$ MAKE A BET $" )
		self.coinflip.balance_txt:SetText( "Money: $" .. LocalPlayer:GetMoney() )
	end
end

function Casino:TextBox( args )
	self.coinflip.messages:SetVisible( true )
	self.coinflip.messages:SetText( args.text )
	if args.color then
		self.coinflip.messages:SetTextColor( args.color )

		local sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 20,
			sound_id = 20,
			position = LocalPlayer:GetPosition(),
			angle = Angle()
		})
	
		sound:SetParameter(0,1)
	else
		self.coinflip.messages:SetTextColor( Color.White )
	end
end

function Casino:UpdateMoneyString( money )
    if money == nil then
        money = LocalPlayer:GetMoney()
    end

    if LocalPlayer:GetValue( "Lang" ) then
		if LocalPlayer:GetValue( "Lang" ) == "RU" then
			self.coinflip.balance_txt:SetText( "Баланс: $" .. formatNumber( money ) )
		else
			self.coinflip.balance_txt:SetText( "Money: $" .. formatNumber( money ) )
		end
    end
end

function Casino:LocalPlayerMoneyChange( args )
    self:UpdateMoneyString( args.new_money )
end

function Casino:OpenCasinoMenu()
	if Game:GetState() ~= GUIState.Game then return end

    if self.window:GetVisible() then
        self:WindowClosed()
    else
        self.window:SetVisible( true )
        Mouse:SetVisible( true )

		if LocalPlayer:GetValue( "SystemFonts" ) then
			self.coinflip.balance_txt:SetFont( AssetLocation.SystemFont, "Impact" )
			self.coinflip.stavka_txt:SetFont( AssetLocation.SystemFont, "Impact" )
			self.coinflip.messages:SetFont( AssetLocation.SystemFont, "Impact" )
		end

        if not self.LocalPlayerInputEvent then
            self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
        end
    end
end

function Casino:CreateWindow()
    self.window = Window.Create()
    self.window:SetSize( self.size )
    self.window:SetPositionRel( Vector2( 0.75, 0.5 ) - self.window:GetSizeRel()/2 )
    self.window:SetTitle( "▧ Казино" )
    self.window:SetVisible( false )
    self.window:Subscribe( "WindowClosed", self, self.CasinoMenuClosed )

	local topAreaBackground = Rectangle.Create( self.window )
	topAreaBackground:SetPadding( Vector2.One * 2 , Vector2.One * 2 )
	topAreaBackground:SetDock( GwenPosition.Top )
	topAreaBackground:SetColor( Color( 160, 160, 160 ) )
	topAreaBackground:SetMargin( Vector2.Zero, Vector2( 0, 10 ) )

	local topArea = Rectangle.Create( topAreaBackground )
	topArea:SetPadding (Vector2( 6, 6 ), Vector2( 6, 6 ) )
	topArea:SetDock( GwenPosition.Top )
	topArea:SetColor( Color.FromHSV( 25, 0.95, 0.85 ) )

	self.largeName = Label.Create( topArea )
	self.largeName:SetMargin( Vector2(), Vector2( 0, -6 ) )
	self.largeName:SetDock( GwenPosition.Top )
	self.largeName:SetAlignment( GwenPosition.CenterH )
	self.largeName:SetTextSize( 42 )
	self.largeName:SetText( "Казино" )
	self.largeName:SizeToContents()

	topArea:SizeToChildren()
	topAreaBackground:SizeToChildren()

	self.coinflip = {}
	-- Conflip

	self.coinflip.scroll_control = ScrollControl.Create( self.window )
	self.coinflip.scroll_control:SetScrollable( false, true )
	self.coinflip.scroll_control:SetDock( GwenPosition.Fill )
	self.coinflip.scroll_control:SetVisible( false )

	self.coinflip.balance_txt = Label.Create( self.coinflip.scroll_control )
	self.coinflip.balance_txt:SetTextColor( Color( 251, 184, 41 ) )
	self.coinflip.balance_txt:SetDock( GwenPosition.Top )
	self.coinflip.balance_txt:SetText( "Баланс: $" .. LocalPlayer:GetMoney() )
	self.coinflip.balance_txt:SetTextSize( 20 )
	self.coinflip.balance_txt:SizeToContents()

	self.coinflip.stavka_txt = Label.Create( self.coinflip.scroll_control )
	self.coinflip.stavka_txt:SetDock( GwenPosition.Top )
	self.coinflip.stavka_txt:SetMargin( Vector2( 0, 15 ), Vector2.Zero )
	self.coinflip.stavka_txt:SetText( "Ваша ставка:" )
	self.coinflip.stavka_txt:SetTextSize( 15 )
	self.coinflip.stavka_txt:SizeToContents()

	self.coinflip.stavka = TextBoxNumeric.Create( self.coinflip.scroll_control )
	self.coinflip.stavka:SetDock( GwenPosition.Top )
	self.coinflip.stavka:SetMargin( Vector2( 10, 6 ), Vector2( 10, 0 ) )
	self.coinflip.stavka:SetTextSize( 30 )
	self.coinflip.stavka:SetSize( Vector2( 0, 40 ) )
	self.coinflip.stavka:Subscribe( "TextChanged", self, self.UpdateStavkaButton )
	self.coinflip.stavka:Subscribe( "Focus", self, self.Focus )
	self.coinflip.stavka:Subscribe( "Blur", self, self.Blur )

	self.coinflip.stavka_ok_btn = Button.Create( self.coinflip.scroll_control )
	self.coinflip.stavka_ok_btn:SetDock( GwenPosition.Top )
	self.coinflip.stavka_ok_btn:SetMargin( Vector2( 50, 15 ), Vector2( 50, 0 ) )
	self.coinflip.stavka_ok_btn:SetText( "$ СДЕЛАТЬ СТАВКУ $" )
	self.coinflip.stavka_ok_btn:SetTextSize( 18 )
	self.coinflip.stavka_ok_btn:SetSize( Vector2( 0, 40 ) )
	self.coinflip.stavka_ok_btn:Subscribe( "Press", self, self.StartCoinflip )

	self.coinflip.messages = Label.Create( self.coinflip.scroll_control )
	self.coinflip.messages:SetDock( GwenPosition.Top )
	self.coinflip.messages:SetAlignment( GwenPosition.CenterH )
	self.coinflip.messages:SetMargin( Vector2( 0, 10 ), Vector2.Zero )
	self.coinflip.messages:SetText( "" )
	self.coinflip.messages:SetTextSize( 20 )
	self.coinflip.messages:SizeToContents()

	--[[self.coinflip.bottomlabel = Label.Create( self.coinflip.scroll_control )
	self.coinflip.bottomlabel:SetDock( GwenPosition.Bottom )
	self.coinflip.bottomlabel:SetSize( Vector2( 0, 25 ) )

	self.coinflip.multiply_tip = Label.Create( self.coinflip.bottomlabel )
	self.coinflip.multiply_tip:SetDock( GwenPosition.Left )
	self.coinflip.multiply_tip:SetAlignment( GwenPosition.CenterV )
	self.coinflip.multiply_tip:SetText( "Чем выше множитель, тем выше награда, но меньше шансов выиграть." )
	self.coinflip.multiply_tip:SizeToContents()

	self.coinflip.multiply_combobox = ComboBox.Create( self.coinflip.bottomlabel )
	self.coinflip.multiply_combobox:SetDock( GwenPosition.Right )
	self.coinflip.multiply_combobox:SetSize( Vector2( 40, 10 ) )
	self.coinflip.multiply_combobox:AddItem( "X1" )
	self.coinflip.multiply_combobox:AddItem( "X2" )
	self.coinflip.multiply_combobox:AddItem( "X3" )
	self.coinflip.multiply_combobox:AddItem( "X4" )

	self.coinflip.multiply_text = Label.Create( self.coinflip.bottomlabel )
	self.coinflip.multiply_text:SetDock( GwenPosition.Right )
	self.coinflip.multiply_text:SetAlignment( GwenPosition.CenterV )
	self.coinflip.multiply_text:SetText( "МНОЖИТЕЛЬ: " )
	self.coinflip.multiply_text:SizeToContents()--]]

	self.coinflipmenu = true

	self.coinflip.stavka:DeleteText( 0, self.coinflip.stavka:GetTextLength() )
	self.coinflip.scroll_control:SetVisible( true )
end

function Casino:UpdateStavkaButton()
	if self.coinflip.stavka_ok_btn then
		if self.coinflip.stavka:GetValue() <= 0 or self.coinflip.stavka:GetValue() > CASINO_CONFIGURATION.COINFLIPLIMIT or LocalPlayer:GetMoney() < self.coinflip.stavka:GetValue() or string.find( self.coinflip.stavka:GetValue(), "%." ) then
			self.coinflip.stavka_ok_btn:SetEnabled( false )
		else
			self.coinflip.stavka_ok_btn:SetEnabled( true )
		end
	end
end

function Casino:StartCoinflip( args )
	if self.coinflip.stavka then
		Network:Send( "Coinflip", { stavka = self.coinflip.stavka:GetValue(), money = LocalPlayer:GetMoney() } )
		self:UpdateMoneyString( args.new_money )
		self:UpdateStavkaButton()
	end
end

function Casino:LocalPlayerInput( args )
	if args.input == Action.GuiPause then
		if self.window:GetVisible() == true then
			self:WindowClosed()
		end
	end

	if self.actions[args.input] then
		return false
	end
end

function Casino:Focus()
	Input:SetEnabled( false )
end

function Casino:Blur()
	Input:SetEnabled( true )
end

function Casino:WindowClosed()
    self.window:SetVisible( false )
    Mouse:SetVisible( false )

    if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end
end

function Casino:CasinoMenuClosed()
	self:WindowClosed()

	ClientEffect.Create(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

casino = Casino()