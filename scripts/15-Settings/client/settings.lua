class 'Settings'

function Settings:__init()
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
		[16] = true,
		[114] = true,
		[115] = true,
		[117] = true,
		[51] = true,
		[52] = true,
		[116] = true
	}

	self.permissions = {
        ["Creator"] = true,
        ["GlAdmin"] = true,
        ["Admin"] = true,
        ["AdminD"] = true,
        ["ModerD"] = true,
        ["VIP"] = true
    }

	self.debug_permissions = {
        ["Creator"] = true,
        ["GlAdmin"] = true
    }

	self.SkyImage1 = Image.Create( AssetLocation.Resource, "Sky1" )
	self.SkyImage2 = Image.Create( AssetLocation.Resource, "Sky2" )
	self.SkyImage3 = Image.Create( AssetLocation.Resource, "Sky3" )
	self.SkyImage4 = Image.Create( AssetLocation.Resource, "Sky4" )
	self.SkyImage5 = Image.Create( AssetLocation.Resource, "Sky5" )
	self.SkyImage6 = Image.Create( AssetLocation.Resource, "Sky6" )
	self.SkyImage7 = Image.Create( AssetLocation.Resource, "Sky6" )

	self.AnimeImage1 = Image.Create( AssetLocation.Resource, "Anime1" )
	self.AnimeImage2 = Image.Create( AssetLocation.Resource, "Anime2" )

	self.active = false
	self.actvCH = LocalPlayer:GetValue( "CustomCrosshair" )
	self.actvSn = false

	self.aim = true

	self.longerGrapple_txt = "Дальний крюк"
	self.meters = "м"
	self.unavailable_txt = "[НЕДОСТУПНО]"

	self:LoadCategories()

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.window:SetTitle( "▧ Настройки" )
		self.subcategory6:SetText( "Основные опции:" )
		self.hidetexttip:SetText( "Нажмите F11, чтобы скрыть/показать интерфейс" )
		self.hidetext:SetText( "Используется скрытие серверного интерфейса" )
		self.buttonBoost:SetText( "Настройка супер-ускорения (для ТС)" )
		self.buttonSpeedo:SetText( "Настройка спидометра" )
		self.buttonSDS:SetText( "Настройка скайдайвинга" )
		self.buttonTags:SetText( "Настройка тегов" )
		self.buttonChatSett:SetText( "Настройка чата" )
		self.subcategory:SetText( "Сохранения:" )
		self.buttonSPOff:SetText( "Сбросить сохраненную позицию" )

		self.posreset_txt = "Позиция сброшена. Перезайдите в игру."

		self.jpviptip:SetText( "★ Доступно только для VIP" )
		self.buttonJP:SetText( "Использовать реактивный ранец" )
		self.subcategory2:SetText( "Погода:" )
		self.button:SetText( "Ясно" )
		self.buttonTw:SetText( "Пасмурно" )
		self.buttonTh:SetText( "Гроза" )

		self.rollbutton:GetLabel():SetText( "Бочка" )
		self.spinbutton:GetLabel():SetText( "Спиннер" )
		self.flipbutton:GetLabel():SetText( "Кувырок" )

		self.subcategory3:SetText( "Транспортные трюки (кнопка Y):" )

		self.subcategory4:SetText( "Предосмотр:" )
		self.setPlayerColorBtn:SetText( "Установить цвет »" )

		self.skyOption:GetLabel():SetText( "Ahhh" )
		self.skyOption2:GetLabel():SetText( "Хоррор" )
		self.skyOption3:GetLabel():SetText( "Пахом" )
		self.skyOption4:GetLabel():SetText( "Мастер подземелий" )
		self.skyOption5:GetLabel():SetText( "Аниме" )
		self.skyOption6:GetLabel():SetText( "Цвет ↓" )
		self.skyOptionRnb:GetLabel():SetText( "Переливания цветов неба" )

		--self.subcategory5:SetText( "Выполнить консольную команду на сервере:" )

		self.hidetext:SizeToContents()
	end

	Network:Subscribe( "ResetDone", self, self.ResetDone )

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "LoadUI", self, self.LoadUI )
	Events:Subscribe( "GameLoad", self, self.GameLoad )
	Events:Subscribe( "GameRender", self, self.GameRender )
	Events:Subscribe( "OpenSettingsMenu", self, self.OpenSettingsMenu )
	Events:Subscribe( "CloseSettingsMenu", self, self.CloseSettingsMenu )
	Events:Subscribe( "KeyUp", self, self.KeyHide )

	self:GameLoad()
end

function Settings:Lang()
	self.window:SetTitle( "▧ Settings" )
	self.hidetexttip:SetText( "Press F11 to hide/show server UI" )
	self.hidetext:SetText( "Used server UI hiding" )
	self.hidetexttip:SizeToContents()
	self.hidetext:SizeToContents()
	self.buttonBoost:SetText( "Boost Setting (for vehicles)" )
	self.buttonSpeedo:SetText( "Speedometer Setting" )
	self.buttonSDS:SetText( "Skydiving Settings" )
	self.buttonTags:SetText( "Tags Settings" )
	self.buttonChatSett:SetText( "Chat Settings" )
	self.subcategory:SetText( "Saves:" )
	self.buttonSPOff:SetText( "Reset Saved Position" )

	self.longerGrapple_txt = "Longer grapple"
	self.meters = "m"
	self.unavailable_txt = "[UNAVAILABLE]"

	self.subcategory6:SetText( "Main options:" )
	self.option1:GetLabel():SetText( "Display clock" )
	self.option2:GetLabel():SetText( "12-hour format" )
	self.option3:GetLabel():SetText( 'Display "Passive" at the top of the screen' )
	self.option4:GetLabel():SetText( 'Display "Jesus" at the top of the screen' )
	self.option5:GetLabel():SetText( "Display fantastic records" )
	self.option6:GetLabel():SetText( "Display killfeed" )
	self.option7:GetLabel():SetText( "Display tooltip below chat" )
	self.option8:GetLabel():SetText( "Display chat background" )
	self.option9:GetLabel():SetText( "Display player markers" )
	self.option10:GetLabel():SetText( "Display task markers" )
	self.option11:GetLabel():SetText( "Display crosshair" )
	self.option12:GetLabel():SetText( "Server crosshair" )
	self.option13:GetLabel():SetText( "Longer grapple indicator" )
	self.option14:GetLabel():SetText( "Jet HUD (for aviation)" )
	self.option15:GetLabel():SetText( "Display tasks" )
	self.option24:GetLabel():SetText( "Display door opening tips" )
	self.option16:GetLabel():SetText( "Display snow on the screen" )

	self.posreset_txt = "Position has been reset. Restart the game."

	self.option17:GetLabel():SetText( "Keep the character in vehicle" )
	self.option23:GetLabel():SetText( "Drift control configuration" )
	self.option25:GetLabel():SetText( "Vehicle jump" )
	self.option19:GetLabel():SetText( "Hydraulics" )
	self.option18:GetLabel():SetText( "Wingsuit" )

	self.rollbutton:GetLabel():SetText( "Barrel" )
	self.spinbutton:GetLabel():SetText( "Spinner" )
	self.flipbutton:GetLabel():SetText( "Somersault" )

	self.subcategory3:SetText( "Vehicle tricks (Y button):" )

	self.jpviptip:SetText( "★ Available only for VIP" )
	self.buttonJP:SetText( "Use Jetpack" )
	self.subcategory2:SetText( "Weather:" )
	self.button:SetText( "Clear" )
	self.buttonTw:SetText( "Cloudy" )
	self.buttonTh:SetText( "Thunderstorm" )

	self.subcategory4:SetText( "Preview:" )
	self.setPlayerColorBtn:SetText( "Set color »" )

	self.skyOption:GetLabel():SetText( "Ahhh" )
	self.skyOption2:GetLabel():SetText( "Horror" )
	self.skyOption3:GetLabel():SetText( "Pakhom" )
	self.skyOption4:GetLabel():SetText( "Dungeon Master" )
	self.skyOption5:GetLabel():SetText( "Anime" )
	self.skyOption6:GetLabel():SetText( "Color ↓" )
	self.skyOptionRnb:GetLabel():SetText( "Rainbow sky" )

	--[[
	self.option20:GetLabel():SetText( "Display debug messages" )
	self.option21:GetLabel():SetText( "Display player information" )
	self.option22:GetLabel():SetText( "Display vehicle information" )

	self.subcategory5:SetText( "Run console command on the server:" )
	]]--

	self.hidetext:SizeToContents()
end

function Settings:LoadUI()
	self:GameLoad()
end

function Settings:LoadCategories()
	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.5, 0.5 ) )
	self.window:SetMinimumSize( Vector2( 680, 442 ) )
	self.window:SetPositionRel( Vector2( 0.73, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetVisible( self.active )
	self.window:Subscribe( "WindowClosed", self, self.Open )

	self.tab = TabControl.Create( self.window )
	self.tab:SetDock( GwenPosition.Fill )

	local widgets = BaseWindow.Create( self.window )
	self.tab:AddPage( "Основное", widgets )

	local scroll_control = ScrollControl.Create( widgets )
	scroll_control:SetScrollable( false, true )
	scroll_control:SetDock( GwenPosition.Fill )
	scroll_control:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )

	self.subcategory6 = Label.Create( scroll_control )
	self.subcategory6:SetDock( GwenPosition.Top )
	self.subcategory6:SetMargin( Vector2( 0, 4 ), Vector2( 0, 4 ) )
	self.subcategory6:SizeToContents()

	self.option1 = self:OptionCheckBox( scroll_control, "Отображать часы", LocalPlayer:GetValue( "ClockVisible" ) or false )
	self.option1:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 1 , boolean = not LocalPlayer:GetValue( "ClockVisible" ) } ) end )

	self.option2 = self:OptionCheckBox( scroll_control, "12-часовой формат", LocalPlayer:GetValue( "ClockPendosFormat" ) or false )
	self.option2:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 2 , boolean = not LocalPlayer:GetValue( "ClockPendosFormat" ) } ) end )

	self.option3 = self:OptionCheckBox( scroll_control, 'Отображать "Мирный" вверху экрана', LocalPlayer:GetValue( "PassiveModeVisible" ) or false )
	self.option3:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 4 , boolean = not LocalPlayer:GetValue( "PassiveModeVisible" ) } ) end )
	self.option3:SetMargin( Vector2( 0, 20 ), Vector2.Zero )

	self.option4 = self:OptionCheckBox( scroll_control, 'Отображать "Иисус" вверху экрана', LocalPlayer:GetValue( "JesusModeVisible" ) or false )
	self.option4:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 5 , boolean = not LocalPlayer:GetValue( "JesusModeVisible" ) } ) end )

	self.option5 = self:OptionCheckBox( scroll_control, "Отображать хорошечные рекорды", LocalPlayer:GetValue( "BestRecordVisible" ) or false )
	self.option5:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 3 , boolean = not LocalPlayer:GetValue( "BestRecordVisible" ) } ) end )
	self.option5:SetMargin( Vector2( 0, 20 ), Vector2.Zero )

	self.option6 = self:OptionCheckBox( scroll_control, "Отображать чат убийств", LocalPlayer:GetValue( "KillFeedVisible" ) or false )
	self.option6:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 6 , boolean = not LocalPlayer:GetValue( "KillFeedVisible" ) } ) end )

	self.option7 = self:OptionCheckBox( scroll_control, "Отображать подсказку под чатом", LocalPlayer:GetValue( "ChatTipsVisible" ) or false )
	self.option7:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 7 , boolean = not LocalPlayer:GetValue( "ChatTipsVisible" ) } ) end )
	self.option7:SetMargin( Vector2( 0, 20 ), Vector2.Zero )

	self.option8 = self:OptionCheckBox( scroll_control, "Отображать фон чата", LocalPlayer:GetValue( "ChatBackgroundVisible" ) or false )
	self.option8:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 8 , boolean = not LocalPlayer:GetValue( "ChatBackgroundVisible" ) } ) end )

	self.option9 = self:OptionCheckBox( scroll_control, "Отображать маркеры игроков", LocalPlayer:GetValue( "PlayersMarkersVisible" ) or false )
	self.option9:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 9 , boolean = not LocalPlayer:GetValue( "PlayersMarkersVisible" ) } ) end )
	self.option9:SetMargin( Vector2( 0, 20 ), Vector2.Zero )

	self.option10 = self:OptionCheckBox( scroll_control, "Отображать маркеры заданий", LocalPlayer:GetValue( "JobsMarkersVisible" ) or false )
	self.option10:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 10 , boolean = not LocalPlayer:GetValue( "JobsMarkersVisible" ) } ) end )

	self.option11 = self:OptionCheckBox( scroll_control, "Отображать прицел", self.aim )
	self.option11:GetCheckBox():Subscribe( "CheckChanged", self, self.ToggleAim )
	self.option11:SetMargin( Vector2( 0, 20 ), Vector2.Zero )

	self.option12 = self:OptionCheckBox( scroll_control, "Серверный прицел", LocalPlayer:GetValue( "CustomCrosshair" ) or false )
	self.option12:GetCheckBox():Subscribe( "CheckChanged", function() self.actvCH = not LocalPlayer:GetValue( "CustomCrosshair" ) self:GameLoad() Network:Send( "UpdateParameters", { parameter = 11 , boolean = not LocalPlayer:GetValue( "CustomCrosshair" ) } ) end )

	self.option13 = self:OptionCheckBox( scroll_control, "Индикатор дальнего крюка", LocalPlayer:GetValue( "LongerGrappleVisible" ) or false )
	self.option13:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 13 , boolean = not LocalPlayer:GetValue( "LongerGrappleVisible" ) } ) end )

	self.option15 = self:OptionCheckBox( scroll_control, "Отображать задания", LocalPlayer:GetValue( "JobsVisible" ) or false )
	self.option15:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 14 , boolean = not LocalPlayer:GetValue( "JobsVisible" ) } ) end )
	self.option15:SetMargin( Vector2( 0, 20 ), Vector2.Zero )

	self.option24 = self:OptionCheckBox( scroll_control, "Отображать подсказки открытия ворот", LocalPlayer:GetValue( "OpenDoorsTipsVisible" ) or false )
	self.option24:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 20 , boolean = not LocalPlayer:GetValue( "OpenDoorsTipsVisible" ) } ) end )

	self.option14 = self:OptionCheckBox( scroll_control, "Jet HUD (для авиации)", LocalPlayer:GetValue( "JetHUD" ) or false )
	self.option14:GetCheckBox():Subscribe( "CheckChanged", function() Events:Fire( "JHudActive" ) Network:Send( "UpdateParameters", { parameter = 12 , boolean = not LocalPlayer:GetValue( "JetHUD" ) } ) end )
	self.option14:SetMargin( Vector2( 0, 20 ), Vector2.Zero )

	self.option16 = self:OptionCheckBox( scroll_control, "Отображать снег на экране", self.actvSn )
	self.option16:GetCheckBox():Subscribe( "CheckChanged", function() self.actvSn = self.option16:GetCheckBox():GetChecked() self:GameLoad() end )

	local bkpanelsLabel = Label.Create( widgets )
	bkpanelsLabel:SetVisible( true )
	bkpanelsLabel:SetDock( GwenPosition.Right )
	bkpanelsLabel:SetWidth( 310 )

	local scroll_bkpanels = ScrollControl.Create( bkpanelsLabel )
	scroll_bkpanels:SetScrollable( false, true )
	scroll_bkpanels:SetDock( GwenPosition.Fill )
	scroll_bkpanels:SetMargin( Vector2( 5, 0 ), Vector2( 5, 0 ) )

	self.hidetexttip = Label.Create( bkpanelsLabel )
	self.hidetexttip:SetDock( GwenPosition.Bottom )
	self.hidetexttip:SetMargin( Vector2( 5, 5 ), Vector2( 5, 4 ) )
	self.hidetexttip:SizeToContents()

	self.hidetext = Label.Create( bkpanelsLabel )
	self.hidetext:SetVisible( false )
	self.hidetext:SetTextColor( Color.Yellow )
	self.hidetext:SetDock( GwenPosition.Bottom )
	self.hidetext:SetMargin( Vector2( 5, 5 ), Vector2( 5, 0 ) )

	self.buttonBoost = Button.Create( scroll_bkpanels )
	self.buttonBoost:SetHeight( 30 )
	self.buttonBoost:SetTextSize( 14 )
	self.buttonBoost:SetDock( GwenPosition.Top )
	self.buttonBoost:SetMargin( Vector2( 0, 3 ), Vector2( 0, 3 ) )
	self.buttonBoost:Subscribe( "Press", self, function() Events:Fire( "BoostSettings" ) end )

	self.buttonSpeedo = Button.Create( scroll_bkpanels )
	self.buttonSpeedo:SetHeight( 30 )
	self.buttonSpeedo:SetTextSize( 14 )
	self.buttonSpeedo:SetDock( GwenPosition.Top )
	self.buttonSpeedo:SetMargin( Vector2( 0, 3 ), Vector2( 0, 3 ) )
	self.buttonSpeedo:Subscribe( "Press", self, function() Events:Fire( "OpenSpeedometerMenu" ) end )

	self.buttonSDS = Button.Create( scroll_bkpanels )
	self.buttonSDS:SetHeight( 30 )
	self.buttonSDS:SetTextSize( 14 )
	self.buttonSDS:SetDock( GwenPosition.Top )
	self.buttonSDS:SetMargin( Vector2( 0, 3 ), Vector2( 0, 3 ) )
	self.buttonSDS:Subscribe( "Press", self, function() Events:Fire( "OpenSkydivingStatsMenu" ) end )

	self.buttonTags = Button.Create( scroll_bkpanels )
	self.buttonTags:SetHeight( 30 )
	self.buttonTags:SetTextSize( 14 )
	self.buttonTags:SetDock( GwenPosition.Top )
	self.buttonTags:SetMargin( Vector2( 0, 3 ), Vector2( 0, 3 ) )
	self.buttonTags:Subscribe( "Press", self, function() Events:Fire( "OpenNametagsMenu" ) end )

	self.buttonChatSett = Button.Create( scroll_bkpanels )
	self.buttonChatSett:SetHeight( 30 )
	self.buttonChatSett:SetTextSize( 14 )
	self.buttonChatSett:SetDock( GwenPosition.Top )
	self.buttonChatSett:SetMargin( Vector2( 0, 3 ), Vector2( 0, 3 ) )
	self.buttonChatSett:Subscribe( "Press", self, function() Events:Fire( "OpenChatMenu" ) self:Open() end )

	self.subcategory = Label.Create( scroll_bkpanels )
	self.subcategory:SetDock( GwenPosition.Top )
	self.subcategory:SetMargin( Vector2( 0, 10 ), Vector2( 0, 4 ) )
	self.subcategory:SizeToContents()

	self.buttonSPOff = Button.Create( scroll_bkpanels )
	self.buttonSPOff:SetHeight( 30 )
	self.buttonSPOff:SetTextSize( 14 )
	self.buttonSPOff:SetDock( GwenPosition.Top )
	self.buttonSPOff:SetMargin( Vector2( 0, 3 ), Vector2( 0, 3 ) )
	self.buttonSPOff:Subscribe( "Press", self, function() Network:Send( "SPOff" ) end )

	local powers = BaseWindow.Create( self.window )
	self.tab:AddPage( "Способности", powers )

	local bkpanelsLabel = Label.Create( powers )
	bkpanelsLabel:SetVisible( true )
	bkpanelsLabel:SetDock( GwenPosition.Bottom )
	bkpanelsLabel:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )
	bkpanelsLabel:SetHeight( 80 )

	local scroll_control = ScrollControl.Create( powers )
	scroll_control:SetScrollable( false, true )
	scroll_control:SetDock( GwenPosition.Fill )
	scroll_control:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )

	self.option17 = self:OptionCheckBox( scroll_control, "Не выбрасывать персонажа из транспорта", LocalPlayer:GetValue( "VehicleEjectBlocker" ) or false )
	self.option17:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 16 , boolean = not LocalPlayer:GetValue( "VehicleEjectBlocker" ) } ) end )

	self.option23 = self:OptionCheckBox( scroll_control, "Дрифт-конфигурация управления", LocalPlayer:GetValue( "DriftPhysics" ) or false )
	self.option23:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 19 , boolean = not LocalPlayer:GetValue( "DriftPhysics" ) } ) end )

	self.option25 = self:OptionCheckBox( scroll_control, "Прыжок на транспорте", LocalPlayer:GetValue( "VehicleJump" ) or false )
	self.option25:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 21 , boolean = not LocalPlayer:GetValue( "VehicleJump" ) } ) end )

	self.option19 = self:OptionCheckBox( scroll_control, "Гидравлика", LocalPlayer:GetValue( "HydraulicsEnabled" ) or false )
	self.option19:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 18 , boolean = not LocalPlayer:GetValue( "HydraulicsEnabled" ) } ) end )

	self.option18 = self:OptionCheckBox( scroll_control, "Вингсьют", LocalPlayer:GetValue( "WingsuitEnabled" ) or false )
	self.option18:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 17 , boolean = not LocalPlayer:GetValue( "WingsuitEnabled" ) } ) end )
	self.option18:SetMargin( Vector2( 0, 20 ), Vector2.Zero )

	self.buttonLH = LabeledCheckBox.Create( scroll_control )
	if LocalPlayer:GetValue( "LongerGrapple" ) then
		self.buttonLH:GetLabel():SetText( self.longerGrapple_txt .. " (" .. LocalPlayer:GetValue( "LongerGrapple" ) .. "м)" )
		self.buttonLH:GetLabel():SetEnabled( true )
		self.buttonLH:GetCheckBox():SetEnabled( true )
	else
		self.buttonLH:GetLabel():SetText( self.longerGrapple_txt .. " (150м) | [НЕДОСТУПНО]" )
		self.buttonLH:GetLabel():SetEnabled( false )
		self.buttonLH:GetCheckBox():SetEnabled( false )
	end
	self.buttonLH:SetSize( Vector2( 305, 20 ) )
	self.buttonLH:GetLabel():SetTextSize( 15 )
	self.buttonLH:SetDock( GwenPosition.Top )
	self.buttonLH:GetCheckBox():SetChecked( LocalPlayer:GetValue( "LongerGrappleEnabled" ) or false )
	self.buttonLH:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 15 , boolean = not LocalPlayer:GetValue( "LongerGrappleEnabled" ) } ) end )

	self.flipbutton = LabeledCheckBox.Create( bkpanelsLabel )
	self.spinbutton = LabeledCheckBox.Create( bkpanelsLabel )
	self.rollbutton = LabeledCheckBox.Create( bkpanelsLabel )

	self.rollbutton:SetSize( Vector2( 300, 20 ) )
	self.rollbutton:GetCheckBox():SetEnabled( false )
	self.rollbutton:SetDock( GwenPosition.Bottom )
	self.rollbutton:GetCheckBox():SetChecked( LocalPlayer:GetValue( "EnhancedWoet" ) == "Roll" )
	self.rollbutton:GetCheckBox():Subscribe( "CheckChanged", 
		function()
			if self.rollbutton:GetCheckBox():GetChecked() then
				LocalPlayer:SetValue( "EnhancedWoet", "Roll" )

				self.spinbutton:GetCheckBox():SetChecked( false )
				self.flipbutton:GetCheckBox():SetChecked( false )
			else
				if LocalPlayer:GetValue( "EnhancedWoet" ) == "Roll" then
					LocalPlayer:SetValue( "EnhancedWoet", nil )
				end
			end
		end
	)

	self.spinbutton:SetSize( Vector2( 300, 20 ) )
	self.spinbutton:GetCheckBox():SetEnabled( false )
	self.spinbutton:SetDock( GwenPosition.Bottom )
	self.spinbutton:GetCheckBox():SetChecked( LocalPlayer:GetValue( "EnhancedWoet" ) == "Spin" )
	self.spinbutton:GetCheckBox():Subscribe( "CheckChanged", 
		function()
			if self.spinbutton:GetCheckBox():GetChecked() then
				LocalPlayer:SetValue( "EnhancedWoet", "Spin" )

				self.rollbutton:GetCheckBox():SetChecked( false )
				self.flipbutton:GetCheckBox():SetChecked( false )
			else
				if LocalPlayer:GetValue( "EnhancedWoet" ) == "Spin" then
					LocalPlayer:SetValue( "EnhancedWoet", nil )
				end
			end
		end
	)

	self.flipbutton:SetSize( Vector2( 300, 20 ) )
	self.flipbutton:GetCheckBox():SetEnabled( false )
	self.flipbutton:SetDock( GwenPosition.Bottom )
	self.flipbutton:GetCheckBox():SetChecked( LocalPlayer:GetValue( "EnhancedWoet" ) == "Flip" )
	self.flipbutton:GetCheckBox():Subscribe( "CheckChanged", 
		function()
			if self.flipbutton:GetCheckBox():GetChecked() then
				LocalPlayer:SetValue( "EnhancedWoet", "Flip" )

				self.rollbutton:GetCheckBox():SetChecked( false )
				self.spinbutton:GetCheckBox():SetChecked( false )
			else
				if LocalPlayer:GetValue( "EnhancedWoet" ) == "Flip" then
					LocalPlayer:SetValue( "EnhancedWoet", nil )
				end
			end
		end
	)

	self.subcategory3 = Label.Create( bkpanelsLabel )
	self.subcategory3:SetDock( GwenPosition.Bottom )
	self.subcategory3:SetMargin( Vector2( 0, 0 ), Vector2( 0, 5 ) )
	self.subcategory3:SizeToContents()

	local bkpanelsLabel = Label.Create( powers )
	bkpanelsLabel:SetVisible( true )
	bkpanelsLabel:SetDock( GwenPosition.Right )
	bkpanelsLabel:SetWidth( 310 )

	local scroll_bkpanels = ScrollControl.Create( bkpanelsLabel )
	scroll_bkpanels:SetScrollable( false, true )
	scroll_bkpanels:SetDock( GwenPosition.Fill )
	scroll_bkpanels:SetMargin( Vector2( 5, 0 ), Vector2( 5, 0 ) )

	self.jpviptip = Label.Create( scroll_bkpanels )
	self.jpviptip:SetVisible( true )
	self.jpviptip:SetTextColor( Color.DarkGray )
	self.jpviptip:SetDock( GwenPosition.Top )
	self.jpviptip:SetMargin( Vector2( 0, 3 ), Vector2( 0, 5 ) )
	self.jpviptip:SizeToContents()

	self.buttonJP = Button.Create( scroll_bkpanels )
	self.buttonJP:SetEnabled( false )
	self.buttonJP:SetSize( Vector2( 315, 30 ) )
	self.buttonJP:SetTextSize( 14 )
	self.buttonJP:SetDock( GwenPosition.Top )
	self.buttonJP:SetMargin( Vector2( 0, 3 ), Vector2( 0, 5 ) )
	self.buttonJP:Subscribe( "Press", self, self.GetJetpack )

	self.subcategory2 = Label.Create( scroll_bkpanels )
	self.subcategory2:SetVisible( false )
	self.subcategory2:SetDock( GwenPosition.Top )
	self.subcategory2:SetMargin( Vector2( 0, 10 ), Vector2( 0, 5 ) )
	self.subcategory2:SizeToContents()

	local weathertabsLabel = Label.Create( scroll_bkpanels )
	weathertabsLabel:SetVisible( true )
	weathertabsLabel:SetDock( GwenPosition.Top )
	weathertabsLabel:SetSize( Vector2( 0, 30 ) )

	self.button = Button.Create( weathertabsLabel )
	self.button:SetVisible( false )
	self.button:SetTextSize( 15 )
	self.button:SetDock( GwenPosition.Left )
	self.button:Subscribe( "Press", self, function() Network:Send( "SetWeather", { severity = 0 } ) self:Open() end )

	self.buttonTw = Button.Create( weathertabsLabel )
	self.buttonTw:SetVisible( false )
	self.buttonTw:SetTextSize( 15 )
	self.buttonTw:SetDock( GwenPosition.Fill )
	self.buttonTw:SetMargin( Vector2( 5, 0 ), Vector2( 5, 0 ) )
	self.buttonTw:Subscribe( "Press", self, function() Network:Send( "SetWeather", { severity = 1 } ) self:Open() end )

	self.buttonTh = Button.Create( weathertabsLabel )
	self.buttonTh:SetVisible( false )
	self.buttonTh:SetTextSize( 15 )
	self.buttonTh:SetDock( GwenPosition.Right )
	self.buttonTh:Subscribe( "Press", self, function() Network:Send( "SetWeather", { severity = 2 } ) self:Open() end )

	local nickcolor = BaseWindow.Create( self.window )
	self.tab:AddPage( "Цвет ника", nickcolor )

	local tab_control = TabControl.Create( nickcolor )
	tab_control:SetDock( GwenPosition.Fill )

	self.pcolor = LocalPlayer:GetColor()

	self.subcategory4 = Label.Create( nickcolor )
	self.subcategory4:SetDock( GwenPosition.Top )
	self.subcategory4:SetMargin( Vector2( 5, 10 ), Vector2( 0, 0 ) )
	self.subcategory4:SizeToContents()

	self.nicknameColorPreview = Label.Create( nickcolor )
	self.nicknameColorPreview:SetText( LocalPlayer:GetName() )
	self.nicknameColorPreview:SetTextSize( 14 )
	self.nicknameColorPreview:SetTextColor( self.pcolor )
	self.nicknameColorPreview:SetDock( GwenPosition.Top )
	self.nicknameColorPreview:SetMargin( Vector2( 5, 0 ), Vector2( 0, 4 ) )
	self.nicknameColorPreview:SizeToContents()

	self.pcolorPicker = HSVColorPicker.Create( tab_control )
	self.pcolorPicker:SetColor( self.pcolor )
	self.pcolorPicker:SetDock( GwenPosition.Fill )
	self.pcolorPicker:Subscribe( "ColorChanged", function()
		self.nicknameColorPreview:SetTextColor( self.pcolor )

		self.pcolor = self.pcolorPicker:GetColor()
		self.colorChanged = true
	end )

	self.setPlayerColorBtn = Button.Create( nickcolor )
	self.setPlayerColorBtn:SetTextHoveredColor( Color.GreenYellow )
	self.setPlayerColorBtn:SetTextPressedColor( Color.GreenYellow )
	self.setPlayerColorBtn:SetTextSize( 15 )
	self.setPlayerColorBtn:SetHeight( 30 )
	self.setPlayerColorBtn:SetDock( GwenPosition.Bottom )
	self.setPlayerColorBtn:SetMargin( Vector2( 0, 5 ), Vector2( 0, 0 ) )
	self.setPlayerColorBtn:Subscribe( "Up", function()
		Network:Send( "SetPlyColor", { pcolor = self.pcolor } )
		local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 20,
				sound_id = 22,
				position = LocalPlayer:GetPosition(),
				angle = Angle()
		})

		sound:SetParameter(0,1)	
		Game:FireEvent( "bm.savecheckpoint.go" )
	end )

	local skyOptions = BaseWindow.Create( self.window )
	self.tab:AddPage( "Небо", skyOptions )

	local scroll_control = ScrollControl.Create( skyOptions )
	scroll_control:SetScrollable( false, true )
	scroll_control:SetDock( GwenPosition.Fill )
	scroll_control:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )

	self.skyOption4 = LabeledCheckBox.Create( scroll_control )
	self.skyOption = LabeledCheckBox.Create( scroll_control )
	self.skyOption2 = LabeledCheckBox.Create( scroll_control )
	self.skyOption3 = LabeledCheckBox.Create( scroll_control )
	self.skyOption5 = LabeledCheckBox.Create( scroll_control )
	self.skyOption6 = LabeledCheckBox.Create( scroll_control )
	self.skyOptionRnb = LabeledCheckBox.Create( scroll_control )

	self.skyOption:SetSize( Vector2( 300, 20 ) )
	self.skyOption:SetDock( GwenPosition.Top )
	self.skyOption:GetLabel():SetText( "Ahhh" )
	self.skyOption:GetLabel():SetTextSize( 15 )
	self.skyOption:GetCheckBox():Subscribe( "CheckChanged", function() self.skyTw = self.skyOption:GetCheckBox():GetChecked() end )

	self.skyOption2:SetSize( Vector2( 300, 20 ) )
	self.skyOption2:SetDock( GwenPosition.Top )
	self.skyOption2:GetLabel():SetText( "Хоррор" )
	self.skyOption2:GetLabel():SetTextSize( 15 )
	self.skyOption2:GetCheckBox():Subscribe( "CheckChanged", function() self.skyFi = self.skyOption2:GetCheckBox():GetChecked() end )

	self.skyOption3:SetSize( Vector2( 300, 20 ) )
	self.skyOption3:SetDock( GwenPosition.Top )
	self.skyOption3:GetLabel():SetText( "Пахом" )
	self.skyOption3:GetLabel():SetTextSize( 15 )
	self.skyOption3:GetCheckBox():Subscribe( "CheckChanged", function() self.skyTh = self.skyOption3:GetCheckBox():GetChecked() end )

	self.skyOption4:SetSize( Vector2( 300, 20 ) )
	self.skyOption4:SetDock( GwenPosition.Top )
	self.skyOption4:GetLabel():SetText( "Мастер подземелий" )
	self.skyOption4:GetLabel():SetTextSize( 15 )
	self.skyOption4:GetCheckBox():Subscribe( "CheckChanged", function() self.skySi = self.skyOption4:GetCheckBox():GetChecked() end )

	self.skyOption5:SetSize( Vector2( 300, 20 ) )
	self.skyOption5:SetDock( GwenPosition.Top )
	self.skyOption5:GetLabel():SetText( "Аниме" )
	self.skyOption5:GetLabel():SetTextSize( 15 )
	self.skyOption5:GetCheckBox():Subscribe( "CheckChanged", function() self.skySe = self.skyOption5:GetCheckBox():GetChecked() if self.skySe then self.timer = Timer() else self.timer = nil end end )

	self.skyOption6:SetSize( Vector2( 300, 20 ) )
	self.skyOption6:SetDock( GwenPosition.Top )
	self.skyOption6:GetLabel():SetText( "Цвет ↓" )
	self.skyOption6:GetLabel():SetTextSize( 15 )
	self.skyOption6:GetCheckBox():Subscribe( "CheckChanged", function() self.skyColor = self.skyOption6:GetCheckBox():GetChecked() end )

	local tab_control = TabControl.Create( scroll_control )
	tab_control:SetDock( GwenPosition.Fill )

	self.toneS1Picker = HSVColorPicker.Create()
	tab_control:AddPage( "▨ Цвет", self.toneS1Picker )
	tab_control:SetMargin( Vector2( 0, 5 ), Vector2( 0, 5 ) )
	self.toneS1Picker:SetDock( GwenPosition.Fill )

	self.skyOptionRnb:SetSize( Vector2( 300, 20 ) )
	self.skyOptionRnb:SetDock( GwenPosition.Bottom )
	self.skyOptionRnb:GetLabel():SetText( "Переливания цветов неба" )
	self.skyOptionRnb:GetLabel():SetTextSize( 13 )
	self.skyOptionRnb:GetCheckBox():Subscribe( "CheckChanged", function() self.skyRainbow = self.skyOptionRnb:GetCheckBox():GetChecked() if self.skyRainbow then self.rT = Timer() else self.rT = nil end end )

	--[[
	local gettag = LocalPlayer:GetValue( "Tag" )

	if self.debug_permissions[gettag] then
		local debug = BaseWindow.Create( self.window )
		self.tab:AddPage( "DEBUG", debug )

		local scroll_control = ScrollControl.Create( debug )
		scroll_control:SetScrollable( false, true )
		scroll_control:SetDock( GwenPosition.Fill )
		scroll_control:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )

		self.option20 = self:OptionCheckBox( scroll_control, "Отображать отладочные сообщения", LocalPlayer:GetValue( "DEBUGShowOSD" ) or false )
		self.option20:GetCheckBox():Subscribe( "CheckChanged", function() LocalPlayer:SetValue( "DEBUGShowOSD", not LocalPlayer:GetValue( "DEBUGShowOSD" ) ) end )

		self.option21 = self:OptionCheckBox( scroll_control, "Отображать информацию игрока", LocalPlayer:GetValue( "DEBUGShowPlayerInfo" ) or false )
		self.option21:GetCheckBox():Subscribe( "CheckChanged", function() LocalPlayer:SetValue( "DEBUGShowPlayerInfo", not LocalPlayer:GetValue( "DEBUGShowPlayerInfo" ) ) end )

		self.option22 = self:OptionCheckBox( scroll_control, "Отображать информацию транспорта", LocalPlayer:GetValue( "DEBUGShowVehicleInfo" ) or false )
		self.option22:GetCheckBox():Subscribe( "CheckChanged", function() LocalPlayer:SetValue( "DEBUGShowVehicleInfo", not LocalPlayer:GetValue( "DEBUGShowVehicleInfo" ) ) end )

		self.subcategory5 = Label.Create( scroll_control )
		self.subcategory5:SetDock( GwenPosition.Top )
		self.subcategory5:SetMargin( Vector2( 0, 10 ), Vector2( 0, 4 ) )
		self.subcategory5:SizeToContents()

		local consoleCommand = TextBox.Create( scroll_control )
		consoleCommand:SetDock( GwenPosition.Top )
		consoleCommand:Subscribe( "ReturnPressed", self, function() Network:Send( "RunConsoleCommand", consoleCommand:GetText() ) consoleCommand:SetText( "" ) end )
		consoleCommand:Subscribe( "Focus", self, self.Focus )
		consoleCommand:Subscribe( "Blur", self, self.Blur )
		consoleCommand:Subscribe( "EscPressed", self, self.EscPressed )

		local subcategory = Label.Create( scroll_control )
		subcategory:SetText( "FireEvent:" )
		subcategory:SetDock( GwenPosition.Top )
		subcategory:SetMargin( Vector2( 0, 10 ), Vector2( 0, 4 ) )

		local customFireEvent = TextBox.Create( scroll_control )
		customFireEvent:SetDock( GwenPosition.Top )
		customFireEvent:Subscribe( "ReturnPressed", self, function() Game:FireEvent( customFireEvent:GetText() ) customFireEvent:SetText( "" ) end )
		customFireEvent:Subscribe( "Focus", self, self.Focus )
		customFireEvent:Subscribe( "Blur", self, self.Blur )
		customFireEvent:Subscribe( "EscPressed", self, self.EscPressed )
	end
	]]--
end

function Settings:Focus()
	Input:SetEnabled( false )
end

function Settings:Blur()
	Input:SetEnabled( true )
end

function Settings:EscPressed()
	self:Blur()
	self:CloseSettingsMenu()
end

function Settings:OptionCheckBox( tab, title, checked )
	local checkbox = LabeledCheckBox.Create( tab )
	checkbox:GetLabel():SetText( title )
	checkbox:SetSize( Vector2( 300, 20 ) )
	checkbox:GetLabel():SetTextSize( 15 )

	checkbox:SetDock( GwenPosition.Top )
	if checked then
		checkbox:GetCheckBox():SetChecked( checked )
	end

	return checkbox
end

function Settings:GameRender()
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	if self.skyFo then
		self.SkyImage4:SetSize( Vector2( Render.Width, Render.Height ) )
		self.SkyImage4:Draw()
	end

	if self.sky then
		self.SkyImage1:SetSize( Vector2( Render.Width, Render.Height ) )
		self.SkyImage1:Draw()
	end

	if self.skyFi then
		self.SkyImage5:SetSize( Vector2( Render.Width, Render.Height ) )
		self.SkyImage5:Draw()
	end

	if self.skyColor then
		if self.skyRainbow and self.rT then
			h = ( 0.01 * self.rT:GetMilliseconds() ) * 5
			color = Color.FromHSV( h % 360, 1, 1 )
			Render:FillArea( Vector2.Zero, Render.Size, color + Color( 0, 0, 0, 100 ) )
		else
			Render:FillArea( Vector2.Zero, Render.Size, self.toneS1Picker:GetColor() + Color( 0, 0, 0, 100 ) )
		end
	end

	if self.skyTw then
		self.SkyImage2:SetSize( Vector2( Render.Width, Render.Height ) )
		self.SkyImage2:Draw()
	end

	if self.skySi then
		self.SkyImage6:SetSize( Vector2( Render.Width, Render.Height ) )
		self.SkyImage6:Draw()
	end

	if self.skySe then
		self.SkyImage7:SetSize( Vector2( Render.Width, Render.Height ) )
		self.SkyImage7:Draw()

		local speed = 1
		if self.timer then
			if self.timer:GetSeconds() <= speed then
				self.SkyImage7 = self.AnimeImage1
			else
				self.SkyImage7 = self.AnimeImage2
			end
			if self.timer:GetSeconds() >= speed * 2 then
				self.timer:Restart()
			end
		end
	end

	if self.skyTh then
		self.SkyImage3:SetSize( Vector2( Render.Width, Render.Height ) )
		self.SkyImage3:Draw()
	end
end

function Settings:GameLoad()
	Events:Fire( "GetOption", { actCH = self.actvCH, actSn = self.actvSn } )
end

function Settings:Open()
	self:SetWindowVisible( not self.active )
	if LocalPlayer:GetValue( "JesusModeEnabled" ) then
		self.option4:SetVisible( true )
	else
		self.option4:SetVisible( false )
	end

	if LocalPlayer:GetValue( "LongerGrapple" ) then
		self.buttonLH:GetLabel():SetText( self.longerGrapple_txt .. " (" .. LocalPlayer:GetValue( "LongerGrapple" ) .. self.meters .. ")" )
		self.buttonLH:GetLabel():SetEnabled( true )
		self.buttonLH:GetCheckBox():SetEnabled( true )
	else
		self.buttonLH:GetLabel():SetText( self.longerGrapple_txt .. " (150" .. self.meters .. ") | " .. self.unavailable_txt )
		self.buttonLH:GetLabel():SetEnabled( false )
		self.buttonLH:GetCheckBox():SetEnabled( false )
	end

	local gettag = LocalPlayer:GetValue( "Tag" )

	if self.permissions[gettag] then
		self.subcategory2:SetVisible( true )
		self.button:SetVisible( true )
		self.buttonTw:SetVisible( true )
		self.buttonTh:SetVisible( true )

		self.rollbutton:GetCheckBox():SetEnabled( true )
		self.spinbutton:GetCheckBox():SetEnabled( true )
		self.flipbutton:GetCheckBox():SetEnabled( true )
		self.buttonJP:SetEnabled( true )
		self.jpviptip:SetVisible( false )
		self.subcategory2:SetPosition( Vector2( self.window:GetSize().x - 350, 50 ) )
		self.button:SetPosition( Vector2( self.subcategory2:GetPosition().x, self.subcategory2:GetPosition().y + 20 ) )
		self.buttonTw:SetPosition( Vector2( self.button:GetPosition().x + 105, self.subcategory2:GetPosition().y + 20 ) )
		self.buttonTh:SetPosition( Vector2( self.buttonTw:GetPosition().x + 105, self.subcategory2:GetPosition().y + 20 ) )
	else
		self.buttonJP:SetEnabled( false )
		self.jpviptip:SetVisible( true )
		self.subcategory2:SetPosition( Vector2( self.window:GetSize().x - 350, 70 ) )
		self.button:SetPosition( Vector2( self.subcategory2:GetPosition().x, self.subcategory2:GetPosition().y + 20 ) )
		self.buttonTw:SetPosition( Vector2( self.button:GetPosition().x + 105, self.subcategory2:GetPosition().y + 20 ) )
		self.buttonTh:SetPosition( Vector2( self.buttonTw:GetPosition().x + 105, self.subcategory2:GetPosition().y + 20 ) )
	end

	if self.active then
		if not self.LocalPlayerInputEvent then
			self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
		end

        if not self.RenderEvent then
            self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
        end

		ClientEffect.Play(AssetLocation.Game, {
			effect_id = 382,

			position = Camera:GetPosition(),
			angle = Angle()
		})
	else
		if self.LocalPlayerInputEvent then
			Events:Unsubscribe( self.LocalPlayerInputEvent )
			self.LocalPlayerInputEvent = nil
		end

        if self.RenderEvent then
			Events:Unsubscribe( self.RenderEvent )
			self.RenderEvent = nil
        end

		ClientEffect.Play(AssetLocation.Game, {
			effect_id = 383,

			position = Camera:GetPosition(),
			angle = Angle()
		})
	end
end

function Settings:LocalPlayerInput( args )
	if args.input == Action.GuiPause then
		self:CloseSettingsMenu()
	end
	if self.actions[args.input] then
		return false
	end
end

function Settings:OpenSettingsMenu( args )
	if Game:GetState() ~= GUIState.Game then return end
	self:Open()
end

function Settings:CloseSettingsMenu( args )
	if Game:GetState() ~= GUIState.Game then return end
	if self.window:GetVisible() == true then
		self:SetWindowVisible( false )
		if self.LocalPlayerInputEvent then
			Events:Unsubscribe( self.LocalPlayerInputEvent )
			self.LocalPlayerInputEvent = nil
		end

        if self.RenderEvent then
			Events:Unsubscribe( self.RenderEvent )
			self.RenderEvent = nil
        end
	end
end

function Settings:Render()
	local is_visible = Game:GetState() == GUIState.Game

	if self.window:GetVisible() ~= is_visible then
		self.window:SetVisible( is_visible )
	end

	Mouse:SetVisible( is_visible )
end

function Settings:SetWindowVisible( visible )
    if self.active ~= visible then
		self.active = visible
		self.window:SetVisible( visible )
		Mouse:SetVisible( visible )
	end
end

function Settings:ToggleAim()
	self.aim = not self.aim
	if self.aim then
		if self.NoAimRenderEvent then
			Events:Unsubscribe( self.NoAimRenderEvent )
			self.NoAimRenderEvent = nil
		end
		Game:FireEvent( "gui.aim.show" )
		self.actvCH = self.before
		self.before = nil
		self:GameLoad()
	else
		if not self.NoAimRenderEvent then
			self.NoAimRenderEvent = Events:Subscribe( "Render", self, self.NoAim )
		end
		if self.actvCH then
			self.actvCH = false
			self.before = true
			self:GameLoad()
		end
	end
end

function Settings:NoAim()
	Game:FireEvent( "gui.aim.hide" )
end

function Settings:GetJetpack()
	Events:Fire( "UseJetpack" )
	self:Open()
end

function Settings:ResetDone()
	self.buttonSPOff:SetEnabled( false )
	self.buttonSPOff:SetText( self.posreset_txt )
end

function Settings:KeyHide( args )
	if Game:GetState() ~= GUIState.Game then return end

	if args.key == VirtualKey.F11 then
		local hiddenHUD = LocalPlayer:GetValue( "HiddenHUD" )

		self.hidetext:SetVisible( not hiddenHUD )
		LocalPlayer:SetValue( "HiddenHUD", not hiddenHUD )

		self:GameLoad()
	end
end

settings = Settings()