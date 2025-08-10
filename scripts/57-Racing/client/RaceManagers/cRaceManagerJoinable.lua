class("RaceManagerJoinable")

function RaceManagerJoinable:__init(args)
    EGUSM.SubscribeUtility.__init(self)
    self.labels = nil
    self.rows = nil

    self:AddToRaceMenu()

    self:QueuedRaceCreate(args.raceInfo)

    self:EventSubscribe("RaceCreate")
    self:EventSubscribe("RaceEnd")
    self:NetworkSubscribe("QueuedRaceCreate")
    self:NetworkSubscribe("QueuedRacePlayersChange")
    self:NetworkSubscribe("JoinQueue")
    self:NetworkSubscribe("LeaveQueue")
end

function RaceManagerJoinable:AddToRaceMenu()
    local locStrings = settings.locStrings

    local groupBox = RaceMenu.CreateGroupBox(RaceMenu.instance.addonArea)
    groupBox:SetDock(GwenPosition.Fill)
    groupBox:SetText(locStrings["nextrace"])

    local fontSize = 16

    local tableControl
	tableControl, self.labels, self.rows = RaceMenuUtility.CreateTable(
		fontSize,
		{
			"Игроков",
			"Карта",
			"Тип",
			"Авторы",
			"Чекпоинтов",
			"Столкновения",
			-- Distance?
		}
	)
    tableControl:SetParent(groupBox)
    tableControl:SetDock(GwenPosition.Top)
    self.labels["Карта"]:SetTextColor(settings.textColor)
    self.rows["Чекпоинтов"]:SetToolTip(locStrings["checkpointsperlap"])

    local buttonsBase = BaseWindow.Create(groupBox)
    buttonsBase:SetDock(GwenPosition.Top)
    buttonsBase:SetHeight(32)

    self.joinButton = Button.Create(buttonsBase)
    self.joinButton:SetPadding(Vector2(8, 8), Vector2(8, 8))
    self.joinButton:SetDock(GwenPosition.Left)
    self.joinButton:SetTextSize(fontSize)
    self.joinButton:SetText(locStrings["join"])
    self.joinButton:SizeToContents()
    self.joinButton:SetWidthAutoRel(0.475)
    self.joinButton:Subscribe("Press", self, self.JoinButtonPressed)

    self.leaveButton = Button.Create(buttonsBase)
    self.leaveButton:SetPadding(Vector2(8, 8), Vector2(8, 8))
    self.leaveButton:SetDock(GwenPosition.Fill)
    self.leaveButton:SetTextSize(fontSize)
    self.leaveButton:SetText(locStrings["left"])
    self.leaveButton:SizeToContents()
    self.leaveButton:SetEnabled(false)
    self.leaveButton:Subscribe("Press", self, self.LeaveButtonPressed)
end

-- GWEN events

function RaceManagerJoinable:JoinButtonPressed()
    if LocalPlayer:GetWorld() ~= DefaultWorld then
        self.joinButton:SetText("Выйдите из других режимов")
        return
    else
        self.joinButton:SetText(settings.locStrings["join"])
    end

    Network:Send("JoinRace", ".")
    self.joinButton:SetEnabled(false)
end

function RaceManagerJoinable:LeaveButtonPressed()
    Network:Send("LeaveRace", ".")
    self.leaveButton:SetEnabled(false)
end

-- Events

function RaceManagerJoinable:RaceCreate()
    self.leaveButton:SetEnabled(true)
end

function RaceManagerJoinable:RaceEnd()
    self.joinButton:SetEnabled(true)
    self.leaveButton:SetEnabled(false)
end

-- Network events

function RaceManagerJoinable:QueuedRaceCreate(args)
    self.nextRaceMaxPlayers = args.maxPlayers
    self.labels["Игроков"]:SetText(string.format("%i/%i", args.currentPlayers, args.maxPlayers))
    self.labels["Карта"]:SetText(args.course.name)
    self.labels["Авторы"]:SetText(table.concat(args.course.authors, ", "))
    self.labels["Тип"]:SetText(args.course.type)
    self.labels["Чекпоинтов"]:SetText(string.format("%i", args.course.checkpointCount))

    if args.collisions then
        self.labels["Столкновения"]:SetText("Включены")
    else
        self.labels["Столкновения"]:SetText("Отключены")
    end

    for title, label in pairs(self.labels) do
        label:SizeToContents()
    end
end

function RaceManagerJoinable:QueuedRacePlayersChange(newCount)
    self.labels["Игроков"]:SetText(string.format("%i/%i", newCount, self.nextRaceMaxPlayers))
end

function RaceManagerJoinable:JoinQueue()
    self.joinButton:SetEnabled(false)
    self.leaveButton:SetEnabled(true)
end

function RaceManagerJoinable:LeaveQueue()
    self.joinButton:SetEnabled(true)
    self.leaveButton:SetEnabled(false)
end