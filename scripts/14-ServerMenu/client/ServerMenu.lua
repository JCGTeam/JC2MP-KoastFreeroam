class 'ServerMenu'

function ServerMenu:__init()
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

	self.permissions = {
        ["Creator"] = true,
        ["GlAdmin"] = true,
        ["Admin"] = true,
        ["AdminD"] = true,
        ["ModerD"] = true,
        ["VIP"] = true
    }

	self.active = false
	self.resizer_txt = "Черный ниггер"
	self.resizer_txt2 = "Отклюючиить"

	self.cooldown = 0.5
	self.cooltime = 0

	self.shopimage = Image.Create( AssetLocation.Resource, "BlackMarketICO" )
	self.tpimage = Image.Create( AssetLocation.Resource, "TeleportICO" )
	self.clansimage = Image.Create( AssetLocation.Resource, "ClansICO" )
	self.pmimage = Image.Create( AssetLocation.Resource, "MessagesICO" )
	self.settimage = Image.Create( AssetLocation.Resource, "SettingsICO" )
	self.dedmimage = Image.Create( AssetLocation.Resource, "DailyTasksICO" )
	self.mainmenuimage = Image.Create( AssetLocation.Resource, "GameModesICO" )
	self.abiltiesimage = Image.Create( AssetLocation.Resource, "AbilitiesICO" )

	self:LoadCategories()

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.pigeonmodtxt = "Режим голубя"
		self.hidemetxt = "Скрытие маркера"
		self.disabletxt = " отключено"
		self.enabletxt = " включено"
		self.disabletxt_2 = " отключен"
		self.enabletxt_2 = " включен"
	end

	Events:Subscribe( "Lang", self, self.Lang )
    Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "LocalPlayerMoneyChange", self, self.LocalPlayerMoneyChange )

	Network:Subscribe( "Settings", self, self.Open )
	Network:Subscribe( "Bonus", self, self.Bonus )
end

function ServerMenu:Lang()
	if self.window then
		self.window:SetTitle( "▧ Server Menu" )
		self.news_button:SetText( "NEWS" )
		self.help_button:SetText( "HELP / RULES" )
		self.shop_button:SetText( "Black Market" )
		self.shop_button:SetToolTip( "Vehicles, weapons, appearance and others." )
		self.tp_button:SetText( "Teleportation" )
		self.tp_button:SetToolTip( "Teleport to the players." )
		self.clans_button:SetText( "Clans" )
		self.clans_button:SetToolTip( "Your clan and other clans of players." )
		self.pm_button:SetText( "Messages" )
		self.pm_button:SetToolTip( "Communicate personally with the players." )
		self.sett_button:SetText( "Settings" )
		self.sett_button:SetToolTip( "Server settings." )
		self.tasks_button:SetToolTip( "Daily tasks for which you get rewards." )
		self.tasks_button:SetText( "Daily Tasks" )
		self.minigames_button:SetText( "Minigames" )
		self.minigames_button:SetToolTip( "Various minigames." )
		self.abilities_button:SetText( "Abilities" )
		self.abilities_button:SetToolTip( "Upgrading your abilities and skills." )
		self.passive:SetText( "Passive mode:" )
		self.passive:SizeToContents()
		self.jesusmode:SetText( "Jesus mode:" )
		self.jesusmode:SizeToContents()
		self.hideme:SetText( "Invisible marker:" )
		self.pigeonmod:SetText( "Pigeon mod:" )
		self.bonus:SetText( "Bonus:" )
		self.bonus:SizeToContents()
		self.bonus_btn:SetText( "NEEDED 9 LEVEL" )
		self.report_btn:SetText( "Feedback" )
	end

	self.pigeonmodtxt = "Pigeon mod"
	self.hidemetxt = "Invisible marker"
	self.disabletxt = " disabled"
	self.enabletxt = " enabled"
	self.disabletxt_2 = " disabled"
	self.enabletxt_2 = " enabled"
end

function ServerMenu:LoadCategories()
	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.55, 0.5 ) )
	self.window:SetMinimumSize( Vector2( 700, 442 ) )
	self.window:SetPositionRel( Vector2( 0.7, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetVisible( self.active )
	self.window:SetTitle( "▧ Меню сервера" )
	self.window:Subscribe( "WindowClosed", self, self.WindowClosed )

	self.top_label = Label.Create( self.window )
	self.top_label:SetVisible( true )
	self.top_label:SetDock( GwenPosition.Top )
	self.top_label:SetHeight( 30 )

	self.help_button = Button.Create( self.top_label )
	self.help_button:SetVisible( true )
	self.help_button:SetText( "ПОМОЩЬ / ПРАВИЛА" )
	self.help_button:SetDock( GwenPosition.Fill )
	self.help_button:SetTextSize( 14 )
	self.help_button:SetMargin( Vector2( 5, 0 ), Vector2( 0, 0 ) )
	self.help_button:Subscribe( "Press", self, self.CastHelpMenu )

	self.news_button = Button.Create( self.top_label )
	self.news_button:SetVisible( true )
	self.news_button:SetText( "НОВОСТИ" )
	self.news_button:SetDock( GwenPosition.Left )
	self.news_button:SetTextSize( 14 )
	self.news_button:SetMargin( Vector2( 0, 0 ), Vector2( 0, 0 ) )
	self.news_button:SetWidth( Render:GetTextWidth( "НОВОСТИ" ) + 25 )
	self.news_button:Subscribe( "Press", self, self.CastNewsMenu )

	self.scroll_control = ScrollControl.Create( self.window )
	self.scroll_control:SetScrollable( true, false )
	self.scroll_control:SetSize( Vector2( self.window:GetSize().x - 15, 215 ) )
	self.scroll_control:SetDock( GwenPosition.Top )

	self.shop_button = self:CreateServerMenuButton( "Черный рынок", self.shopimage, "Транспорт, оружие, внешность и прочие.", 5, self.CastShop )
	self.tp_button = self:CreateServerMenuButton( "Телепортация", self.tpimage, "Телепортация к игрокам.", self.shop_button:GetPosition().x + Render:GetTextWidth( self.resizer_txt, 19 ) + 15, self.CastWarpGUI )
	self.clans_button = self:CreateServerMenuButton( "Кланы", self.clansimage, "Управление кланом и другие кланы игроков.", self.tp_button:GetPosition().x + Render:GetTextWidth( self.resizer_txt, 19 ) + 15, self.CastClansMenu )
	self.pm_button = self:CreateServerMenuButton( "Сообщения", self.pmimage, "Общайтесь лично с игроками.", self.clans_button:GetPosition().x + Render:GetTextWidth( self.resizer_txt, 19 ) + 15, self.CastGuiPm )
	self.tasks_button = self:CreateServerMenuButton( "Задания", self.dedmimage, "Ежедневные задания за которые вы получаете награды.", self.pm_button:GetPosition().x + Render:GetTextWidth( self.resizer_txt, 19 ) + 15, self.CastDedMorozMenu )
	self.minigames_button = self:CreateServerMenuButton( "Развлечения", self.mainmenuimage, "Различные развлечения.", self.tasks_button:GetPosition().x + Render:GetTextWidth( self.resizer_txt, 19 ) + 15, self.CastMainMenu )
	self.abilities_button = self:CreateServerMenuButton( "Способности", self.abiltiesimage, "Прокачка способностей и навыков.", self.minigames_button:GetPosition().x + Render:GetTextWidth( self.resizer_txt, 19 ) + 15, self.CastAbilitiesMenu )
	self.sett_button = self:CreateServerMenuButton( "Настройки", self.settimage, "Настройки сервера.", self.abilities_button:GetPosition().x + Render:GetTextWidth( self.resizer_txt, 19 ) + 15, self.CastSettingsMenu )

	self.leftlabel = Label.Create( self.window )
	self.leftlabel:SetDock( GwenPosition.Left )
	self.leftlabel:SetMargin( Vector2( 0, 15 ), Vector2( 5, 5 ) )
	self.leftlabel:SetSize( Vector2( Render:GetTextHeight( self.resizer_txt2, 14 ) + 750, 0 ) )

	self.passive = Label.Create( self.leftlabel )
	self.passive:SetTextColor( Color.MediumSpringGreen )
	self.passive:SetText( "Мирный режим:" )
	self.passive:SetPosition( Vector2( 5, 0 ) )
	self.passive:SizeToContents()

	self.passiveon_btn = Button.Create( self.leftlabel )
	self.passiveon_btn:SetVisible( true )
	self.passiveon_btn:SetText( "Включить" )
	self.passiveon_btn:SetSize( Vector2( Render:GetTextWidth( self.resizer_txt2, 14 ), Render:GetTextHeight( self.resizer_txt2, 14 ) + 15 ) )
	self.passiveon_btn:SetTextSize( 14 )
	self.passiveon_btn:SetPosition( Vector2( 5, Render:GetTextHeight( self.passive:GetText() ) ) )
	self.passiveon_btn:Subscribe( "Press", self, self.CastPassive )

	self.jesusmode = Label.Create( self.leftlabel )
	self.jesusmode:SetTextColor( Color.LightBlue )
	self.jesusmode:SetText( "Режим Иисуса:" )
	self.jesusmode:SetPosition( Vector2( self.passiveon_btn:GetSize().x + self.passiveon_btn:GetPosition().x + 10, 0 ) )
	self.jesusmode:SizeToContents()

	self.jesusmode_btn = Button.Create( self.leftlabel )
	self.jesusmode_btn:SetText( "Включить" )
	self.jesusmode_btn:SetSize( Vector2( Render:GetTextWidth( self.resizer_txt2, 14 ), Render:GetTextHeight( self.resizer_txt2, 14 ) + 15 ) )
	self.jesusmode_btn:SetTextSize( 14 )
	self.jesusmode_btn:SetPosition( Vector2( self.passiveon_btn:GetSize().x + self.passiveon_btn:GetPosition().x + 10, Render:GetTextHeight( self.jesusmode:GetText() ) ) )
	self.jesusmode_btn:Subscribe( "Press", self, self.CastJesusMode )

	self.hideme = Label.Create( self.leftlabel )
	self.hideme:SetText( "Скрытие маркера:" )
	self.hideme:SetPosition( Vector2( self.jesusmode_btn:GetSize().x + self.jesusmode_btn:GetPosition().x + 10, 0 ) )
	self.hideme:SizeToContents()

	self.hideme_btn = Button.Create( self.leftlabel )
	self.hideme_btn:SetText( "Включить" )
	self.hideme_btn:SetSize( Vector2( Render:GetTextWidth( self.resizer_txt2, 14 ) * 1.15, Render:GetTextHeight( self.resizer_txt2, 14 ) + 15 ) )
	self.hideme_btn:SetTextSize( 14 )
	self.hideme_btn:SetPosition( Vector2( self.jesusmode_btn:GetSize().x + self.jesusmode_btn:GetPosition().x + 10, Render:GetTextHeight( self.passive:GetText() ) ) )
	self.hideme_btn:Subscribe( "Press", self, self.CastHideMe )

	self.pigeonmod = Label.Create( self.leftlabel )
	self.pigeonmod:SetText( "Режим голубя:" )
	self.pigeonmod:SetPosition( Vector2( self.hideme_btn:GetSize().x + self.hideme_btn:GetPosition().x + 10, 0 ) )
	self.pigeonmod:SizeToContents()
	self.pigeonmod:SetVisible( false )

	self.pigeonmod_btn = Button.Create( self.leftlabel )
	self.pigeonmod_btn:SetText( "Включить" )
	self.pigeonmod_btn:SetSize( Vector2( Render:GetTextWidth( self.resizer_txt2, 14 ) * 1.15, Render:GetTextHeight( self.resizer_txt2, 14 ) + 15 ) )
	self.pigeonmod_btn:SetTextSize( 14 )
	self.pigeonmod_btn:SetPosition( Vector2( self.hideme_btn:GetSize().x + self.hideme_btn:GetPosition().x + 10, Render:GetTextHeight( self.passive:GetText() ) ) )
	self.pigeonmod_btn:Subscribe( "Press", self, self.CastPigeonMod )
	self.pigeonmod_btn:SetVisible( false )

	self.rightlabel = Label.Create( self.window )
	self.rightlabel:SetDock( GwenPosition.Right )
	self.rightlabel:SetMargin( Vector2( 0, 15 ), Vector2( 5, 5 ) )
	self.rightlabel:SetSize( Vector2( Render:GetTextWidth( "Достигните 9-го уровня", 15 ) + 50, 0 ) )

	self.bonus = Label.Create( self.rightlabel )
	self.bonus:SetText( "Награды:" )
	self.bonus:SetDock( GwenPosition.Top )
	self.bonus:SetMargin( Vector2( 0, 0 ), Vector2( 0, 6 ) )
	self.bonus:SizeToContents()

	self.bonus_btn = Button.Create( self.rightlabel )
	self.bonus_btn:SetEnabled( false )
	self.bonus_btn:SetText( "Достигните 9-го уровня" )
	self.bonus_btn:SetSize( Vector2( Render:GetTextWidth( self.bonus_btn:GetText(), 15 ), Render:GetTextHeight( self.bonus:GetText() ) + 15 ) )
	self.bonus_btn:SetTextHoveredColor( Color.Yellow )
	self.bonus_btn:SetTextPressedColor( Color.Yellow )
	self.bonus_btn:SetTextSize( 15 )
	self.bonus_btn:SetDock( GwenPosition.Top )
	self.bonus_btn:Subscribe( "Press", self, self.Cash )

	self.report_btn = Button.Create( self.rightlabel )
	self.report_btn:SetText( "Обратная связь" )
	self.report_btn:SetSize( Vector2( 0, Render:GetTextHeight( self.report_btn:GetText(), 14 ) + 10 ) )
	self.report_btn:SetTextSize( 14 )
	self.report_btn:SetDock( GwenPosition.Bottom )
	self.report_btn:SetMargin( Vector2( Render:GetTextWidth( self.report_btn:GetText(), 14 ), 5 ), Vector2( 0, 0 ) )
	self.report_btn:Subscribe( "Press", self, self.CastReportMenu )

	self.gametime = Label.Create( self.leftlabel )
	self.gametime:SetTextColor( Color.DarkGray )
	self.gametime:SetText( "Игровое время: 00:00" )
	self.gametime:SizeToContents()
	self.gametime:SetMargin( Vector2( 10, 5 ), Vector2( 0, 15 ) )
	self.gametime:SetDock( GwenPosition.Bottom )

	self.level = Label.Create( self.leftlabel )
	self.level:SetTextColor( Color( 251, 184, 41 ) )
	self.level:SetTextSize( 20 )
	self.level:SetText( "Баланс: $" .. formatNumber( LocalPlayer:GetMoney() ) )
	self.level:SizeToContents()
	self.level:SetMargin( Vector2( 10, 5 ), Vector2( 0, 0 ) )
	self.level:SetDock( GwenPosition.Bottom )
end

function ServerMenu:CreateServerMenuButton( title, image, description, pos, event )
	local servermenu_img = ImagePanel.Create( self.scroll_control )
	servermenu_img:SetImage( image )
	servermenu_img:SetPosition( Vector2( pos, 20 ) )
	servermenu_img:SetSize( Vector2( Render:GetTextWidth( self.resizer_txt, 19 ), Render:GetTextWidth( self.resizer_txt, 19 ) ) )

	local servermenu_btn = MenuItem.Create( self.scroll_control )
	servermenu_btn:SetPosition( servermenu_img:GetPosition() )
	servermenu_btn:SetSize( Vector2( servermenu_img:GetSize().x, Render:GetTextWidth( self.resizer_txt, 19 ) * 1.25 ) )
	servermenu_btn:SetText( title )
	servermenu_btn:SetTextPadding( Vector2( 0, Render:GetTextWidth( self.resizer_txt, 19 ) ), Vector2.Zero )
	servermenu_btn:SetTextSize( 19 )
	servermenu_btn:SetToolTip( description )
	servermenu_btn:Subscribe( "Press", self, event )

	return servermenu_btn
end

function ServerMenu:Open()
	self:SetWindowVisible( not self.active )
	if self.active then
		if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
	else
		if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	end

	local effect = ClientEffect.Play(AssetLocation.Game, {
		effect_id = self.active and 382 or 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

function ServerMenu:LocalPlayerInput( args )
	if self.window:GetVisible() == true then
		if args.input == Action.GuiPause then
			self:SetWindowVisible( false )
			if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
		end
		if args.input ~= Action.EquipBlackMarketBeacon then
			if self.actions[args.input] then
				return false
			end
		end
	end

	if Game:GetSetting(GameSetting.GamepadInUse) == 1 then
		if args.input == Action.EquipBlackMarketBeacon then
			if Game:GetState() ~= GUIState.Game then return end
			local time = Client:GetElapsedSeconds()
			if time < self.cooltime then
				return
			else
				self:Open()
				self:CloseOutherWindows()
			end
			self.cooltime = time + self.cooldown
			return false
		end
	end
end

function ServerMenu:KeyUp( args )
	if Game:GetState() ~= GUIState.Game then return end

	if args.key == string.byte('B') then
		self:Open()
		self:CloseOutherWindows()
    end
end

function ServerMenu:CloseOutherWindows()
	Events:Fire( "CloseNewsMenu" )
	Events:Fire( "CloseHelpMenu" )
	Events:Fire( "CloseShop" )
	Events:Fire( "CloseWarpGUI" )
	Events:Fire( "CloseClansMenu" )
	Events:Fire( "CloseGuiPm" )
	Events:Fire( "CloseSettingsMenu" )
	Events:Fire( "CloseDedMorozMenu" )
	Events:Fire( "CloseGameModesMenu" )
	Events:Fire( "CloseAbitiliesMenu" )
	Events:Fire( "CasinoMenuClosed" )
	Events:Fire( "CloseSendMoney" )
	Events:Fire( "CloseReportMenu" )
end

function ServerMenu:WindowClosed()
	self:SetWindowVisible( false )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end

	local effect = ClientEffect.Create(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

function ServerMenu:Render()
	local is_visible = self.active and (Game:GetState() == GUIState.Game)

	if not LocalPlayer:GetValue( "HelpMenuReaded" ) then
		local frac = math.sin( Client:GetElapsedSeconds() *5 ) * 0.5 + 0.5
		local alpha = math.lerp( Color.LightGreen, Color.White, frac )

		self.help_button:SetTextColor( alpha )
	end

    local gettime = Game:GetTime()
    local hh, timedec = math.modf( gettime )
    local mm, _ = math.modf( 59 * timedec )

	if LocalPlayer:GetValue( "Lang" ) == "RU" then
		self.gametime:SetText( "Игровое время: " .. string.format("%d:%02d", hh, mm) )
	else
		self.gametime:SetText( "Game Time: " .. string.format("%d:%02d", hh, mm) )
	end

	if self.window:GetVisible() ~= is_visible then
		self.window:SetVisible( is_visible )
	end

	if self.active then
        Mouse:SetVisible( is_visible )
    end
end

function ServerMenu:SetWindowVisible( visible )
    if self.active ~= visible then
		self.active = visible
		self.window:SetVisible( visible )
		Mouse:SetVisible( visible )

		self.scroll_control:SetSize( Vector2( self.window:GetSize().x - 15, self.shop_button:GetHeight() + 45 ) )

		if LocalPlayer:GetValue( "SystemFonts" ) then
			self.shop_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.tp_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.clans_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.pm_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.sett_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.tasks_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.minigames_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.abilities_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.level:SetFont( AssetLocation.SystemFont, "Impact" )
			self.help_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.news_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.passiveon_btn:SetFont( AssetLocation.SystemFont, "Impact" )
			self.jesusmode_btn:SetFont( AssetLocation.SystemFont, "Impact" )
			self.hideme_btn:SetFont( AssetLocation.SystemFont, "Impact" )
			self.pigeonmod_btn:SetFont( AssetLocation.SystemFont, "Impact" )
			self.bonus_btn:SetFont( AssetLocation.SystemFont, "Impact" )
			self.report_btn:SetFont( AssetLocation.SystemFont, "Impact" )
		end

		local gettag = LocalPlayer:GetValue( "Tag" )

		if self.permissions[gettag] then
			self.pigeonmod:SetVisible( true )
			self.pigeonmod_btn:SetVisible( true )
		else
			self.pigeonmod:SetVisible( false )
			self.pigeonmod_btn:SetVisible( false )
		end

		if LocalPlayer:GetValue( "Lang" ) then
			if LocalPlayer:GetValue( "Lang" ) == "RU" then
				self.level:SetText( "Баланс: $" .. formatNumber( LocalPlayer:GetMoney() ) )

				self.passiveon_btn:SetText( LocalPlayer:GetValue( "Passive" ) and "Отключить" or "Включить" )
				self.jesusmode_btn:SetText( LocalPlayer:GetValue( "WaterWalk" ) and "Отключить" or "Включить" )
				self.hideme_btn:SetText( LocalPlayer:GetValue( "HideMe" ) and "Отключить" or "Включить" )
				self.pigeonmod_btn:SetText( LocalPlayer:GetValue( "PigeonMod" ) and "Отключить" or "Включить" )
				self.bonus_btn:SetText( LocalPlayer:GetValue( "MoneyBonus" ) and "$$ Денежный бонус $$" or "Недоступно :(" )
			else
				self.level:SetText( "Balance: $" .. formatNumber( LocalPlayer:GetMoney() ) )

				self.passiveon_btn:SetText( LocalPlayer:GetValue( "Passive" ) and "Disable" or "Enable" )
				self.jesusmode_btn:SetText( LocalPlayer:GetValue( "WaterWalk" ) and "Disable" or "Enable" )
				self.hideme_btn:SetText( LocalPlayer:GetValue( "HideMe" ) and "Disable" or "Enable" )
				self.pigeonmod_btn:SetText( LocalPlayer:GetValue( "PigeonMod" ) and "Disable" or "Enable" )
				self.bonus_btn:SetText( LocalPlayer:GetValue( "MoneyBonus" ) and "$$ Money bonus $$" or "Not available" )
			end
		end

		if LocalPlayer:GetWorld() == DefaultWorld then
			self.shop_button:SetEnabled( true )
			self.tp_button:SetEnabled( true )
			self.passiveon_btn:SetEnabled( true )
			self.jesusmode_btn:SetEnabled( LocalPlayer:GetValue( "JesusModeEnabled" ) and true or false )
			self.hideme_btn:SetEnabled( true )
			self.pigeonmod_btn:SetEnabled( LocalPlayer:GetValue( "Wingsuit" ) and true or false )
		else
			self.shop_button:SetEnabled( false )
			self.tp_button:SetEnabled( false )
			self.passiveon_btn:SetEnabled( false )
			self.jesusmode_btn:SetEnabled( false )
			self.hideme_btn:SetEnabled( false )
			self.pigeonmod_btn:SetEnabled( false )
		end
	end
end

function ServerMenu:CastNewsMenu()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenNewsMenu" )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
end

function ServerMenu:CastHelpMenu()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenHelpMenu" )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end

function ServerMenu:CastShop()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenShop" )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end

function ServerMenu:CastWarpGUI()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenWarpGUI" )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end

function ServerMenu:CastClansMenu()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenClansMenu" )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end

function ServerMenu:CastGuiPm()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenGuiPm" )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end

function ServerMenu:CastSettingsMenu()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenSettingsMenu" )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end

function ServerMenu:CastDedMorozMenu()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenDedMorozMenu" )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end

function ServerMenu:CastMainMenu()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenGameModesMenu" )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
end

function ServerMenu:CastAbilitiesMenu()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenAbitiliesMenu" )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
end

function ServerMenu:CastPassive()
	self:SetWindowVisible( not self.active )
	Events:Fire( "PassiveOn" )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end

function ServerMenu:CastJesusMode()
	self:SetWindowVisible( not self.active )
	Events:Fire( "JesusToggle" )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end

function ServerMenu:CastHideMe()
	self:SetWindowVisible( not self.active )
	Network:Send( "ToggleHideMe" )
	Events:Fire( "CastCenterText", { text = self.hidemetxt .. ( LocalPlayer:GetValue( "HideMe" ) and self.disabletxt or self.enabletxt ), time = 2, color = Color.White } )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end

function ServerMenu:CastPigeonMod()
	self:SetWindowVisible( not self.active )

	LocalPlayer:SetValue( "PigeonMod", not LocalPlayer:GetValue( "PigeonMod" ) )
	Events:Fire( "CastCenterText", { text = self.pigeonmodtxt ..  ( LocalPlayer:GetValue( "PigeonMod" ) and self.enabletxt_2 or self.disabletxt_2 ), time = 2, color = Color.White } )

	local bs = LocalPlayer:GetBaseState()

	if bs == AnimationState.SSkydive or bs == AnimationState.SSkydiveDash then
		Events:Fire( "AbortWingsuit" )
	end

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end

function ServerMenu:CastReportMenu()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenReportMenu" )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
end


function ServerMenu:Cash()
	local sound = ClientSound.Create(AssetLocation.Game, {
		bank_id = 20,
		sound_id = 20,
		position = LocalPlayer:GetPosition(),
		angle = Angle()
	})

	sound:SetParameter(0,1)

	Network:Send( "Cash" )
	self.bonus_btn:SetEnabled( false )
end

function ServerMenu:Bonus()
	if LocalPlayer:GetValue( "MoneyBonus" ) then
		self.bonus_btn:SetEnabled( true )
		if LocalPlayer:GetValue( "Lang" ) == "EN" then
			Chat:Print( "[Bonus] ", Color.White, "Money bonus is available! Open the server menu to get it!", Color.GreenYellow )
		else
			Chat:Print( "[Бонус] ", Color.White, "Доступен денежный бонус! Откройте меню сервера, чтобы получить его.", Color.GreenYellow )
		end
	end
end

function ServerMenu:UpdateMoneyString( money )
    if money == nil then
        money = LocalPlayer:GetMoney()
    end

    if LocalPlayer:GetValue( "Lang" ) then
		self.level:SetText( LocalPlayer:GetValue( "Lang" ) == "EN" and "Balance: $" .. formatNumber( money ) or "Баланс: $" .. formatNumber( money ) )
    end
end

function ServerMenu:LocalPlayerMoneyChange( args )
    self:UpdateMoneyString( args.new_money )
end

function math.round( number, decimals, method )
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

servermenu = ServerMenu()