class("PlayersTab")

function PlayersTab:__init(...) ; TabBase.__init(self , "Игроки" , ...)
	self.sortType = PlayerSortType.None
	self.searchBox = nil
	self.sortByComboBox = nil
	self.playerList = nil
	self.recordsIndex = 1
	self.previousRecordsButton = nil
	self.topRecordsButton = nil
	self.nextRecordsButton = nil
	
	-- Create the tab.
	self:CreateSearchArea()
	self:CreateResultsArea()
	self:CreateDetailsArea()
end

function PlayersTab:CreateSearchArea()
	local groupBoxSearch = RaceMenu.CreateGroupBox(self.page)
	groupBoxSearch:SetDock(GwenPosition.Top)
	groupBoxSearch:SetHeight(56)
	groupBoxSearch:SetText("Поиск")
	
	local textBox = TextBox.Create(groupBoxSearch)
	textBox:SetDock(GwenPosition.Left)
	textBox:SetWidth(280)
	textBox:SetText("Поиск по имени")
	textBox:SetDataBool("isValid" , false)
	textBox:Subscribe("Focus" , self , self.SearchBoxFocused)
	textBox:Subscribe("Blur" , self , self.SearchBoxUnfocused)
	textBox:Subscribe("ReturnPressed" , self , self.SearchBoxAccepted)
	self.searchBox = textBox
	
	local CreateOrLabel = function()
		local label = Label.Create(groupBoxSearch)
		label:SetDock(GwenPosition.Left)
		label:SetMargin(Vector2(6 , 5) , Vector2(6 , 0))
		label:SetText("или")
		label:SizeToContents()
		
		return label
	end
	
	CreateOrLabel()
	
	local comboBox = ComboBox.Create(groupBoxSearch)
	comboBox:SetDock(GwenPosition.Left)
	comboBox:SetWidth(180)
	comboBox:AddItem("Поиск по статистике")
	comboBox:AddItem("Запусков")
	comboBox:AddItem("Завершено")
	comboBox:AddItem("Побед")
	comboBox:AddItem("Время в гонках")
	comboBox:Subscribe("Selection" , self , self.SortTypeSelected)
	self.sortByComboBox = comboBox
	
	CreateOrLabel()
	
	local button = Button.Create(groupBoxSearch)
	button:SetPadding(Vector2(8 , 0) , Vector2(8 , 0))
	button:SetDock(GwenPosition.Left)
	button:SetText("Моя статистика")
	button:Subscribe("Press" , self , self.MyStatsButtonPressed)
	self.myStatsButton = button
end

function PlayersTab:CreateResultsArea()
	local groupBoxPlayerTable = RaceMenu.CreateGroupBox(self.page)
	groupBoxPlayerTable:SetDock(GwenPosition.Left)
	groupBoxPlayerTable:SetWidthAutoRel(0.45)
	groupBoxPlayerTable:SetText("Игроки")
	
	-- TODO: Merge this and course records list into a single utility function?
	
	self.playerList = ListBox.Create(groupBoxPlayerTable)
	self.playerList:SetDock(GwenPosition.Fill)
	self.playerList:SetColumnCount(3)
	self.playerList:SetColumnWidth(0 , 32)
	self.playerList:Subscribe("RowSelected" , self , self.RecordSelected)
	
	local buttonsBase = BaseWindow.Create(groupBoxPlayerTable)
	buttonsBase:SetDock(GwenPosition.Bottom)
	buttonsBase:SetHeight(24)
	
	local CreateButton = function(text , dock)
		local button = Button.Create(buttonsBase)
		if dock ~= GwenPosition.Right then
			button:SetMargin(Vector2.Zero , Vector2(40 , 0))
		end
		button:SetPadding(Vector2(2 , 0) , Vector2(2 , 0))
		button:SetDock(dock)
		button:SetText(text)
		button:SizeToContents()
		button:SetEnabled(false)
		button:Subscribe("Press" , self , self.PlayerListButtonPressed)
		
		return button
	end
	
	self.previousRecordsButton = CreateButton("Предыдущие 10" , GwenPosition.Left)
	self.topRecordsButton = CreateButton("Топ 10" , GwenPosition.Left)
	self.nextRecordsButton = CreateButton("Следующие 10" , GwenPosition.Right)
end

function PlayersTab:CreateDetailsArea()
	self.groupBoxPlayerDetails = RaceMenu.CreateGroupBox(self.page)
	self.groupBoxPlayerDetails:SetDock(GwenPosition.Fill)
	self.groupBoxPlayerDetails:SetText("Статистика")
	
	self.playerStatsControl = RaceMenuUtility.CreatePlayerStatsControl(self.groupBoxPlayerDetails)
	self.playerStatsControl.base:SetDock(GwenPosition.Fill)
end

function PlayersTab:Search()
	self:SetRecordButtonsEnabled(false)
	
	if self.sortType == PlayerSortType.None then
		return
	end
	
	local args = {self.sortType , self.recordsIndex}
	if self.sortType == PlayerSortType.Name then
		args[3] = self.searchBox:GetText()
	end
	
	RaceMenu.instance:AddRequest("RequestSortedPlayers" , args)
end

function PlayersTab:SetRecordButtonsEnabled(enabled)
	self.previousRecordsButton:SetEnabled(enabled)
	self.topRecordsButton:SetEnabled(enabled)
	self.nextRecordsButton:SetEnabled(enabled)
end

-- RaceMenu callbacks

function PlayersTab:OnActivate()
	self:NetworkSubscribe("ReceiveSortedPlayers")
	self:NetworkSubscribe("ReceivePlayerStats")
end

function PlayersTab:OnDeactivate()
	self:NetworkUnsubscribeAll()
end

-- GWEN events

function PlayersTab:SearchBoxFocused()
	-- inputSuspensionValue = inputSuspensionValue + 1
	
	if self.searchBox:GetText() == "Поиск по имени" then
		self.searchBox:SetText("")
	end
end

function PlayersTab:SearchBoxUnfocused()
	-- inputSuspensionValue = inputSuspensionValue - 1
	
	if self.searchBox:GetText() == "" then
		self.searchBox:SetText("Поиск по имени")
	end
end

function PlayersTab:SearchBoxAccepted()
	if self.searchBox:GetText():len() == 0 then
		self.sortType = PlayerSortType.None
	else
		self.sortType = PlayerSortType.Name
		self.recordsIndex = 1
		self:Search()
	end
end

function PlayersTab:SortTypeSelected()
	local name = self.sortByComboBox:GetSelectedItem():GetText()
	
	local map = {
		["Запусков"] = PlayerSortType.Starts ,
		["Завершено"] = PlayerSortType.Finishes ,
		["Побед"] = PlayerSortType.Wins ,
		["Время в гонках"] = PlayerSortType.PlayTime
	}
	
	self.sortType = map[name] or PlayerSortType.None
	if self.sortType == PlayerSortType.None then
		return
	end
	
	self.recordsIndex = 1
	self:Search()
end

function PlayersTab:MyStatsButtonPressed()
	self.playerList:Clear()
	
	RaceMenu.instance:AddRequest("RequestPlayerStats" , LocalPlayer:GetSteamId().id)
end

function PlayersTab:RecordSelected()
	local row = self.playerList:GetSelectedRow()
	local steamId = row:GetDataString("steamId")
	RaceMenu.instance:AddRequest("RequestPlayerStats" , steamId)
end

function PlayersTab:PlayerListButtonPressed(button)
	if button == self.previousRecordsButton then
		self.recordsIndex = self.recordsIndex - 10
	elseif button == self.nextRecordsButton then
		self.recordsIndex = self.recordsIndex + 10
	elseif button == self.topRecordsButton then
		self.recordsIndex = 1
	end
	
	if self.recordsIndex < 1 then
		self.recordsIndex = 1
	end
	
	self:Search()
end

-- Network events

function PlayersTab:ReceiveSortedPlayers(args)
	local playerSortType = args[1]
	local sortedPlayers = args[2]
	
	self.playerList:Clear()
	
	for index , sortedPlayer in ipairs(sortedPlayers) do
		local row = self.playerList:AddItem(string.format("%i" , self.recordsIndex + index - 1))
		row:SetDataString("steamId" , sortedPlayer[1])
		row:SetColumnCount(3)
		row:SetCellText(1 , sortedPlayer[2])
		
		if playerSortType == PlayerSortType.PlayTime then
			local text = string.format(
				"%iч, %iм, %iс" ,
				Utility.SplitSeconds(sortedPlayer[3])
			)
			row:SetCellText(2 , text)
		elseif playerSortType == PlayerSortType.Starts then
			row:SetCellText(2 , string.format("%i запусков" , sortedPlayer[3]))
		elseif playerSortType == PlayerSortType.Finishes then
			row:SetCellText(2 , string.format("%i завершений" , sortedPlayer[3]))
		elseif playerSortType == PlayerSortType.Wins then
			row:SetCellText(2 , string.format("%i побед" , sortedPlayer[3]))
		end
	end
	
	self:SetRecordButtonsEnabled(true)
end

function PlayersTab:ReceivePlayerStats(playerStats)
	self.playerStatsControl:Update(playerStats)
	
	self.groupBoxPlayerDetails:SetText(playerStats.name)
end
