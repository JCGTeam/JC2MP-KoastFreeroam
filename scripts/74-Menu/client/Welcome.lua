class 'WelcomeScreen'

function WelcomeScreen:Lang()
	self.continue = "Continue ( ͡° ͜ʖ ͡°)"
	self.helpRules = "Help/Rules"
	self.title = "Welcome to Koast Freeroam!"
	self.text = "We are glad to see you here, please read the rules and FAQ before starting the game.\n\n\n" ..
	"> Telegram channel - t.me/koastfreeroam\n" ..
	"> Discord server - clck.ru/37FZrU\n" ..
	"> Steam group - steamcommunity.com/groups/koastfreeroam\n" ..
	"> YouTube channel - www.youtube.com/@jcgteam\n\n\n" ..
	"Have a nice game, enjoy :)"
end

function WelcomeScreen:Open( lang )
	if self.isOpened then return end

	self.isOpened = true

	if lang and lang == "EN" then
		self:Lang()
	else
		self.continue = "Продолжить ( ͡° ͜ʖ ͡°)"
		self.title = "Добро пожаловать на Koast Freeroam!"
		self.helpRules = "Помощь/правила"
		self.text = "Мы рады, что вы зашли на наш проект, пожалуйста, прочитайте правила и FAQ перед началом игры.\n\n" ..
		"> Наш Telegram канал - t.me/koastfreeroam\n" ..
		"> Наш Discord сервер - clck.ru/37FZrU\n" ..
		"> Наша группа в Steam - steamcommunity.com/groups/koastfreeroam\n" ..
		"> Наш YouTube канал - www.youtube.com/@jcgteam\n\n" ..
		"Желаем вам приятной игры, наслаждайтесь :)"
	end

	self.copyright_txt = "© JCGTeam 2024"
	self.text_clr = Color.White
	self.background_clr = Color( 10, 10, 10, 200 )

	self.rico = Image.Create( AssetLocation.Resource, "Rico" )
	self.rico:SetSize( Vector2( Render.Size.x / 4, Render.Size.x / 2 ) )
	self.rico:SetPosition( Vector2( Render.Size.x - self.rico:GetSize().x + 10, Render.Size.y - self.rico:GetSize().y / 1.35 ) )

	if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
	if not self.ResolutionChangeEvent then self.ResolutionChangeEvent = Events:Subscribe( "ResolutionChange", self, self.ResolutionChange ) end
	if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end

	if not self.Menu_background then
		self.Menu_background = Rectangle.Create()
		self.Menu_background:SetHeight( Render.Size.x / 30 )
		self.Menu_background:SetWidth( Render.Size.x / 5 )
		self.Menu_background:SetPosition( Vector2( Render.Size.x / 2 - self.Menu_background:GetWidth() / 2, Render.Size.x / 2.7 ) )
		self.Menu_background:SetColor( Color( 255, 255, 255, 20 ) )
	end

	if not self.Menu_button then
		self.Menu_button = MenuItem.Create( self.Menu_background )
		self.Menu_button:SetDock( GwenPosition.Fill )
		self.Menu_button:SetText( self.continue )
		self.Menu_button:SetTextSize( 15 )
		self.Menu_button:Subscribe( "Press", self, self.Close )
	end

	if not self.Help_background then
		self.Help_background = Rectangle.Create()
		self.Help_background:SetHeight( Render.Size.x / 30 )
		self.Help_background:SetWidth( Render.Size.x / 5 )
		self.Help_background:SetPosition( self.Menu_background:GetPosition() + Vector2( 0, Render.Size.x / 25 ) )
		self.Help_background:SetColor( Color( 255, 255, 255, 20 ) )
	end

	if not self.Help_button then
		self.Help_button = MenuItem.Create( self.Help_background )
		self.Help_button:SetDock( GwenPosition.Fill )
		self.Help_button:SetText( self.helpRules )
		self.Help_button:SetTextSize( 15 )
		self.Help_button:Subscribe( "Press", function() Events:Fire( "OpenHelpMenu" ) end )
	end
end

function WelcomeScreen:LocalPlayerInput()
	return false
end

function WelcomeScreen:Render()
	Game:FireEvent( "ply.pause" )
	Game:FireEvent( "gui.hud.hide" )

	Mouse:SetVisible( true )
	Chat:SetEnabled( false )

	Render:FillArea( Vector2.Zero, Render.Size, self.background_clr )

	self.rico:Draw()

	if LocalPlayer:GetValue( "SystemFonts" ) then Render:SetFont( AssetLocation.SystemFont, "Impact" ) end

	Render:DrawText( Vector2( Render.Size.x / 2 - Render:GetTextWidth( self.title, Render.Size.x / 40 ) / 2, Render.Size.x / 7 ), self.title, self.text_clr, Render.Size.x / 40 )
	Render:DrawText( Vector2( Render.Size.x / 2 - Render:GetTextWidth( self.text, Render.Size.x / 70 ) / 2, Render.Size.x / 5 ), self.text, self.text_clr, Render.Size.x / 70 )
	Render:DrawText( Vector2( 20, Render.Height - Render:GetTextHeight( self.copyright_txt ) - 20 ), self.copyright_txt, self.text_clr, 15 )
end

function WelcomeScreen:ResolutionChange( args )
	self.rico:SetSize( Vector2( args.size.x / 4, args.size.x / 2 ) )
	self.rico:SetPosition( Vector2( args.size.x - self.rico:GetSize().x + 10, args.size.y - self.rico:GetSize().y / 1.35 ) )
end

function WelcomeScreen:Close()
	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	if self.ResolutionChangeEvent then Events:Unsubscribe( self.ResolutionChangeEvent ) self.ResolutionChangeEvent = nil end
	if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end

	if self.Menu_background then self.Menu_button:Remove() self.Menu_button = nil self.Menu_background:Remove() self.Menu_background = nil end
	if self.Help_button then self.Help_button:Remove() self.Help_button = nil end
	if self.Help_background then self.Help_background:Remove() self.Help_background = nil end
	if self.rico then self.rico = nil end

	self.isOpened = nil
	self.copyright_txt = nil
	self.text_clr = nil
	self.background_clr = nil

	Menu:Freeroam()

	local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 18,
				sound_id = 0,
				position = Camera:GetPosition(),
				angle = Angle()
	})

	sound:SetParameter(0,1)
end