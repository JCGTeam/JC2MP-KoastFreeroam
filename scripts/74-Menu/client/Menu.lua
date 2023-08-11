class 'Menu'

function Menu:__init()
	self.rusflag = Image.Create( AssetLocation.Resource, "RusFlag" )
	self.engflag = Image.Create( AssetLocation.Resource, "EngFlag" )

	self:GameLoad()

	self.upgrade = true
	self.hider = true

	self.sbar = Color.Gold

	self.active = true

	self.tofreeroamtext = "Добро пожаловать в свободный режим!"
	self.tName = "ВЫБЕРИТЕ ЯЗЫК / LANGUAGE SELECT"

	self.rus_image = ImagePanel.Create()
	self.rus_image:SetImage( self.rusflag )
	self.rus_image:SetPosition( Vector2( Render.Size.x / 3.5, Render.Size.y - Render.Size.x / 3.5 ) )
	self.rus_image:SetSize( Vector2( Render.Size.x / 5.5, Render.Size.x / 9 ) )
	self.rus_image:SetVisible( false )

	self.rus_button = MenuItem.Create()
	if LocalPlayer:GetValue( "SystemFonts" ) then
		self.rus_button:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	self.rus_button:SetSize( Vector2( Render.Size.x / 5.5, Render.Size.x / 7 ) )
	self.rus_button:SetPosition( self.rus_image:GetPosition() )
	self.rus_button:SetText( "Русский [RU]" )
	self.rus_button:SetTextPadding( Vector2( 0, Render.Size.x / 9 ), Vector2.Zero )
	self.rus_button:SetTextSize( Render.Size.x / 0.75 / Render:GetTextWidth( "BTextResoliton" ) )
	if LocalPlayer:GetMoney() <= 0.5 then
		self.rus_button:Subscribe( "Press", self, self.Welcome )
	else
		self.rus_button:Subscribe( "Press", self, self.Rus )
	end

	self.eng_image = ImagePanel.Create()
	self.eng_image:SetImage( self.engflag )
	self.eng_image:SetPosition( Vector2( self.rus_button:GetPosition().x + Render.Size.x / 4.8, self.rus_button:GetPosition().y ) )
	self.eng_image:SetSize( Vector2( Render.Size.x / 5.5, Render.Size.x / 9 ) )
	self.eng_image:SetVisible( false )

	self.eng_button = MenuItem.Create()
	if LocalPlayer:GetValue( "SystemFonts" ) then
		self.eng_button:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	self.eng_button:SetSize( Vector2( Render.Size.x / 5.5, Render.Size.x / 7 ) )
	self.eng_button:SetPosition( self.eng_image:GetPosition() )
	self.eng_button:SetText( "English [EN]" )
	self.eng_button:SetToolTip( "Not full. Recommended playing on Alpha's Salt Factory" )
	self.eng_button:SetTextPadding( Vector2( 0, Render.Size.x / 9 ), Vector2.Zero )
	self.eng_button:SetTextSize( Render.Size.x / 0.75 / Render:GetTextWidth( "BTextResoliton" ) )
	self.eng_button:Subscribe( "Press", self, self.Eng )

	Console:Subscribe( "misload", self, self.Mission )

	self.ResolutionChangeEvent = Events:Subscribe( "ResolutionChange", self, self.ResolutionChange )
	self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
	self.GameLoadEvent = Events:Subscribe( "GameLoad", self, self.GameLoad )
	self.LocalPlayerWorldChangeEvent = Events:Subscribe( "LocalPlayerWorldChange", self, self.LocalPlayerWorldChange )
	self.ModuleLoadEvent = Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	self.ModuleUnloadEvent = Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
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
	if LocalPlayer:GetValue( "Tag" ) == "Creator" then
		self.status = "  [Пошлый Создатель]"
	elseif LocalPlayer:GetValue( "Tag" ) == "GlAdmin" then
		self.status = "  [Гл. Админ]"
	elseif LocalPlayer:GetValue( "Tag" ) == "Admin" then
		self.status = "  [Админ]"
	elseif LocalPlayer:GetValue( "Tag" ) == "AdminD" then
		self.status = "  [Админ $]"
	elseif LocalPlayer:GetValue( "Tag" ) == "ModerD" then
		self.status = "  [Модератор $]"
	elseif LocalPlayer:GetValue( "Tag" ) == "VIP" then
		self.status = "  [VIP]"
	elseif LocalPlayer:GetValue( "Tag" ) == "YouTuber" then
		self.status = "  [YouTube Деятель]"
	elseif LocalPlayer:GetValue( "NT_TagName" ) then
		self.status = "  [" .. LocalPlayer:GetValue( "NT_TagName" ) .. "]"
	end
end

function Menu:ResolutionChange( args )
	self.rus_image:SetPosition( Vector2( args.size.x / 3.5, (args.size.y - args.size.x / 3.5 ) ) )
	self.rus_image:SetSize( Vector2( args.size.x / 5.5, args.size.x / 9 ) )

	self.rus_button:SetSize( Vector2( args.size.x / 5.5, args.size.x / 7 ) )
	self.rus_button:SetPosition( self.rus_image:GetPosition() )
	self.rus_button:SetTextPadding( Vector2( 0, args.size.x / 9 ), Vector2.Zero )
	self.rus_button:SetTextSize( args.size.x / 0.75 / Render:GetTextWidth( "BTextResoliton" ) )

	self.eng_image:SetPosition( Vector2( self.rus_button:GetPosition().x + args.size.x / 4.8, self.rus_button:GetPosition().y ) )
	self.eng_image:SetSize( Vector2( args.size.x / 5.5, args.size.x / 9 ) )

	self.eng_button:SetSize( Vector2( args.size.x / 5.5, args.size.x / 7 ) )
	self.eng_button:SetPosition( self.eng_image:GetPosition() )
	self.eng_button:SetTextPadding( Vector2( 0, args.size.x / 9 ), Vector2.Zero )
	self.eng_button:SetTextSize( args.size.x / 0.75 / Render:GetTextWidth( "BTextResoliton" ) )
end

function Menu:LocalPlayerWorldChange( args )
	self:Close()
end

function Menu:ModuleLoad()
	Game:FireEvent( "ply.pause" )
	Mouse:SetVisible( true )
	Chat:SetEnabled( false )

	local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 13,
				sound_id = 1,
				position = Camera:GetPosition(),
				angle = Angle()
	})

	sound:SetParameter(0,1)
end

function Menu:LocalPlayerInput( args )
	return false
end

function Menu:GetActive()
	return self.active
end

function Menu:SetActive( active )
	if self.active ~= active then
		if not active then
			if self.ResolutionChangeEvent then
				Events:Unsubscribe( self.ResolutionChangeEvent )
				self.ResolutionChangeEvent = nil
			end

			if self.RenderEvent then
				Events:Unsubscribe( self.RenderEvent )
				self.RenderEvent = nil
			end

			if self.GameLoadEvent then
				Events:Unsubscribe( self.GameLoadEvent )
				self.GameLoadEvent = nil
			end

			if self.LocalPlayerWorldChangeEvent then
				Events:Unsubscribe( self.LocalPlayerWorldChangeEvent )
				self.LocalPlayerWorldChangeEvent = nil
			end

			if self.ModuleLoadEvent then
				Events:Unsubscribe( self.ModuleLoadEvent )
				self.ModuleLoadEvent = nil
			end

			if self.LocalPlayerInputEvent then
				Events:Unsubscribe( self.LocalPlayerInputEvent )
				self.LocalPlayerInputEvent = nil
			end

			if self.ModuleUnloadEvent then
				Events:Unsubscribe( self.ModuleUnloadEvent )
				self.ModuleUnloadEvent = nil
			end

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
		Game:FireEvent( "gui.hud.hide" )
		Render:FillArea( Vector2.Zero, Render.Size, Color( 10, 10, 10, 200 ) )

		if self.ambsound then
			self.ambsound:SetParameter( 0, Game:GetSetting(GameSetting.MusicVolume) / 100 )
		end
	end

	if self.hider then
		if Game:GetState() ~= GUIState.Loading then
			self.rus_image:SetVisible( true )
			self.rus_button:SetVisible( true )
			self.eng_image:SetVisible( true )
			self.eng_button:SetVisible( true )
			if LocalPlayer:GetValue( "SystemFonts" ) then
				self.rus_button:SetFont( AssetLocation.SystemFont, "Impact" )
				self.eng_button:SetFont( AssetLocation.SystemFont, "Impact" )
			end
		else
			self.rus_image:SetVisible( false )
			self.rus_button:SetVisible( false )
			self.eng_image:SetVisible( false )
			self.eng_button:SetVisible( false )
		end
	end

	if self.active then
		local version_txt = "KMod Version: " .. tostring( LocalPlayer:GetValue( "KoastBuild" ) )

		if self.upgrade then
			Game:FireEvent( "gui.minimap.hide" )
		end
		if LocalPlayer:GetValue( "KoastBuild" ) then
			Render:DrawText( Vector2( (Render.Width - Render:GetTextWidth( version_txt, 15 ) - 30 ), Render.Size.y - 45 ), version_txt, Color( 255, 255, 255, 100 ), 15 )
		end
		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		end

		local playername_pos = Vector2( 20, Render.Size.y - 60 )
		local links_pos = Vector2( 40, 50 )

		Render:DrawText( links_pos, "ССЫЛКИ / LINKS:", Color.White, 25 )
		Render:DrawText( Vector2( links_pos.x, links_pos.y + Render:GetTextHeight( "ССЫЛКИ / LINKS:", 25 ) + 10 ), "- TELEGRAM | [empty_link]\n- DISCORD | [empty_link]\n- STEAM | [empty_link]\n- VK | [empty_link]", Color( 180, 180, 180 ), 20 )
		Render:DrawText( Vector2( Render.Size.x / 2 - Render:GetTextWidth( self.tName, 30 ) / 2, Render.Size.y / 2.5 ), self.tName, Color.White, 30 )

		LocalPlayer:GetAvatar():Draw( playername_pos, Vector2( 40, 40 ), Vector2.Zero, Vector2.One )
		Render:DrawText( playername_pos + Vector2( 50, 15 ), LocalPlayer:GetName(), Color.White, 17 )
		if self.status then
			Render:DrawText( playername_pos + Vector2( 50, 15 ) + Vector2( Render:GetTextWidth( LocalPlayer:GetName(), 17 ), 0 ), self.status, Color.DarkGray, 17 )
		end
	end
end

function Menu:Close()
	self:SetActive( false )
end

function Menu:Freeroam()
	self:Close()
	Game:FireEvent( "ply.unpause" )
	if LocalPlayer:GetValue( "Passive" ) then
		Game:FireEvent( "ply.invulnerable" )
	end
	Network:Send( "SetFreeroam" )
	Events:Fire( "CastCenterText", { text = self.tofreeroamtext, time = 2, color = Color( 255, 255, 255 ) } )
end

function Menu:CleanUp()
	if self.ambsound then
		self.ambsound:Remove()
		self.ambsound = nil
	end
end

function Menu:ModuleUnload()
	self:CleanUp()
end

function Menu:Welcome()
    Network:Send( "SetRus" )
	WelcomeScreen:Open()

	self.hider = false
	self:SetActive( false )

	if self.rus_image then
		self.rus_image:Remove()
		self.rus_image = nil
	end

	if self.rus_button then
		self.rus_button:Remove()
		self.rus_button = nil
	end

	if self.eng_image then
		self.eng_image:Remove()
		self.eng_image = nil
	end

	if self.eng_button then
		self.eng_button:Remove()
		self.eng_button = nil
	end

	local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 18,
				sound_id = 0,
				position = Camera:GetPosition(),
				angle = Angle()
	})

	sound:SetParameter(0,1)
end

function Menu:Selected()
	Network:Send( "JoinMessage" )
	self.hider = false

	if self.rus_image then
		self.rus_image:Remove()
		self.rus_image = nil
	end

	if self.rus_button then
		self.rus_button:Remove()
		self.rus_button = nil
	end

	if self.eng_image then
		self.eng_image:Remove()
		self.eng_image = nil
	end

	if self.eng_button then
		self.eng_button:Remove()
		self.eng_button = nil
	end

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
		Events:Fire( "OpenWhatsNew", { titletext = "СТАНЬТЕ СПОНСОРОМ СЕРВЕРА", text = "Задонатьте более, чем 500 рублей для попадания в список спонсоров!\nСпонсируя сервер и его автора, вы мотивируете и продлеваете жизнь проекту ( и не только ).\n \nСсылки:\n> Донат - [empty_link]\n> Discord - [empty_link]\n> Telegram - [empty_link]\n \nС помощью доната, вы также можете приобрести какую-либо услугу на сервере или привилегию.", usepause = true } )
	elseif type == 1 then
		Events:Fire( "OpenWhatsNew", { titletext = "РАЗ И НАВСЕГДА ( ͡° ͜ʖ ͡°)", text = "Успейте приобрести VIP навсегда за 50 рублей!\nАкция действует до 16-го апреля.\n \nСсылки:\n> Донат - [empty_link]\n> Discord - [empty_link]\n> Telegram - [empty_link]\n\nСписок возможностей для VIP перечислен в меню помощи.", usepause = true } )
	elseif type == 2 then
		Events:Fire( "OpenWhatsNew", { titletext = "ПОДДЕРЖКА СООБЩЕСТВА", text = "Создавайте контент с участием нашего сервера, а мы будем продвигать вас!\n      Подробности о поддержке сообщества сможете найти в меню помощи.", usepause = true } )
	end
	self:Selected()
end

function Menu:Eng()
	Events:Fire( "SetEng" )
	Network:Send( "SetEng" )

	self.tofreeroamtext = "Welcome to freeroam mode!"

	Events:Fire( "EngHelp" )
	Events:Fire( "Lang" )

	--Events:Fire( "OpenWhatsNew", { titletext = "SPONSOR THE SERVER", text = "Donate more than 6,16$ to be in the list of sponsors!\nBy sponsoring the server and its author, you motivate and prolong the life of the project (and not only).\n \nLinks:\n> Donate - [empty_link]\n> Discord - [empty_link]\n> Telegram - [empty_link]\n \nWith donation, you can also buy some service on the server or a privilege.", usepause = true } )
	self:Selected()
end

menu = Menu()
