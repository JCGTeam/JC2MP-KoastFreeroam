class 'Load'

function Load:__init()
	self.BackgroundImages = {
		Image.Create( AssetLocation.Resource, "BackgroundImage" ),
		Image.Create( AssetLocation.Resource, "BackgroundImageTw" ),
		Image.Create( AssetLocation.Resource, "BackgroundImageTh" ),
		Image.Create( AssetLocation.Resource, "BackgroundImageFo" ) ,
		Image.Create( AssetLocation.Resource, "BackgroundImageFi" ),
		Image.Create( AssetLocation.Resource, "BackgroundImageSi" )
	}

	self.BackgroundImage = self.BackgroundImages[math.random(#self.BackgroundImages)]
	self.LoadingCircle_Outer = Image.Create( AssetLocation.Game, "fe_initial_load_icon_dif.dds" )

	self.text_clr = Color.White
	self.text_shadow = Color( 0, 0, 0 )

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.name = "СОВЕТ: Нажмите [ B ], чтобы открыть меню сервера."
		self.wtitle = "ОШИБКА :С"
		self.wtext = "Возможно, вы застряли на экране загрузки. \nЖелаете покинуть сервер?"
		self.wbutton = "Покинуть сервер"
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "GameLoad", self, self.GameLoad )
	Events:Subscribe( "LocalPlayerDeath", self, self.LocalPlayerDeath )
	self.PostRenderEvent = Events:Subscribe( "PostRender", self, self.PostRender )

	self.IsJoining = false

	self.border_width = Vector2( Render.Width, 25 )
end

function Load:Lang()
	self.name = "TIP: Press [ B ] to open Server Menu."
	self.wtitle = "ERROR :С"
	self.wtext = "You maybe stuck on the loading screen. \nWant to leave the server?"
	self.wbutton = "Leave Server"
end

function Load:ModuleLoad()
	if Game:GetState() ~= GUIState.Loading then
		self.IsJoining = false
	else
		self.IsJoining = true
		self.FadeInTimer = Timer()
	end
end

function Load:GameLoad()
	self.FadeInTimer = nil

	if not self.PostRenderEvent then
		self.PostRenderEvent = Events:Subscribe( "PostRender", self, self.PostRender )
		self:WindowClosed()
	end
end

function Load:LocalPlayerDeath()
	self.BackgroundImage = self.BackgroundImages[math.random(#self.BackgroundImages)]
	self.FadeInTimer = Timer()
end

function Load:PostRender()
	if Game:GetState() == GUIState.Loading then
		local TxtSizePos = Render.Size.x / 0.55 / Render:GetTextWidth( "BTextResoliton" )
		local TxtSize = Render:GetTextSize( self.name, TxtSizePos )
		local CircleSize = Vector2( 70, 70 )
		local TransformOuter = Transform2()
		local TxtPos = Vector2( ( Render.Size.x/2 ) - ( TxtSize.x/2 ), Render.Size.y / 1.100 )
		local Rotation = self:GetRotation()
		local Pos = Vector2( 40, Render.Size.y / 1.075 )
		local PosTw = Vector2( Render.Width - 60, 60 )

		self.BackgroundImage:SetSize( Vector2( Render.Width, Render.Height ) )
		self.BackgroundImage:Draw()

		Render:FillArea( TxtPos - self.border_width, Vector2( Render.Width, 100 ) + self.border_width * 2, Color( 0, 0, 0, 150 ) )

		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		end
		Render:DrawShadowedText( Pos, self.name, self.text_clr, self.text_shadow, TxtSizePos )

		if self.FadeInTimer then
			TransformOuter:Translate( PosTw )
			TransformOuter:Rotate( math.pi * Rotation )

			Render:SetTransform( TransformOuter )
			self.LoadingCircle_Outer:Draw( -(CircleSize / 2), CircleSize, Vector2.Zero, Vector2.One )
			Render:ResetTransform()

			if self.FadeInTimer:GetMinutes() >= 1 then
				if self.PostRenderEvent then
					Events:Unsubscribe( self.PostRenderEvent )
					self.PostRenderEvent = nil
				end
				self:ExitWindow()
			end
		end
	end
end

function Load:ExitWindow()
	self.FadeInTimer = nil
	Mouse:SetVisible( true )

	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.2, 0.2 ) )
	self.window:SetMinimumSize( Vector2( 500, 200 ) )
	self.window:SetPositionRel( Vector2( 0.7, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetVisible( true )
	self.window:SetTitle( self.wtitle )
	self.window:Subscribe( "WindowClosed", self, self.WindowClosed )

	self.errorText = Label.Create( self.window )
	self.errorText:SetPosition( Vector2( 20, 30 ) )
	self.errorText:SetSize( Vector2( 450, 100 ) )
	self.errorText:SetText( self.wtext )
	self.errorText:SetTextSize( 20 )

	self.leaveButton = Button.Create( self.window )
	self.leaveButton:SetSize( Vector2( 100, 40 ) )
	self.leaveButton:SetDock( GwenPosition.Bottom )
	self.leaveButton:SetText( self.wbutton )
	self.leaveButton:Subscribe( "Press", self, self.Exit )
end

function Load:WindowClosed()
	if self.window then
		self.window:Remove()
		self.window = nil
	end

	if self.errorText then
		self.errorText:Remove()
		self.errorText = nil
	end

	if self.leaveButton then
		self.leaveButton:Remove()
		self.leaveButton = nil
	end

	Mouse:SetVisible( false )
end

function Load:Exit()
	self:WindowClosed()
	Network:Send( "KickPlayer" )
end

function Load:GetRotation()
	if self.FadeInTimer then
		local RotationValue = self.FadeInTimer:GetSeconds()* 3
		return RotationValue
	end
end

load = Load()