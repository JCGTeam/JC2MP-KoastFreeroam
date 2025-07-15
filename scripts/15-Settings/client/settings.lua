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

    self.SkyImage2 = Image.Create(AssetLocation.Resource, "Sky2")
    self.SkyImage3 = Image.Create(AssetLocation.Resource, "Sky3")
    self.SkyImage5 = Image.Create(AssetLocation.Resource, "Sky5")
    self.SkyImage6 = Image.Create(AssetLocation.Resource, "Sky6")
    self.SkyImage7 = Image.Create(AssetLocation.Resource, "Sky6")

    self.AnimeImage1 = Image.Create(AssetLocation.Resource, "Anime1")
    self.AnimeImage2 = Image.Create(AssetLocation.Resource, "Anime2")

    self.actvCH = LocalPlayer:GetValue("CustomCrosshair")
    self.actvSn = false

    self.aim = true

    self.textSize = 15
    self.textSize2 = self.textSize - 1

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            title = "▧ Настройки",
            main = "Основное",
            abilities = "Способности",
            nickcolor = "Цвет ника",
            sky = "Небо",
            infoandstats = "Информация и статистика",
            promocodes = "Промокоды",
            subcategory6 = "Основные опции:",
            option1 = "Отображать часы",
            option2 = "12-часовой формат",
            option3 = 'Отображать "Мирный" вверху экрана',
            option4 = 'Отображать "Иисус" вверху экрана',
            option5 = "Отображать хорошечные рекорды",
            option6 = "Отображать чат убийств",
            option7 = "Отображать подсказку под чатом",
            option8 = "Отображать фон чата",
            option9 = "Отображать маркеры игроков",
            option10 = "Отображать маркеры заданий",
            option11 = "Отображать прицел",
            option12 = "Серверный прицел",
            option13 = "Индикатор дальнего крюка",
            option14 = "Jet HUD (для авиации)",
            option15 = "Отображать задания",
            option24 = "Отображать подсказки открытия ворот",
            option17 = "Не выбрасывать персонажа из транспорта",
            option26 = "Управляемость в полете на транспорте",
            option23 = "Дрифт-конфигурация управления",
            option25 = "Прыжок на транспорте",
            option19 = "Гидравлика",
            option18 = "Вингсьют",
            hidetexttip = "Нажмите F11, чтобы скрыть/показать интерфейс",
            hidetext = "Используется скрытие серверного интерфейса",
            buttonBoost = "Настройка супер-ускорения (для ТС)",
            buttonSpeedo = "Настройка спидометра",
            buttonSDS = "Настройка скайдайвинга",
            buttonTags = "Настройка тегов",
            buttonChatSett = "Настройка чата",
            subcategory = "Сохранения:",
            buttonSPOff = "Сбросить сохраненную позицию",
            jpviptip = "★ Доступно только для VIP",
            buttonJP = "Использовать реактивный ранец",
            subcategory2 = "Погода:",
            button = "Ясно",
            buttonTw = "Облачно",
            buttonTh = "Гроза",
            rollbutton = "Бочка",
            spinbutton = "Спиннер",
            flipbutton = "Кувырок",
            subcategory3 = "Транспортные трюки (кнопка Y):",
            subcategory4 = "Предосмотр:",
            setPlayerColorBtn = "Установить цвет »",
            skyOption = "Ahhh",
            skyOption2 = "Хоррор",
            skyOption3 = "Пахом",
            skyOption4 = "Мастер подземелий",
            skyOption5 = "Аниме",
            skyOption6 = "Цвет ↓",
            skyOptionRnb = "Переливание цветов неба",
            color = "▨ Цвет",
            subcategory7 = "Аккаунт",
            subcategory8 = "Другие данные",
            subcategory9 = "Глобальная статистика",
            subcategory10 = "Приглашения",
            subcategory12 = "За каждую активацию, вы получаете бонус $" .. formatNumber(InviteBonuses.Bonus1) .. ", а новый игрок получит дополнительные $" .. formatNumber(InviteBonuses.Bonus2) .. "." .. "\nБонус зачисляется после того, как активировавший промокод игрок проведет на сервере более 2-х часов.",
            invitePromocode = "Выделите и зажмите Ctrl + C, чтобы скопировать промокод",
            togglePromocodeBtn = "Сгенерировать промокод",
            getInviteBonusBtn = "Получить вознаграждение за активированный промокод ($" .. formatNumber(LocalPlayer:GetValue("ActivePromocode") or InviteBonuses.Bonus2) .. ")",
            subcategory13 = "Активация промокода",
            --[[
			option20 = "Отображать отладочные сообщения",
			option21 = "Отображать информацию игрока",
			option22 = "Отображать информацию транспорта",
			subcategory5 = "Выполнить консольную команду на сервере:",
			--]]
            longerGrapple = "Дальний крюк",
            posreset = "Позиция сброшена. Перезайдите в игру.",
            setweather = "Установлена погода: ",
            meters = "м",
            unavailable = "[НЕДОСТУПНО]",
            unknown = "Отсутствует",
            onfoot = "Ноги",
            timeFormat = "%02d час(ов), %02d минут(ы), %02d секунд(ы)",
            accountInfo1 = "\nДата первого подключения: ",
            accountInfo2 = "\nПроведено времени на сервере: ",
            accountInfo3 = "\nСтрана: ",
            accountInfo4 = "\nУровень: ",
            accountInfo5 = "\nБаланс: $",
            accountInfo6 = "Время текущей сессии: ",
            accountInfo7 = "\nКлан: ",
            accountInfo8 = "\nТекущий ID: ",
            accountInfo9 = "\nЦвет имени: ",
            accountInfo10 = "\nID персонажа: ",
            accountInfo11 = "\nТекущий транспорт: ",
            accountInfo12 = "Отправленных сообщений в чате: ",
            accountInfo13 = "\nУбийств: ",
            accountInfo14 = "\nСобранных ящиков: ",
            accountInfo15 = "\nВыполненных заданий: ",
            accountInfo16 = "\nВыполненных ежедневных заданий: ",
            accountInfo17 = "\nЛучший счет в хорошечном дрифте: ",
            accountInfo18 = "\nЛучший счет в хорошечном тетрисе: ",
            accountInfo19 = "\nЛучший счет в хорошечном полете: ",
            accountInfo20 = "\nПобед в гонках: ",
            accountInfo21 = "\nПобед в троне: ",
            accountInfo22 = "\nПобед в царь горы: ",
            accountInfo23 = "\nПобед в дерби: ",
            accountInfo24 = "\nПобед в понге: ",
            accountInfo25 = "\nПравильных ответов в викторинах: ",
            uses = "Использований: ",
            activations = "Активаций: ",
            promocodeGenerationDate = "Дата генерации промокода: ",
            getInvitationsBonus = "Получить вознаграждение за приглашения",
            activatePromocode = "Активировать промокод"
        }
    end

    Network:Subscribe("ResetDone", self, self.ResetDone)
    Network:Subscribe("UpdateStats", self, self.UpdateStats)
    Network:Subscribe("UpdatePromocodes", self, self.UpdatePromocodes)

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("LoadUI", self, self.LoadUI)
    Events:Subscribe("GameLoad", self, self.GameLoad)
    Events:Subscribe("GameRender", self, self.GameRender)
    Events:Subscribe("OpenSettingsMenu", self, self.OpenSettingsMenu)
    Events:Subscribe("CloseSettingsMenu", self, self.CloseSettingsMenu)
    Events:Subscribe("KeyUp", self, self.KeyUp)

    self:GameLoad()
end

function Settings:Lang()
    self.locStrings = {
        title = "▧ Settings",
        main = "General",
        abilities = "Abilities",
        nickcolor = "Nickname Color",
        sky = "Sky",
        infoandstats = "Info and Stats",
        promocodes = "Promo Codes",
        subcategory6 = "Main options:",
        option1 = "Show clock",
        option2 = "12-hour format",
        option3 = 'Show "Passive" at the top of the screen',
        option4 = 'Show "Jesus" at the top of the screen',
        option5 = "Show fantastic records",
        option6 = "Show killfeed",
        option7 = "Show tooltip below chat",
        option8 = "Show chat background",
        option9 = "Show player markers",
        option10 = "Show task markers",
        option11 = "Show crosshair",
        option12 = "Server crosshair",
        option13 = "Longer grapple indicator",
        option14 = "Jet HUD (for aviation)",
        option15 = "Show tasks",
        option24 = "Show door opening tips",
        option17 = "Keep the character in vehicle",
        option26 = "Vehicle air control",
        option23 = "Drift control configuration",
        option25 = "Vehicle jump",
        option19 = "Hydraulics",
        option18 = "Wingsuit",
        hidetexttip = "Press F11 to toggle server UI",
        hidetext = "Used server UI hiding",
        buttonBoost = "Boost Settings (vehicles)",
        buttonSpeedo = "Speedometer Settings",
        buttonSDS = "Skydiving Settings",
        buttonTags = "Tags Settings",
        buttonChatSett = "Chat Settings",
        subcategory = "Saves:",
        buttonSPOff = "Reset Saved Position",
        jpviptip = "★ Available only for VIP",
        buttonJP = "Use Jetpack",
        subcategory2 = "Weather:",
        button = "Clear",
        buttonTw = "Cloudy",
        buttonTh = "Thunderstorm",
        rollbutton = "Barrel",
        spinbutton = "Spinner",
        flipbutton = "Somersault",
        subcategory3 = "Vehicle tricks (Y button):",
        subcategory4 = "Preview:",
        setPlayerColorBtn = "Set color »",
        skyOption = "Ahhh",
        skyOption2 = "Horror",
        skyOption3 = "Pakhom",
        skyOption4 = "Dungeon Master",
        skyOption5 = "Anime",
        skyOption6 = "Color ↓",
        skyOptionRnb = "Rainbow sky",
        color = "▨ Color",
        subcategory7 = "Account",
        subcategory8 = "Other information",
        subcategory9 = "Global statistics",
        subcategory10 = "Invitations",
        subcategory12 = "For each activation, you receive a bonus of $" .. formatNumber(InviteBonuses.Bonus1) .. ", and the new player will receive an additional $" .. formatNumber(InviteBonuses.Bonus2) .. "." .. "\nThe bonus is credited after the player who activated the promo code spends more than 2 hours on the server.",
        invitePromocode = "Highlight and hold Ctrl + C to copy the promo code",
        togglePromocodeBtn = "Generate promo code",
        getInviteBonusBtn = "Claim reward for activated promo code ($" .. formatNumber(LocalPlayer:GetValue("ActivePromocode") or InviteBonuses.Bonus2) .. ")",
        subcategory13 = "Promo code activation",
        --[[
		option20 = "Show debug messages",
		option21 = "Show player information",
		option22 = "Show vehicle information",
		subcategory5 = "Run console command on the server:",
		]] --
        longerGrapple = "Longer grapple",
        posreset = "Position has been reset. Restart the game.",
        setweather = "Weather set: ",
        meters = "m",
        unavailable = "[UNAVAILABLE]",
        unknown = "Unknown",
        onfoot = "On foot",
        timeFormat = "%02d hour(s), %02d minute(s), %02d second(s)",
        accountInfo1 = "\nDate of first connection: ",
        accountInfo2 = "\nTime spent on server: ",
        accountInfo3 = "\nCountry: ",
        accountInfo4 = "\nLevel: ",
        accountInfo5 = "\nBalance: $",
        accountInfo6 = "Current session time: ",
        accountInfo7 = "\nClan: ",
        accountInfo8 = "\nCurrent ID: ",
        accountInfo9 = "\nNickname color: ",
        accountInfo10 = "\nCharacter ID ",
        accountInfo11 = "\nCurrent vehicle: ",
        accountInfo12 = "Sent chat messages: ",
        accountInfo13 = "\nKills: ",
        accountInfo14 = "\nCrates collected: ",
        accountInfo15 = "\nCompleted tasks: ",
        accountInfo16 = "\nCompleted daily tasks: ",
        accountInfo17 = "\nBest score in fantastic drift: ",
        accountInfo18 = "\nBest score in fantastic tetris: ",
        accountInfo19 = "\nBest score in fantastic flight: ",
        accountInfo20 = "\nRace wins: ",
        accountInfo21 = "\nTron wins: ",
        accountInfo22 = "\nKing of the hill wins: ",
        accountInfo23 = "\nDerby wins: ",
        accountInfo24 = "\nPong wins: ",
        accountInfo25 = "\nQuiz answers correct: ",
        uses = "Uses: ",
        activations = "Activations: ",
        promocodeGenerationDate = "Promo code generation date: ",
        getInvitationsBonus = "Get rewarded for invitations",
        activatePromocode = "Activate promo code"
    }
end

function Settings:LoadUI()
    self:GameLoad()
end

function Settings:CreateWindow()
    if self.window then return end

    self.window = Window.Create()
    self.window:SetSizeRel(Vector2(0.5, 0.5))
    self.window:SetMinimumSize(Vector2(680, 442))
    self.window:SetPositionRel(Vector2(0.73, 0.5) - self.window:GetSizeRel() / 2)
    self.window:SetTitle(self.locStrings["title"])
    self.window:Subscribe("WindowClosed", self, function() self:SetWindowVisible(false, true) end)

    local tab = TabControl.Create(self.window)
    tab:SetDock(GwenPosition.Fill)

    local widgets = BaseWindow.Create(self.window)
    tab:AddPage(self.locStrings["main"], widgets)

    local scroll_control = ScrollControl.Create(widgets)
    scroll_control:SetScrollable(false, true)
    scroll_control:SetDock(GwenPosition.Fill)
    scroll_control:SetMargin(Vector2(5, 5), Vector2(5, 5))

    self.subcategory6 = Label.Create(scroll_control)
    self.subcategory6:SetDock(GwenPosition.Top)
    self.subcategory6:SetMargin(Vector2(0, 4), Vector2(0, 4))
    self.subcategory6:SetText(self.locStrings["subcategory6"])
    self.subcategory6:SizeToContents()

    self.option1 = self:OptionCheckBox(scroll_control, self.locStrings["option1"], LocalPlayer:GetValue("ClockVisible") or false)
    self.option1:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 1, boolean = not LocalPlayer:GetValue("ClockVisible")}) end)

    self.option2 = self:OptionCheckBox(scroll_control, self.locStrings["option2"], LocalPlayer:GetValue("ClockPendosFormat") or false)
    self.option2:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 2, boolean = not LocalPlayer:GetValue("ClockPendosFormat")}) end)

    self.option3 = self:OptionCheckBox(scroll_control, self.locStrings["option3"], LocalPlayer:GetValue("PassiveModeVisible") or false)
    self.option3:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 4, boolean = not LocalPlayer:GetValue("PassiveModeVisible")}) end)
    self.option3:SetMargin(Vector2(0, 20), Vector2.Zero)

    self.option4 = self:OptionCheckBox(scroll_control, self.locStrings["option4"], LocalPlayer:GetValue("JesusModeVisible") or false)
    self.option4:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 5, boolean = not LocalPlayer:GetValue("JesusModeVisible")}) end)

    self.option5 = self:OptionCheckBox(scroll_control, self.locStrings["option5"], LocalPlayer:GetValue("BestRecordVisible") or false)
    self.option5:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 3, boolean = not LocalPlayer:GetValue("BestRecordVisible")}) end)
    self.option5:SetMargin(Vector2(0, 20), Vector2.Zero)

    self.option6 = self:OptionCheckBox(scroll_control, self.locStrings["option6"], LocalPlayer:GetValue("KillFeedVisible") or false)
    self.option6:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 6, boolean = not LocalPlayer:GetValue("KillFeedVisible")}) end)

    self.option7 = self:OptionCheckBox(scroll_control, self.locStrings["option7"], LocalPlayer:GetValue("ChatTipsVisible") or false)
    self.option7:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 7, boolean = not LocalPlayer:GetValue("ChatTipsVisible")}) end)
    self.option7:SetMargin(Vector2(0, 20), Vector2.Zero)

    self.option8 = self:OptionCheckBox(scroll_control, self.locStrings["option8"], LocalPlayer:GetValue("ChatBackgroundVisible") or false)
    self.option8:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 8, boolean = not LocalPlayer:GetValue("ChatBackgroundVisible")}) end)

    self.option9 = self:OptionCheckBox(scroll_control, self.locStrings["option9"], LocalPlayer:GetValue("PlayersMarkersVisible") or false)
    self.option9:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 9, boolean = not LocalPlayer:GetValue("PlayersMarkersVisible")}) end)
    self.option9:SetMargin(Vector2(0, 20), Vector2.Zero)

    self.option10 = self:OptionCheckBox(scroll_control, self.locStrings["option10"], LocalPlayer:GetValue("JobsMarkersVisible") or false)
    self.option10:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 10, boolean = not LocalPlayer:GetValue("JobsMarkersVisible")}) end)

    self.option11 = self:OptionCheckBox(scroll_control, self.locStrings["option11"], self.aim)
    self.option11:GetCheckBox():Subscribe("CheckChanged", self, self.ToggleAim)
    self.option11:SetMargin(Vector2(0, 20), Vector2.Zero)

    self.option12 = self:OptionCheckBox(scroll_control, self.locStrings["option12"], LocalPlayer:GetValue("CustomCrosshair") or false)
    self.option12:GetCheckBox():Subscribe("CheckChanged", function()
        self.actvCH = not LocalPlayer:GetValue("CustomCrosshair")
        self:GameLoad()
        Network:Send("UpdateParameters", {parameter = 11, boolean = not LocalPlayer:GetValue("CustomCrosshair")})
	end)

    self.option13 = self:OptionCheckBox(scroll_control, self.locStrings["option13"], LocalPlayer:GetValue("LongerGrappleVisible") or false)
    self.option13:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 13, boolean = not LocalPlayer:GetValue("LongerGrappleVisible")}) end)

    self.option15 = self:OptionCheckBox(scroll_control, self.locStrings["option15"], LocalPlayer:GetValue("JobsVisible") or false)
    self.option15:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 14, boolean = not LocalPlayer:GetValue("JobsVisible")}) end)
    self.option15:SetMargin(Vector2(0, 20), Vector2.Zero)

    self.option24 = self:OptionCheckBox(scroll_control, self.locStrings["option24"], LocalPlayer:GetValue("OpenDoorsTipsVisible") or false)
    self.option24:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", { parameter = 20, boolean = not LocalPlayer:GetValue("OpenDoorsTipsVisible")}) end)

    self.option14 = self:OptionCheckBox(scroll_control, self.locStrings["option14"], LocalPlayer:GetValue("JetHUD") or false)
    self.option14:GetCheckBox():Subscribe("CheckChanged", function() Events:Fire("JHudActive") Network:Send("UpdateParameters", {parameter = 12, boolean = not LocalPlayer:GetValue("JetHUD")}) end)
    self.option14:SetMargin(Vector2(0, 20), Vector2.Zero)

    local bkpanelsContainer = BaseWindow.Create(widgets)
    bkpanelsContainer:SetVisible(true)
    bkpanelsContainer:SetDock(GwenPosition.Right)
    bkpanelsContainer:SetWidth(310)

    local scroll_bkpanels = ScrollControl.Create(bkpanelsContainer)
    scroll_bkpanels:SetScrollable(false, true)
    scroll_bkpanels:SetDock(GwenPosition.Fill)
    scroll_bkpanels:SetMargin(Vector2(5, 0), Vector2(5, 0))

    self.hidetexttip = Label.Create(bkpanelsContainer)
    self.hidetexttip:SetDock(GwenPosition.Bottom)
    self.hidetexttip:SetMargin(Vector2(5, 5), Vector2(5, 4))
    self.hidetexttip:SetText(self.locStrings["hidetexttip"])
    self.hidetexttip:SizeToContents()

    self.hidetext = Label.Create(bkpanelsContainer)
    self.hidetext:SetVisible(LocalPlayer:GetValue("HiddenHUD") or false)
    self.hidetext:SetTextColor(Color.Yellow)
    self.hidetext:SetDock(GwenPosition.Bottom)
    self.hidetext:SetMargin(Vector2(5, 5), Vector2(5, 0))
    self.hidetext:SetText(self.locStrings["hidetext"])
    self.hidetext:SizeToContents()

    local btnHeight = 30
    self.buttonBoost = Button.Create(scroll_bkpanels)
    self.buttonBoost:SetHeight(btnHeight)
    self.buttonBoost:SetText(self.locStrings["buttonBoost"])
    self.buttonBoost:SetTextSize(self.textSize2)
    self.buttonBoost:SetDock(GwenPosition.Top)
    self.buttonBoost:SetMargin(Vector2(0, 3), Vector2(0, 3))
    self.buttonBoost:Subscribe("Press", self, function() Events:Fire("BoostSettings") end)

    self.buttonSpeedo = Button.Create(scroll_bkpanels)
    self.buttonSpeedo:SetHeight(btnHeight)
    self.buttonSpeedo:SetText(self.locStrings["buttonSpeedo"])
    self.buttonSpeedo:SetTextSize(self.textSize2)
    self.buttonSpeedo:SetDock(GwenPosition.Top)
    self.buttonSpeedo:SetMargin(Vector2(0, 3), Vector2(0, 3))
    self.buttonSpeedo:Subscribe("Press", self, function() Events:Fire("OpenSpeedometerMenu") end)

    self.buttonSDS = Button.Create(scroll_bkpanels)
    self.buttonSDS:SetHeight(btnHeight)
    self.buttonSDS:SetText(self.locStrings["buttonSDS"])
    self.buttonSDS:SetTextSize(self.textSize2)
    self.buttonSDS:SetDock(GwenPosition.Top)
    self.buttonSDS:SetMargin(Vector2(0, 3), Vector2(0, 3))
    self.buttonSDS:Subscribe("Press", self, function() Events:Fire("OpenSkydivingStatsMenu") end)

    self.buttonTags = Button.Create(scroll_bkpanels)
    self.buttonTags:SetHeight(btnHeight)
    self.buttonTags:SetText(self.locStrings["buttonTags"])
    self.buttonTags:SetTextSize(self.textSize2)
    self.buttonTags:SetDock(GwenPosition.Top)
    self.buttonTags:SetMargin(Vector2(0, 3), Vector2(0, 3))
    self.buttonTags:Subscribe("Press", self, function() Events:Fire("OpenNametagsMenu") end)

    self.buttonChatSett = Button.Create(scroll_bkpanels)
    self.buttonChatSett:SetHeight(btnHeight)
    self.buttonChatSett:SetText(self.locStrings["buttonChatSett"])
    self.buttonChatSett:SetTextSize(self.textSize2)
    self.buttonChatSett:SetDock(GwenPosition.Top)
    self.buttonChatSett:SetMargin(Vector2(0, 3), Vector2(0, 3))
    self.buttonChatSett:Subscribe("Press", self, function() Events:Fire("OpenChatMenu") self:SetWindowVisible(false, true) end)

    self.subcategory = Label.Create(scroll_bkpanels)
    self.subcategory:SetDock(GwenPosition.Top)
    self.subcategory:SetMargin(Vector2(0, 10), Vector2(0, 4))
    self.subcategory:SetText(self.locStrings["subcategory"])
    self.subcategory:SizeToContents()

    self.buttonSPOff = Button.Create(scroll_bkpanels)
    self.buttonSPOff:SetHeight(btnHeight)
    self.buttonSPOff:SetText(self.locStrings["buttonSPOff"])
    self.buttonSPOff:SetTextSize(self.textSize2)
    self.buttonSPOff:SetDock(GwenPosition.Top)
    self.buttonSPOff:SetMargin(Vector2(0, 3), Vector2(0, 3))
    self.buttonSPOff:Subscribe("Press", self, function() Network:Send("SPOff") end)

    local powers = BaseWindow.Create(self.window)
    tab:AddPage(self.locStrings["abilities"], powers)

    local bkpanelsContainer = BaseWindow.Create(powers)
    bkpanelsContainer:SetVisible(true)
    bkpanelsContainer:SetDock(GwenPosition.Bottom)
    bkpanelsContainer:SetMargin(Vector2(5, 5), Vector2(5, 5))
    bkpanelsContainer:SetHeight(80)

    local scroll_control = ScrollControl.Create(powers)
    scroll_control:SetScrollable(false, true)
    scroll_control:SetDock(GwenPosition.Fill)
    scroll_control:SetMargin(Vector2(5, 5), Vector2(5, 5))

    self.option17 = self:OptionCheckBox(scroll_control, self.locStrings["option17"], LocalPlayer:GetValue("VehicleEjectBlocker") or false)
    self.option17:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 16, boolean = not LocalPlayer:GetValue("VehicleEjectBlocker")}) end)

    self.option26 = self:OptionCheckBox(scroll_control, self.locStrings["option26"], LocalPlayer:GetValue("AirControl") or false)
    self.option26:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 22, boolean = not LocalPlayer:GetValue("AirControl")}) end)

    self.option23 = self:OptionCheckBox(scroll_control, self.locStrings["option23"], LocalPlayer:GetValue("DriftPhysics") or false)
    self.option23:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 19, boolean = not LocalPlayer:GetValue("DriftPhysics")}) end)

    self.option25 = self:OptionCheckBox(scroll_control, self.locStrings["option25"], LocalPlayer:GetValue("VehicleJump") or false)
    self.option25:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 21, boolean = not LocalPlayer:GetValue("VehicleJump") }) end)

    self.option19 = self:OptionCheckBox(scroll_control, self.locStrings["option19"], LocalPlayer:GetValue("HydraulicsEnabled") or false)
    self.option19:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 18, boolean = not LocalPlayer:GetValue("HydraulicsEnabled")}) end)

    self.option18 = self:OptionCheckBox(scroll_control, self.locStrings["option18"], LocalPlayer:GetValue("WingsuitEnabled") or false)
    self.option18:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 17, boolean = not LocalPlayer:GetValue("WingsuitEnabled")}) end)
    self.option18:SetMargin(Vector2(0, 20), Vector2.Zero)

    self.buttonLH = LabeledCheckBox.Create(scroll_control)
    if LocalPlayer:GetValue("LongerGrapple") then
        self.buttonLH:GetLabel():SetText(self.locStrings["longerGrapple"] .. " (" .. LocalPlayer:GetValue("LongerGrapple") .. "м)")
        self.buttonLH:GetLabel():SetEnabled(true)
        self.buttonLH:GetCheckBox():SetEnabled(true)
    else
        self.buttonLH:GetLabel():SetText(self.locStrings["longerGrapple"] .. " (150м) | [НЕДОСТУПНО]")
        self.buttonLH:GetLabel():SetEnabled(false)
        self.buttonLH:GetCheckBox():SetEnabled(false)
    end
    self.buttonLH:GetLabel():SetTextSize(self.textSize)
    self.buttonLH:SetDock(GwenPosition.Top)
    self.buttonLH:GetCheckBox():SetChecked(LocalPlayer:GetValue("LongerGrappleEnabled") or false)
    self.buttonLH:GetCheckBox():Subscribe("CheckChanged", function() Network:Send("UpdateParameters", {parameter = 15, boolean = not LocalPlayer:GetValue("LongerGrappleEnabled")}) end)

    self.flipbutton = LabeledCheckBox.Create(bkpanelsContainer)
    self.spinbutton = LabeledCheckBox.Create(bkpanelsContainer)
    self.rollbutton = LabeledCheckBox.Create(bkpanelsContainer)

    self.rollbutton:GetCheckBox():SetEnabled(false)
    self.rollbutton:SetDock(GwenPosition.Bottom)
    self.rollbutton:GetLabel():SetText(self.locStrings["rollbutton"])
    self.rollbutton:GetCheckBox():SetChecked(LocalPlayer:GetValue("EnhancedWoet") == "Roll")
    self.rollbutton:GetCheckBox():Subscribe("CheckChanged", function()
        if self.rollbutton:GetCheckBox():GetChecked() then
            LocalPlayer:SetValue("EnhancedWoet", "Roll")

            self.spinbutton:GetCheckBox():SetChecked(false)
            self.flipbutton:GetCheckBox():SetChecked(false)
        else
            if LocalPlayer:GetValue("EnhancedWoet") == "Roll" then
                LocalPlayer:SetValue("EnhancedWoet", nil)
            end
        end
    end)

    self.spinbutton:GetCheckBox():SetEnabled(false)
    self.spinbutton:SetDock(GwenPosition.Bottom)
    self.spinbutton:GetLabel():SetText(self.locStrings["spinbutton"])
    self.spinbutton:GetCheckBox():SetChecked(LocalPlayer:GetValue("EnhancedWoet") == "Spin")
    self.spinbutton:GetCheckBox():Subscribe("CheckChanged", function()
        if self.spinbutton:GetCheckBox():GetChecked() then
            LocalPlayer:SetValue("EnhancedWoet", "Spin")

            self.rollbutton:GetCheckBox():SetChecked(false)
            self.flipbutton:GetCheckBox():SetChecked(false)
        else
            if LocalPlayer:GetValue("EnhancedWoet") == "Spin" then
                LocalPlayer:SetValue("EnhancedWoet", nil)
            end
        end
    end)

    self.flipbutton:GetCheckBox():SetEnabled(false)
    self.flipbutton:SetDock(GwenPosition.Bottom)
    self.flipbutton:GetLabel():SetText(self.locStrings["flipbutton"])
    self.flipbutton:GetCheckBox():SetChecked(LocalPlayer:GetValue("EnhancedWoet") == "Flip")
    self.flipbutton:GetCheckBox():Subscribe("CheckChanged", function()
        if self.flipbutton:GetCheckBox():GetChecked() then
            LocalPlayer:SetValue("EnhancedWoet", "Flip")

            self.rollbutton:GetCheckBox():SetChecked(false)
            self.spinbutton:GetCheckBox():SetChecked(false)
        else
            if LocalPlayer:GetValue("EnhancedWoet") == "Flip" then
                LocalPlayer:SetValue("EnhancedWoet", nil)
            end
        end
    end)

    self.subcategory3 = Label.Create(bkpanelsContainer)
    self.subcategory3:SetDock(GwenPosition.Bottom)
    self.subcategory3:SetMargin(Vector2.Zero, Vector2(0, 5))
    self.subcategory3:SetText(self.locStrings["subcategory3"])
    self.subcategory3:SizeToContents()

    local bkpanelsContainer = BaseWindow.Create(powers)
    bkpanelsContainer:SetVisible(true)
    bkpanelsContainer:SetDock(GwenPosition.Right)
    bkpanelsContainer:SetWidth(310)

    local scroll_bkpanels = ScrollControl.Create(bkpanelsContainer)
    scroll_bkpanels:SetScrollable(false, true)
    scroll_bkpanels:SetDock(GwenPosition.Fill)
    scroll_bkpanels:SetMargin(Vector2(5, 0), Vector2(5, 0))

    self.jpviptip = Label.Create(scroll_bkpanels)
    self.jpviptip:SetVisible(true)
    self.jpviptip:SetTextColor(Color.DarkGray)
    self.jpviptip:SetDock(GwenPosition.Top)
    self.jpviptip:SetMargin(Vector2(0, 3), Vector2(0, 5))
    self.jpviptip:SetText(self.locStrings["jpviptip"])
    self.jpviptip:SizeToContents()

    self.buttonJP = Button.Create(scroll_bkpanels)
    self.buttonJP:SetEnabled(false)
    self.buttonJP:SetHeight(btnHeight)
    self.buttonJP:SetText(self.locStrings["buttonJP"])
    self.buttonJP:SetTextSize(self.textSize2)
    self.buttonJP:SetDock(GwenPosition.Top)
    self.buttonJP:SetMargin(Vector2(0, 3), Vector2(0, 5))
    self.buttonJP:Subscribe("Press", self, self.GetJetpack)

    self.subcategory2 = Label.Create(scroll_bkpanels)
    self.subcategory2:SetVisible(false)
    self.subcategory2:SetDock(GwenPosition.Top)
    self.subcategory2:SetMargin(Vector2(0, 10), Vector2(0, 5))
    self.subcategory2:SetText(self.locStrings["subcategory2"])
    self.subcategory2:SizeToContents()

    local weathertabsContainer = BaseWindow.Create(scroll_bkpanels)
    weathertabsContainer:SetVisible(true)
    weathertabsContainer:SetDock(GwenPosition.Top)
    weathertabsContainer:SetHeight(btnHeight)

    self.button = Button.Create(weathertabsContainer)
    self.button:SetVisible(false)
    self.button:SetText(self.locStrings["button"])
    self.button:SetTextSize(self.textSize)
    self.button:SetDock(GwenPosition.Left)
    self.button:Subscribe("Press", self, function() self:ChangeWeather(0, self.button:GetText()) end)

    self.buttonTw = Button.Create(weathertabsContainer)
    self.buttonTw:SetVisible(false)
    self.buttonTw:SetText(self.locStrings["buttonTw"])
    self.buttonTw:SetTextSize(self.textSize)
    self.buttonTw:SetDock(GwenPosition.Fill)
    self.buttonTw:SetMargin(Vector2(5, 0), Vector2(5, 0))
    self.buttonTw:Subscribe("Press", self, function() self:ChangeWeather(1, self.buttonTw:GetText()) end)

    self.buttonTh = Button.Create(weathertabsContainer)
    self.buttonTh:SetVisible(false)
    self.buttonTh:SetText(self.locStrings["buttonTh"])
    self.buttonTh:SetTextSize(self.textSize)
    self.buttonTh:SetDock(GwenPosition.Right)
    self.buttonTh:Subscribe("Press", self, function() self:ChangeWeather(2, self.buttonTh:GetText()) end)

    local nickcolor = BaseWindow.Create(self.window)
    tab:AddPage(self.locStrings["nickcolor"], nickcolor)

    local tab_control = TabControl.Create(nickcolor)
    tab_control:SetDock(GwenPosition.Fill)

    self.lpColor = LocalPlayer:GetColor()

    self.subcategory4 = Label.Create(nickcolor)
    self.subcategory4:SetDock(GwenPosition.Top)
    self.subcategory4:SetMargin(Vector2(5, 10), Vector2.Zero)
    self.subcategory4:SetText(self.locStrings["subcategory4"])
    self.subcategory4:SizeToContents()

    self.nicknameColorPreview = Label.Create(nickcolor)
    self.nicknameColorPreview:SetText(LocalPlayer:GetName())
    self.nicknameColorPreview:SetTextSize(self.textSize2)
    self.nicknameColorPreview:SetTextColor(self.lpColor)
    self.nicknameColorPreview:SetDock(GwenPosition.Top)
    self.nicknameColorPreview:SetMargin(Vector2(5, 0), Vector2(0, 4))
    self.nicknameColorPreview:SizeToContents()

    self.pcolorPicker = HSVColorPicker.Create(tab_control)
    self.pcolorPicker:SetColor(self.lpColor)
    self.pcolorPicker:SetDock(GwenPosition.Fill)
    self.pcolorPicker:Subscribe("ColorChanged", function()
        self.nicknameColorPreview:SetTextColor(self.lpColor)

        self.lpColor = self.pcolorPicker:GetColor()
        self.colorChanged = true
    end)

    self.setPlayerColorBtn = Button.Create(nickcolor)
    self.setPlayerColorBtn:SetText(self.locStrings["setPlayerColorBtn"])
    local btnColor = Color.LightGreen
    self.setPlayerColorBtn:SetTextHoveredColor(btnColor)
    self.setPlayerColorBtn:SetTextPressedColor(btnColor)
    self.setPlayerColorBtn:SetTextSize(self.textSize)
    self.setPlayerColorBtn:SetHeight(btnHeight)
    self.setPlayerColorBtn:SetDock(GwenPosition.Bottom)
    self.setPlayerColorBtn:SetMargin(Vector2(0, 5), Vector2.Zero)
    self.setPlayerColorBtn:Subscribe("Up", function()
        Network:Send("SetPlyColor", {pcolor = self.lpColor})

        local sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 20,
            sound_id = 22,
            position = LocalPlayer:GetPosition(),
            angle = Angle()
        })

        sound:SetParameter(0, 1)

        Game:FireEvent("bm.savecheckpoint.go")
    end)

    local skyOptions = BaseWindow.Create(self.window)
    tab:AddPage(self.locStrings["sky"], skyOptions)

    local scroll_control = ScrollControl.Create(skyOptions)
    scroll_control:SetScrollable(false, true)
    scroll_control:SetDock(GwenPosition.Fill)
    scroll_control:SetMargin(Vector2(5, 5), Vector2(5, 5))

    self.skyOption4 = LabeledCheckBox.Create(scroll_control)
    self.skyOption = LabeledCheckBox.Create(scroll_control)
    self.skyOption2 = LabeledCheckBox.Create(scroll_control)
    self.skyOption3 = LabeledCheckBox.Create(scroll_control)
    self.skyOption5 = LabeledCheckBox.Create(scroll_control)
    self.skyOption6 = LabeledCheckBox.Create(scroll_control)
    self.skyOptionRnb = LabeledCheckBox.Create(scroll_control)

    self.skyOption:SetDock(GwenPosition.Top)
    self.skyOption:GetLabel():SetText(self.locStrings["skyOption"])
    self.skyOption:GetLabel():SetTextSize(self.textSize)
    self.skyOption:GetCheckBox():Subscribe("CheckChanged", function() self.skyTw = self.skyOption:GetCheckBox():GetChecked() end)

    self.skyOption2:SetDock(GwenPosition.Top)
    self.skyOption2:GetLabel():SetText(self.locStrings["skyOption2"])
    self.skyOption2:GetLabel():SetTextSize(self.textSize)
    self.skyOption2:GetCheckBox():Subscribe("CheckChanged", function() self.skyFi = self.skyOption2:GetCheckBox():GetChecked() end)

    self.skyOption3:SetDock(GwenPosition.Top)
    self.skyOption3:GetLabel():SetText(self.locStrings["skyOption3"])
    self.skyOption3:GetLabel():SetTextSize(self.textSize)
    self.skyOption3:GetCheckBox():Subscribe("CheckChanged", function() self.skyTh = self.skyOption3:GetCheckBox():GetChecked() end)

    self.skyOption4:SetDock(GwenPosition.Top)
    self.skyOption4:GetLabel():SetText(self.locStrings["skyOption4"])
    self.skyOption4:GetLabel():SetTextSize(self.textSize)
    self.skyOption4:GetCheckBox():Subscribe("CheckChanged", function() self.skySi = self.skyOption4:GetCheckBox():GetChecked() end)

    self.skyOption5:SetDock(GwenPosition.Top)
    self.skyOption5:GetLabel():SetText(self.locStrings["skyOption5"])
    self.skyOption5:GetLabel():SetTextSize(self.textSize)
    self.skyOption5:GetCheckBox():Subscribe("CheckChanged", function()
        self.skySe = self.skyOption5:GetCheckBox():GetChecked()

        if self.skySe then
            self.timer = Timer()
        else
            self.timer = nil
        end
    end)

    self.skyOption6:SetDock(GwenPosition.Top)
    self.skyOption6:GetLabel():SetText(self.locStrings["skyOption6"])
    self.skyOption6:GetLabel():SetTextSize(self.textSize)
    self.skyOption6:GetCheckBox():Subscribe("CheckChanged", function() self.skyColor = self.skyOption6:GetCheckBox():GetChecked() end)

    local tab_control = TabControl.Create(scroll_control)
    tab_control:SetDock(GwenPosition.Fill)

    self.toneS1Picker = HSVColorPicker.Create()
    tab_control:AddPage(self.locStrings["color"], self.toneS1Picker)
    tab_control:SetMargin(Vector2(0, 5), Vector2(0, 5))
    self.toneS1Picker:SetDock(GwenPosition.Fill)

    self.skyOptionRnb:SetDock(GwenPosition.Bottom)
    self.skyOptionRnb:GetLabel():SetText(self.locStrings["skyOptionRnb"])
    self.skyOptionRnb:GetLabel():SetTextSize(13)
    self.skyOptionRnb:GetCheckBox():Subscribe("CheckChanged", function()
        self.skyRainbow = self.skyOptionRnb:GetCheckBox():GetChecked()

        if self.skyRainbow then
            self.rT = Timer()
        else
            self.rT = nil
        end
    end)

    local stats = BaseWindow.Create(self.window)
    local statsText = self.locStrings["infoandstats"]
    tab:AddPage(statsText, stats)
    tab:Subscribe("TabSwitch", function()
        if tab:GetCurrentTab():GetText() == statsText then
            Network:Send("RequestStats")
        end
    end)

    local scroll_control = ScrollControl.Create(stats)
    scroll_control:SetScrollable(false, true)
    scroll_control:SetDock(GwenPosition.Fill)
    scroll_control:SetMargin(Vector2(5, 5), Vector2(5, 5))

    self.subcategory7 = GroupBox.Create(scroll_control)
    self.subcategory7:SetDock(GwenPosition.Top)
    self.subcategory7:SetMargin(Vector2(0, 4), Vector2(0, 4))
    self.subcategory7:SetText(self.locStrings["subcategory7"])

    local accountInfo = BaseWindow.Create(self.subcategory7)
    accountInfo:SetDock(GwenPosition.Fill)
    accountInfo:SetMargin(Vector2(110, 4), Vector2(0, 4))

    self.statsName = Label.Create(accountInfo)
    self.statsName:SetDock(GwenPosition.Top)
    self.statsName:SetText(LocalPlayer:GetName())
    self.statsName:SetTextSize(20)

    self.accountInfoText = Label.Create(accountInfo)
    self.accountInfoText:SetDock(GwenPosition.Fill)
    self.accountInfoText:SetText("...")

    local avatar = ImagePanel.Create(self.subcategory7)
    avatar:SetSize(Vector2(100, 100))
    avatar:SetPosition(Vector2(0, 4))
    avatar:SetImage(LocalPlayer:GetAvatar(2))

    self.statsName:SizeToContents()
    self.accountInfoText:SizeToContents()
    self.subcategory7:SetHeight((self.statsName:GetSize().y + 4 * 4) + (self.accountInfoText:GetSize().y + 4 * 4))

    self.subcategory8 = GroupBox.Create(scroll_control)
    self.subcategory8:SetDock(GwenPosition.Top)
    self.subcategory8:SetMargin(Vector2(0, 4), Vector2(0, 4))
    self.subcategory8:SetText(self.locStrings["subcategory8"])

    self.moreInfoText = Label.Create(self.subcategory8)
    self.moreInfoText:SetDock(GwenPosition.Fill)
    self.moreInfoText:SetText("...")

    self.moreInfoText:SizeToContents()
    self.subcategory8:SetHeight((self.moreInfoText:GetSize().y + 4 * 4))

    self.subcategory9 = GroupBox.Create(scroll_control)
    self.subcategory9:SetDock(GwenPosition.Top)
    self.subcategory9:SetMargin(Vector2(0, 4), Vector2(0, 4))
    self.subcategory9:SetText(self.locStrings["subcategory9"])

    self.statsText = Label.Create(self.subcategory9)
    self.statsText:SetDock(GwenPosition.Fill)
    self.statsText:SetText("...")
    self.statsText:SizeToContents()

    self.subcategory9:SetHeight((self.statsText:GetSize().y + 4 * 4))

    local promocodes = BaseWindow.Create(self.window)
    local promocodesText = self.locStrings["promocodes"]
    tab:AddPage(promocodesText, promocodes)
    tab:Subscribe("TabSwitch", function()
        if tab:GetCurrentTab():GetText() == promocodesText then
            Network:Send("RequestPromocodes")
        end
    end)

    local scroll_control = ScrollControl.Create(promocodes)
    scroll_control:SetScrollable(false, true)
    scroll_control:SetDock(GwenPosition.Fill)
    scroll_control:SetMargin(Vector2(5, 5), Vector2(5, 5))

    self.subcategory10 = GroupBox.Create(scroll_control)
    self.subcategory10:SetDock(GwenPosition.Top)
    self.subcategory10:SetMargin(Vector2(0, 4), Vector2(0, 4))
    self.subcategory10:SetText(self.locStrings["subcategory10"])
    self.subcategory10:SetHeight((Render:GetTextHeight("", self.textSize - 4) + btnHeight) * 4.75)

    self.subcategory11 = Label.Create(self.subcategory10)
    self.subcategory11:SetDock(GwenPosition.Top)
    self.subcategory11:SetMargin(Vector2(0, 4), Vector2(0, 4))

    self.subcategory12 = Label.Create(self.subcategory10)
    self.subcategory12:SetDock(GwenPosition.Top)
    self.subcategory12:SetMargin(Vector2(0, 4), Vector2(0, 4))
    self.subcategory12:SetText(self.locStrings["subcategory12"])
    self.subcategory12:SizeToContents()

    self.invitePromocode = TextBox.Create(self.subcategory10)
    self.invitePromocode:SetDock(GwenPosition.Top)
    self.invitePromocode:SetMargin(Vector2(0, 4), Vector2(0, 8))
    self.invitePromocode:SetHeight(btnHeight)
    self.invitePromocode:SetToolTip(self.locStrings["invitePromocode"])
    self.invitePromocode:Subscribe("Focus", self, self.Focus)
    self.invitePromocode:Subscribe("Blur", self, self.Blur)
    self.invitePromocode:Subscribe("EscPressed", self, self.EscPressed)
    self.invitePromocode:Subscribe("TextChanged", function() self.invitePromocode:SetText(self.invitePromocodeText or "") end)

    self.togglePromocodeBtn = Button.Create(self.subcategory10)
    self.togglePromocodeBtn:SetVisible(false)
    self.togglePromocodeBtn:SetText(self.locStrings["togglePromocodeBtn"])
    self.togglePromocodeBtn:SetTextSize(self.textSize)
    self.togglePromocodeBtn:SetDock(GwenPosition.Top)
    self.togglePromocodeBtn:SetMargin(Vector2(0, 4), Vector2(0, 8))
    self.togglePromocodeBtn:SetHeight(btnHeight)
    self.togglePromocodeBtn:Subscribe("Press", function() Network:Send("GeneratePromocode") end)

    self.getInvitationsBonusBtn = Button.Create(self.subcategory10)
    self.getInvitationsBonusBtn:SetEnabled(false)
    self.getInvitationsBonusBtn:SetTextSize(self.textSize)
    self.getInvitationsBonusBtn:SetDock(GwenPosition.Top)
    self.getInvitationsBonusBtn:SetMargin(Vector2(0, 4), Vector2(0, 4))
    self.getInvitationsBonusBtn:SetHeight(btnHeight)
    local btnColor = Color.Yellow
    self.getInvitationsBonusBtn:SetTextHoveredColor(btnColor)
    self.getInvitationsBonusBtn:SetTextPressedColor(btnColor)
    self.getInvitationsBonusBtn:SetText("...")
    self.getInvitationsBonusBtn:Subscribe("Press", function()
        Network:Send("GetInvitationPromocodesReward")
        Network:Send("RequestPromocodes")
    end)

    self.getInviteBonusBtn = Button.Create(self.subcategory10)
    self.getInviteBonusBtn:SetEnabled(false)
    self.getInviteBonusBtn:SetText(self.locStrings["getInviteBonusBtn"])
    self.getInviteBonusBtn:SetTextSize(self.textSize)
    self.getInviteBonusBtn:SetDock(GwenPosition.Top)
    self.getInviteBonusBtn:SetHeight(btnHeight)
    local btnColor = Color.Yellow
    self.getInviteBonusBtn:SetTextHoveredColor(btnColor)
    self.getInviteBonusBtn:SetTextPressedColor(btnColor)
    self.getInviteBonusBtn:Subscribe("Press", function()
        Network:Send("ActivateInvitationPromocode")
        Network:Send("RequestPromocodes")
    end)

    self.subcategory13 = GroupBox.Create(scroll_control)
    self.subcategory13:SetDock(GwenPosition.Top)
    self.subcategory13:SetMargin(Vector2(0, 4), Vector2(0, 4))
    self.subcategory13:SetHeight((Render:GetTextHeight("", self.textSize - 8) + 85))
    self.subcategory13:SetText(self.locStrings["subcategory13"])

    self.promocode = TextBox.Create(self.subcategory13)
    self.promocode:SetDock(GwenPosition.Top)
    self.promocode:SetMargin(Vector2(0, 4), Vector2(0, 8))
    self.promocode:SetHeight(btnHeight)
    self.promocode:SetText("")
    self.promocode:Subscribe("Focus", self, self.Focus)
    self.promocode:Subscribe("Blur", self, self.Blur)
    self.promocode:Subscribe("EscPressed", self, self.EscPressed)
    self.promocode_color = self.promocode:GetTextColor()
    self.promocode:Subscribe("TextChanged", function()
        self.promocode:SetTextColor(self.promocode_color)
        self.getBonusBtn:SetEnabled(self.promocode:GetText() ~= "" and true or false)
    end)

    self.getBonusBtn = Button.Create(self.subcategory13)
    self.getBonusBtn:SetEnabled(false)
    self.getBonusBtn:SetText(self.locStrings["activatePromocode"])
    self.getBonusBtn:SetTextSize(self.textSize)
    self.getBonusBtn:SetDock(GwenPosition.Top)
    self.getBonusBtn:SetHeight(btnHeight)
    self.getBonusBtn:SetText(self.locStrings["activatePromocode"])
    self.getBonusBtn:Subscribe("Press", function() Events:Fire("ApplyPromocode", {type = 0, name = self.promocode:GetText()}) end)

    --[[
    local gettag = LocalPlayer:GetValue("Tag")

    if self.debug_permissions[gettag] then
        local debug = BaseWindow.Create(self.window)
        tab:AddPage("DEBUG", debug)

        local scroll_control = ScrollControl.Create(debug)
        scroll_control:SetScrollable(false, true)
        scroll_control:SetDock(GwenPosition.Fill)
        scroll_control:SetMargin(Vector2(5, 5), Vector2(5, 5))

        self.option20 = self:OptionCheckBox(scroll_control, self.locStrings["option20"], LocalPlayer:GetValue("DEBUGShowOSD") or false)
        self.option20:GetCheckBox():Subscribe("CheckChanged", function() LocalPlayer:SetValue("DEBUGShowOSD", not LocalPlayer:GetValue("DEBUGShowOSD")) end)

        self.option21 = self:OptionCheckBox(scroll_control, self.locStrings["option21"], LocalPlayer:GetValue("DEBUGShowPlayerInfo") or false)
        self.option21:GetCheckBox():Subscribe("CheckChanged", function() LocalPlayer:SetValue("DEBUGShowPlayerInfo", not LocalPlayer:GetValue("DEBUGShowPlayerInfo")) end)

        self.option22 = self:OptionCheckBox(scroll_control, self.locStrings["option22"], LocalPlayer:GetValue("DEBUGShowVehicleInfo") or false)
        self.option22:GetCheckBox():Subscribe("CheckChanged", function() LocalPlayer:SetValue("DEBUGShowVehicleInfo", not LocalPlayer:GetValue("DEBUGShowVehicleInfo")) end)

        self.subcategory5 = Label.Create(scroll_control)
        self.subcategory5:SetDock(GwenPosition.Top)
        self.subcategory5:SetMargin(Vector2(0, 10), Vector2(0, 4))
        self.subcategory5:SetText(self.locStrings["subcategory5"])
        self.subcategory5:SizeToContents()

        local consoleCommand = TextBox.Create(scroll_control)
        consoleCommand:SetDock(GwenPosition.Top)
        consoleCommand:Subscribe("ReturnPressed", self, function() Network:Send("RunConsoleCommand", consoleCommand:GetText()) consoleCommand:SetText("") end)
        consoleCommand:Subscribe("Focus", self, self.Focus)
        consoleCommand:Subscribe("Blur", self, self.Blur)
        consoleCommand:Subscribe("EscPressed", self, self.EscPressed)

        local subcategory = Label.Create(scroll_control)
        subcategory:SetText("FireEvent:")
        subcategory:SetDock(GwenPosition.Top)
        subcategory:SetMargin(Vector2(0, 10), Vector2(0, 4))

        local customFireEvent = TextBox.Create(scroll_control)
        customFireEvent:SetDock(GwenPosition.Top)
        customFireEvent:Subscribe("ReturnPressed", self, function() Game:FireEvent(customFireEvent:GetText()) customFireEvent:SetText("") end)
        customFireEvent:Subscribe("Focus", self, self.Focus)
        customFireEvent:Subscribe("Blur", self, self.Blur)
        customFireEvent:Subscribe("EscPressed", self, self.EscPressed)
    end
	]] --

    Events:Subscribe("PromocodeFound", function() self.promocode:SetTextColor(Color.Green) self.getBonusBtn:SetText("Промокод активирован!") end)
    Events:Subscribe("PromocodeNotFound", function() self.promocode:SetTextColor(Color.Red) self.getBonusBtn:SetText(self.locStrings["activatePromocode"]) end)
end

function Settings:Focus()
    Input:SetEnabled(false)
end

function Settings:Blur()
    Input:SetEnabled(true)
end

function Settings:EscPressed()
    self:Blur()
    self:CloseSettingsMenu()
end

function Settings:ChangeWeather(value, name)
    Events:Fire("CastCenterText", {text = self.locStrings["setweather"] .. name, time = 2})
    Network:Send("SetWeather", {severity = value})

    self:SetWindowVisible(false, true)
end

function Settings:OptionCheckBox(tab, title, checked)
    local checkbox = LabeledCheckBox.Create(tab)
    checkbox:GetLabel():SetText(title)
    checkbox:GetLabel():SetTextSize(self.textSize)

    checkbox:SetDock(GwenPosition.Top)
    if checked then
        checkbox:GetCheckBox():SetChecked(checked)
    end

    return checkbox
end

function Settings:GameRender()
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    if self.skyFi then self.SkyImage5:SetSize(Render.Size) self.SkyImage5:Draw() end

    if self.skyColor then
        if self.skyRainbow and self.rT then
            h = (0.01 * self.rT:GetMilliseconds()) * 5
            color = Color.FromHSV(h % 360, 1, 1)
            Render:FillArea(Vector2.Zero, Render.Size, color + Color(0, 0, 0, 100))
        else
            Render:FillArea(Vector2.Zero, Render.Size, self.toneS1Picker:GetColor() + Color(0, 0, 0, 100))
        end
    end

    if self.skyTw then self.SkyImage2:SetSize(Render.Size) self.SkyImage2:Draw() end
    if self.skySi then self.SkyImage6:SetSize(Render.Size) self.SkyImage6:Draw() end

    if self.skySe then
        self.SkyImage7:SetSize(Render.Size) self.SkyImage7:Draw()

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

    if self.skyTh then self.SkyImage3:SetSize(Render.Size) self.SkyImage3:Draw() end
end

function Settings:GameLoad()
    Events:Fire("GetOption", {actCH = self.actvCH})
end

function Settings:UpdateStats(args)
    self.statsName:SetTextColor(LocalPlayer:GetColor())

    if not self.accountInfoTextRenderEvent then
        local steamId = LocalPlayer:GetSteamId()
        local joinDate = tostring(LocalPlayer:GetValue("JoinDate") or "Х/З")
        local country = tostring(LocalPlayer:GetValue("Country"))

        self.accountInfoTextRenderEvent = self.accountInfoText:Subscribe("Render", function()
            self.accountInfoText:SetText(
                "Steam ID: " .. tostring(steamId) .. " / Steam64 ID: " .. tostring(steamId.id) ..
				self.locStrings["accountInfo1"] .. joinDate ..
				self.locStrings["accountInfo2"] .. self:ConvertSecondsToTimeFormat(LocalPlayer:GetValue("TotalTime") or "0") ..
				self.locStrings["accountInfo3"] .. country ..
				self.locStrings["accountInfo4"] .. tostring(LocalPlayer:GetValue("PlayerLevel")) ..
				self.locStrings["accountInfo5"] .. formatNumber(LocalPlayer:GetMoney())
			)
        end)
    end

    self.statsName:SizeToContents()
    self.accountInfoText:SizeToContents()
    self.subcategory7:SetHeight((self.statsName:GetSize().y + 4 * 4) + (self.accountInfoText:GetSize().y + 4 * 4))

    if not self.moreInfoTextRenderEvent then
        local pId = tostring(LocalPlayer:GetId())

        self.moreInfoTextRenderEvent = self.moreInfoText:Subscribe("Render", function()
            local vehicle = LocalPlayer:GetVehicle()

            self.moreInfoText:SetText(
				self.locStrings["accountInfo6"] .. self:ConvertSecondsToTimeFormat(LocalPlayer:GetValue("SessionTime") or "0") ..
				self.locStrings["accountInfo7"] .. tostring(LocalPlayer:GetValue("ClanTag") or self.locStrings["unknown"]) ..
				self.locStrings["accountInfo8"] .. pId .. self.locStrings["accountInfo9"] .. "rgba(" .. tostring(LocalPlayer:GetColor()) .. ")" ..
				self.locStrings["accountInfo10"] .. args.modelId ..
				self.locStrings["accountInfo11"] .. (vehicle and tostring(vehicle) .. " (ID: " .. tostring(vehicle:GetModelId()) .. ")" or self.locStrings["onfoot"])
			)
        end)
    end

    self.moreInfoText:SizeToContents()
    self.subcategory8:SetHeight((self.moreInfoText:GetSize().y + 4 * 4))

    if not self.statsTextRenderEvent then
        local defaultValue = 0

        self.statsTextRenderEvent = self.statsText:Subscribe("Render", function()
            self.statsText:SetText(
				self.locStrings["accountInfo12"] ..
				tostring(LocalPlayer:GetValue("ChatMessagesCount") or defaultValue) ..
				self.locStrings["accountInfo13"] ..
				tostring(LocalPlayer:GetValue("KillsCount") or defaultValue) ..
				self.locStrings["accountInfo14"] ..
				tostring(LocalPlayer:GetValue("CollectedResourceItemsCount") or defaultValue) ..
				self.locStrings["accountInfo15"] ..
				tostring(LocalPlayer:GetValue("CompletedTasksCount") or defaultValue) ..
				self.locStrings["accountInfo16"] ..
				tostring(LocalPlayer:GetValue("CompletedDailyTasksCount") or defaultValue) ..
				self.locStrings["accountInfo17"] ..
				tostring(LocalPlayer:GetValue("MaxRecordInBestDrift") or defaultValue) ..
				self.locStrings["accountInfo18"] ..
				tostring(LocalPlayer:GetValue("MaxRecordInBestTetris") or defaultValue) ..
				self.locStrings["accountInfo19"] ..
				tostring(LocalPlayer:GetValue("MaxRecordInBestFlight") or defaultValue) ..
				self.locStrings["accountInfo20"] ..
				tostring(LocalPlayer:GetValue("RaceWinsCount") or defaultValue) ..
				self.locStrings["accountInfo21"] ..
				tostring(LocalPlayer:GetValue("TronWinsCount") or defaultValue) ..
				self.locStrings["accountInfo22"] ..
				tostring(LocalPlayer:GetValue("KingHillWinsCount") or defaultValue) ..
				self.locStrings["accountInfo23"] ..
				tostring(LocalPlayer:GetValue("DerbyWinsCount") or defaultValue) ..
				self.locStrings["accountInfo24"] ..
				tostring(LocalPlayer:GetValue("PongWinsCount") or defaultValue) ..
				self.locStrings["accountInfo25"] ..
				tostring(LocalPlayer:GetValue("VictorinsCorrectAnswers") or defaultValue)
			)
        end)
    end

    self.statsText:SizeToContents()
    self.subcategory9:SetHeight((self.statsText:GetSize().y + 4 * 4))
end

function Settings:UpdatePromocodes(args)
    self.subcategory11:SetText(
		self.locStrings["uses"] .. tostring(LocalPlayer:GetValue("PromoCodeUses") or 0) .. " | " ..
		self.locStrings["activations"] .. tostring(LocalPlayer:GetValue("PromoCodeActivations") or 0) .. "\n" ..
		self.locStrings["promocodeGenerationDate"] .. tostring(LocalPlayer:GetValue("PromoCodeCreationDate") or self.locStrings["unknown"])
	)
    self.subcategory11:SizeToContents()

    self.invitePromocodeText = LocalPlayer:GetValue("PromoCodeName")
    if self.invitePromocodeText then
        self.invitePromocode:SetText(self.invitePromocodeText)
        self.togglePromocodeBtn:SetVisible(false)
        self.invitePromocode:SetVisible(not self.togglePromocodeBtn:GetVisible())
    else
        self.invitePromocode:SetText("")
        self.togglePromocodeBtn:SetVisible(true)
        self.invitePromocode:SetVisible(not self.togglePromocodeBtn:GetVisible())
    end

    local isActive = LocalPlayer:GetValue("PromoCodeRewards") and tonumber(LocalPlayer:GetValue("PromoCodeRewards")) >= 1
    self.getInvitationsBonusBtn:SetEnabled(isActive and true or false)

    self.getInvitationsBonusBtn:SetText(self.locStrings["getInvitationsBonus"] .. " ($" .. formatNumber((LocalPlayer:GetValue("PromoCodeRewards") or 0) * InviteBonuses.Bonus1) .. ")")

    self.getInviteBonusBtn:SetEnabled(LocalPlayer:GetValue("ActivePromocode") and true or false)
end

function Settings:LocalPlayerInput(args)
    if args.input == Action.GuiPause then
        self:SetWindowVisible(false)
    end

    if self.actions[args.input] then
        return false
    end
end

function Settings:OpenSettingsMenu()
    if Game:GetState() ~= GUIState.Game then return end

    self:SetWindowVisible(not self.activeWindow, true)
end

function Settings:CloseSettingsMenu()
    if Game:GetState() ~= GUIState.Game then return end

    if self.window and self.window:GetVisible() then
        self:SetWindowVisible(false)
    end
end

function Settings:Render()
    local is_visible = Game:GetState() == GUIState.Game

    if self.window:GetVisible() ~= is_visible then
        self.window:SetVisible(is_visible)
        Mouse:SetVisible(is_visible)
    end
end

function Settings:SetWindowVisible(visible, sound)
    self:CreateWindow()

    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end

    if self.activeWindow then
        self.option4:SetVisible(LocalPlayer:GetValue("JesusModeEnabled") and true or false)

        local longerGrapple = LocalPlayer:GetValue("LongerGrapple")
        if longerGrapple then
            self.buttonLH:GetLabel():SetText(self.locStrings["longerGrapple"] .. " (" .. longerGrapple .. self.locStrings["meters"] .. ")")
            self.buttonLH:GetLabel():SetEnabled(true)
            self.buttonLH:GetCheckBox():SetEnabled(true)
        else
            self.buttonLH:GetLabel():SetText(self.locStrings["longerGrapple"] .. " (150" .. self.locStrings["meters"] .. ") | " .. self.locStrings["unavailable"])
            self.buttonLH:GetLabel():SetEnabled(false)
            self.buttonLH:GetCheckBox():SetEnabled(false)
        end

        local gettag = LocalPlayer:GetValue("Tag")

        if self.permissions[gettag] then
            local pWorld = LocalPlayer:GetWorld() == DefaultWorld

            self.subcategory2:SetVisible(true)
            self.button:SetVisible(true)
            self.buttonTw:SetVisible(true)
            self.buttonTh:SetVisible(true)

            self.button:SetEnabled(pWorld)
            self.buttonTw:SetEnabled(pWorld)
            self.buttonTh:SetEnabled(pWorld)

            self.rollbutton:GetCheckBox():SetEnabled(true)
            self.spinbutton:GetCheckBox():SetEnabled(true)
            self.flipbutton:GetCheckBox():SetEnabled(true)

            self.buttonJP:SetEnabled(pWorld)
            self.jpviptip:SetVisible(false)

            self.subcategory2:SetPosition(Vector2(self.window:GetSize().x - 350, 50))

            local pos_y = self.subcategory2:GetPosition().y + 20
            self.button:SetPosition(Vector2(self.subcategory2:GetPosition().x, pos_y))
            self.buttonTw:SetPosition(Vector2(self.button:GetPosition().x + 105, pos_y))
            self.buttonTh:SetPosition(Vector2(self.buttonTw:GetPosition().x + 105, pos_y))
        else
            self.buttonJP:SetEnabled(false)
            self.jpviptip:SetVisible(true)

            self.subcategory2:SetPosition(Vector2(self.window:GetSize().x - 350, 70))

            local pos_y = self.subcategory2:GetPosition().y + 20
            self.button:SetPosition(Vector2(self.subcategory2:GetPosition().x, pos_y))
            self.buttonTw:SetPosition(Vector2(self.button:GetPosition().x + 105, pos_y))
            self.buttonTh:SetPosition(Vector2(self.buttonTw:GetPosition().x + 105, pos_y))
        end

        Network:Send("RequestStats")

        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
        if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
    else
        if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
        if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
    end

    if sound then
        local effect = ClientEffect.Play(AssetLocation.Game, {
            effect_id = self.activeWindow and 382 or 383,

            position = Camera:GetPosition(),
            angle = Angle()
        })
    end
end

function Settings:ToggleAim()
    self.aim = not self.aim

    if self.aim then
        if self.NoAimRenderEvent then Events:Unsubscribe(self.NoAimRenderEvent) self.NoAimRenderEvent = nil end

        Game:FireEvent("gui.aim.show")
        self.actvCH = self.before
        self.before = nil
        self:GameLoad()
    else
        if not self.NoAimRenderEvent then self.NoAimRenderEvent = Events:Subscribe("Render", self, self.NoAim) end

        if self.actvCH then
            self.actvCH = false
            self.before = true
            self:GameLoad()
        end
    end
end

function Settings:NoAim()
    Game:FireEvent("gui.aim.hide")
end

function Settings:GetJetpack()
    Events:Fire("UseJetpack")
    self:SetWindowVisible(false, true)
end

function Settings:ResetDone()
    self.buttonSPOff:SetEnabled(false)
    self.buttonSPOff:SetText(self.locStrings["posreset"])
end

function Settings:KeyUp(args)
    if Game:GetState() ~= GUIState.Game then return end

    if args.key == VirtualKey.F11 then
        local hiddenHUD = LocalPlayer:GetValue("HiddenHUD")

        if self.hidetext then
            self.hidetext:SetVisible(not hiddenHUD)
        end

        LocalPlayer:SetValue("HiddenHUD", not hiddenHUD)

        self:GameLoad()
    end
end

function Settings:ConvertSecondsToTimeFormat(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local seconds = seconds % 60
    return string.format(self.locStrings["timeFormat"], hours, minutes, seconds)
end

local settings = Settings()