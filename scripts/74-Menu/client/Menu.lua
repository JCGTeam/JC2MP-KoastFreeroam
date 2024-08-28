class 'Menu'

function Menu:__init()
	self.rusflag = Image.Create( AssetLocation.Resource, "RusFlag" )
	self.engflag = Image.Create( AssetLocation.Resource, "EngFlag" )

	self.active = true
	self.hider = true

	self.text_clr = Color.White
	self.background_clr = Color( 10, 10, 10, 200 )

	self.tofreeroamtext = "Добро пожаловать в свободный режим!"
	self.tName = "ВЫБЕРИТЕ ЯЗЫК / LANGUAGE SELECT"

	local sizeX = Render.Size.x / 5.5
	local tPV1, tPV2 = Vector2( 0, Render.Size.x / 9 ), Vector2.Zero
	local textSize = Render.Size.x / 0.75 / Render:GetTextWidth( "BTextResoliton" )

	self.rus_image = ImagePanel.Create()
	self.rus_image:SetImage( self.rusflag )
	self.rus_image:SetSize( Vector2( sizeX, Render.Size.x / 9 ) )
	self.rus_image:SetPosition( Vector2( Render.Size.x / 2 - self.rus_image:GetSize().x / 2 * 2.15, Render.Size.y - Render.Size.x / 3.5 ) )
	self.rus_image:SetVisible( false )

	self.rus_button = MenuItem.Create()
	if LocalPlayer:GetValue( "SystemFonts" ) then
		self.rus_button:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	self.rus_button:SetSize( Vector2( sizeX, Render.Size.x / 7 ) )
	self.rus_button:SetPosition( self.rus_image:GetPosition() )
	self.rus_button:SetText( "Русский [RU]" )
	self.rus_button:SetTextPadding( tPV1, tPV2 )
	self.rus_button:SetTextSize( textSize )
	if LocalPlayer:GetMoney() <= 0.5 then
		self.rus_button:Subscribe( "Press", self, self.Welcome )
	else
		self.rus_button:Subscribe( "Press", self, self.Rus )
	end

	self.eng_image = ImagePanel.Create()
	self.eng_image:SetImage( self.engflag )
	self.eng_image:SetSize( Vector2( sizeX, Render.Size.x / 9 ) )
	local rus_button_pos = self.rus_button:GetPosition()
	self.eng_image:SetPosition( Vector2( rus_button_pos.x + Render.Size.x / 4.8, rus_button_pos.y ) )
	self.eng_image:SetVisible( false )

	self.eng_button = MenuItem.Create()
	if LocalPlayer:GetValue( "SystemFonts" ) then
		self.eng_button:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	self.eng_button:SetSize( Vector2( sizeX, Render.Size.x / 7 ) )
	self.eng_button:SetPosition( self.eng_image:GetPosition() )
	self.eng_button:SetText( "English [EN]" )
	self.eng_button:SetTextPadding( tPV1, tPV2 )
	self.eng_button:SetTextSize( textSize )
	self.eng_button:Subscribe( "Press", self, self.Eng )

	Console:Subscribe( "misload", self, self.Mission )

	self.ResolutionChangeEvent = Events:Subscribe( "ResolutionChange", self, self.ResolutionChange )
	self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
	self.LocalPlayerWorldChangeEvent = Events:Subscribe( "LocalPlayerWorldChange", self, self.LocalPlayerWorldChange )
	self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	self.ModuleUnloadEvent = Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )

	Game:FireEvent( "ply.pause" )

	if Game:GetState() ~= GUIState.Loading then
		self:GameLoad()
	else
		self.GameLoadEvent = Events:Subscribe( "GameLoad", self, self.GameLoad )
	end

	Chat:SetEnabled( false )

	local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 13,
				sound_id = 1,
				position = Camera:GetPosition(),
				angle = Angle()
	})

	sound:SetParameter(0,1)
end

function Menu:Mission( args )
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	if tonumber(args.text) == 1 then
		print( "Start msy.km01.completed" )
		print( "Please wait..." )
		Game:FireEvent( "msy.km01.completed" )
	elseif tonumber(args.text) == 6 then
		print( "Start msy.km06.completed" )
		print( "Please wait..." )
		Game:FireEvent( "msy.km06.completed" )
	end
end

function Menu:GameLoad()
	Mouse:SetPosition( Vector2( Render.Width / 2, Render.Height / 2 ) )
	Mouse:SetVisible( true )

	if LocalPlayer:GetValue( "SystemFonts" ) then
		self.rus_button:SetFont( AssetLocation.SystemFont, "Impact" )
		self.eng_button:SetFont( AssetLocation.SystemFont, "Impact" )
	end

	if self.GameLoadEvent then Events:Unsubscribe( self.GameLoadEvent ) self.GameLoadEvent = nil end

	local tag = LocalPlayer:GetValue( "Tag" )

	if tag == "Creator" then
		self.status = "  [Пошлый Создатель]"
	elseif tag == "GlAdmin" then
		self.status = "  [Гл. Админ]"
	elseif tag == "Admin" then
		self.status = "  [Админ]"
	elseif tag == "AdminD" then
		self.status = "  [Админ $]"
	elseif tag == "ModerD" then
		self.status = "  [Модератор $]"
	elseif tag == "Organizer" then
		self.status = "  [Организатор]"
	elseif tag == "Parther" then
		self.status = "  [Партнер]"
	elseif tag == "VIP" then
		self.status = "  [VIP]"
	elseif LocalPlayer:GetValue( "NT_TagName" ) then
		self.status = "  [" .. LocalPlayer:GetValue( "NT_TagName" ) .. "]"
	end
end

function Menu:ResolutionChange( args )
	local sizeX = args.size.x / 5.5
	local tPV1, tPV2 = Vector2( 0, args.size.x / 9 ), Vector2.Zero
	local textSize = args.size.x / 0.75 / Render:GetTextWidth( "BTextResoliton" )

	self.rus_image:SetSize( Vector2( sizeX, args.size.x / 9 ) )
	self.rus_image:SetPosition( Vector2( args.size.x / 2 - self.rus_image:GetSize().x / 2 * 2.15, ( args.size.y - args.size.x / 3.5 ) ) )

	self.rus_button:SetSize( Vector2( sizeX, args.size.x / 7 ) )
	self.rus_button:SetPosition( self.rus_image:GetPosition() )
	self.rus_button:SetTextPadding( tPV1, tPV2 )
	self.rus_button:SetTextSize( textSize )

	self.eng_image:SetSize( Vector2( sizeX, args.size.x / 9 ) )
	local rus_button_pos = self.rus_button:GetPosition()
	self.eng_image:SetPosition( Vector2( rus_button_pos.x + args.size.x / 4.8, rus_button_pos.y ) )

	self.eng_button:SetSize( Vector2( sizeX, args.size.x / 7 ) )
	self.eng_button:SetPosition( self.eng_image:GetPosition() )
	self.eng_button:SetTextPadding( tPV1, tPV2 )
	self.eng_button:SetTextSize( textSize )
end

function Menu:LocalPlayerWorldChange()
	self:SetActive( false )
end

function Menu:LocalPlayerInput()
	return false
end

function Menu:SetActive( active )
	if self.active ~= active then
		if not active then
			self:CleanUp()
			Game:FireEvent( "gui.hud.show" )
			Chat:SetEnabled( true )
			local sound = ClientSound.Create(AssetLocation.Game, {
						bank_id = 35,
						sound_id = 6,
						position = Camera:GetPosition(),
						angle = Angle()
			})

			sound:SetParameter(0,0.75)
			sound:SetParameter(1,0)
		end

		self.active = active
		Mouse:SetVisible( self.active )
    end
end

function Menu:Render()
	if self.active then
		Render:FillArea( Vector2.Zero, Render.Size, self.background_clr )

		Game:FireEvent( "gui.hud.hide" )
		Game:FireEvent( "gui.minimap.hide" )

		if self.ambsound then
			self.ambsound:SetParameter( 0, Game:GetSetting(GameSetting.MusicVolume) / 100 )
		end

		local versionTxt = "KMod Version: " .. tostring( LocalPlayer:GetValue( "KoastBuild" ) )

		if LocalPlayer:GetValue( "KoastBuild" ) then
			Render:DrawText( Vector2( ( Render.Width - Render:GetTextWidth( versionTxt, 15 ) - 30 ), Render.Size.y - 45 ), versionTxt, Color( 255, 255, 255, 100 ), 15 )
		end

		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		end

		local pNameTxt = LocalPlayer:GetName()
		local pNameSize = 17
		local pNamePos = Vector2( 20, Render.Size.y - 60 )
		local linksTitleTxt = "ССЫЛКИ / LINKS:"
		local linksSize = 25
		local linksPos = Vector2( 40, 50 )

		Render:DrawText( linksPos, linksTitleTxt, self.text_clr, linksSize )
		Render:DrawText( Vector2( linksPos.x, linksPos.y + Render:GetTextHeight( linksTitleTxt, linksSize ) + 10 ), "- TELEGRAM | t.me/koastfreeroam\n- DISCORD | clck.ru/37FZrU\n- STEAM | steamcommunity.com/groups/koastfreeroam\n- YouTube | www.youtube.com/@jcgteam", Color( 180, 180, 180 ), linksSize - 5 )

		local tSize = 30
		Render:DrawText( Vector2( Render.Size.x / 2 - Render:GetTextWidth( self.tName, tSize ) / 2, Render.Size.y / 2.5 ), self.tName, self.text_clr, tSize )

		LocalPlayer:GetAvatar():Draw( pNamePos, Vector2( 40, 40 ), Vector2.Zero, Vector2.One )

		Render:DrawText( pNamePos + Vector2( 50, 15 ), pNameTxt, self.text_clr, pNameSize )
		if self.status then
			Render:DrawText( pNamePos + Vector2( 50, 15 ) + Vector2( Render:GetTextWidth( pNameTxt, pNameSize ), 0 ), self.status, Color.DarkGray, pNameSize )
		end
	end

	if self.hider then
		local visiblity = Game:GetState() ~= GUIState.Loading

		self.rus_image:SetVisible( visiblity )
		self.rus_button:SetVisible( visiblity )
		self.eng_image:SetVisible( visiblity )
		self.eng_button:SetVisible( visiblity )
	end
end

function Menu:Freeroam()
	self:SetActive( false )

	Game:FireEvent( "ply.unpause" )
	if LocalPlayer:GetValue( "Passive" ) then
		Game:FireEvent( "ply.invulnerable" )
	end
	Network:Send( "SetFreeroam" )
	Events:Fire( "CastCenterText", { text = self.tofreeroamtext, time = 2, color = self.text_clr } )
end

function Menu:CleanUp()
	if self.ResolutionChangeEvent then Events:Unsubscribe( self.ResolutionChangeEvent ) self.ResolutionChangeEvent = nil end
	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	if self.LocalPlayerWorldChangeEvent then Events:Unsubscribe( self.LocalPlayerWorldChangeEvent ) self.LocalPlayerWorldChangeEvent = nil end
	if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
	if self.ModuleUnloadEvent then Events:Unsubscribe( self.ModuleUnloadEvent ) self.ModuleUnloadEvent = nil end
	if self.ambsound then self.ambsound:Remove() self.ambsound = nil end
	if self.rus_image then self.rus_image:Remove() self.rus_image = nil end
	if self.rus_button then self.rus_button:Remove() self.rus_button = nil end
	if self.eng_image then self.eng_image:Remove() self.eng_image = nil end
	if self.eng_button then self.eng_button:Remove() self.eng_button = nil end

	self.text_clr = nil
	self.background_clr = nil

	self.tofreeroamtext = nil
	self.tName = nil

	self.rusflag = nil
	self.engflag = nil
end

function Menu:ModuleUnload()
	self:CleanUp()
end

function Menu:Welcome()
    Network:Send( "SetRus" )
	WelcomeScreen:Open()

	self.hider = false
	self:SetActive( false )

	local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 18,
				sound_id = 0,
				position = Camera:GetPosition(),
				angle = Angle()
	})

	sound:SetParameter(0,1)
end

function Menu:Selected()
	self.hider = false

	self:Freeroam()

	local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 18,
				sound_id = 1,
				position = Camera:GetPosition(),
				angle = Angle()
	})

	sound:SetParameter(0,1)
end

function Menu:Rus()
	Network:Send( "SetRus" )

	local type = 0

	if type == 0 then
		Events:Fire( "OpenWhatsNew", { titletext = "Внимание!", text = "Данный сервер основан на открытом исходном коде и не является официальным.", usepause = true } )
	end

	self:Selected()
end

function Menu:Eng()
	Events:Fire( "SetEng" )
	Network:Send( "SetEng" )

	self.tofreeroamtext = "Welcome to freeroam mode!"

	Events:Fire( "Lang" )

	local type = 0

	if type == 0 then
		Events:Fire( "OpenWhatsNew", { titletext = "Warning!", text = "This server is based on open source code and is not official.", usepause = true } )
	end

	self:Selected()
end

menu = Menu()