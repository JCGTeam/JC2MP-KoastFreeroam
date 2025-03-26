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
		["Organizer"] = true,
		["Parther"] = true,
        ["VIP"] = true
    }

	self.debug_permissions = {
		["Creator"] = true,
		["GlAdmin"] = true
    }

	self.SkyImage2 = Image.Create( AssetLocation.Resource, "Sky2" )
	self.SkyImage3 = Image.Create( AssetLocation.Resource, "Sky3" )
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

	self.textSize = 15
	self.textSize2 = self.textSize - 1

	self:LoadCategories()

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
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

		self.setweather_txt = "Установлена погода: "
		self.subcategory2:SetText( "Погода:" )
		self.button:SetText( "Ясно" )
		self.buttonTw:SetText( "Облачно" )
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

		self.unknown_txt = "Отсутствует"
		self.onfoot_txt = "Ноги"
		self.timeFormat = "%02d час(ов), %02d минут(ы), %02d секунд(ы)"

		self.subcategory7:SetText( "Аккаунт" )
		self.accountInfo1_txt = "\nДата первого подключения: "
		self.accountInfo2_txt = "\nПроведено времени на сервере: "
		self.accountInfo3_txt = "\nСтрана: "
		self.accountInfo4_txt = "\nУровень: "
		self.accountInfo5_txt = "\nБаланс: $"

		self.subcategory8:SetText( "Другие данные" )
		self.accountInfo6_txt = "Время текущей сессии: "
		self.accountInfo7_txt = "\nКлан: "
		self.accountInfo8_txt = "\nТекущий ID: "
		self.accountInfo9_txt = "\nЦвет имени: "
		self.accountInfo10_txt = "\nID персонажа: "
		self.accountInfo11_txt = "\nТекущий транспорт: "

		self.subcategory9:SetText( "Глобальная статистика" )
		self.accountInfo12_txt = "Отправленных сообщений в чате: "
		self.accountInfo13_txt = "\nУбийств: "
		self.accountInfo14_txt = "\nСобранных ящиков: "
		self.accountInfo15_txt = "\nВыполненных заданий: "
		self.accountInfo16_txt = "\nВыполненных ежедневных заданий: "
		self.accountInfo17_txt = "\nЛучший счет в хорошечном дрифте: "
		self.accountInfo18_txt = "\nЛучший счет в хорошечном тетрисе: "
		self.accountInfo19_txt = "\nЛучший счет в хорошечном полете: "
		self.accountInfo20_txt = "\nПобед в гонках: "
		self.accountInfo21_txt = "\nПобед в троне: "
		self.accountInfo22_txt = "\nПобед в царь горы: "
		self.accountInfo23_txt = "\nПобед в дерби: "
		self.accountInfo24_txt = "\nПобед в понге: "
		self.accountInfo25_txt = "\nПравильных ответов в викторинах: "

		self.subcategory10:SetText( "Приглашения" )
		self.subcategory12:SetText(
			"За каждую активацию, вы получаете бонус $" .. formatNumber( InviteBonuses.Bonus1 ) .. ", а новый игрок получит дополнительные $" .. formatNumber( InviteBonuses.Bonus2 ) .. "." ..
			"\nБонус зачисляется после того, как активировавший промокод игрок проведет на сервере более 2-х часов."
			)
		self.invitePromocode:SetToolTip( "Выделите и зажмите Ctrl + C, чтобы скопировать промокод" )
		self.togglePromocodeBtn:SetText( "Сгенерировать промокод" )
		self.getInviteBonusBtn:SetText( "Получить вознаграждение за активированный промокод ($" .. formatNumber( LocalPlayer:GetValue( "ActivePromocode" ) or InviteBonuses.Bonus2 ) .. ")" )
		self.subcategory13:SetText( "Активация промокода" )
		self.uses_txt = "Использований: "
		self.activations = "Активаций: "
		self.promocodeGenerationDate_txt = "Дата генерации промокода: "
		self.getInvitationsBonus_txt = "Получить вознаграждение за приглашения"
		self.activatePromocode_txt = "Активировать промокод"
		self.getBonusBtn:SetText( self.activatePromocode_txt )

		--self.subcategory5:SetText( "Выполнить консольную команду на сервере:" )
	end

	self.hidetext:SizeToContents()
	self.hidetexttip:SizeToContents()
	self.subcategory:SizeToContents()
	self.subcategory3:SizeToContents()
	self.subcategory4:SizeToContents()
	--self.subcategory5:SizeToContents()
	self.subcategory6:SizeToContents()
	self.jpviptip:SizeToContents()
	self.subcategory2:SizeToContents()
	self.nicknameColorPreview:SizeToContents()
	self.statsName:SizeToContents()
	self.subcategory12:SizeToContents()

	Network:Subscribe( "ResetDone", self, self.ResetDone )
	Network:Subscribe( "UpdateStats", self, self.UpdateStats )
	Network:Subscribe( "UpdatePromocodes", self, self.UpdatePromocodes )

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "LoadUI", self, self.LoadUI )
	Events:Subscribe( "GameLoad", self, self.GameLoad )
	Events:Subscribe( "GameRender", self, self.GameRender )
	Events:Subscribe( "OpenSettingsMenu", self, self.OpenSettingsMenu )
	Events:Subscribe( "CloseSettingsMenu", self, self.CloseSettingsMenu )
	Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe( "PromocodeFound", function() self.promocode:SetTextColor( Color.Green ) self.getBonusBtn:SetText( "Промокод активирован!" ) end )
	Events:Subscribe( "PromocodeNotFound", function() self.promocode:SetTextColor( Color.Red ) self.getBonusBtn:SetText( self.activatePromocode_txt ) end )

	self:GameLoad()
end

function Settings:Lang()
	self.window:SetTitle( "▧ Settings" )
	self.hidetexttip:SetText( "Press F11 to hide/show server UI" )
	self.hidetext:SetText( "Used server UI hiding" )
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

	self.posreset_txt = "Position has been reset. Restart the game."

	self.option17:GetLabel():SetText( "Keep the character in vehicle" )
	self.option26:GetLabel():SetText( "Air control" )
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

	self.setweather_txt = "Weather set: "
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

	self.unknown_txt = "Unknown"
	self.onfoot_txt = "On foot"
	self.timeFormat = "%02d hour(s), %02d minute(s), %02d second(s)"

	self.subcategory7:SetText( "Account" )
	self.accountInfo1_txt = "\nDate of first connection: "
	self.accountInfo2_txt = "\nTime spent on server: "
	self.accountInfo3_txt = "\nCountry: "
	self.accountInfo4_txt = "\nLevel: "
	self.accountInfo5_txt = "\nBalance: $"

	self.subcategory8:SetText( "Other information" )
	self.accountInfo6_txt = "Current session time: "
	self.accountInfo7_txt = "\nClan: "
	self.accountInfo8_txt = "\nCurrent ID: "
	self.accountInfo9_txt = "\nNickname color: "
	self.accountInfo10_txt = "\nCharacter ID "
	self.accountInfo11_txt = "\nCurrent vehicle: "

	self.subcategory9:SetText( "Global statistics" )
	self.accountInfo12_txt = "Sent chat messages: "
	self.accountInfo13_txt = "\nKills: "
	self.accountInfo14_txt = "\nCrates collected: "
	self.accountInfo15_txt = "\nCompleted tasks: "
	self.accountInfo16_txt = "\nCompleted daily tasks: "
	self.accountInfo17_txt = "\nBest score in fantastic drift: "
	self.accountInfo18_txt = "\nBest score in fantastic tetris: "
	self.accountInfo19_txt = "\nBest score in fantastic flight: "
	self.accountInfo20_txt = "\nRace wins: "
	self.accountInfo21_txt = "\nTron wins: "
	self.accountInfo22_txt = "\nKing of the hill wins: "
	self.accountInfo23_txt = "\nDerby wins: "
	self.accountInfo24_txt = "\nPong wins: "
	self.accountInfo25_txt = "\nQuiz answers correct: "

	self.subcategory10:SetText( "Invitations" )
	self.subcategory12:SetText(
		"For each activation, you receive a bonus of $" .. formatNumber( InviteBonuses.Bonus1 ) .. ", and the new player will receive an additional $" .. formatNumber( InviteBonuses.Bonus2 ) .. "." ..
		"\nThe bonus is credited after the player who activated the promo code spends more than 2 hours on the server."
		)
	self.invitePromocode:SetToolTip( "Highlight and hold Ctrl + C to copy the promo code" )
	self.togglePromocodeBtn:SetText( "Generate promo code" )
	self.getInviteBonusBtn:SetText( "Claim reward for activated promo code ($" .. formatNumber( LocalPlayer:GetValue( "ActivePromocode" ) or InviteBonuses.Bonus2 ) .. ")" )
	self.subcategory13:SetText( "Promo code activation" )
	self.uses_txt = "Uses: "
	self.activations = "Activations: "
	self.promocodeGenerationDate_txt = "Promo code generation date: "
	self.getInvitationsBonus_txt = "Get rewarded for invitations"
	self.activatePromocode_txt = "Activate promo code"
	self.getBonusBtn:SetText( self.activatePromocode_txt )

	--[[
	self.option20:GetLabel():SetText( "Display debug messages" )
	self.option21:GetLabel():SetText( "Display player information" )
	self.option22:GetLabel():SetText( "Display vehicle information" )

	self.subcategory5:SetText( "Run console command on the server:" )
	]]--
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

	local tab = TabControl.Create( self.window )
	tab:SetDock( GwenPosition.Fill )

	local widgets = BaseWindow.Create( self.window )
	tab:AddPage( "Основное", widgets )

	local scroll_control = ScrollControl.Create( widgets )
	scroll_control:SetScrollable( false, true )
	scroll_control:SetDock( GwenPosition.Fill )
	scroll_control:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )

	self.subcategory6 = Label.Create( scroll_control )
	self.subcategory6:SetDock( GwenPosition.Top )
	self.subcategory6:SetMargin( Vector2( 0, 4 ), Vector2( 0, 4 ) )

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

	local bkpanelsContainer = BaseWindow.Create( widgets )
	bkpanelsContainer:SetVisible( true )
	bkpanelsContainer:SetDock( GwenPosition.Right )
	bkpanelsContainer:SetWidth( 310 )

	local scroll_bkpanels = ScrollControl.Create( bkpanelsContainer )
	scroll_bkpanels:SetScrollable( false, true )
	scroll_bkpanels:SetDock( GwenPosition.Fill )
	scroll_bkpanels:SetMargin( Vector2( 5, 0 ), Vector2( 5, 0 ) )

	self.hidetexttip = Label.Create( bkpanelsContainer )
	self.hidetexttip:SetDock( GwenPosition.Bottom )
	self.hidetexttip:SetMargin( Vector2( 5, 5 ), Vector2( 5, 4 ) )

	self.hidetext = Label.Create( bkpanelsContainer )
	self.hidetext:SetVisible( false )
	self.hidetext:SetTextColor( Color.Yellow )
	self.hidetext:SetDock( GwenPosition.Bottom )
	self.hidetext:SetMargin( Vector2( 5, 5 ), Vector2( 5, 0 ) )

	local btnHeight = 30
	self.buttonBoost = Button.Create( scroll_bkpanels )
	self.buttonBoost:SetHeight( btnHeight )
	self.buttonBoost:SetTextSize( self.textSize2 )
	self.buttonBoost:SetDock( GwenPosition.Top )
	self.buttonBoost:SetMargin( Vector2( 0, 3 ), Vector2( 0, 3 ) )
	self.buttonBoost:Subscribe( "Press", self, function() Events:Fire( "BoostSettings" ) end )

	self.buttonSpeedo = Button.Create( scroll_bkpanels )
	self.buttonSpeedo:SetHeight( btnHeight )
	self.buttonSpeedo:SetTextSize( self.textSize2 )
	self.buttonSpeedo:SetDock( GwenPosition.Top )
	self.buttonSpeedo:SetMargin( Vector2( 0, 3 ), Vector2( 0, 3 ) )
	self.buttonSpeedo:Subscribe( "Press", self, function() Events:Fire( "OpenSpeedometerMenu" ) end )

	self.buttonSDS = Button.Create( scroll_bkpanels )
	self.buttonSDS:SetHeight( btnHeight )
	self.buttonSDS:SetTextSize( self.textSize2 )
	self.buttonSDS:SetDock( GwenPosition.Top )
	self.buttonSDS:SetMargin( Vector2( 0, 3 ), Vector2( 0, 3 ) )
	self.buttonSDS:Subscribe( "Press", self, function() Events:Fire( "OpenSkydivingStatsMenu" ) end )

	self.buttonTags = Button.Create( scroll_bkpanels )
	self.buttonTags:SetHeight( btnHeight )
	self.buttonTags:SetTextSize( self.textSize2 )
	self.buttonTags:SetDock( GwenPosition.Top )
	self.buttonTags:SetMargin( Vector2( 0, 3 ), Vector2( 0, 3 ) )
	self.buttonTags:Subscribe( "Press", self, function() Events:Fire( "OpenNametagsMenu" ) end )

	self.buttonChatSett = Button.Create( scroll_bkpanels )
	self.buttonChatSett:SetHeight( btnHeight )
	self.buttonChatSett:SetTextSize( self.textSize2 )
	self.buttonChatSett:SetDock( GwenPosition.Top )
	self.buttonChatSett:SetMargin( Vector2( 0, 3 ), Vector2( 0, 3 ) )
	self.buttonChatSett:Subscribe( "Press", self, function() Events:Fire( "OpenChatMenu" ) self:Open() end )

	self.subcategory = Label.Create( scroll_bkpanels )
	self.subcategory:SetDock( GwenPosition.Top )
	self.subcategory:SetMargin( Vector2( 0, 10 ), Vector2( 0, 4 ) )

	self.buttonSPOff = Button.Create( scroll_bkpanels )
	self.buttonSPOff:SetHeight( btnHeight )
	self.buttonSPOff:SetTextSize( self.textSize2 )
	self.buttonSPOff:SetDock( GwenPosition.Top )
	self.buttonSPOff:SetMargin( Vector2( 0, 3 ), Vector2( 0, 3 ) )
	self.buttonSPOff:Subscribe( "Press", self, function() Network:Send( "SPOff" ) end )

	local powers = BaseWindow.Create( self.window )
	tab:AddPage( "Способности", powers )

	local bkpanelsContainer = BaseWindow.Create( powers )
	bkpanelsContainer:SetVisible( true )
	bkpanelsContainer:SetDock( GwenPosition.Bottom )
	bkpanelsContainer:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )
	bkpanelsContainer:SetHeight( 80 )

	local scroll_control = ScrollControl.Create( powers )
	scroll_control:SetScrollable( false, true )
	scroll_control:SetDock( GwenPosition.Fill )
	scroll_control:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )

	self.option17 = self:OptionCheckBox( scroll_control, "Не выбрасывать персонажа из транспорта", LocalPlayer:GetValue( "VehicleEjectBlocker" ) or false )
	self.option17:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 16 , boolean = not LocalPlayer:GetValue( "VehicleEjectBlocker" ) } ) end )

	self.option26 = self:OptionCheckBox( scroll_control, "Управляемость в полете", LocalPlayer:GetValue( "AirControl" ) or false )
	self.option26:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 22 , boolean = not LocalPlayer:GetValue( "AirControl" ) } ) end )

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
	self.buttonLH:GetLabel():SetTextSize( self.textSize )
	self.buttonLH:SetDock( GwenPosition.Top )
	self.buttonLH:GetCheckBox():SetChecked( LocalPlayer:GetValue( "LongerGrappleEnabled" ) or false )
	self.buttonLH:GetCheckBox():Subscribe( "CheckChanged", function() Network:Send( "UpdateParameters", { parameter = 15 , boolean = not LocalPlayer:GetValue( "LongerGrappleEnabled" ) } ) end )

	self.flipbutton = LabeledCheckBox.Create( bkpanelsContainer )
	self.spinbutton = LabeledCheckBox.Create( bkpanelsContainer )
	self.rollbutton = LabeledCheckBox.Create( bkpanelsContainer )

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

	self.subcategory3 = Label.Create( bkpanelsContainer )
	self.subcategory3:SetDock( GwenPosition.Bottom )
	self.subcategory3:SetMargin( Vector2.Zero, Vector2( 0, 5 ) )

	local bkpanelsContainer = BaseWindow.Create( powers )
	bkpanelsContainer:SetVisible( true )
	bkpanelsContainer:SetDock( GwenPosition.Right )
	bkpanelsContainer:SetWidth( 310 )

	local scroll_bkpanels = ScrollControl.Create( bkpanelsContainer )
	scroll_bkpanels:SetScrollable( false, true )
	scroll_bkpanels:SetDock( GwenPosition.Fill )
	scroll_bkpanels:SetMargin( Vector2( 5, 0 ), Vector2( 5, 0 ) )

	self.jpviptip = Label.Create( scroll_bkpanels )
	self.jpviptip:SetVisible( true )
	self.jpviptip:SetTextColor( Color.DarkGray )
	self.jpviptip:SetDock( GwenPosition.Top )
	self.jpviptip:SetMargin( Vector2( 0, 3 ), Vector2( 0, 5 ) )

	self.buttonJP = Button.Create( scroll_bkpanels )
	self.buttonJP:SetEnabled( false )
	self.buttonJP:SetHeight( btnHeight )
	self.buttonJP:SetTextSize( self.textSize2 )
	self.buttonJP:SetDock( GwenPosition.Top )
	self.buttonJP:SetMargin( Vector2( 0, 3 ), Vector2( 0, 5 ) )
	self.buttonJP:Subscribe( "Press", self, self.GetJetpack )

	self.subcategory2 = Label.Create( scroll_bkpanels )
	self.subcategory2:SetVisible( false )
	self.subcategory2:SetDock( GwenPosition.Top )
	self.subcategory2:SetMargin( Vector2( 0, 10 ), Vector2( 0, 5 ) )

	local weathertabsContainer = BaseWindow.Create( scroll_bkpanels )
	weathertabsContainer:SetVisible( true )
	weathertabsContainer:SetDock( GwenPosition.Top )
	weathertabsContainer:SetHeight( btnHeight )

	self.button = Button.Create( weathertabsContainer )
	self.button:SetVisible( false )
	self.button:SetTextSize( self.textSize )
	self.button:SetDock( GwenPosition.Left )
	self.button:Subscribe( "Press", self, function() self:ChangeWeather( 0, self.button:GetText() ) end )

	self.buttonTw = Button.Create( weathertabsContainer )
	self.buttonTw:SetVisible( false )
	self.buttonTw:SetTextSize( self.textSize )
	self.buttonTw:SetDock( GwenPosition.Fill )
	self.buttonTw:SetMargin( Vector2( 5, 0 ), Vector2( 5, 0 ) )
	self.buttonTw:Subscribe( "Press", self, function() self:ChangeWeather( 1, self.buttonTw:GetText() ) end )

	self.buttonTh = Button.Create( weathertabsContainer )
	self.buttonTh:SetVisible( false )
	self.buttonTh:SetTextSize( self.textSize )
	self.buttonTh:SetDock( GwenPosition.Right )
	self.buttonTh:Subscribe( "Press", self, function() self:ChangeWeather( 2, self.buttonTh:GetText() ) end )

	local nickcolor = BaseWindow.Create( self.window )
	tab:AddPage( "Цвет ника", nickcolor )

	local tab_control = TabControl.Create( nickcolor )
	tab_control:SetDock( GwenPosition.Fill )

	self.lpColor = LocalPlayer:GetColor()

	self.subcategory4 = Label.Create( nickcolor )
	self.subcategory4:SetDock( GwenPosition.Top )
	self.subcategory4:SetMargin( Vector2( 5, 10 ), Vector2.Zero )

	self.nicknameColorPreview = Label.Create( nickcolor )
	self.nicknameColorPreview:SetText( LocalPlayer:GetName() )
	self.nicknameColorPreview:SetTextSize( self.textSize2 )
	self.nicknameColorPreview:SetTextColor( self.lpColor )
	self.nicknameColorPreview:SetDock( GwenPosition.Top )
	self.nicknameColorPreview:SetMargin( Vector2( 5, 0 ), Vector2( 0, 4 ) )

	self.pcolorPicker = HSVColorPicker.Create( tab_control )
	self.pcolorPicker:SetColor( self.lpColor )
	self.pcolorPicker:SetDock( GwenPosition.Fill )
	self.pcolorPicker:Subscribe( "ColorChanged", function()
		self.nicknameColorPreview:SetTextColor( self.lpColor )

		self.lpColor = self.pcolorPicker:GetColor()
		self.colorChanged = true
	end )

	self.setPlayerColorBtn = Button.Create( nickcolor )
	local btnColor = Color.GreenYellow
	self.setPlayerColorBtn:SetTextHoveredColor( btnColor )
	self.setPlayerColorBtn:SetTextPressedColor( btnColor )
	self.setPlayerColorBtn:SetTextSize( self.textSize )
	self.setPlayerColorBtn:SetHeight( btnHeight )
	self.setPlayerColorBtn:SetDock( GwenPosition.Bottom )
	self.setPlayerColorBtn:SetMargin( Vector2( 0, 5 ), Vector2.Zero )
	self.setPlayerColorBtn:Subscribe( "Up", function()
		Network:Send( "SetPlyColor", { pcolor = self.lpColor } )
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
	tab:AddPage( "Небо", skyOptions )

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

	self.skyOption:SetDock( GwenPosition.Top )
	self.skyOption:GetLabel():SetText( "Ahhh" )
	self.skyOption:GetLabel():SetTextSize( self.textSize )
	self.skyOption:GetCheckBox():Subscribe( "CheckChanged", function() self.skyTw = self.skyOption:GetCheckBox():GetChecked() end )

	self.skyOption2:SetDock( GwenPosition.Top )
	self.skyOption2:GetLabel():SetText( "Хоррор" )
	self.skyOption2:GetLabel():SetTextSize( self.textSize )
	self.skyOption2:GetCheckBox():Subscribe( "CheckChanged", function() self.skyFi = self.skyOption2:GetCheckBox():GetChecked() end )

	self.skyOption3:SetDock( GwenPosition.Top )
	self.skyOption3:GetLabel():SetText( "Пахом" )
	self.skyOption3:GetLabel():SetTextSize( self.textSize )
	self.skyOption3:GetCheckBox():Subscribe( "CheckChanged", function() self.skyTh = self.skyOption3:GetCheckBox():GetChecked() end )

	self.skyOption4:SetDock( GwenPosition.Top )
	self.skyOption4:GetLabel():SetText( "Мастер подземелий" )
	self.skyOption4:GetLabel():SetTextSize( self.textSize )
	self.skyOption4:GetCheckBox():Subscribe( "CheckChanged", function() self.skySi = self.skyOption4:GetCheckBox():GetChecked() end )

	self.skyOption5:SetDock( GwenPosition.Top )
	self.skyOption5:GetLabel():SetText( "Аниме" )
	self.skyOption5:GetLabel():SetTextSize( self.textSize )
	self.skyOption5:GetCheckBox():Subscribe( "CheckChanged", function() self.skySe = self.skyOption5:GetCheckBox():GetChecked() if self.skySe then self.timer = Timer() else self.timer = nil end end )

	self.skyOption6:SetDock( GwenPosition.Top )
	self.skyOption6:GetLabel():SetText( "Цвет ↓" )
	self.skyOption6:GetLabel():SetTextSize( self.textSize )
	self.skyOption6:GetCheckBox():Subscribe( "CheckChanged", function() self.skyColor = self.skyOption6:GetCheckBox():GetChecked() end )

	local tab_control = TabControl.Create( scroll_control )
	tab_control:SetDock( GwenPosition.Fill )

	self.toneS1Picker = HSVColorPicker.Create()
	tab_control:AddPage( "▨ Цвет", self.toneS1Picker )
	tab_control:SetMargin( Vector2( 0, 5 ), Vector2( 0, 5 ) )
	self.toneS1Picker:SetDock( GwenPosition.Fill )

	self.skyOptionRnb:SetDock( GwenPosition.Bottom )
	self.skyOptionRnb:GetLabel():SetText( "Переливания цветов неба" )
	self.skyOptionRnb:GetLabel():SetTextSize( 13 )
	self.skyOptionRnb:GetCheckBox():Subscribe( "CheckChanged", function() self.skyRainbow = self.skyOptionRnb:GetCheckBox():GetChecked() if self.skyRainbow then self.rT = Timer() else self.rT = nil end end )

	local stats = BaseWindow.Create( self.window )
	local statsText = "Информация и статистика"
	tab:AddPage( statsText, stats )
	tab:Subscribe( "TabSwitch", function() if tab:GetCurrentTab():GetText() == statsText then Network:Send( "RequestStats" ) end end )

	local scroll_control = ScrollControl.Create( stats )
	scroll_control:SetScrollable( false, true )
	scroll_control:SetDock( GwenPosition.Fill )
	scroll_control:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )

	self.subcategory7 = GroupBox.Create( scroll_control )
	self.subcategory7:SetDock( GwenPosition.Top )
	self.subcategory7:SetMargin( Vector2( 0, 4 ), Vector2( 0, 4 ) )

	local accountInfo = BaseWindow.Create( self.subcategory7 )
	accountInfo:SetDock( GwenPosition.Fill )
	accountInfo:SetMargin( Vector2( 110, 4 ), Vector2( 0, 4 ) )

	self.statsName = Label.Create( accountInfo )
	self.statsName:SetDock( GwenPosition.Top )
	self.statsName:SetText( LocalPlayer:GetName() )
	self.statsName:SetTextSize( 20 )

	self.accountInfoText = Label.Create( accountInfo )
	self.accountInfoText:SetDock( GwenPosition.Fill )
	self.accountInfoText:SetText( "..." )

	local avatar = ImagePanel.Create( self.subcategory7 )
	avatar:SetSize( Vector2( 100, 100 ) )
	avatar:SetPosition( Vector2( 0, 4 ) )
	avatar:SetImage( LocalPlayer:GetAvatar( 2 ) )

	self.statsName:SizeToContents()
	self.accountInfoText:SizeToContents()
	self.subcategory7:SetHeight( ( self.statsName:GetSize().y + 4 * 4 ) + ( self.accountInfoText:GetSize().y + 4 * 4 ) )

	self.subcategory8 = GroupBox.Create( scroll_control )
	self.subcategory8:SetDock( GwenPosition.Top )
	self.subcategory8:SetMargin( Vector2( 0, 4 ), Vector2( 0, 4 ) )

	self.moreInfoText = Label.Create( self.subcategory8 )
	self.moreInfoText:SetDock( GwenPosition.Fill )
	self.moreInfoText:SetText( "..." )

	self.moreInfoText:SizeToContents()
	self.subcategory8:SetHeight( ( self.moreInfoText:GetSize().y + 4 * 4 ) )

	self.subcategory9 = GroupBox.Create( scroll_control )
	self.subcategory9:SetDock( GwenPosition.Top )
	self.subcategory9:SetMargin( Vector2( 0, 4 ), Vector2( 0, 4 ) )

	self.statsText = Label.Create( self.subcategory9 )
	self.statsText:SetDock( GwenPosition.Fill )
	self.statsText:SetText( "..." )
	self.statsText:SizeToContents()

	self.subcategory9:SetHeight( ( self.statsText:GetSize().y + 4 * 4 ) )

	local promocodes = BaseWindow.Create( self.window )
	local promocodesText = "Промокоды"
	tab:AddPage( promocodesText, promocodes )
	tab:Subscribe( "TabSwitch", function() if tab:GetCurrentTab():GetText() == promocodesText then Network:Send( "RequestPromocodes" ) end end )

	local scroll_control = ScrollControl.Create( promocodes )
	scroll_control:SetScrollable( false, true )
	scroll_control:SetDock( GwenPosition.Fill )
	scroll_control:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )

	self.subcategory10 = GroupBox.Create( scroll_control )
	self.subcategory10:SetDock( GwenPosition.Top )
	self.subcategory10:SetMargin( Vector2( 0, 4 ), Vector2( 0, 4 ) )
	self.subcategory10:SetHeight( ( Render:GetTextHeight( "", self.textSize - 4 ) + btnHeight ) * 4.75 )

	self.subcategory11 = Label.Create( self.subcategory10 )
	self.subcategory11:SetDock( GwenPosition.Top )
	self.subcategory11:SetMargin( Vector2( 0, 4 ), Vector2( 0, 4 ) )

	self.subcategory12 = Label.Create( self.subcategory10 )
	self.subcategory12:SetDock( GwenPosition.Top )
	self.subcategory12:SetMargin( Vector2( 0, 4 ), Vector2( 0, 4 ) )

	self.invitePromocode = TextBox.Create( self.subcategory10 )
	self.invitePromocode:SetDock( GwenPosition.Top )
	self.invitePromocode:SetMargin( Vector2( 0, 4 ), Vector2( 0, 8 ) )
	self.invitePromocode:SetHeight( btnHeight )
	self.invitePromocode:Subscribe( "Focus", self, self.Focus )
	self.invitePromocode:Subscribe( "Blur", self, self.Blur )
	self.invitePromocode:Subscribe( "EscPressed", self, self.EscPressed )
	self.invitePromocode:Subscribe( "TextChanged", function() self.invitePromocode:SetText( self.invitePromocodeText or "" ) end )

	self.togglePromocodeBtn = Button.Create( self.subcategory10 )
	self.togglePromocodeBtn:SetVisible( false )
	self.togglePromocodeBtn:SetTextSize( self.textSize )
	self.togglePromocodeBtn:SetDock( GwenPosition.Top )
	self.togglePromocodeBtn:SetMargin( Vector2( 0, 4 ), Vector2( 0, 8 ) )
	self.togglePromocodeBtn:SetHeight( btnHeight )
	self.togglePromocodeBtn:Subscribe( "Press", function() Network:Send( "GeneratePromocode" ) end )

	self.getInvitationsBonusBtn = Button.Create( self.subcategory10 )
	self.getInvitationsBonusBtn:SetEnabled( false )
	self.getInvitationsBonusBtn:SetTextSize( self.textSize )
	self.getInvitationsBonusBtn:SetDock( GwenPosition.Top )
	self.getInvitationsBonusBtn:SetMargin( Vector2( 0, 4 ), Vector2( 0, 4 ) )
	self.getInvitationsBonusBtn:SetHeight( btnHeight )
	local btnColor = Color.Yellow
	self.getInvitationsBonusBtn:SetTextHoveredColor( btnColor )
	self.getInvitationsBonusBtn:SetTextPressedColor( btnColor )
	self.getInvitationsBonusBtn:SetText( "..." )
	self.getInvitationsBonusBtn:Subscribe( "Press", function() Network:Send( "GetInvitationPromocodesReward" ) Network:Send( "RequestPromocodes" ) end )

	self.getInviteBonusBtn = Button.Create( self.subcategory10 )
	self.getInviteBonusBtn:SetEnabled( false )
	self.getInviteBonusBtn:SetTextSize( self.textSize )
	self.getInviteBonusBtn:SetDock( GwenPosition.Top )
	self.getInviteBonusBtn:SetHeight( btnHeight )
	local btnColor = Color.Yellow
	self.getInviteBonusBtn:SetTextHoveredColor( btnColor )
	self.getInviteBonusBtn:SetTextPressedColor( btnColor )
	self.getInviteBonusBtn:Subscribe( "Press", function() Network:Send( "ActivateInvitationPromocode" ) Network:Send( "RequestPromocodes" ) end )

	self.subcategory13 = GroupBox.Create( scroll_control )
	self.subcategory13:SetDock( GwenPosition.Top )
	self.subcategory13:SetMargin( Vector2( 0, 4 ), Vector2( 0, 4 ) )
	self.subcategory13:SetHeight( ( Render:GetTextHeight( "", self.textSize - 8 ) + 85 ) )

	self.promocode = TextBox.Create( self.subcategory13 )
	self.promocode:SetDock( GwenPosition.Top )
	self.promocode:SetMargin( Vector2( 0, 4 ), Vector2( 0, 8 ) )
	self.promocode:SetHeight( btnHeight )
	self.promocode:SetText( "" )
	self.promocode:Subscribe( "Focus", self, self.Focus )
	self.promocode:Subscribe( "Blur", self, self.Blur )
	self.promocode:Subscribe( "EscPressed", self, self.EscPressed )
	self.promocode_color = self.promocode:GetTextColor()
	self.promocode:Subscribe( "TextChanged", function() self.promocode:SetTextColor( self.promocode_color ) self.getBonusBtn:SetEnabled( self.promocode:GetText() ~= "" and true or false ) end )

	self.getBonusBtn = Button.Create( self.subcategory13 )
	self.getBonusBtn:SetEnabled( false )
	self.getBonusBtn:SetTextSize( self.textSize )
	self.getBonusBtn:SetDock( GwenPosition.Top )
	self.getBonusBtn:SetHeight( btnHeight )
	self.getBonusBtn:Subscribe( "Press", function() Events:Fire( "ApplyPromocode", { type = 0, name = self.promocode:GetText() } ) end )

	--[[
	local gettag = LocalPlayer:GetValue( "Tag" )

	if self.debug_permissions[gettag] then
		local debug = BaseWindow.Create( self.window )
		tab:AddPage( "DEBUG", debug )

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

function Settings:ChangeWeather( value, name )
	Events:Fire( "CastCenterText", { text = self.setweather_txt .. name, time = 2 } )
	Network:Send( "SetWeather", { severity = value } )
	self:Open()
end

function Settings:OptionCheckBox( tab, title, checked )
	local checkbox = LabeledCheckBox.Create( tab )
	checkbox:GetLabel():SetText( title )
	checkbox:GetLabel():SetTextSize( self.textSize )

	checkbox:SetDock( GwenPosition.Top )
	if checked then
		checkbox:GetCheckBox():SetChecked( checked )
	end

	return checkbox
end

function Settings:GameRender()
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	if self.skyFi then
		self.SkyImage5:SetSize( Render.Size )
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
		self.SkyImage2:SetSize( Render.Size )
		self.SkyImage2:Draw()
	end

	if self.skySi then
		self.SkyImage6:SetSize( Render.Size )
		self.SkyImage6:Draw()
	end

	if self.skySe then
		self.SkyImage7:SetSize( Render.Size )
		self.SkyImage7:Draw()

		local speed = 1

		if self.timer then
			local timerSeconds = self.timer:GetSeconds()

			if timerSeconds <= speed then
				self.SkyImage7 = self.AnimeImage1
			else
				self.SkyImage7 = self.AnimeImage2
			end

			if timerSeconds >= speed * 2 then
				self.timer:Restart()
			end
		end
	end

	if self.skyTh then
		self.SkyImage3:SetSize( Render.Size )
		self.SkyImage3:Draw()
	end
end

function Settings:GameLoad()
	Events:Fire( "GetOption", { actCH = self.actvCH } )
end

function Settings:UpdateStats( args )
	self.statsName:SetTextColor( LocalPlayer:GetColor() )

	if not self.accountInfoTextRenderEvent then
		local steamId = LocalPlayer:GetSteamId()
		local joinDate = tostring( LocalPlayer:GetValue( "JoinDate" ) or "Х/З" )
		local country = tostring( LocalPlayer:GetValue( "Country" ) )

		self.accountInfoTextRenderEvent = self.accountInfoText:Subscribe( "Render", function()
			self.accountInfoText:SetText(
				"Steam ID: " .. tostring( steamId ) .. " / Steam64 ID: " .. tostring( steamId.id ) ..
				self.accountInfo1_txt .. joinDate ..
				self.accountInfo2_txt .. self:ConvertSecondsToTimeFormat( LocalPlayer:GetValue( "TotalTime" ) or "0" ) ..
				self.accountInfo3_txt .. country ..
				self.accountInfo4_txt .. tostring( LocalPlayer:GetValue( "PlayerLevel" ) ) ..
				self.accountInfo5_txt .. formatNumber( LocalPlayer:GetMoney() )
			)
		end )
	end

	self.statsName:SizeToContents()
	self.accountInfoText:SizeToContents()
	self.subcategory7:SetHeight( ( self.statsName:GetSize().y + 4 * 4 ) + ( self.accountInfoText:GetSize().y + 4 * 4 ) )

	if not self.moreInfoTextRenderEvent then
		local pId = tostring( LocalPlayer:GetId() )

		self.moreInfoTextRenderEvent = self.moreInfoText:Subscribe( "Render", function()
			local vehicle = LocalPlayer:GetVehicle()

			self.moreInfoText:SetText(
				self.accountInfo6_txt .. self:ConvertSecondsToTimeFormat( LocalPlayer:GetValue( "SessionTime" ) or "0" ) ..
				self.accountInfo7_txt .. tostring( LocalPlayer:GetValue( "ClanTag" ) or self.unknown_txt ) ..
				self.accountInfo8_txt .. pId ..
				self.accountInfo9_txt .. "rgba(" .. tostring( LocalPlayer:GetColor() ) .. ")" ..
				self.accountInfo10_txt .. args.modelId ..
				self.accountInfo11_txt .. ( vehicle and tostring( vehicle ) .. " (ID: " .. tostring( vehicle:GetModelId() ) .. ")" or self.onfoot_txt )
			)
		end )
	end

	self.moreInfoText:SizeToContents()
	self.subcategory8:SetHeight( ( self.moreInfoText:GetSize().y + 4 * 4 ) )

	if not self.statsTextRenderEvent then
		local defaultValue = 0

		self.statsTextRenderEvent = self.statsText:Subscribe( "Render", function()
			self.statsText:SetText(
				self.accountInfo12_txt .. tostring( LocalPlayer:GetValue( "ChatMessagesCount" ) or defaultValue ) ..
				self.accountInfo13_txt .. tostring( LocalPlayer:GetValue( "KillsCount" ) or defaultValue ) ..
				self.accountInfo14_txt .. tostring( LocalPlayer:GetValue( "CollectedResourceItemsCount" ) or defaultValue ) ..
				self.accountInfo15_txt .. tostring( LocalPlayer:GetValue( "CompletedTasksCount" ) or defaultValue ) ..
				self.accountInfo16_txt .. tostring( LocalPlayer:GetValue( "CompletedDailyTasksCount" ) or defaultValue ) ..
				self.accountInfo17_txt .. tostring( LocalPlayer:GetValue( "MaxRecordInBestDrift" ) or defaultValue ) ..
				self.accountInfo18_txt .. tostring( LocalPlayer:GetValue( "MaxRecordInBestTetris" ) or defaultValue ) ..
				self.accountInfo19_txt .. tostring( LocalPlayer:GetValue( "MaxRecordInBestFlight" ) or defaultValue ) ..
				self.accountInfo20_txt .. tostring( LocalPlayer:GetValue( "RaceWinsCount" ) or defaultValue ) ..
				self.accountInfo21_txt.. tostring( LocalPlayer:GetValue( "TronWinsCount" ) or defaultValue ) ..
				self.accountInfo22_txt .. tostring( LocalPlayer:GetValue( "KingHillWinsCount" ) or defaultValue ) ..
				self.accountInfo23_txt .. tostring( LocalPlayer:GetValue( "DerbyWinsCount" ) or defaultValue ) ..
				self.accountInfo24_txt .. tostring( LocalPlayer:GetValue( "PongWinsCount" ) or defaultValue ) ..
				self.accountInfo25_txt .. tostring( LocalPlayer:GetValue( "VictorinsCorrectAnswers" ) or defaultValue )
			)	
		end )
	end

	self.statsText:SizeToContents()
	self.subcategory9:SetHeight( ( self.statsText:GetSize().y + 4 * 4 ) )
end

function Settings:UpdatePromocodes( args )
	self.subcategory11:SetText(
		self.uses_txt .. tostring( LocalPlayer:GetValue( "PromoCodeUses" ) or 0 ) .. " | " .. self.activations .. tostring( LocalPlayer:GetValue( "PromoCodeActivations" ) or 0 ) ..
		"\n" .. self.promocodeGenerationDate_txt .. tostring( LocalPlayer:GetValue( "PromoCodeCreationDate" ) or self.unknown_txt )
	)
	self.subcategory11:SizeToContents()

	self.invitePromocodeText = LocalPlayer:GetValue( "PromoCodeName" )
	if self.invitePromocodeText then
		self.invitePromocode:SetText( self.invitePromocodeText )
		self.togglePromocodeBtn:SetVisible( false )
		self.invitePromocode:SetVisible( not self.togglePromocodeBtn:GetVisible() )
	else
		self.invitePromocode:SetText( "" )
		self.togglePromocodeBtn:SetVisible( true )
		self.invitePromocode:SetVisible( not self.togglePromocodeBtn:GetVisible() )
	end

	local isActive = LocalPlayer:GetValue( "PromoCodeRewards" ) and tonumber( LocalPlayer:GetValue( "PromoCodeRewards" ) ) >= 1
	self.getInvitationsBonusBtn:SetEnabled( isActive and true or false )

	self.getInvitationsBonusBtn:SetText( self.getInvitationsBonus_txt .. " ($" .. formatNumber( ( LocalPlayer:GetValue( "PromoCodeRewards" ) or 0 ) * InviteBonuses.Bonus1 ) .. ")" )

	self.getInviteBonusBtn:SetEnabled( LocalPlayer:GetValue( "ActivePromocode" ) and true or false )
end

function Settings:Open()
	self:SetWindowVisible( not self.active )

	if self.active then
		self.option4:SetVisible( LocalPlayer:GetValue( "JesusModeEnabled" ) and true or false )

		local longerGrapple = LocalPlayer:GetValue( "LongerGrapple" )
		if longerGrapple then
			self.buttonLH:GetLabel():SetText( self.longerGrapple_txt .. " (" .. longerGrapple .. self.meters .. ")" )
			self.buttonLH:GetLabel():SetEnabled( true )
			self.buttonLH:GetCheckBox():SetEnabled( true )
		else
			self.buttonLH:GetLabel():SetText( self.longerGrapple_txt .. " (150" .. self.meters .. ") | " .. self.unavailable_txt )
			self.buttonLH:GetLabel():SetEnabled( false )
			self.buttonLH:GetCheckBox():SetEnabled( false )
		end
	
		local gettag = LocalPlayer:GetValue( "Tag" )
	
		if self.permissions[gettag] then
			local pWorld = LocalPlayer:GetWorld() == DefaultWorld

			self.subcategory2:SetVisible( true )
			self.button:SetVisible( true )
			self.buttonTw:SetVisible( true )
			self.buttonTh:SetVisible( true )

			self.button:SetEnabled( pWorld )
			self.buttonTw:SetEnabled( pWorld )
			self.buttonTh:SetEnabled( pWorld )
	
			self.rollbutton:GetCheckBox():SetEnabled( true )
			self.spinbutton:GetCheckBox():SetEnabled( true )
			self.flipbutton:GetCheckBox():SetEnabled( true )

			self.buttonJP:SetEnabled( pWorld )
			self.jpviptip:SetVisible( false )
	
			self.subcategory2:SetPosition( Vector2( self.window:GetSize().x - 350, 50 ) )
	
			local pos_y = self.subcategory2:GetPosition().y + 20
			self.button:SetPosition( Vector2( self.subcategory2:GetPosition().x, pos_y ) )
			self.buttonTw:SetPosition( Vector2( self.button:GetPosition().x + 105, pos_y ) )
			self.buttonTh:SetPosition( Vector2( self.buttonTw:GetPosition().x + 105, pos_y ) )
		else
			self.buttonJP:SetEnabled( false )
			self.jpviptip:SetVisible( true )
	
			self.subcategory2:SetPosition( Vector2( self.window:GetSize().x - 350, 70 ) )
	
			local pos_y = self.subcategory2:GetPosition().y + 20
			self.button:SetPosition( Vector2( self.subcategory2:GetPosition().x, pos_y ) )
			self.buttonTw:SetPosition( Vector2( self.button:GetPosition().x + 105, pos_y ) )
			self.buttonTh:SetPosition( Vector2( self.buttonTw:GetPosition().x + 105, pos_y ) )
		end

		Network:Send( "RequestStats" )

		if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end
        if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
	else
		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
		if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	end

	local effect = ClientEffect.Play(AssetLocation.Game, {
		effect_id = self.active and 382 or 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

function Settings:LocalPlayerInput( args )
	if args.input == Action.GuiPause then
		self:CloseSettingsMenu()
	end

	if self.actions[args.input] then
		return false
	end
end

function Settings:OpenSettingsMenu()
	if Game:GetState() ~= GUIState.Game then return end
	self:Open()
end

function Settings:CloseSettingsMenu()
	if Game:GetState() ~= GUIState.Game then return end

	if self.window:GetVisible() == true then
		self:SetWindowVisible( false )

		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
        if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
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
		if self.NoAimRenderEvent then Events:Unsubscribe( self.NoAimRenderEvent ) self.NoAimRenderEvent = nil end

		Game:FireEvent( "gui.aim.show" )
		self.actvCH = self.before
		self.before = nil
		self:GameLoad()
	else
		if not self.NoAimRenderEvent then self.NoAimRenderEvent = Events:Subscribe( "Render", self, self.NoAim ) end

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

function Settings:KeyUp( args )
	if Game:GetState() ~= GUIState.Game then return end

	if args.key == VirtualKey.F11 then
		local hiddenHUD = LocalPlayer:GetValue( "HiddenHUD" )

		self.hidetext:SetVisible( not hiddenHUD )
		LocalPlayer:SetValue( "HiddenHUD", not hiddenHUD )

		self:GameLoad()
	end
end

function Settings:ConvertSecondsToTimeFormat( seconds )
    local hours = math.floor( seconds / 3600 )
    local minutes = math.floor( ( seconds % 3600 ) / 60 )
    local seconds = seconds % 60
    return string.format( self.timeFormat, hours, minutes, seconds )
end

settings = Settings()