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

    --self.dedmimage = Image.Create( AssetLocation.Resource, "DedMImage" )

    self.active = false

    self.huntkillsneeded = 666
    self.fireworksneeded = 666
    self.flyingrecordneeded = 666
    self.tetrisrecordneeded = 666
    self.driftrecordneeded = 666
    self.tronwinsneeded = 666

    Network:Send( "GetNeededs" )

    self.unlock = "√"

    self.huntkills = "x"
    self.huntkillsC = Color.Silver

    self.tronwins = "x"
    self.tronwinsC = Color.Silver

    self.tetrisrecord = "x"
    self.tetrisrecordC = Color.Silver

    self.driftrecord = "x"
    self.driftrecordC = Color.Silver

    self.flyingrecord = "x"
    self.flyingrecordC = Color.Silver

    self.fireworkstossed = "x"
    self.fireworkstossedC = Color.Silver

    self.bloozing = "x"
    self.bloozingC = Color.Silver

    self.window = Window.Create()
    self.window:SetSizeRel( Vector2( 0.5, 0.5 ) )
    self.window:SetMinimumSize( Vector2( 600, 442 ) )
    self.window:SetPositionRel( Vector2( 0.72, 0.5 ) - self.window:GetSizeRel()/2 )
    self.window:SetVisible( self.active )
    self.window:Subscribe( "WindowClosed", self, self.Open )

    self.LeftLabel = Label.Create( self.window )
	self.LeftLabel:SetDock( GwenPosition.Fill )
	self.LeftLabel:SetMargin( Vector2( 0, 2 ), Vector2( 0, 4 ) )

    self.prize_btn = Button.Create( self.LeftLabel )
    self.prize_btn:SetDock( GwenPosition.Bottom )
    self.prize_btn:SetSize( Vector2( 0, 30 ) )
    self.prize_btn:Subscribe( "Press", self, self.GetPrize )

    self.hidetexttip = Label.Create( self.LeftLabel )
	self.hidetexttip:SetDock( GwenPosition.Top )
	self.hidetexttip:SetMargin( Vector2( 0, 2 ), Vector2( 0, 4 ) )
    self.hidetexttip:SizeToContents()

    self.list = SortedList.Create( self.LeftLabel )
	self.list:SetDock( GwenPosition.Fill )
	self.list:SetBackgroundVisible( false )
	self.list:AddColumn( "Задание:" )
    self.list:AddColumn( "√/x", 50 )

    if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
        if self.window then
            self.window:SetTitle( "▧ Ежедневные задания" )
            self.prize_btn:SetText( "Получить награду " .. "( $10.000 )" )
            self.hidetexttip:SetText( "Выполняй эти задания, чтобы получить свой приз. Задания обновляются каждый день." )
        end
        self.hunttask_txt = "Убейте "
        self.hunttask2_txt = ' человек в режиме "Охота"'
        self.hunttip_txt = 'Зайдите в развлечения через меню сервера, чтобы присоединиться к режиму "Охота"'
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
    self.hunttask_txt = "Kill "
    self.hunttask2_txt = ' players in "Hunt" mode'
    self.hunttip_txt = 'Go to the minigames section through the server menu to go to the "Hunt" mode'
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
    self.huntkillsneeded = args.huntkillsneeded
    self.fireworksneeded = args.fireworksneeded
    self.flyingrecordneeded = args.flyingrecordneeded
    self.tetrisrecordneeded = args.tetrisrecordneeded
    self.driftrecordneeded = args.driftrecordneeded
    self.tronwinsneeded = args.tronwinsneeded
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

function DailyTasks:Open()
    self:SetWindowVisible( not self.active )

    if self.active then
        if LocalPlayer:GetValue( "HuntKills" ) then
            if LocalPlayer:GetValue( "HuntKills" ) >= self.huntkillsneeded then
                self.huntkills = self.unlock
                self.huntkillsC = Color.Chartreuse
            end
        end

        if LocalPlayer:GetValue( "TronWins" ) then
            if LocalPlayer:GetValue( "TronWins" ) >= self.tronwinsneeded then
                self.tronwins = self.unlock
                self.tronwinsC = Color.Chartreuse
            end
        end
    
        if LocalPlayer:GetValue( "TetrisRecord" ) then
            if LocalPlayer:GetValue( "TetrisRecord" ) >= self.tetrisrecordneeded then
                self.tetrisrecord = self.unlock
                self.tetrisrecordC = Color.Chartreuse
            end
        end

        if LocalPlayer:GetValue( "DriftRecord" ) then
            if LocalPlayer:GetValue( "DriftRecord" ) >= self.driftrecordneeded then
                self.driftrecord = self.unlock
                self.driftrecordC = Color.Chartreuse
            end
        end

        if LocalPlayer:GetValue( "FlyingRecord" ) then
            if LocalPlayer:GetValue( "FlyingRecord" ) >= self.flyingrecordneeded then
                self.flyingrecord = self.unlock
                self.flyingrecordC = Color.Chartreuse
            end
        end

        if LocalPlayer:GetValue( "FireworksTossed" ) then
            if LocalPlayer:GetValue( "FireworksTossed" ) >= self.fireworksneeded then
                self.fireworkstossed = self.unlock
                self.fireworkstossedC = Color.Chartreuse
            end
        end

        if LocalPlayer:GetValue( "Bloozing" ) then
            if LocalPlayer:GetValue( "Bloozing" ) >= 1 then
                self.bloozing = self.unlock
                self.bloozingC = Color.Chartreuse
            end
        end

        if LocalPlayer:GetValue( "Prize" ) ~= 0 then
            if LocalPlayer:GetValue( "HuntKills" ) >= self.huntkillsneeded and LocalPlayer:GetValue( "TronWins" ) >= self.tronwinsneeded and LocalPlayer:GetValue( "TetrisRecord" ) >= self.tetrisrecordneeded and LocalPlayer:GetValue( "DriftRecord" ) >= self.driftrecordneeded and LocalPlayer:GetValue( "FlyingRecord" ) >= self.flyingrecordneeded and LocalPlayer:GetValue( "FireworksTossed" ) >= self.fireworksneeded and LocalPlayer:GetValue( "Bloozing" ) >= 1 then
                self.prize_btn:SetEnabled( true )
            else
                self.prize_btn:SetEnabled( false )
            end
        else
            self.prize_btn:SetEnabled( false )
        end

        local item = self.list:AddItem( self.hunttask_txt .. self.huntkillsneeded .. self.hunttask2_txt )
        item:SetCellText( 1, self.huntkills )
        item:SetTextColor( self.huntkillsC )
        item:SetToolTip( self.hunttip_txt )
        local item = self.list:AddItem( self.trontask_txt .. self.tronwinsneeded .. self.trontask2_txt )
        item:SetCellText( 1, self.tronwins )
        item:SetTextColor( self.tronwinsC )
        item:SetToolTip( self.trontip_txt )
        local item = self.list:AddItem( self.earn_txt .. self.tetrisrecordneeded .. self.tetristask_txt )
        item:SetCellText( 1,  self.tetrisrecord )
        item:SetTextColor( self.tetrisrecordC )
        item:SetToolTip( self.tetristip_txt )
        local item = self.list:AddItem( self.earn_txt .. self.driftrecordneeded .. self.drifttask_txt )
        item:SetCellText( 1,  self.driftrecord )
        item:SetTextColor( self.driftrecordC )
        local item = self.list:AddItem( self.earn_txt .. self.flyingrecordneeded .. self.wingtask_txt )
        item:SetCellText( 1,  self.flyingrecord )
        item:SetTextColor( self.flyingrecordC )
        item:SetToolTip( self.wingtip_txt )
        local item = self.list:AddItem( self.bloozingtask_txt )
        item:SetCellText( 1,  self.bloozing )
        item:SetTextColor( self.bloozingC )
        item:SetToolTip( self.bloozingtip_txt )
        local item = self.list:AddItem( self.fireworkstask_txt .. self.fireworksneeded .. self.fireworkstask2_txt )
        item:SetCellText( 1,  self.fireworkstossed )
        item:SetTextColor( self.fireworkstossedC )
        item:SetToolTip( self.fireworkstip_txt )

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
        self.list:Clear()
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

function DailyTasks:GetPrize( args )
    self.prize_btn:SetEnabled( false )
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