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

    self.activeWindow = false

    local defaultValue = 666
    self.completedTasksNeeded = defaultValue
    self.fireworksNeeded = defaultValue
    self.flyingRecordNeeded = defaultValue
    self.tetrisRecordNeeded = defaultValue
    self.driftRecordNeeded = defaultValue
    self.tronWinsNeeded = defaultValue

    Network:Send("GetNeededs")

    self.window = Window.Create()
    self.window:SetSizeRel(Vector2(0.5, 0.5))
    self.window:SetMinimumSize(Vector2(600, 442))
    self.window:SetPositionRel(Vector2(0.72, 0.5) - self.window:GetSizeRel() / 2)
    self.window:SetVisible(self.activeWindow)
    self.window:Subscribe("WindowClosed", self, function() self:SetWindowVisible(false, true) end)

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.window:SetTitle("▧ Ежедневные задания")

        self.locStrings = {
            getreward = "Получить награду",
            toptip = "Выполняй эти задания, чтобы получить свой приз. Задания обновляются каждый день.",
            task = "Задание",
            reward = "Награда",
            taskstask = "Выполните ",
            taskstask2 = ' заданий',
            taskstip = "Задания расположены по всему Панау, а также отмечены кружками на мини-карте",
            trontask = 'Выиграте в режиме "Трон" более ',
            trontask2 = "-х раз",
            trontip = 'Зайдите в развлечения через меню сервера, чтобы присоединиться к режиму "Трон"',
            earn = "Наберите ",
            tetristask = "+ очков в тетрисе",
            tetristip = "Зайдите в развлечения через меню сервера, чтобы поиграть в тетрис",
            drifttask = "+ очков хорошечного дрифта",
            wingtask = "+ очков полёта на вингсьюте",
            wingtip = "Нажмите на Q во время полёта, чтобы раскрыть вингсьют",
            bloozingtask = "Расслабьтесь и бухните :)",
            bloozingtip = 'Нажмите V, чтобы открыть меню действий, а затем нажмите кнопку "Бухнуть"',
            fireworkstask = "Время фейерверков! Взорвите ",
            fireworkstask2 = " осколочных гранат ( ͡° ͜ʖ ͡°)",
            fireworkstip = "Нажмите на G, чтобы выбрать гранату"
        }
    end

    Events:Subscribe("Lang", self, self.Lang)
    Network:Subscribe("NewNeededs", self, self.NewNeededs)
    Events:Subscribe("OpenDedMorozMenu", self, self.OpenDedMorozMenu)
    Events:Subscribe("CloseDedMorozMenu", self, function() self:SetWindowVisible(false) end)
end

function DailyTasks:Lang()
    self.window:SetTitle("▧ Daily Tasks")

    self.locStrings = {
        getreward = "Get award",
        toptip = "Complete these tasks to get your prize. Quests are updated every day.",
        task = "Task",
        reward = "Reward",
        taskstask = "Complete ",
        taskstask2 = " tasks",
        taskstip = "Tasks are located all over Panau and are also marked with icons on the minimap",
        trontask = 'Win "Tron" mode more than ',
        trontask2 = " times",
        trontip = 'Go to the minigames section through the server menu to go to the "Tron" mode',
        earn = "Get ",
        tetristask = "+ points in Tetris",
        tetristip = "Go to the minigames section through the server menu to to play Tetris",
        drifttask = "+ drifting points",
        wingtask = "+ wingsuit flight points",
        wingtip = "Press Q while flying to open the wingsuit",
        bloozingtask = "Relax and drink :)",
        bloozingtip = 'Press V to open the actions menu and then press the "Drink" button',
        fireworkstask = "Fireworks time! Detonate ",
        fireworkstask2 = " frag grenades ( ͡° ͜ʖ ͡°)",
        fireworkstip = "Press G to select grenade"
    }
end

function DailyTasks:NewNeededs(args)
    self.completedTasksNeeded = args.completedtasksneeded
    self.fireworksNeeded = args.fireworksneeded
    self.flyingRecordNeeded = args.flyingrecordneeded
    self.tetrisRecordNeeded = args.tetrisrecordneeded
    self.driftRecordNeeded = args.driftrecordneeded
    self.tronWinsNeeded = args.tronwinsneeded
end

function DailyTasks:OpenDedMorozMenu()
    if Game:GetState() ~= GUIState.Game then return end

    self:SetWindowVisible(not self.activeWindow, true)
end

function DailyTasks:CreateWindowObjects()
    if self.isObjectsCreated then return end

    self.isObjectsCreated = true

    local container = BaseWindow.Create(self.window)
    container:SetDock(GwenPosition.Fill)
    container:SetMargin(Vector2(0, 2), Vector2(0, 4))

    self.prize_btn = Button.Create(container)
    self.prize_btn:SetDock(GwenPosition.Bottom)
    self.prize_btn:SetSize(Vector2(0, 30))
    self.prize_btn:SetText(self.locStrings["getreward"] .. " ( $10.000 )")
    self.prize_btn:Subscribe("Press", self, self.GetPrize)

    self.hidetexttip = Label.Create(container)
    self.hidetexttip:SetDock(GwenPosition.Top)
    self.hidetexttip:SetMargin(Vector2(0, 2), Vector2(0, 4))
    self.hidetexttip:SetText(self.locStrings["toptip"])
    self.hidetexttip:SizeToContents()

    self.list = SortedList.Create(container)
    self.list:SetDock(GwenPosition.Fill)
    self.list:SetBackgroundVisible(false)
    self.list:AddColumn(self.locStrings["task"])
    self.list:AddColumn("√/x", 50)
    -- self.list:AddColumn(self.locStrings["reward"], 65)
end

function DailyTasks:Task(text, completed, tip, rewarded)
    local item = self.list:AddItem(text)
    item:SetCellText(1, completed and "√" or "x")
    item:SetTextColor(completed and Color.LightGreen or Color.Silver)
    if tip then
        item:SetToolTip(tip)
    end

    --[[local button = Button.Create( item )
    button:SetText( rewarded and "Забрать" or "-" )
    button:SetDock( GwenPosition.Fill )
    button:SetEnabled( ( rewarded and completed ) and true or false )

    item:SetCellContents( 2, button )]] --
end

function DailyTasks:GetPrize()
    self.prize_btn:SetEnabled(false)

    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 20,
        sound_id = 20,
        position = LocalPlayer:GetPosition(),
        angle = Angle()
    })

    sound:SetParameter(0, 1)

    Network:Send("GetPrize")
end

function DailyTasks:LocalPlayerInput(args)
    if args.input == Action.GuiPause then
        self:SetWindowVisible(false)
    end

    if self.actions[args.input] then
        return false
    end
end

function DailyTasks:Render()
    local is_visible = Game:GetState() == GUIState.Game

    if self.window:GetVisible() ~= is_visible then
        self.window:SetVisible(is_visible)
        Mouse:SetVisible(is_visible)
    end
end

function DailyTasks:SetWindowVisible(visible, sound)
    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end

    if self.activeWindow then
        self:CreateWindowObjects()

        local defaultValue = 0
        local completedTasks = LocalPlayer:GetValue("CompletedTasks")
        local tronWins = LocalPlayer:GetValue("TronWins")
        local tetrisRecord = LocalPlayer:GetValue("TetrisRecord")
        local driftRecord = LocalPlayer:GetValue("DriftRecord")
        local flyingRecord = LocalPlayer:GetValue("FlyingRecord")
        local fireworksTossed = LocalPlayer:GetValue("FireworksTossed")
        local bloozing = LocalPlayer:GetValue("Bloozing")

        self.completedTasks = (completedTasks and completedTasks or defaultValue) >= self.completedTasksNeeded
        self.tronWins = (tronWins and tronWins or defaultValue) >= self.tronWinsNeeded
        self.tetrisRecord = (tetrisRecord and tetrisRecord or defaultValue) >= self.tetrisRecordNeeded
        self.driftRecord = (driftRecord and driftRecord or defaultValue) >= self.driftRecordNeeded
        self.flyingRecord = (flyingRecord and flyingRecord or defaultValue) >= self.flyingRecordNeeded
        self.fireworksTossed = (fireworksTossed and fireworksTossed or defaultValue) >= self.fireworksNeeded
        self.bloozing = (bloozing and bloozing or defaultValue) >= 1

        local prize = LocalPlayer:GetValue("Prize")
        if prize and prize ~= 0 then
            local tasksCompleted = completedTasks >= self.completedTasksNeeded and tronWins >= self.tronWinsNeeded and tetrisRecord >= self.tetrisRecordNeeded and driftRecord >= self.driftRecordNeeded and flyingRecord >= self.flyingRecordNeeded and fireworksTossed >= self.fireworksNeeded and bloozing >= 1
            self.prize_btn:SetEnabled(tasksCompleted and true or false)
        else
            self.prize_btn:SetEnabled(false)
        end

        self:Task(self.locStrings["taskstask"] .. self.completedTasksNeeded .. self.locStrings["taskstask2"], self.completedTasks, self.locStrings["taskstip"], true)
        self:Task(self.locStrings["trontask"] .. self.tronWinsNeeded .. self.locStrings["trontask2"], self.tronWins, self.locStrings["trontip"], true)
        self:Task(self.locStrings["earn"] .. self.tetrisRecordNeeded .. self.locStrings["tetristask"], self.tetrisRecord, self.locStrings["tetristip"], true)
        self:Task(self.locStrings["earn"] .. self.driftRecordNeeded .. self.locStrings["drifttask"], self.driftRecord, nil, true)
        self:Task(self.locStrings["earn"] .. self.flyingRecordNeeded .. self.locStrings["wingtask"], self.flyingRecord, self.locStrings["wingtip"], true)
        self:Task(self.locStrings["bloozingtask"], self.bloozing, self.locStrings["bloozingtip"])
        self:Task(self.locStrings["fireworkstask"] .. self.fireworksNeeded .. self.locStrings["fireworkstask2"], self.fireworksTossed, self.locStrings["fireworkstip"])

        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
        if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
    else
        if self.list then self.list:Clear() end

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

local dailytasks = DailyTasks()