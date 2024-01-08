class 'WelcomeScreen'

function WelcomeScreen:__init()
	Events:Subscribe( "Lang", self, self.Lang )
end

function WelcomeScreen:Lang()
	if self.Menu_button then
		self.Menu_button:SetText( "Continue ( ͡° ͜ʖ ͡°)" )
	end
end

function WelcomeScreen:Open()
	self.title = "Добро пожаловать на Koast Freeroam!"
	self.text = "Мы рады, что вы зашли на наш проект, пожалуйста, прочитайте правила и FAQ перед началом игры.\n\n" ..
	"> Наша группа в VK - [empty_link]\n" ..
	"> Наша группа в Steam - [empty_link]\n" ..
	"> Наш Discord сервер - [empty_link]\n" ..
	"> Наш Telegram канал - [empty_link]\n\n" ..
	"Желаем вам приятной игры, наслаждайтесь :)"

	if not self.RenderEvent then
		self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
	end

	if not self.LocalPlayerInputEvent then
		self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	end

	self.rico = Image.Create( AssetLocation.Resource, "Rico" )

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
		self.Menu_button:SetText( "Продолжить ( ͡° ͜ʖ ͡°)" )
		self.Menu_button:SetTextSize( 15 )
		self.Menu_button:Subscribe( "Press", self, self.Menu )
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
		self.Help_button:SetText( "Помощь/правила" )
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
	Render:FillArea( Vector2.Zero, Render.Size, Color( 10, 10, 10, 200 ) )

	self.rico:SetPosition( Vector2( (Render.Width - 350), (Render.Height - 520) ) )
	self.rico:SetSize( Vector2( 350, 700 ) )
	self.rico:Draw()

	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end

	Render:DrawText( Vector2( Render.Size.x / 2 - Render:GetTextWidth( self.title, Render.Size.x / 40 ) / 2, Render.Size.x / 7 ), self.title, Color.White, Render.Size.x / 40 )
	Render:DrawText( Vector2( Render.Size.x / 2 - Render:GetTextWidth( self.text, Render.Size.x / 70 ) / 2, Render.Size.x / 5 ), self.text, Color.White, Render.Size.x / 70 )
	Render:DrawText( Vector2( 20, (Render.Height - 40) ), "© JCGTeam 2024", Color.White, 15 )
end

function WelcomeScreen:Menu()
	if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end

	if self.RenderEvent then
		Events:Unsubscribe( self.RenderEvent )
		self.RenderEvent = nil
	end

	if self.Menu_background then
		self.Menu_button:Remove()
		self.Menu_button = nil
		self.Menu_background:Remove()
		self.Menu_background = nil
	end

	if self.Help_button then
		self.Help_button:Remove()
		self.Help_button = nil
	end

	if self.Help_background then
		self.Help_background:Remove()
		self.Help_background = nil
	end

	if self.rico then
		self.rico = nil
	end

	Menu:Freeroam()

	local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 18,
				sound_id = 0,
				position = Camera:GetPosition(),
				angle = Angle()
	})

	sound:SetParameter(0,1)
end

welcomescreen = WelcomeScreen()
