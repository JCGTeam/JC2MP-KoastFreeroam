class 'GameModesMenu'

function GameModesMenu:__init()
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

	self.derbyimage = Image.Create( AssetLocation.Resource, "DerbyICO" )
	self.raceimage = Image.Create( AssetLocation.Resource, "RaceICO" )
	self.tronimage = Image.Create( AssetLocation.Resource, "TronICO" )
	self.kinghillimage = Image.Create( AssetLocation.Resource, "KingHillICO" )
	self.tetrisimage = Image.Create( AssetLocation.Resource, "TetrisICO" )
	self.pongimage = Image.Create( AssetLocation.Resource, "PongICO" )
	self.casinoimage = Image.Create( AssetLocation.Resource, "CasinoICO" )
	self.customimage = Image.Create( AssetLocation.Resource, "CustomICO" )

	self.resizer_txt = "Черный ниггер"
    self:CreateWindow()

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.customButton_txt = "Неизвестно"
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "OpenGameModesMenu", self, self.OpenGameModesMenu )
	Events:Subscribe( "CloseGameModesMenu", self, self.CloseGameModesMenu )
	Events:Subscribe( "AddCustomGameModeButton", self, self.AddCustomGameModeButton )
	Events:Subscribe( "RemoveCustomGameModeButton", self, self.RemoveCustomGameModeButton )
end

function GameModesMenu:Lang()
    self.window:SetTitle( "▧ Minigames" )
	self.mainButton.txtlabel_gm:SetText( "Game Modes:" )
	self.mainButton.race:SetText( "Race" )
	self.mainButton.race:SetToolTip( "Get first to the finish line among other riders." )
	self.mainButton.tron:SetText( "Tron" )
	self.mainButton.tron:SetToolTip( "Lure other players into your lane to win." )
	self.mainButton.khill:SetText( "King Of The Hill" )
	self.mainButton.khill:SetToolTip( "Get to the top of the hill first to win." )
	self.mainButton.derby:SetText( "Derby" )
	self.mainButton.derby:SetToolTip( "Crush the cars of other players trying to survive on your own." )
	self.mainButton.txtlabel_mg:SetText( "Others:" )
	self.mainButton.tetris:SetText( "Tetris" )
	self.mainButton.tetris:SetToolTip( "Classic tetris." )
	self.mainButton.pong:SetText( "Pong" )
	self.mainButton.pong:SetToolTip( "Enemy waiting you in pong." )
	self.mainButton.casino:SetText( "Casino" )
	self.mainButton.casino:SetToolTip( "Money gambling." )

	self.customButton_txt = "Unknown"
end

function GameModesMenu:CreateGameModesMenuButton( scroll, title, image, description, pos, event )
	local textSize = 19
	local textWidth = Render:GetTextWidth( self.resizer_txt, textSize )

	local gamemodesmenu_img = ImagePanel.Create( scroll )
	gamemodesmenu_img:SetImage( image )
	gamemodesmenu_img:SetPosition( Vector2( pos, 0 ) )
	gamemodesmenu_img:SetSize( Vector2( textWidth, textWidth ) )

	local gamemodesmenu_btn = MenuItem.Create( scroll )
	gamemodesmenu_btn:SetPosition( gamemodesmenu_img:GetPosition() )
	gamemodesmenu_btn:SetSize( Vector2( gamemodesmenu_img:GetSize().x, textWidth * 1.25 ) )
	gamemodesmenu_btn:SetText( title )
	gamemodesmenu_btn:SetTextPadding( Vector2( 0, textWidth ), Vector2.Zero )
	gamemodesmenu_btn:SetTextSize( textSize )
	gamemodesmenu_btn:SetToolTip( description )
	gamemodesmenu_btn:Subscribe( "Press", self, event )

	return gamemodesmenu_btn
end

function GameModesMenu:OpenGameModesMenu()
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

		self.mainButton.scroll_mg:SetSize( Vector2( self.window:GetSize().x - 15, self.mainButton.tetris:GetHeight() + 25 ) )

		if LocalPlayer:GetValue( "SystemFonts" ) then
			self.mainButton.race:SetFont( AssetLocation.SystemFont, "Impact" )
			self.mainButton.tron:SetFont( AssetLocation.SystemFont, "Impact" )
			self.mainButton.khill:SetFont( AssetLocation.SystemFont, "Impact" )
			self.mainButton.derby:SetFont( AssetLocation.SystemFont, "Impact" )
			self.mainButton.tetris:SetFont( AssetLocation.SystemFont, "Impact" )
			self.mainButton.pong:SetFont( AssetLocation.SystemFont, "Impact" )
			self.mainButton.casino:SetFont( AssetLocation.SystemFont, "Impact" )
			if self.mainButton.custom then
				self.mainButton.custom:SetFont( AssetLocation.SystemFont, "Impact" )
			end
		end

		if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end
    end
end

function GameModesMenu:CloseGameModesMenu()
	if Game:GetState() ~= GUIState.Game then return end
	if self.window:GetVisible() == true then
		self:WindowClosed()
	end
end

function GameModesMenu:CreateWindow()
    self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.5, 0.5 ) )
	self.window:SetMinimumSize( Vector2( 500, 442 ) )
	self.window:SetPositionRel( Vector2( 0.7, 0.5 ) - self.window:GetSizeRel()/2 )
    self.window:SetTitle( "▧ Развлечения" )
    self.window:SetVisible( false )
    self.window:Subscribe( "WindowClosed", self, self.GameModesMenuClosed )

    self.scroll_control = ScrollControl.Create( self.window )
	self.scroll_control:SetScrollable( false, true )
	self.scroll_control:SetDock( GwenPosition.Fill )

	local textSize = 19
	local textHeight = Render:GetTextHeight( self.resizer_txt, textSize )

    self.mainButton = {}

	self.mainButton.txtlabel_gm = Label.Create( self.scroll_control )
	self.mainButton.txtlabel_gm:SetText( "Игровые режимы:" )
	self.mainButton.txtlabel_gm:SetDock( GwenPosition.Top )
	local padding = Vector2( 5, 10 )
	self.mainButton.txtlabel_gm:SetMargin( padding, Vector2.Zero )
	self.mainButton.txtlabel_gm:SizeToContents()

	self.mainButton.scroll_gm = ScrollControl.Create( self.scroll_control )
	self.mainButton.scroll_gm:SetScrollable( true, false )
	self.mainButton.scroll_gm:SetSize( Vector2( self.window:GetSize().x - 15, textHeight * 10 ) )
	self.mainButton.scroll_gm:SetDock( GwenPosition.Top )
	self.mainButton.scroll_gm:SetMargin( padding, padding )

	local textWidth = Render:GetTextWidth( self.resizer_txt, textSize )

	local spacing = textWidth + 15
	self.mainButton.race = self:CreateGameModesMenuButton( self.mainButton.scroll_gm, "Гонки", self.raceimage, "Доберитесь первым до финиша среди прочих гонщиков.", 0, self.RaceToggle )
	self.mainButton.tron = self:CreateGameModesMenuButton( self.mainButton.scroll_gm, "Трон", self.tronimage, "Заманивайте других игроков в свою полосу, чтобы одержать победу.", self.mainButton.race:GetPosition().x + spacing, self.TronToggle )
	self.mainButton.khill = self:CreateGameModesMenuButton( self.mainButton.scroll_gm, "Царь горы", self.kinghillimage, "Доберитесь первым до вершины горы, чтобы одержать победу.", self.mainButton.tron:GetPosition().x + spacing, self.KHillToggle )
	self.mainButton.derby = self:CreateGameModesMenuButton( self.mainButton.scroll_gm, "Дерби", self.derbyimage, "Ушатывайте машины других игроков стараясь выжить сами.", self.mainButton.khill:GetPosition().x + spacing, self.DerbyToggle )

	self.mainButton.txtlabel_mg = Label.Create( self.scroll_control )
	self.mainButton.txtlabel_mg:SetText( "Прочие:" )
	self.mainButton.txtlabel_mg:SetDock( GwenPosition.Top )
	self.mainButton.txtlabel_mg:SetMargin( Vector2( 5, 0 ), Vector2.Zero )
	self.mainButton.txtlabel_mg:SizeToContents()

	spacing = textWidth / 1.2 + 15
	self.mainButton.scroll_mg = ScrollControl.Create( self.scroll_control )
	self.mainButton.scroll_mg:SetScrollable( true, false )
	self.mainButton.scroll_mg:SetSize( Vector2( self.window:GetSize().x - 15, textHeight * 9 ) )
	self.mainButton.scroll_mg:SetDock( GwenPosition.Top )
	self.mainButton.scroll_mg:SetMargin( padding, padding )

	self.mainButton.tetris_IMG = ImagePanel.Create( self.mainButton.scroll_mg )
	self.mainButton.tetris_IMG:SetImage( self.tetrisimage )
	self.mainButton.tetris_IMG:SetSize( Vector2( textWidth / 1.2, textWidth / 1.2 ) )

	local textPadding = Vector2( 0, textWidth / 1.15 )
	local height = textWidth * 1.25 / 1.15
	self.mainButton.tetris = MenuItem.Create( self.mainButton.scroll_mg )
	self.mainButton.tetris:SetPosition( self.mainButton.tetris_IMG:GetPosition() )
	self.mainButton.tetris:SetSize( Vector2( self.mainButton.tetris_IMG:GetSize().x, height ) )
	self.mainButton.tetris:SetText( "Тетрис" )
	self.mainButton.tetris:SetTextPadding( textPadding, Vector2.Zero )
	self.mainButton.tetris:SetTextSize( textSize )
	self.mainButton.tetris:SetToolTip( "Классический тетрис." )
	self.mainButton.tetris:Subscribe( "Press", self, self.TetrisToggle )

	self.mainButton.pong_IMG = ImagePanel.Create( self.mainButton.scroll_mg )
	self.mainButton.pong_IMG:SetImage( self.pongimage )
	self.mainButton.pong_IMG:SetPosition( Vector2( self.mainButton.tetris_IMG:GetPosition().x + spacing, 0 ) )
	self.mainButton.pong_IMG:SetSize( Vector2( textWidth / 1.2, textWidth / 1.2 ) )

	self.mainButton.pong = MenuItem.Create( self.mainButton.scroll_mg )
	self.mainButton.pong:SetPosition( self.mainButton.pong_IMG:GetPosition() )
	self.mainButton.pong:SetSize( Vector2( self.mainButton.pong_IMG:GetSize().x, height ) )
	self.mainButton.pong:SetText( "Понг" )
	self.mainButton.pong:SetTextPadding( textPadding, Vector2.Zero )
	self.mainButton.pong:SetTextSize( textSize )
	self.mainButton.pong:SetToolTip( "Соперник ждет вас в понг." )
	self.mainButton.pong:Subscribe( "Press", self, self.PongToggle )

	self.mainButton.casino_IMG = ImagePanel.Create( self.mainButton.scroll_mg )
	self.mainButton.casino_IMG:SetImage( self.casinoimage )
	self.mainButton.casino_IMG:SetPosition( Vector2( self.mainButton.pong_IMG:GetPosition().x + spacing, 0 ) )
	self.mainButton.casino_IMG:SetSize( Vector2( textWidth / 1.2, textWidth / 1.2 ) )

	self.mainButton.casino = MenuItem.Create( self.mainButton.scroll_mg )
	self.mainButton.casino:SetPosition( self.mainButton.casino_IMG:GetPosition() )
	self.mainButton.casino:SetSize( Vector2( self.mainButton.casino_IMG:GetSize().x, height ) )
	self.mainButton.casino:SetText( "Казино" )
	self.mainButton.casino:SetTextPadding( textPadding, Vector2.Zero )
	self.mainButton.casino:SetTextSize( textSize )
	self.mainButton.casino:SetToolTip( "Азартные игры на деньги." )
	self.mainButton.casino:Subscribe( "Press", self, self.CasinoToggle )
end

function GameModesMenu:AddCustomGameModeButton( args )
	if not self.mainButton.custom then
		local textSize = 19
		local textWidth = Render:GetTextWidth( self.resizer_txt, textSize )
		local spacing = textWidth + 15
		spacing = textWidth / 1.2 + 15

		self.mainButton.custom_IMG = ImagePanel.Create( self.mainButton.scroll_mg )
		self.mainButton.custom_IMG:SetImage( self.customimage )
		self.mainButton.custom_IMG:SetPosition( Vector2( self.mainButton.casino_IMG:GetPosition().x + spacing, 0 ) )
		self.mainButton.custom_IMG:SetSize( Vector2( textWidth / 1.2, textWidth / 1.2 ) )

		self.mainButton.custom = MenuItem.Create( self.mainButton.scroll_mg )
		self.mainButton.custom:SetPosition( self.mainButton.custom_IMG:GetPosition() )
		self.mainButton.custom:SetSize( Vector2( self.mainButton.custom_IMG:GetSize().x, textWidth * 1.25 / 1.15 ) )
		self.mainButton.custom:SetText( ( args and args.title ) or self.customButton_txt )
		self.mainButton.custom:SetTextPadding( Vector2( 0, textWidth / 1.15 ), Vector2.Zero )
		self.mainButton.custom:SetTextSize( textSize )
		if args then
			if args.description then
				self.mainButton.custom:SetToolTip( args.description )
			end
			if args.fireevent then
				self.customButtonEvent = self.mainButton.custom:Subscribe( "Press", function() self:CustomToggle( args.fireevent ) end )
			end
		end

		if LocalPlayer:GetValue( "SystemFonts" ) then
			self.mainButton.custom:SetFont( AssetLocation.SystemFont, "Impact" )
		end
	else
		self.mainButton.custom:SetText( ( args and args.title ) or self.customButton_txt )
		if args then
			if args.description then
				self.mainButton.custom:SetToolTip( args.description )
			end
			if args.fireevent then
				if self.customButtonEvent then self.mainButton.custom:Unsubscribe( self.customButtonEvent ) end
				self.customButtonEvent = self.mainButton.custom:Subscribe( "Press", function() self:CustomToggle( args.fireevent ) end )
			end
		end
	end
end

function GameModesMenu:RemoveCustomGameModeButton()
	if self.mainButton.custom_IMG then self.mainButton.custom_IMG:Remove() self.mainButton.custom_IMG = nil end
	if self.mainButton.custom then self.mainButton.custom:Remove() self.mainButton.custom = nil end
end

function GameModesMenu:RaceToggle()
	Events:Fire( "EnableRaceMenu" )
	self:GameModesMenuClosed()
end

function GameModesMenu:TronToggle()
	Network:Send( "GoTron" )
	self:GameModesMenuClosed()
end

function GameModesMenu:KHillToggle()
	Network:Send( "GoKHill" )
	self:GameModesMenuClosed()
end

function GameModesMenu:DerbyToggle()
	Network:Send( "GoDerby" )
	self:GameModesMenuClosed()
end

function GameModesMenu:TetrisToggle()
	Events:Fire( "TetrisToggle" )
	self:GameModesMenuClosed()
end

function GameModesMenu:PongToggle()
	local inPong = LocalPlayer:GetValue( "InPong" )
	LocalPlayer:SetValue( "InPong", not inPong )

	if not inPong then
		Network:Send( "GoPong" )
	else
		Network:Send( "LeavePong" )
	end

	self:GameModesMenuClosed()
end

function GameModesMenu:CasinoToggle()
	Events:Fire( "OpenCasinoMenu" )
	self:GameModesMenuClosed()
end

function GameModesMenu:CustomToggle( fireevent )
	Events:Fire( fireevent )
	self:GameModesMenuClosed()
end

function GameModesMenu:Render()
    local is_visible = Game:GetState() == GUIState.Game

    if self.window:GetVisible() ~= is_visible then
        self.window:SetVisible( is_visible )
    end

    Mouse:SetVisible( is_visible )
end

function GameModesMenu:LocalPlayerInput( args )
	if args.input == Action.GuiPause then
		if self.window:GetVisible() == true then
			self:WindowClosed()
		end
	end
	if self.actions[args.input] then
		return false
	end
end

function GameModesMenu:WindowClosed()
    self.window:SetVisible( false )

    Mouse:SetVisible( false )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
    if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
end

function GameModesMenu:GameModesMenuClosed()
	self:WindowClosed()

	local effect = ClientEffect.Create(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

gamemodesmenu = GameModesMenu()