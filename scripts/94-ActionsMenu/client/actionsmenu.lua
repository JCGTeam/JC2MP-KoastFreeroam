class 'ActionsMenu'

function ActionsMenu:__init()
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
        ["Organizer"] = true,
        ["Parther"] = true,
        ["VIP"] = true
    }

    self:UpdateKeyBinds()

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            title = "▧ Меню действий",
            healme = "Вылечить себя",
            killme = "Убить себя",
            clearinv = "Очистить инвентарь",
            sendmoney_txt = "Отправить деньги",
            bloozing = "Бухнуть",
            seat = "Сесть",
            lezat = "Лечь",
            vehiclerepair = "Починить транспорт (Не визуально)",
            vehicledriverseatlock = "Заблокировать водительскую дверь",
            vehicledriverseatunlock = "Разблокировать водительскую дверь",
            vehicleboom = "Взорвать транспорт",
            sky = "Взлететь в небо",
            down = "Опуститься вниз",
            pvpblock = "Вы не можете использовать это во время боя!",
            novehicle = "Вы должны находиться за водительским местом!",
            novip = "У вас отсутствует VIP-статус :(",
            heal = "++ Восстановление ++",
            healnotneeded = "Восстановление не требуется",
            seatlocked = "Водительская дверь заблокирована",
            seatunlocked = "Водительская дверь разблокирована",
            ltext1 = "Игрок:",
            ltext2 = "Транспорт:"
        }
    end

    self.textSize = 15

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("UpdateKeyBinds", self, self.UpdateKeyBinds)
    Events:Subscribe("KeyUp", self, self.KeyUp)
    Events:Subscribe("LocalPlayerChat", self, self.LocalPlayerChat)
    Events:Subscribe("LocalPlayerWorldChange", self, function() self:SetWindowVisible(false) end)
end

function ActionsMenu:Lang()
    self.locStrings = {
        title = "▧ Actions Menu",
        healme = "Heal Yourself",
        killme = "Kill Yourself",
        clearinv = "Clear Inventory",
        sendmoney_txt = "Send Money",
        bloozing = "Drink",
        seat = "Sit",
        lezat = "Lie",
        vehiclerepair = "Repair a vehicle (Not visually)",
        vehicledriverseatlock = "Lock driver's door",
        vehicledriverseatunlock = "Unlock driver's door",
        vehicleboom = "Blow up a vehicle",
        sky = "Take to the Sky",
        down = "Going Down",
        pvpblock = "You cannot use this during combat!",
        novehicle = "You must be behind the driver's seat!",
        novip = "Required VIP status :(",
        heal = "++ Healing ++",
        healnotneeded = "Healing is not required",
        seatlocked = "Driver's door is locked",
        seatunlocked = "Driver's door is unlocked",
        ltext1 = "Player:",
        ltext2 = "Vehicle:"
    }
end

function ActionsMenu:UpdateKeyBinds()
    local keyBinds = LocalPlayer:GetValue("KeyBinds")
    local bind = keyBinds and keyBinds["ActionsMenu"]

    self.expectedKey = bind and bind.type == "Key" and bind.value or 86
end

function ActionsMenu:SetWindowVisible(visible, sound)
    self:CreateWindow()

    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end

    if self.activeWindow then
        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
        if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end

        Events:Fire("CloseSendMoney")
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

function ActionsMenu:KeyUp(args)
    if Game:GetState() ~= GUIState.Game or LocalPlayer:GetWorld() ~= DefaultWorld then return end

    if args.key == self.expectedKey then
        self:SetWindowVisible(not self.activeWindow, true)
    end
end


function ActionsMenu:LocalPlayerChat(args)
    local cmd_args = args.text:split(" ")

    if #cmd_args ~= 1 then return end

    if cmd_args[1] == "/heal" then self:Heal() end
    if cmd_args[1] == "/kill" or cmd_args[1] == "/suicide" then Network:Send("KillMe") end
    if cmd_args[1] == "/clear" then Network:Send("ClearInv") end
    if cmd_args[1] == "/drink" or cmd_args[1] == "/blooze" then Events:Fire("BloozingStart") end
    if cmd_args[1] == "/repair" then self:VehicleRepair() end
    if cmd_args[1] == "/lock" then self:VehicleToggleDriverSeatLock() end
    if cmd_args[1] == "/boom" then self:VehicleBoom() end
    if cmd_args[1] == "/sky" then self:Sky() end
    if cmd_args[1] == "/down" then self:Down() end
end

function ActionsMenu:CreateActionButton(title, event, color)
    local actionBtn = Button.Create(self.scroll)
    actionBtn:SetText(title)
    local margin = Vector2(5, 5)
    actionBtn:SetMargin(margin, margin)
    if color then
        actionBtn:SetTextHoveredColor(color)
        actionBtn:SetTextPressedColor(color)
    end
    actionBtn:SetTextSize(self.textSize)
    actionBtn:SetHeight(30)
    actionBtn:SetDock(GwenPosition.Top)
    if LocalPlayer:GetValue("SystemFonts") then
        actionBtn:SetFont(AssetLocation.SystemFont, "Impact")
    end
    actionBtn:Subscribe("Press", self, event)

    return actionBtn
end

function ActionsMenu:CreateWindow()
    if self.window then return end

    local locStrings = self.locStrings

    self.greenColor = Color(192, 255, 192)

    self.window = Window.Create()
    self.window:SetSize(Vector2(Render:GetTextWidth(locStrings["vehiclerepair"], self.textSize) + 90, 430))
    self.window:SetMinimumSize(Vector2(300, 315))
    self.window:SetPosition(Vector2(Render.Size.x - self.window:GetSize().x - 45, Render.Size.y / 2 - self.window:GetSize().y / 2))
    self.window:SetVisible(false)
    self.window:SetTitle(locStrings["title"])
    self.window:Subscribe("WindowClosed", self, function() self:SetWindowVisible(false, true) end)

    self.scroll = ScrollControl.Create(self.window)
    self.scroll:SetDock(GwenPosition.Fill)
    self.scroll:SetScrollable(false, true)

    self.SendMoneyBtn = self:CreateActionButton(locStrings["sendmoney_txt"], function() Events:Fire("OpenSendMoneyMenu") self:SetWindowVisible(false) end)

    self.label1 = Label.Create(self.scroll)
    self.label1:SetDock(GwenPosition.Top)
    self.label1:SetText(locStrings["ltext1"])
    self.label1:SetMargin(Vector2(5, 5), Vector2(5, 0))
    self.label1:SizeToContents()

    self.HealMeBtn = self:CreateActionButton(locStrings["healme"], self.Heal, self.greenColor)
    self.KillMeBtn = self:CreateActionButton(locStrings["killme"], function() Network:Send("KillMe") self:SetWindowVisible(false) end)
    self.ClearInvBtn = self:CreateActionButton(locStrings["clearinv"], function() Network:Send("ClearInv") self:SetWindowVisible(false) end)
    self.BloozingBtn = self:CreateActionButton(locStrings["bloozing"], function() Events:Fire("BloozingStart") self:SetWindowVisible(false) end)
    self.SeatBtn = self:CreateActionButton(locStrings["seat"], self.Seat)
    self.LezatBtn = self:CreateActionButton(locStrings["lezat"], self.Sleep)

    self.label2 = Label.Create(self.scroll)
    self.label2:SetDock(GwenPosition.Top)
    self.label2:SetText(locStrings["ltext2"])
    self.label2:SetMargin(Vector2(5, 5), Vector2(5, 0))
    self.label2:SizeToContents()

    self.VehicleRepairBtn = self:CreateActionButton(locStrings["vehiclerepair"], self.VehicleRepair, self.greenColor)
    local vehicle = LocalPlayer:GetVehicle()
    self.VehicleDriverSeatLockBtn = self:CreateActionButton((vehicle and vehicle:GetSeatLocked(VehicleSeat.Driver)) and locStrings["vehicledriverseatunlock"] or locStrings["vehicledriverseatlock"], self.VehicleToggleDriverSeatLock)
    self.VehicleBoomBtn = self:CreateActionButton(locStrings["vehicleboom"], self.VehicleBoom)

    self.label3 = Label.Create(self.scroll)
    self.label3:SetDock(GwenPosition.Top)
    self.label3:SetText("VIP:")
    self.label3:SetMargin(Vector2(5, 5), Vector2(5, 0))
    self.label3:SizeToContents()

    self.SkyBtn = self:CreateActionButton(locStrings["sky"], self.Sky)
    self.DownBtn = self:CreateActionButton(locStrings["down"], self.Down)
end

function ActionsMenu:Heal()
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    if LocalPlayer:GetValue("PVPMode") then
        Events:Fire("CastCenterText", {text = self.locStrings["pvpblock"], time = 6, color = Color.Red})
    else
        if LocalPlayer:GetHealth() >= 1 then
            Events:Fire("CastCenterText", {text = self.locStrings["healnotneeded"], time = 1})
        else
            Network:Send("HealMe")
            local sound = ClientSound.Create(AssetLocation.Game, {
                bank_id = 19,
                sound_id = 30,
                position = LocalPlayer:GetPosition(),
                angle = Angle()
            })

            sound:SetParameter(0, 1)
            Events:Fire("CastCenterText", {text = self.locStrings["heal"], time = 1, color = self.greenColor})
        end
    end

    self:SetWindowVisible(false)
end

function ActionsMenu:Seat()
    if LocalPlayer:GetVehicle() then self:SetWindowVisible(false) return end

    local bs = LocalPlayer:GetBaseState()

    if bs == 6 then
        if not self.SeatInputEvent then self.SeatInputEvent = Events:Subscribe("LocalPlayerInput", self, self.SeatInput) end
        if not self.CalcViewEvent then self.CalcViewEvent = Events:Subscribe("CalcView", self, self.CalcView) end
        if not self.LocalPlayerEnterVehicleEvent then self.LocalPlayerEnterVehicleEvent = Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle) end

        LocalPlayer:SetBaseState(AnimationState.SIdlePassengerVehicle)

        self:SetWindowVisible(false)
    elseif bs == AnimationState.SIdlePassengerVehicle then
        LocalPlayer:SetBaseState(AnimationState.SUprightIdle)

        if self.SeatInputEvent then Events:Unsubscribe(self.SeatInputEvent) self.SeatInputEvent = nil end
        if self.CalcViewEvent then Events:Unsubscribe(self.CalcViewEvent) self.CalcViewEvent = nil end
        if self.LocalPlayerEnterVehicleEvent then Events:Unsubscribe(self.LocalPlayerEnterVehicleEvent) self.LocalPlayerEnterVehicleEvent = nil end

        self:SetWindowVisible(false)
    end
end

function ActionsMenu:SeatInput(args)
    if args.input == 39 or args.input == 40 or args.input == 41 or args.input == 42 then
        LocalPlayer:SetBaseState(AnimationState.SUprightIdle)

        if self.SeatInputEvent then Events:Unsubscribe(self.SeatInputEvent) self.SeatInputEvent = nil end
        if self.CalcViewEvent then Events:Unsubscribe(self.CalcViewEvent) self.CalcViewEvent = nil end
        if self.LocalPlayerEnterVehicleEvent then Events:Unsubscribe(self.LocalPlayerEnterVehicleEvent) self.LocalPlayerEnterVehicleEvent = nil end
    end
end

function ActionsMenu:Sleep()
    local bs = LocalPlayer:GetBaseState()

    if bs == AnimationState.SUprightIdle then
        LocalPlayer:SetBaseState(AnimationState.SSwimDie)
    else
        if bs == AnimationState.SDead then
            LocalPlayer:SetBaseState(AnimationState.SUprightIdle)
        end
    end

    self:SetWindowVisible(false)
end

function ActionsMenu:VehicleRepair()
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    local vehicle = LocalPlayer:GetVehicle()

    if vehicle and vehicle:GetDriver() == LocalPlayer then
        if LocalPlayer:GetValue("PVPMode") then
            Events:Fire("CastCenterText", {text = self.locStrings["pvpblock"], time = 6, color = Color.Red})
        else
            if vehicle:GetHealth() >= 1 then
                Events:Fire("CastCenterText", {text = self.locStrings["healnotneeded"], time = 1})
            else
                Network:Send("VehicleRepair")

                local sound = ClientSound.Create(AssetLocation.Game, {
                    bank_id = 19,
                    sound_id = 30,
                    position = LocalPlayer:GetPosition(),
                    angle = Angle()
                })

                sound:SetParameter(0, 1)
                Events:Fire("CastCenterText", {text = self.locStrings["heal"], time = 1, color = self.greenColor})
            end
        end
    else
        Events:Fire("CastCenterText", {text = self.locStrings["novehicle"], time = 3, color = Color.Red})
    end

    self:SetWindowVisible(false)
end

function ActionsMenu:VehicleToggleDriverSeatLock()
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    local vehicle = LocalPlayer:GetVehicle()

    if vehicle and vehicle:GetDriver() == LocalPlayer then
        local seat = VehicleSeat.Driver

        if vehicle:GetSeatLocked(seat) then
            Events:Fire("CastCenterText", {text = self.locStrings["seatunlocked"], time = 1.5})

            self:LocalPlayerExitVehicle({vehicle = vehicle})
        else
            Events:Fire("CastCenterText", {text = self.locStrings["seatlocked"], time = 1.5})

            if self.VehicleDriverSeatLockBtn then
                self.VehicleDriverSeatLockBtn:SetText(self.locStrings["vehicledriverseatunlock"])
            end

            Events:Fire("SetVehicleSeatLocked", {vehicle = vehicle, seat = seat, locked = true})

            if not self.LocalPlayerExitVehicleEvent then self.LocalPlayerExitVehicleEvent = Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle) end
        end
    else
        Events:Fire("CastCenterText", {
            text = self.locStrings["novehicle"],
            time = 3,
            color = Color.Red
        })
    end

    self:SetWindowVisible(false)
end

function ActionsMenu:VehicleBoom()
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    local vehicle = LocalPlayer:GetVehicle()

    if vehicle and vehicle:GetDriver() == LocalPlayer then
        Network:Send("VehicleBoom")
    else
        Events:Fire("CastCenterText", {text = self.locStrings["novehicle"], time = 3, color = Color.Red})
    end

    self:SetWindowVisible(false)
end

function ActionsMenu:Sky()
    local gettag = LocalPlayer:GetValue("Tag")

    if self.permissions[gettag] then
        Network:Send("Sky")
    else
        Events:Fire("CastCenterText", {text = self.locStrings["novip"], time = 3, color = Color.Red})
    end

    self:SetWindowVisible(false)
end

function ActionsMenu:Down()
    local gettag = LocalPlayer:GetValue("Tag")

    if self.permissions[gettag] then
        Network:Send("Down")
    else
        Events:Fire("CastCenterText", {text = self.locStrings["novip"], time = 3, color = Color.Red})
    end

    self:SetWindowVisible(false)
end

function ActionsMenu:LocalPlayerInput(args)
    if self.actions[args.input] then
        return false
    end

    if args.input == Action.GuiPause then
        self:SetWindowVisible(false)
    end
end

function ActionsMenu:Render()
    local is_visible = Game:GetState() == GUIState.Game
    local window = self.window
    local windowGetVisible = window:GetVisible()

    if windowGetVisible ~= is_visible then
        self.window:SetVisible(is_visible)
        Mouse:SetVisible(is_visible)
    end
end

function ActionsMenu:SeatInput(args)
    if args.input == 39 or args.input == 40 or args.input == 41 or args.input == 42 then
        LocalPlayer:SetBaseState(AnimationState.SUprightIdle)

        if self.SeatInputEvent then Events:Unsubscribe(self.SeatInputEvent) self.SeatInputEvent = nil end
        if self.CalcViewEvent then Events:Unsubscribe(self.CalcViewEvent) self.CalcViewEvent = nil end
    end
end

function ActionsMenu:CalcView()
    Camera:SetPosition(Camera:GetPosition() - Vector3(0, 1, 0))
end

function ActionsMenu:LocalPlayerEnterVehicle()
    if self.SeatInputEvent then Events:Unsubscribe(self.SeatInputEvent) self.SeatInputEvent = nil end
    if self.CalcViewEvent then Events:Unsubscribe(self.CalcViewEvent) self.CalcViewEvent = nil end
    if self.LocalPlayerEnterVehicleEvent then Events:Unsubscribe(self.LocalPlayerEnterVehicleEvent) self.LocalPlayerEnterVehicleEvent = nil end
end

function ActionsMenu:LocalPlayerExitVehicle(args)
    Events:Fire("SetVehicleSeatLocked", {vehicle = args.vehicle, seat = VehicleSeat.Driver, locked = false})

    if self.VehicleDriverSeatLockBtn then
        self.VehicleDriverSeatLockBtn:SetText(self.locStrings["vehicledriverseatlock"])
    end

    if self.LocalPlayerExitVehicleEvent then Events:Unsubscribe(self.LocalPlayerExitVehicleEvent) self.LocalPlayerExitVehicleEvent = nil end
end

local actionsmenu = ActionsMenu()