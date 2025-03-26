class 'DailyTasks'

function DailyTasks:__init()
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

    self.active = false

    local defaultValue = 666
    self.completedTasksNeeded = defaultValue
    self.fireworksNeeded = defaultValue
    self.flyingRecordNeeded = defaultValue
    self.tetrisRecordNeeded = defaultValue
    self.driftRecordNeeded = defaultValue
    self.tronWinsNeeded = defaultValue

    Network:Send( "GetNeededs" )

    self.window = Window.Create()
    self.window:SetSizeRel( Vector2( 0.5, 0.5 ) )
    self.window:SetMinimumSize( Vector2( 600, 442 ) )
    self.window:SetPositionRel( Vector2( 0.72, 0.5 ) - self.window:GetSizeRel()/2 )
    self.window:SetVisible( self.active )
    self.window:Subscribe( "WindowClosed", self, self.Open )

    local container = BaseWindow.Create( self.window )
	container:SetDock( GwenPosition.Fill )
	container:SetMargin( Vector2( 0, 2 ), Vector2( 0, 4 ) )

    self.prize_btn = Button.Create( container )
    self.prize_btn:SetDock( GwenPosition.Bottom )
    self.prize_btn:SetSize( Vector2( 0, 30 ) )
    self.prize_btn:Subscribe( "Press", self, self.GetPrize )

    self.hidetexttip = Label.Create( container )
	self.hidetexttip:SetDock( GwenPosition.Top )
	self.hidetexttip:SetMargin( Vector2( 0, 2 ), Vector2( 0, 4 ) )

    self.list = SortedList.Create( container )
	self.list:SetDock( GwenPosition.Fill )
	self.list:SetBackgroundVisible( false )
	self.list:AddColumn( "Задание:" )
    self.list:AddColumn( "√/x", 50 )
    --self.list:AddColumn( "Награда", 65 )

    local lang = LocalPlayer:GetValue( "Lang" )
    if lang and lang == "EN" then
		self:Lang()
	else
        if self.window then
            self.window:SetTitle( "▧ Ежедневные задания" )
            self.prize_btn:SetText( "Получить награду " .. "( $10.000 )" )
            self.hidetexttip:SetText( "Выполняй эти задания, чтобы получить свой приз. Задания обновляются каждый день." )
        end
        self.taskstask_txt = "Выполните "
        self.taskstask2_txt = ' заданий'
        self.taskstip_txt = "Задания расположены по всему Панау, а также отмечены кружками на мини-карте"
        self.trontask_txt = 'Выиграте в режиме "Трон" более '
        self.trontask2_txt = "-х раз"
        self.trontip_txt = 'Зайдите в развлечения через меню сервера, чтобы присоединиться к режиму "Трон"'
        self.earn_txt = "Наберите "
        self.tetristask_txt = "+ очков в тетрисе"
        self.tetristip_txt = "Зайдите в развлечения через меню сервера, чтобы поиграть в тетрис"
        self.drifttask_txt = "+ очков хорошечного дрифта"
        self.wingtask_txt = "+ очков полёта на вингсьюте"
        self.wingtip_txt = "Нажмите на Q во время полёта, чтобы раскрыть вингсьют"
        self.bloozingtask_txt = "Расслабьтесь и бухните :)"
        self.bloozingtip_txt = 'Нажмите V, чтобы открыть меню действий, а затем нажмите кнопку "Бухнуть"'
        self.fireworkstask_txt = "Время фейерверков! Взорвите "
        self.fireworkstask2_txt = " осколочных гранат ( ͡° ͜ʖ ͡°)"
        self.fireworkstip_txt = "Нажмите на G, чтобы выбрать гранату"
	end

    self.hidetexttip:SizeToContents()

    Events:Subscribe( "Lang", self, self.Lang )
    Network:Subscribe( "NewNeededs", self, self.NewNeededs )
    Events:Subscribe( "OpenDedMorozMenu", self, self.OpenDedMorozMenu )
    Events:Subscribe( "CloseDedMorozMenu", self, self.CloseDedMorozMenu )
end

function DailyTasks:Lang()
    if self.window then
        self.window:SetTitle( "▧ Daily Tasks" )
        self.hidetexttip:SetText( "Complete these tasks to get your prize. Quests are updated every day." )
        self.prize_btn:SetText( "Get award " .. "( $10.000 )" )
    end
    self.taskstask_txt = "Complete "
    self.taskstask2_txt = " tasks"
    self.taskstip_txt = "Tasks are located all over Panau and are also marked with icons on the minimap"
    self.trontask_txt = 'Win "Tron" mode more than '
    self.trontask2_txt = " times"
    self.trontip_txt = 'Go to the minigames section through the server menu to go to the "Tron" mode'
    self.earn_txt = "Get "
    self.tetristask_txt = "+ points in Tetris"
    self.tetristip_txt = "Go to the minigames section through the server menu to to play Tetris"
    self.drifttask_txt = "+ drifting points"
    self.wingtask_txt = "+ wingsuit flight points"
    self.wingtip_txt = "Press Q while flying to open the wingsuit"
    self.bloozingtask_txt = "Relax and drink :)"
    self.bloozingtip_txt = 'Press V to open the actions menu and then press the "Drink" button'
    self.fireworkstask_txt = "Fireworks time! Detonate "
    self.fireworkstask2_txt = " frag grenades ( ͡° ͜ʖ ͡°)"
    self.fireworkstip_txt = "Press G to select grenade"
end

function DailyTasks:NewNeededs( args )
    self.completedTasksNeeded = args.completedtasksneeded
    self.fireworksNeeded = args.fireworksneeded
    self.flyingRecordNeeded = args.flyingrecordneeded
    self.tetrisRecordNeeded = args.tetrisrecordneeded
    self.driftRecordNeeded = args.driftrecordneeded
    self.tronWinsNeeded = args.tronwinsneeded
end

function DailyTasks:OpenDedMorozMenu()
    if Game:GetState() ~= GUIState.Game then return end
    self:Open()
end

function DailyTasks:CloseDedMorozMenu()
    if Game:GetState() ~= GUIState.Game then return end
	if self.window:GetVisible() == true then
        self:SetWindowVisible( false )
        self.list:Clear()

		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
        if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	end
end

function DailyTasks:Open()
    self:SetWindowVisible( not self.active )

    if self.active then
        local defaultValue = 0
        local completedTasks = LocalPlayer:GetValue( "CompletedTasks" )
        local tronWins = LocalPlayer:GetValue( "TronWins" )
        local tetrisRecord = LocalPlayer:GetValue( "TetrisRecord" )
        local driftRecord = LocalPlayer:GetValue( "DriftRecord" )
        local flyingRecord = LocalPlayer:GetValue( "FlyingRecord" )
        local fireworksTossed = LocalPlayer:GetValue( "FireworksTossed" )
        local bloozing = LocalPlayer:GetValue( "Bloozing" )

        self.completedTasks = ( completedTasks and completedTasks or defaultValue ) >= self.completedTasksNeeded
        self.tronWins = ( tronWins and tronWins or defaultValue ) >= self.tronWinsNeeded
        self.tetrisRecord = ( tetrisRecord and tetrisRecord or defaultValue ) >= self.tetrisRecordNeeded
        self.driftRecord = ( driftRecord and driftRecord or defaultValue ) >= self.driftRecordNeeded
        self.flyingRecord = ( flyingRecord and flyingRecord or defaultValue ) >= self.flyingRecordNeeded
        self.fireworksTossed = ( fireworksTossed and fireworksTossed or defaultValue ) >= self.fireworksNeeded
        self.bloozing = ( bloozing and bloozing or defaultValue ) >= 1

        local prize = LocalPlayer:GetValue( "Prize" )
        if prize and prize ~= 0 then
            local tasksCompleted = completedTasks >= self.completedTasksNeeded and tronWins >= self.tronWinsNeeded and tetrisRecord >= self.tetrisRecordNeeded and driftRecord >= self.driftRecordNeeded and flyingRecord >= self.flyingRecordNeeded and fireworksTossed >= self.fireworksNeeded and bloozing >= 1
            self.prize_btn:SetEnabled( tasksCompleted and true or false )
        else
            self.prize_btn:SetEnabled( false )
        end

        self:Task( self.taskstask_txt .. self.completedTasksNeeded .. self.taskstask2_txt, self.completedTasks, self.taskstip_txt, true )
        self:Task( self.trontask_txt .. self.tronWinsNeeded .. self.trontask2_txt, self.tronWins, self.trontip_txt, true )
        self:Task( self.earn_txt .. self.tetrisRecordNeeded .. self.tetristask_txt, self.tetrisRecord, self.tetristip_txt, true )
        self:Task( self.earn_txt .. self.driftRecordNeeded .. self.drifttask_txt, self.driftRecord, nil, true )
        self:Task( self.earn_txt .. self.flyingRecordNeeded .. self.wingtask_txt, self.flyingRecord, self.wingtip_txt, true )
        self:Task( self.bloozingtask_txt, self.bloozing, self.bloozingtip_txt )
        self:Task( self.fireworkstask_txt .. self.fireworksNeeded .. self.fireworkstask2_txt, self.fireworksTossed, self.fireworkstip_txt )

		if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end
        if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
    else
        self.list:Clear()

		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
        if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	end

    local effect = ClientEffect.Play(AssetLocation.Game, {
        effect_id = self.active and 382 or 383,

        position = Camera:GetPosition(),
        angle = Angle()
    })
end

function DailyTasks:Task( text, completed, tip, rewarded )
    local item = self.list:AddItem( text )
    item:SetCellText( 1, completed and "√" or "x" )
    item:SetTextColor( completed and Color.Chartreuse or Color.Silver )
    if tip then
        item:SetToolTip( tip )
    end

    --[[local button = Button.Create( item )
    button:SetText( rewarded and "Забрать" or "-" )
    button:SetDock( GwenPosition.Fill )
    button:SetEnabled( ( rewarded and completed ) and true or false )

    item:SetCellContents( 2, button )]]--
end

function DailyTasks:GetPrize()
    self.prize_btn:SetEnabled( false )

    local sound = ClientSound.Create(AssetLocation.Game, {
		bank_id = 20,
		sound_id = 20,
		position = LocalPlayer:GetPosition(),
		angle = Angle()
	})

	sound:SetParameter(0,1)

    Network:Send( "GetPrize" )
end

function DailyTasks:LocalPlayerInput( args )
    if args.input == Action.GuiPause then
        self:CloseDedMorozMenu()
    end
	if self.actions[args.input] then
		return false
	end
end

function DailyTasks:Render()
	local is_visible = Game:GetState() == GUIState.Game

	if self.window:GetVisible() ~= is_visible then
		self.window:SetVisible( is_visible )
	end

	Mouse:SetVisible( is_visible )
end

function DailyTasks:SetWindowVisible( visible )
    if self.active ~= visible then
		self.active = visible
		self.window:SetVisible( visible )
		Mouse:SetVisible( visible )
	end
end

tasks = DailyTasks()