class 'Tuner'

function Tuner:__init()
    self.planeVehicles = {24, 30, 34, 39, 51, 59, 81, 85}

    self.blacklist = {Action.VehicleFireLeft, Action.VehicleFireRight, Action.McFire, Action.LookRight, Action.LookLeft, Action.LookUp, Action.LookDown}

    local vehicle = LocalPlayer:GetVehicle()
    if vehicle then
        self.vehicleFly = self:CheckList(self.planeVehicles, vehicle:GetModelId()) and true
    end

    self.maxThrust = 5
    self.minThrust = 0.1
    self.currentThrust = 0
    self.carFlyLandThrust = 2
    self.thrustIncreaseFactor = 1.05

    self:InitGUI()

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            gear = "Передача: ",
            kmh = "км/ч",
            ms = "м/с",
            mph = "миль/ч",
            kg_txt = "кг",
            in_txt = "за",
            seconds = "секунд"
        }

        self.gui.window:SetTitle("▧ Тюнинг")
    end

    self.syncTimer = Timer()

    self.neons = {}

    for v in Client:GetVehicles() do
        if v:GetValue("Neon") then
            self:CreateNeon(v)
        end
    end

    if vehicle and vehicle:GetDriver() == LocalPlayer then
        self:InitVehicle(vehicle)

        self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
        self.RenderEvent = Events:Subscribe("Render", self, self.Render)
        self.KeyUpEvent = Events:Subscribe("KeyUp", self, self.KeyUp)
    end

    Network:Subscribe("ToggleNeonLight", self, self.ToggleNeonLight)

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("LocalPlayerEnterVehicle", self, self.EnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.ExitVehicle)
    Events:Subscribe("EntitySpawn", self, self.EntitySpawn)
    Events:Subscribe("EntityDespawn", self, self.EntityDespawn)
    Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
    Events:Subscribe("PostTick", self, self.PostTick)
end

function Tuner:Lang()
    self.locStrings = {
        gear = "Gear: ",
        kmh = "km/h",
        ms = "m/s",
        mph = "mph",
        kg_txt = "kg",
        in_txt = "in",
        seconds = "seconds"
    }

    self.gui.window:SetTitle("▧ Tuning")

    if self.gui.veh.labels then
        self.gui.veh.labels[1]:SetText("Name")
        self.gui.veh.labels[2]:SetText("Driver")
        self.gui.veh.labels[3]:SetText("Vehicle ID")
        self.gui.veh.labels[4]:SetText("Class")
        self.gui.veh.labels[5]:SetText("Type")
        self.gui.veh.labels[6]:SetText("Decal")
        self.gui.veh.labels[7]:SetText("Health")
        self.gui.veh.labels[8]:SetText("Mass")
        self.gui.veh.labels[9]:SetText("Wheels")
        self.gui.veh.labels[10]:SetText("Max RPM")
        self.gui.veh.labels[11]:SetText("Current RPM")
        self.gui.veh.labels[12]:SetText("Torque")
        self.gui.veh.labels[13]:SetText("Peak torque")
        self.gui.veh.labels[14]:SetText("Wheel torque")
        self.gui.veh.labels[15]:SetText("Top speed")
        self.gui.veh.labels[16]:SetText("Current speed")
        self.gui.veh.labels[17]:SetText("Peak speed")
        self.gui.veh.labels[18]:SetText("0-100 km/h")

        for i, label in ipairs(self.gui.veh.labels) do
            label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
            label:SizeToContents()
        end
    end

    if self.setColorBtn then
        self.setColorBtn:SetText("Apply")
    end

    if self.gui.trans.labels then
        self.gui.trans.labels[1]:SetText("Upshift RPM")
        self.gui.trans.labels[2]:SetText("Downshift RPM")
        self.gui.trans.labels[3]:SetText("Max gear")
        self.gui.trans.labels[4]:SetText("Is manual (Num 1/2)")
        self.gui.trans.labels[5]:SetText("Clutch delay")
        self.gui.trans.labels[6]:SetText("Current gear")
        self.gui.trans.labels[7]:SetText("1st gear ratio")
        self.gui.trans.labels[8]:SetText("2st gear ratio")
        self.gui.trans.labels[9]:SetText("3st gear ratio")
        self.gui.trans.labels[10]:SetText("4th gear ratio")
        self.gui.trans.labels[11]:SetText("5th gear ratio")
        self.gui.trans.labels[12]:SetText("6th gear ratio")
        self.gui.trans.labels[13]:SetText("Reverse ratio")
        self.gui.trans.labels[14]:SetText("Primary ratio")
        self.gui.trans.labels[15]:SetText("Wheel 1 torque ratio")
        self.gui.trans.labels[16]:SetText("Wheel 2 torque ratio")
        self.gui.trans.labels[17]:SetText("Wheel 3 torque ratio")
        self.gui.trans.labels[18]:SetText("Wheel 4 torque ratio")
        self.gui.trans.labels[19]:SetText("Wheel 5 torque ratio")
        self.gui.trans.labels[20]:SetText("Wheel 6 torque ratio")
        self.gui.trans.labels[21]:SetText("Wheel 7 torque ratio")
        self.gui.trans.labels[22]:SetText("Wheel 8 torque ratio")

        for i, label in ipairs(self.gui.trans.labels) do
            label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
            label:SizeToContents()
        end

        self.gui.aero.labels[1]:SetText("Air density")
        self.gui.aero.labels[2]:SetText("Frontal area")
        self.gui.aero.labels[3]:SetText("Drag coeff")
        self.gui.aero.labels[4]:SetText("Lift coeff")
        self.gui.aero.labels[5]:SetText("Extra gravity X")
        self.gui.aero.labels[6]:SetText("Extra gravity Y")
        self.gui.aero.labels[7]:SetText("Extra gravity Z")

        for i, label in ipairs(self.gui.aero.labels) do
            label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
            label:SizeToContents()
        end

    end

    if self.gui.susp.labels then
        self.gui.susp.labels[1]:SetText("Length")
        self.gui.susp.labels[2]:SetText("Strength")
        self.gui.susp.labels[3]:SetText("Chassis direction X")
        self.gui.susp.labels[4]:SetText("Chassis direction Y")
        self.gui.susp.labels[5]:SetText("Chassis direction Z")
        self.gui.susp.labels[6]:SetText("Chassis position X")
        self.gui.susp.labels[7]:SetText("Chassis position Y")
        self.gui.susp.labels[8]:SetText("Chassis position Z")
        self.gui.susp.labels[9]:SetText("Damping compression")
        self.gui.susp.labels[10]:SetText("Damping relaxation")

        self.gui.susp.labels[11]:SetText("Length")
        self.gui.susp.labels[12]:SetText("Strength")
        self.gui.susp.labels[13]:SetText("Chassis direction X")
        self.gui.susp.labels[14]:SetText("Chassis direction Y")
        self.gui.susp.labels[15]:SetText("Chassis direction Z")
        self.gui.susp.labels[16]:SetText("Chassis position X")
        self.gui.susp.labels[17]:SetText("Chassis position Y")
        self.gui.susp.labels[18]:SetText("Chassis position Z")
        self.gui.susp.labels[19]:SetText("Damping compression")
        self.gui.susp.labels[20]:SetText("Damping relaxation")

        for i, label in ipairs(self.gui.susp.labels) do
            label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
            label:SizeToContents()
        end
    end

    if self.gui.aero.flyT then
        self.gui.aero.flyT:SetText("Vertical takeoff (Z button)")
    end

    if self.neontoggle then
        self.neontoggle:SetText("Toggle Neon")
    end
end

function Tuner:CheckList(tableList, modelID)
    for k, v in ipairs(tableList) do
        if v == modelID then
            return true
        end
    end
    return false
end

function Tuner:CreateNeon(vehicle)
    if not vehicle then return end

    local vId = vehicle:GetId()

    if not self.neons[vId] then
        local neonPos = vehicle:GetPosition() + Vector3.Up

        self.neons[vId] = ClientLight.Create {
            position = neonPos,
            color = vehicle:GetValue("NeonColor") or Color.White,
            constant_attenuation = 0,
            linear_attenuation = 0,
            quadratic_attenuation = 0,
            multiplier = 10.0,
            radius = 4
        }
    end
end

function Tuner:RemoveNeon(vehicle)
    if not vehicle then return end

    local vId = vehicle:GetId()

    if IsValid(self.neons[vId]) then
        self.neons[vId]:Remove()
        self.neons[vId] = nil
    end
end

function Tuner:ToggleNeonLight(args)
    if args.value then
        self:RemoveNeon(args.vehicle)
    else
        self:CreateNeon(args.vehicle)
    end
end

function Tuner:Render()
    local is_visible = self.activeWindow and (Game:GetState() == GUIState.Game)

    if self.gui.window:GetVisible() ~= is_visible then
        self.gui.window:SetVisible(is_visible)
        Mouse:SetVisible(is_visible)
    end
end

function Tuner:PostTick()
    for v in Client:GetVehicles() do
        local vId = v:GetId()
        local neon = self.neons[vId]

        if neon then
            local neonPos = v:GetPosition() + Vector3.Up
            neon:SetPosition(neonPos)
        end
    end

    if self.syncTimer:GetSeconds() <= 1 then
        return
    end

    for v in Client:GetVehicles() do
        if v:GetValue("vehid") then
            local vehicleTransmission = v:GetTransmission()

            if vehicleTransmission then
                vehicleTransmission:SetClutchDelayTime(v:GetValue("clutch_delay"))

                local gear_ratios = vehicleTransmission:GetGearRatios()
                if v:GetValue("gear_ratios1") then gear_ratios[1] = v:GetValue("gear_ratios1") end
                if v:GetValue("gear_ratios2") then gear_ratios[2] = v:GetValue("gear_ratios2") end
                if v:GetValue("gear_ratios3") then gear_ratios[3] = v:GetValue("gear_ratios3") end
                if v:GetValue("gear_ratios4") then gear_ratios[4] = v:GetValue("gear_ratios4") end
                if v:GetValue("gear_ratios5") then gear_ratios[5] = v:GetValue("gear_ratios5") end
                if v:GetValue("gear_ratios6") then gear_ratios[6] = v:GetValue("gear_ratios6") end
                if v:GetValue("gear_ratios7") then gear_ratios[7] = v:GetValue("gear_ratios7") end
                vehicleTransmission:SetGearRatios(gear_ratios)

                local wheel_ratios = vehicleTransmission:GetWheelTorqueRatios()
                for wheel, ratio in ipairs(wheel_ratios) do
                    wheel_ratios[wheel] = v:GetValue("wheel_ratios" .. wheel)
                end
                vehicleTransmission:SetWheelTorqueRatios(wheel_ratios)

                vehicleTransmission:SetReverseGearRatio(v:GetValue("reverse_ratio"))
                vehicleTransmission:SetPrimaryTransmissionRatio(v:GetValue("primary_transmission_ratio"))
            end

            local vehicleAerodynamics = v:GetAerodynamics()

            if vehicleAerodynamics then
                vehicleAerodynamics:SetAirDensity(v:GetValue("airdensity"))
                vehicleAerodynamics:SetFrontalArea(v:GetValue("frontalarea"))
                vehicleAerodynamics:SetDragCoefficient(v:GetValue("dragcoeff"))
                vehicleAerodynamics:SetLiftCoefficient(v:GetValue("liftcoeff"))
                -- vehicleAerodynamics:SetExtraGravity(v:GetValue( "gravity" ))
            end

            local vehicleSuspension = v:GetSuspension()

            if vehicleSuspension then
                for wheel = 1, v:GetWheelCount() do
                    vehicleSuspension:SetLength(wheel, v:GetValue("wheel" .. wheel .. "_length"))
                    vehicleSuspension:SetStrength(wheel, v:GetValue("wheel" .. wheel .. "_strength"))
                    vehicleSuspension:SetChassisDirection(wheel, v:GetValue("wheel" .. wheel .. "_direction"))
                    vehicleSuspension:SetChassisPosition(wheel, v:GetValue("wheel" .. wheel .. "_position"))
                    vehicleSuspension:SetDampingCompression(wheel, v:GetValue("wheel" .. wheel .. "_dampcompression"))
                    vehicleSuspension:SetDampingRelaxation(wheel, v:GetValue("wheel" .. wheel .. "_damprelaxation"))
                end
            end
        end
    end

    self.syncTimer:Restart()
end

function Tuner:InitGUI()
    self.peredacha = 1

    self.gui = {
        veh = {},
        color = {},
        trans = {},
        aero = {},
        neon = {},
        susp = {}
    }

    self.activeWindow = false

    self.gui.window = Window.Create()
    self.gui.window:SetVisible(self.activeWindow)
    self.gui.window:SetPosition(Vector2(0.15 * Render.Width, 0.02 * Render.Height))
    self.gui.window:SetSize(Vector2(500, 520))
    self.gui.window:Subscribe("WindowClosed", self, function() self:SetWindowVisible(false, true) end)

    self.gui.tabs = TabControl.Create(self.gui.window)
    self.gui.tabs:SetDock(GwenPosition.Fill)

    self.gui.veh.window = BaseWindow.Create(self.gui.window)
    self.gui.color.window = BaseWindow.Create(self.gui.window)
    self.gui.trans.window = BaseWindow.Create(self.gui.window)
    self.gui.aero.window = BaseWindow.Create(self.gui.window)
    self.gui.neon.window = BaseWindow.Create(self.gui.window)
    self.gui.susp.window = BaseWindow.Create(self.gui.window)

    local vehicle = LocalPlayer:GetVehicle()
    if not vehicle then return end

    local vehicleClass = vehicle:GetClass()

    if vehicle:GetDriver() == LocalPlayer and vehicleClass == VehicleClass.Land then
        self.gui.veh.window:Subscribe("Render", self, self.VehicleUpdate)
    else
        self.gui.veh.window:Subscribe("Render", self, self.OtherVehicleUpdate)
    end

    if vehicleClass == VehicleClass.Land then
        self.gui.trans.window:Subscribe("Render", self, self.TransmissionUpdate)
        self.gui.susp.window:Subscribe("Render", self, self.SuspensionUpdate)
        self.gui.aero.window:Subscribe("Render", self, self.AerodynamicsUpdate)
    end

    self.gui.veh.button = self.gui.tabs:AddPage("Информация", self.gui.veh.window)
    self.gui.veh.button:Subscribe("Press", function() self.gui.window:SetSize(Vector2(360, 465)) end)

    self.gui.color.button = self.gui.tabs:AddPage("Цвет", self.gui.color.window)
    self.gui.color.button:Subscribe("Press", function() self.gui.window:SetSize(Vector2(460, 350)) end)

    local tab_control = TabControl.Create(self.gui.color.window)
    tab_control:SetDock(GwenPosition.Fill)
    tab_control:SetMargin(Vector2(1, 0), Vector2(1, 5))

    local vColor1, vColor2 = vehicle:GetColors()
    local tone1Picker = HSVColorPicker.Create()
    tab_control:AddPage("▧ Тон 1", tone1Picker)
    tone1Picker:SetDock(GwenPosition.Fill)
    tone1Picker:SetColor(vColor1)

    local tone2Picker = HSVColorPicker.Create()
    tab_control:AddPage("▨ Тон 2", tone2Picker)
    tone2Picker:SetDock(GwenPosition.Fill)
    tone2Picker:SetColor(vColor2)

    local lpColor = LocalPlayer:GetColor()
    tone1Picker:SetColor(lpColor)
    tone2Picker:SetColor(lpColor)

    self.setColorBtn = Button.Create(self.gui.color.window)
    self.setColorBtn:SetText("Применить")
    self.setColorBtn:SetHeight(30)
    self.setColorBtn:SetDock(GwenPosition.Bottom)
    self.setColorBtn:Subscribe("Press", function() Network:Send("ColorChanged", {tone1 = tone1Picker:GetColor(), tone2 = tone2Picker:GetColor()}) end)

    if vehicleClass == VehicleClass.Land then
        self.gui.trans.button = self.gui.tabs:AddPage("Трансмиссия", self.gui.trans.window)
        self.gui.trans.button:Subscribe("Press", function()
            local gears = self.trans:GetMaxGear()

            for i = 7, 7 + gears - 1 do
                self.gui.trans.getters[i]:Show()
                self.gui.trans.setters[i]:Show()
            end

            for i = 7 + gears, 12 do
                self.gui.trans.getters[i]:Hide()
                self.gui.trans.setters[i]:Hide()
            end

            local count = self.veh:GetWheelCount()
            for i = 15, 15 + count - 1 do
                self.gui.trans.getters[i]:Show()
                self.gui.trans.setters[i]:Show()
            end

            for i = 15 + count, 22 do
                self.gui.trans.getters[i]:Hide()
                self.gui.trans.setters[i]:Hide()
            end

            self.gui.window:SetSize(Vector2(360, 555 - 22 * (8 - count)))
        end)

        self.gui.susp.button = self.gui.tabs:AddPage("Подвеска", self.gui.susp.window)
        self.gui.susp.button:Subscribe("Press", function()
            local count = self.veh:GetWheelCount()

            for wheel = 1, count + 1 do
                for _, getter in ipairs(self.gui.susp[wheel].getters) do
                    getter:Show()
                end

                for _, setter in ipairs(self.gui.susp[wheel].setters) do
                    setter:Show()
                end
            end

            count = count + 1

            for wheel = count + 1, 8 do
                for _, getter in ipairs(self.gui.susp[wheel].getters) do
                    getter:Hide()
                end

                for _, setter in ipairs(self.gui.susp[wheel].setters) do
                    setter:Hide()
                end
            end
            self.gui.window:SetSize(Vector2(150 + 80 * count, 510))
        end)
    end

    self.gui.aero.button = self.gui.tabs:AddPage("Аэродинамика", self.gui.aero.window)
    self.gui.aero.button:Subscribe("Press", function() self.gui.window:SetSize(Vector2(360, 244)) end)

    self.gui.neon.button = self.gui.tabs:AddPage("Неон", self.gui.neon.window)
    local neoncolor = HSVColorPicker.Create(self.gui.neon.window)
    neoncolor:SetColor(vehicle:GetValue("NeonColor") or vehicle:GetColors())
    neoncolor:SetDock(GwenPosition.Fill)
    neoncolor:SetMargin(Vector2(1, 0), Vector2(1, 5))

    local neontoggle = Button.Create(self.gui.neon.window)
    neontoggle:SetText("Включить/отключить неон")
    neontoggle:SetTextSize(15)
    neontoggle:SetHeight(30)
    neontoggle:SetDock(GwenPosition.Bottom)
    neontoggle:Subscribe("Up", function() Network:Send("UpdateNeonColor", {neoncolor = neoncolor:GetColor()}) Network:Send("ToggleSyncNeon") end)
    self.gui.neon.button:Subscribe("Press", function() self.gui.window:SetSize(Vector2(460, 350)) end)

    self:InitVehicleGUI()

    if vehicleClass == VehicleClass.Land then
        self:InitTransmissionGUI()
        self:InitSuspensionGUI()
    end

    self:InitAerodynamicsGUI()
end

function Tuner:InitVehicleGUI()
    self.gui.veh.labels = {}
    self.gui.veh.getters = {}
    self.gui.veh.setters = {}

    for i = 1, 18 do
        table.insert(self.gui.veh.labels, Label.Create(self.gui.veh.window))
        table.insert(self.gui.veh.getters, Label.Create(self.gui.veh.window))
    end

    self.gui.veh.labels[1]:SetText("Название")
    self.gui.veh.labels[2]:SetText("Водитель")
    self.gui.veh.labels[3]:SetText("ID транспорта")
    self.gui.veh.labels[4]:SetText("Класс")
    self.gui.veh.labels[5]:SetText("Тип")
    self.gui.veh.labels[6]:SetText("Декаль")
    self.gui.veh.labels[7]:SetText("Состояние")
    self.gui.veh.labels[8]:SetText("Масса")
    self.gui.veh.labels[9]:SetText("Колёса")
    self.gui.veh.labels[10]:SetText("Макс. обороты")
    self.gui.veh.labels[11]:SetText("Текущие обороты")
    self.gui.veh.labels[12]:SetText("Крутящий момент")
    self.gui.veh.labels[13]:SetText("Рекорд крут. момента")
    self.gui.veh.labels[14]:SetText("Крут. момент колеса")
    self.gui.veh.labels[15]:SetText("Макс. скорость")
    self.gui.veh.labels[16]:SetText("Текущая скорость")
    self.gui.veh.labels[17]:SetText("Рекорд скорости")
    self.gui.veh.labels[18]:SetText("Время разгона 100 км/ч")

    for i, label in ipairs(self.gui.veh.labels) do
        label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
        label:SizeToContents()
    end

    for i, getter in ipairs(self.gui.veh.getters) do
        getter:SetPosition(Vector2(160, 5 + 22 * (i - 1)))
        getter:SetSize(Vector2(210, 12))
    end
end

function Tuner:InitTransmissionGUI()
    self.gui.trans.labels = {}
    self.gui.trans.getters = {}
    self.gui.trans.setters = {}

    for i = 1, 22 do
        table.insert(self.gui.trans.labels, Label.Create(self.gui.trans.window))
        table.insert(self.gui.trans.getters, Label.Create(self.gui.trans.window))
    end

    self.gui.trans.labels[1]:SetText("Передачи RPM")
    self.gui.trans.labels[2]:SetText("Пониж. передачи RPM")
    self.gui.trans.labels[3]:SetText("Макс. передач")
    self.gui.trans.labels[4]:SetText("Ручное (Num 1/2)")
    self.gui.trans.labels[5]:SetText("Задержка сцепления")
    self.gui.trans.labels[6]:SetText("Текущая передача")
    self.gui.trans.labels[7]:SetText("1-я передача")
    self.gui.trans.labels[8]:SetText("2-я передача")
    self.gui.trans.labels[9]:SetText("3-я передача")
    self.gui.trans.labels[10]:SetText("4-я передача")
    self.gui.trans.labels[11]:SetText("5-я передача")
    self.gui.trans.labels[12]:SetText("6-я передача")
    self.gui.trans.labels[13]:SetText("Обратное соотношение")
    self.gui.trans.labels[14]:SetText("Первичное соотношение")
    self.gui.trans.labels[15]:SetText("Крут. момент 1-го колеса")
    self.gui.trans.labels[16]:SetText("Крут. момент 2-го колеса")
    self.gui.trans.labels[17]:SetText("Крут. момент 3-го колеса")
    self.gui.trans.labels[18]:SetText("Крут. момент 4-го колеса")
    self.gui.trans.labels[19]:SetText("Крут. момент 5-го колеса")
    self.gui.trans.labels[20]:SetText("Крут. момент 6-го колеса")
    self.gui.trans.labels[21]:SetText("Крут. момент 7-го колеса")
    self.gui.trans.labels[22]:SetText("Крут. момент 8-го колеса")

    self.gui.trans.setters[4] = CheckBox.Create(self.gui.trans.window)
    self.gui.trans.setters[4]:Subscribe("CheckChanged", function(args) self.trans:SetManual(args:GetChecked()) end)

    self.gui.trans.setters[5] = TextBoxNumeric.Create(self.gui.trans.window)
    self.gui.trans.setters[5]:Subscribe("ReturnPressed", function(args)
        self.trans:SetClutchDelayTime(args:GetValue())
        args:SetText("")
        self:SyncTune()
    end)

    self.gui.trans.setters[6] = TextBoxNumeric.Create(self.gui.trans.window)
    self.gui.trans.setters[6]:Subscribe("ReturnPressed", function(args)
        self.trans:SetGear(args:GetValue())
        args:SetText("")
        self:SyncTune()
    end)

    for i = 7, 12 do
        self.gui.trans.setters[i] = TextBoxNumeric.Create(self.gui.trans.window)
        self.gui.trans.setters[i]:Subscribe("ReturnPressed", function(args)
            local maxValue = 100000000

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            local gear_ratios = self.trans:GetGearRatios()
            gear_ratios[i - 6] = args:GetValue()
            self.trans:SetGearRatios(gear_ratios)
            args:SetText("")
            self:SyncTune()
        end)
    end

    self.gui.trans.setters[13] = TextBoxNumeric.Create(self.gui.trans.window)
    self.gui.trans.setters[13]:Subscribe("ReturnPressed", function(args)
        self.trans:SetReverseGearRatio(args:GetValue())
        args:SetText("")
        self:SyncTune()
    end)

    self.gui.trans.setters[14] = TextBoxNumeric.Create(self.gui.trans.window)
    self.gui.trans.setters[14]:Subscribe("ReturnPressed", function(args)
        local maxValue = 100000000

        if args:GetValue() >= maxValue then
            args:SetText(tostring(maxValue))
        elseif args:GetValue() <= -maxValue then
            args:SetText(tostring(-maxValue))
        end

        self.trans:SetPrimaryTransmissionRatio(args:GetValue())
        args:SetText("")
        self:SyncTune()
    end)

    for i = 15, 22 do
        self.gui.trans.setters[i] = TextBoxNumeric.Create(self.gui.trans.window)
        self.gui.trans.setters[i]:Subscribe("ReturnPressed", function(args)
            local maxValue = 10000000

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            local wheel_ratios = self.trans:GetWheelTorqueRatios()
            wheel_ratios[i - 14] = args:GetValue()
            self.trans:SetWheelTorqueRatios(wheel_ratios)
            args:SetText("")
            self:SyncTune()
        end)
    end

    for i, label in ipairs(self.gui.trans.labels) do
        label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
        label:SizeToContents()
    end

    for i, getter in ipairs(self.gui.trans.getters) do
        getter:SetPosition(Vector2(170, 5 + 22 * (i - 1)))
    end

    for i, setter in pairs(self.gui.trans.setters) do
        if setter.__type == "TextBoxNumeric" then
            setter:SetPosition(Vector2(225, 0 + 22 * (i - 1)))
            setter:SetWidth(57)
            setter:SetText("")
        else
            setter:SetPosition(Vector2(228, 2 + 22 * (i - 1)))
        end
    end
end

function Tuner:InitAerodynamicsGUI()
    local vehicle = LocalPlayer:GetVehicle()

    if not vehicle then return end

    local vehicleClass = vehicle:GetClass()

    self.vehicleFly = self:CheckList(self.planeVehicles, vehicle:GetModelId()) and true or false

    if vehicleClass == VehicleClass.Land then
        self.gui.aero.labels = {}
        self.gui.aero.getters = {}
        self.gui.aero.setters = {}

        for i = 1, 7 do
            table.insert(self.gui.aero.labels, Label.Create(self.gui.aero.window))
            table.insert(self.gui.aero.getters, Label.Create(self.gui.aero.window))
            table.insert(self.gui.aero.setters, TextBoxNumeric.Create(self.gui.aero.window))
        end

        self.gui.aero.labels[1]:SetText("Плотность воздуха")
        self.gui.aero.labels[2]:SetText("Фронтальная зона")
        self.gui.aero.labels[3]:SetText("Коэффициент трения")
        self.gui.aero.labels[4]:SetText("Коэффициент подъема")
        self.gui.aero.labels[5]:SetText("Доп. гравитация X")
        self.gui.aero.labels[6]:SetText("Доп. гравитация Y")
        self.gui.aero.labels[7]:SetText("Доп. гравитация Z")

        self.gui.aero.setters[1]:Subscribe("ReturnPressed", function(args)
            local maxValue = 100000000000

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            self.aero:SetAirDensity(args:GetValue())
            args:SetText("")
            self:SyncTune()
        end)

        self.gui.aero.setters[2]:Subscribe("ReturnPressed", function(args)
            local maxValue = 1000000000000

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            self.aero:SetFrontalArea(args:GetValue())
            args:SetText("")
            self:SyncTune()
        end)

        self.gui.aero.setters[3]:Subscribe("ReturnPressed", function(args)
            local maxValue = 100000000000

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            self.aero:SetDragCoefficient(args:GetValue())
            args:SetText("")
            self:SyncTune()
        end)

        self.gui.aero.setters[4]:Subscribe("ReturnPressed", function(args)
            local maxValue = 100000000000

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            self.aero:SetLiftCoefficient(args:GetValue())
            args:SetText("")
            self:SyncTune()
        end)

        self.gui.aero.setters[5]:Subscribe("ReturnPressed", function(args)
            local gravity = self.aero:GetExtraGravity()

            self.aero:SetExtraGravity(Vector3(args:GetValue(), gravity.y, gravity.z))
            args:SetText("")
            self:SyncTune()
        end)

        self.gui.aero.setters[6]:Subscribe("ReturnPressed", function(args)
            local gravity = self.aero:GetExtraGravity()

            self.aero:SetExtraGravity(Vector3(gravity.x, args:GetValue(), gravity.z))
            args:SetText("")
            self:SyncTune()
        end)

        self.gui.aero.setters[7]:Subscribe("ReturnPressed", function(args)
            local maxValue = 1000000000000

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            local gravity = self.aero:GetExtraGravity()
            self.aero:SetExtraGravity(Vector3(gravity.x, gravity.y, args:GetValue()))
            args:SetText("")
            self:SyncTune()
        end)
    end

    self.gui.aero.fly = CheckBox.Create(self.gui.aero.window)
	self.gui.aero.fly:SetPosition(vehicleClass == VehicleClass.Land and Vector2(5, 160) or Vector2(5, 5) )
    self.gui.aero.fly:SetChecked(self.vehicleFly)
    self.gui.aero.fly:Subscribe("CheckChanged", function() self.vehicleFly = not self.vehicleFly end)

    self.gui.aero.flyT = Label.Create(self.gui.aero.window)
    self.gui.aero.flyT:SetText("Вертикальный взлёт ( Кнопка Z )")
    self.gui.aero.flyT:SetPosition(self.gui.aero.fly:GetPosition() + Vector2(20, 3))
    self.gui.aero.flyT:SizeToContents()

    if vehicleClass == VehicleClass.Land then
        for i, label in ipairs(self.gui.aero.labels) do
            label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
            label:SizeToContents()
        end

        for i, getter in ipairs(self.gui.aero.getters) do
            getter:SetPosition(Vector2(150, 5 + 22 * (i - 1)))
        end

        for i, setter in pairs(self.gui.aero.setters) do
            setter:SetPosition(Vector2(225, 0 + 22 * (i - 1)))
            setter:SetWidth(57)
            setter:SetText("")
        end
    end
end

function Tuner:InitSuspensionGUI()
    self.gui.susp.labels = {}

    for i = 1, 20 do
        table.insert(self.gui.susp.labels, Label.Create(self.gui.susp.window))
    end

    for wheel = 1, 9 do
        self.gui.susp[wheel] = {}
        self.gui.susp[wheel] = {}
        self.gui.susp[wheel].getters = {}
        self.gui.susp[wheel].setters = {}

        for i = 1, 10 do
            table.insert(self.gui.susp[wheel].getters, Label.Create(self.gui.susp.window))
            table.insert(self.gui.susp[wheel].setters, TextBoxNumeric.Create(self.gui.susp.window))
        end
    end

    self.gui.susp.labels[1]:SetText("Длина")
    self.gui.susp.labels[2]:SetText("Сила")
    self.gui.susp.labels[3]:SetText("Направление колеса X")
    self.gui.susp.labels[4]:SetText("Направление колеса Y")
    self.gui.susp.labels[5]:SetText("Направление колеса Z")
    self.gui.susp.labels[6]:SetText("Положение колеса X")
    self.gui.susp.labels[7]:SetText("Положение колеса Y")
    self.gui.susp.labels[8]:SetText("Положение колеса Z")
    self.gui.susp.labels[9]:SetText("Демпфирующее сжатие")
    self.gui.susp.labels[10]:SetText("Прижимная сила")

    self.gui.susp.labels[11]:SetText("Длина")
    self.gui.susp.labels[12]:SetText("Сила")
    self.gui.susp.labels[13]:SetText("Направление колеса X")
    self.gui.susp.labels[14]:SetText("Направление колеса Y")
    self.gui.susp.labels[15]:SetText("Направление колеса Z")
    self.gui.susp.labels[16]:SetText("Положение колеса X")
    self.gui.susp.labels[17]:SetText("Положение колеса Y")
    self.gui.susp.labels[18]:SetText("Положение колеса Z")
    self.gui.susp.labels[19]:SetText("Демпфирующее сжатие")
    self.gui.susp.labels[20]:SetText("Прижимная сила")

    for i, label in ipairs(self.gui.susp.labels) do
        label:SetPosition(Vector2(5, 5 + 22 * (i - 1)))
        label:SizeToContents()
    end

    for wheel in ipairs(self.gui.susp) do
        for i, getter in ipairs(self.gui.susp[wheel].getters) do
            getter:SetPosition(Vector2(150 + 75 * (wheel - 1), 5 + 22 * (i - 1)))
            getter:SetWidth(70)
        end
    end

    for wheel, v in ipairs(self.gui.susp) do
        v.setters[1]:Subscribe("ReturnPressed", function(args)
            local maxValue = 1000000000000000000

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            if wheel > self.veh:GetWheelCount() then
                local count = self.veh:GetWheelCount()

                for wh = 1, count do
                    self.susp:SetLength(wh, args:GetValue())
                end
            else
                self.susp:SetLength(wheel, args:GetValue())
            end

            args:SetText("")
            self:SyncTune()
        end)

        v.setters[2]:Subscribe("ReturnPressed", function(args)
            local maxValue = 10000000000000

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            if wheel > self.veh:GetWheelCount() then
                local count = self.veh:GetWheelCount()
                for wh = 1, count do
                    self.susp:SetStrength(wh, args:GetValue())
                end
            else
                self.susp:SetStrength(wheel, args:GetValue())
            end

            args:SetText("")
            self:SyncTune()
        end)

        v.setters[3]:Subscribe("ReturnPressed", function(args)
            local maxValue = 1000000000000000000

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            if wheel > self.veh:GetWheelCount() then
                local count = self.veh:GetWheelCount()

                for wh = 1, count do
                    local direction = self.susp:GetChassisDirection(wh)
                    if math.fmod(wh, 2) ~= 0 then
                        self.susp:SetChassisDirection(wh, Vector3(args:GetValue(), direction.y, direction.z))
                    else
                        self.susp:SetChassisDirection(wh, Vector3(-args:GetValue(), direction.y, direction.z))
                    end
                end
            else
                local direction = self.susp:GetChassisDirection(wheel)
                self.susp:SetChassisDirection(wheel, Vector3(args:GetValue(), direction.y, direction.z))
            end

            args:SetText("")
            self:SyncTune()
        end)

        v.setters[4]:Subscribe("ReturnPressed", function(args)
            local maxValue = 1000000000000000000
            local zeroValue = 0.000000001

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            elseif args:GetValue() >= 0 and args:GetValue() <= zeroValue then
                args:SetText(tostring(zeroValue))
            end

            if wheel > self.veh:GetWheelCount() then
                local count = self.veh:GetWheelCount()
                for wh = 1, count do
                    local direction = self.susp:GetChassisDirection(wh)
                    self.susp:SetChassisDirection(wh, Vector3(direction.x, args:GetValue(), direction.z))
                end
            else
                local direction = self.susp:GetChassisDirection(wheel)
                self.susp:SetChassisDirection(wheel, Vector3(direction.x, args:GetValue(), direction.z))
            end

            args:SetText("")
            self:SyncTune()
        end)

        v.setters[5]:Subscribe("ReturnPressed", function(args)
            local maxValue = 1000000000000000000

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            if wheel > self.veh:GetWheelCount() then
                local count = self.veh:GetWheelCount()
                for wh = 1, count do
                    local direction = self.susp:GetChassisDirection(wh)
                    self.susp:SetChassisDirection(wh, Vector3(direction.x, direction.y, args:GetValue()))
                end
            else
                local direction = self.susp:GetChassisDirection(wheel)
                self.susp:SetChassisDirection(wheel, Vector3(direction.x, direction.y, args:GetValue()))
            end

            args:SetText("")
            self:SyncTune()
        end)

        v.setters[6]:Subscribe("ReturnPressed", function(args)
            local maxValue = 100000000

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            if wheel > self.veh:GetWheelCount() then
                local count = self.veh:GetWheelCount()
                for wh = 1, count do
                    local position = self.susp:GetChassisPosition(wh)
                    if math.fmod(wh, 2) ~= 0 then
                        self.susp:SetChassisPosition(wh, Vector3(args:GetValue(), position.y, position.z))
                    else
                        self.susp:SetChassisPosition(wh, Vector3(-args:GetValue(), position.y, position.z))
                    end
                end
            else
                local position = self.susp:GetChassisPosition(wheel)
                self.susp:SetChassisPosition(wheel, Vector3(args:GetValue(), position.y, position.z))
            end

            args:SetText("")
            self:SyncTune()
        end)

        v.setters[7]:Subscribe("ReturnPressed", function(args)
            local maxValue = 10000

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            if wheel > self.veh:GetWheelCount() then
                local count = self.veh:GetWheelCount()
                for wh = 1, count do
                    local position = self.susp:GetChassisPosition(wh)
                    self.susp:SetChassisPosition(wh, Vector3(position.x, args:GetValue(), position.z))
                end
            else
                local position = self.susp:GetChassisPosition(wheel)
                self.susp:SetChassisPosition(wheel, Vector3(position.x, args:GetValue(), position.z))
            end

            args:SetText("")
            self:SyncTune()
        end)

        v.setters[8]:Subscribe("ReturnPressed", function(args)
            local maxValue = 100

            if args:GetValue() >= maxValue then
                args:SetText(tostring(maxValue))
            elseif args:GetValue() <= -maxValue then
                args:SetText(tostring(-maxValue))
            end

            if wheel > self.veh:GetWheelCount() then
                local count = self.veh:GetWheelCount()
                for wh = 1, count do
                    local position = self.susp:GetChassisPosition(wh)
                    self.susp:SetChassisPosition(wh, Vector3(position.x, position.y, args:GetValue()))
                end
            else
                local position = self.susp:GetChassisPosition(wheel)
                self.susp:SetChassisPosition(wheel, Vector3(position.x, position.y, args:GetValue()))
            end

            args:SetText("")
            self:SyncTune()
        end)

        v.setters[9]:Subscribe("ReturnPressed", function(args)
            if wheel > self.veh:GetWheelCount() then
                local count = self.veh:GetWheelCount()
                for wh = 1, count do
                    self.susp:SetDampingCompression(wh, args:GetValue())
                end
            else
                self.susp:SetDampingCompression(wheel, args:GetValue())
            end

            args:SetText("")
            self:SyncTune()
        end)

        v.setters[10]:Subscribe("ReturnPressed", function(args)
            if wheel > self.veh:GetWheelCount() then
                local count = self.veh:GetWheelCount()
                for wh = 1, count do
                    self.susp:SetDampingRelaxation(wh, args:GetValue())
                end
            else
                self.susp:SetDampingRelaxation(wheel, args:GetValue())
            end

            args:SetText("")
            self:SyncTune()
        end)

        for i, setter in ipairs(self.gui.susp[wheel].setters) do
            setter:SetPosition(Vector2(150 + 75 * (wheel - 1), 220 + 22 * (i - 1)))
            setter:SetWidth(57)
            setter:SetText("")
            self:SyncTune()
        end
    end
end

function Tuner:SyncTune()
    if not IsValid(self.veh) then return end

    if self.veh:GetDriver() == LocalPlayer then
        local args = {}

        if self.model then
            args.model = self.model
        else
            return
        end

        args.steamid = LocalPlayer:GetSteamId().id
        args.modelid = self.veh:GetModelId()
        args.vehid = self.veh:GetId()

        if self.trans then
            -- args.trans = true
            args.clutch_delay = self.trans:GetClutchDelayTime()

            args.gear_ratios = {}
            local gear_ratios = self.trans:GetGearRatios()
            for wheel, ratio in ipairs(gear_ratios) do
                args.gear_ratios[wheel] = ratio
            end

            args.reverse_ratio = self.trans:GetReverseGearRatio()
            args.primary_transmission_ratio = self.trans:GetPrimaryTransmissionRatio()

            args.wheel_ratios = {}
            wheel_ratios = self.trans:GetWheelTorqueRatios()
            for wheel, ratio in ipairs(wheel_ratios) do
                args.wheel_ratios[wheel] = ratio
            end
        end

        if self.aero then
            -- args.aero = true
            args.airdensity = self.aero:GetAirDensity()
            args.frontalarea = self.aero:GetFrontalArea()
            args.dragcoeff = self.aero:GetDragCoefficient()
            args.liftcoeff = self.aero:GetLiftCoefficient()
            args.gravity = self.aero:GetExtraGravity()
        end

        if self.susp then
            -- args.susp = true
            args.wheels = {}
            for wheel = 1, self.veh:GetWheelCount() do
                args.wheels[wheel] = {}
                args.wheels[wheel].length = self.susp:GetLength(wheel)
                args.wheels[wheel].strength = self.susp:GetStrength(wheel)
                args.wheels[wheel].direction = self.susp:GetChassisDirection(wheel)
                args.wheels[wheel].position = self.susp:GetChassisPosition(wheel)
                args.wheels[wheel].dampcompression = self.susp:GetDampingCompression(wheel)
                args.wheels[wheel].damprelaxation = self.susp:GetDampingRelaxation(wheel)
            end
        end
        Network:Send("SyncTune", args)
    end
end

function Tuner:InitVehicle(vehicle)
    self.veh = vehicle
    self.model = vehicle:GetModelId()
    self.trans = vehicle:GetTransmission()
    self.aero = vehicle:GetAerodynamics()
    self.susp = vehicle:GetSuspension()
    self.mass = vehicle:GetMass()

    local f = string.format
    self.gui.veh.getters[1]:SetText(f("%s", vehicle:GetName()))
    self.gui.veh.getters[2]:SetText(f("%s", vehicle:GetDriver()))
    self.gui.veh.getters[3]:SetText(f("%i", vehicle:GetModelId()))
    self.gui.veh.getters[4]:SetText(f("%i", vehicle:GetClass()))
    if vehicle:GetTemplate() ~= "" then
        self.gui.veh.getters[5]:SetText(f("%s", vehicle:GetTemplate()))
    else
        self.gui.veh.getters[5]:SetText(f("%s", "Default"))
    end
    if vehicle:GetDecal() ~= "" then
        self.gui.veh.getters[6]:SetText(f("%s", vehicle:GetDecal()))
    else
        self.gui.veh.getters[6]:SetText(f("%s", "Default"))
    end
    self.gui.veh.getters[9]:SetText(f("%i", vehicle:GetWheelCount()))
    self.gui.veh.getters[10]:SetText(f("%i", vehicle:GetMaxRPM()))
    self.gui.veh.getters[15]:SetText(f("%i " .. self.locStrings["ms"], vehicle:GetTopSpeed()))
end

function Tuner:VehicleUpdate()
    if not self.veh then return end

    local f = string.format
    local t = self.veh:GetTorque()
    local ratios = self.trans:GetGearRatios()
    local s = self.veh:GetLinearVelocity():Length()
    local wt = t * self.trans:GetPrimaryTransmissionRatio() * ratios[self.trans:GetGear()]

    self.gui.veh.getters[7]:SetText(f("%i%s", self.veh:GetHealth() * 100, "%"))
    self.gui.veh.getters[8]:SetText(f("%s " .. self.locStrings["kg_txt"], self.veh:GetMass()))
    self.gui.veh.getters[11]:SetText(f("%i", self.veh:GetRPM()))
    self.gui.veh.getters[12]:SetText(f("%.f N", t))

    self.peak_t = self.peak_t or 0
    if t > self.peak_t then
        self.peak_t = t
        self.gui.veh.getters[13]:SetText(f("%.f N", self.peak_t))
    end

    self.gui.veh.getters[14]:SetText(f("%.f N", wt))
    self.gui.veh.getters[16]:SetText(f("%i " .. self.locStrings["ms"] .. ", %i " .. self.locStrings["kmh"] .. ", %i " .. self.locStrings["mph"], s, s * 3.6, s * 2.234))

    self.peak_s = self.peak_s or 0
    if s > self.peak_s then
        self.peak_s = s
        self.gui.veh.getters[17]:SetText(f("%i " .. self.locStrings["ms"] .. ", %i " .. self.locStrings["kmh"] .. ", %i " .. self.locStrings["mph"], self.peak_s, self.peak_s * 3.6, self.peak_s * 2.234))
    end

    if s < 0.1 then
        self.timer = Timer()
        self.gui.veh.getters[18]:SetText("")
    elseif self.timer and s > 100 / 3.6 then
        self.time = self.timer:GetSeconds()
        self.gui.veh.getters[18]:SetText(f(self.locStrings["in_txt"] .. " %.3f " .. self.locStrings["seconds"], self.time))
        self.timer = nil
    end
end

function Tuner:OtherVehicleUpdate()
    if not self.veh then return end

    local f = string.format
    local t = self.veh:GetTorque()
    local s = self.veh:GetLinearVelocity():Length()

    self.gui.veh.getters[7]:SetText(f("%i%s", self.veh:GetHealth() * 100, "%"))
    self.gui.veh.getters[8]:SetText(f("%s " .. self.locStrings["kg_txt"], self.veh:GetMass()))
    self.gui.veh.getters[11]:SetText(f("%i", self.veh:GetRPM()))
    self.gui.veh.getters[12]:SetText(f("%i N", t))

    self.peak_t = self.peak_t or 0
    if t > self.peak_t then
        self.peak_t = t
        self.gui.veh.getters[13]:SetText(f("%i N", self.peak_t))
    end

    self.gui.veh.getters[16]:SetText(f("%i " .. self.locStrings["ms"] .. ", %i " .. self.locStrings["kmh"] .. ", %i " .. self.locStrings["mph"], s, s * 3.6, s * 2.234))

    self.peak_s = self.peak_s or 0
    if s > self.peak_s then
        self.peak_s = s
        self.gui.veh.getters[17]:SetText(f("%i " .. self.locStrings["ms"] .. ", %i " .. self.locStrings["kmh"] .. ", %i " .. self.locStrings["mph"], self.peak_s, self.peak_s * 3.6, self.peak_s * 2.234))
    end

    if s < 0.1 then
        self.timer = Timer()
        self.gui.veh.getters[18]:SetText("")
    elseif self.timer and s > 100 / 3.6 then
        self.time = self.timer:GetSeconds()
        self.gui.veh.getters[18]:SetText(f(self.locStrings["in_txt"] .. " %.3f " .. self.locStrings["seconds"], self.time))
        self.timer = nil
    end
end

function Tuner:TransmissionUpdate()
    if not self.trans then return end

    local f = string.format

    self.gui.trans.setters[4]:SetChecked(self.trans:GetManual())

    self.gui.trans.getters[1]:SetText(f("%i", self.trans:GetUpshiftRPM()))
    self.gui.trans.getters[2]:SetText(f("%i", self.trans:GetDownshiftRPM()))
    self.gui.trans.getters[3]:SetText(f("%i", self.trans:GetMaxGear()))
    self.gui.trans.getters[4]:SetText(f("%s", self.trans:GetManual()))
    self.gui.trans.getters[5]:SetText(f("%g", self.trans:GetClutchDelayTime()))
    self.gui.trans.getters[6]:SetText(f("%i", self.trans:GetGear()))

    local gear_ratios = self.trans:GetGearRatios()
    for wheel, ratio in ipairs(gear_ratios) do
        self.gui.trans.getters[6 + wheel]:SetText(f("%g", ratio))
    end

    self.gui.trans.getters[13]:SetText(f("%g", self.trans:GetReverseGearRatio()))
    self.gui.trans.getters[14]:SetText(f("%g", self.trans:GetPrimaryTransmissionRatio()))

    local wheel_ratios = self.trans:GetWheelTorqueRatios()
    for wheel, ratio in ipairs(wheel_ratios) do
        self.gui.trans.getters[14 + wheel]:SetText(f("%g", ratio))
    end
end

function Tuner:AerodynamicsUpdate()
    if not self.aero then return end

    local f = string.format

    self.gui.aero.getters[1]:SetText(f("%g", self.aero:GetAirDensity()))
    self.gui.aero.getters[2]:SetText(f("%g", self.aero:GetFrontalArea()))
    self.gui.aero.getters[3]:SetText(f("%g", self.aero:GetDragCoefficient()))
    self.gui.aero.getters[4]:SetText(f("%g", self.aero:GetLiftCoefficient()))

    local gravity = self.aero:GetExtraGravity()
    self.gui.aero.getters[5]:SetText(f("%.6f", gravity.x))
    self.gui.aero.getters[6]:SetText(f("%.6f", gravity.y))
    self.gui.aero.getters[7]:SetText(f("%.6f", gravity.z))
end

function Tuner:SuspensionUpdate()
    if not self.susp then return end

    local f = string.format

    for wheel = 1, self.veh:GetWheelCount() do
        self.gui.susp[wheel].getters[1]:SetText(f("%g", self.susp:GetLength(wheel)))
        self.gui.susp[wheel].getters[2]:SetText(f("%g", self.susp:GetStrength(wheel)))

        local direction = self.susp:GetChassisDirection(wheel)
        self.gui.susp[wheel].getters[3]:SetText(f("%.6f", direction.x))
        self.gui.susp[wheel].getters[4]:SetText(f("%.6f", direction.y))
        self.gui.susp[wheel].getters[5]:SetText(f("%.6f", direction.z))

        local position = self.susp:GetChassisPosition(wheel)
        self.gui.susp[wheel].getters[6]:SetText(f("%.6f", position.x))
        self.gui.susp[wheel].getters[7]:SetText(f("%.6f", position.y))
        self.gui.susp[wheel].getters[8]:SetText(f("%.6f", position.z))

        self.gui.susp[wheel].getters[9]:SetText(f("%g", self.susp:GetDampingCompression(wheel)))
        self.gui.susp[wheel].getters[10]:SetText(f("%g", self.susp:GetDampingRelaxation(wheel)))
    end
end

function Tuner:KeyUp(args)
    if Game:GetState() ~= GUIState.Game then return end

    if IsValid(self.veh) then
        if args.key == string.byte("N") then
            self:SetWindowVisible(not self.activeWindow, true)
            self.timer = nil
        end

        if self.trans and self.trans:GetManual() then
            if args.key == VirtualKey.Numpad1 then
                if self.peredacha < self.trans:GetMaxGear() then
                    self.peredacha = self.peredacha + 1
                    self.trans:SetGear(self.peredacha)
                    Game:ShowPopup(self.locStrings["gear"] .. self.peredacha, false)
                end
            elseif args.key == VirtualKey.Numpad2 then
                if self.peredacha > 1 then
                    self.peredacha = self.peredacha - 1
                    self.trans:SetGear(self.peredacha)
                    Game:ShowPopup(self.locStrings["gear"] .. self.peredacha, false)
                end
            end
        end
    end
end

function Tuner:CheckThrust()
    self.currentThrust = self.currentThrust * self.thrustIncreaseFactor
    if self.currentThrust < self.minThrust then
        self.currentThrust = self.minThrust
    elseif self.currentThrust > self.maxThrust then
        self.currentThrust = self.maxThrust
    end
end

function Tuner:LocalPlayerInput(args)
    if self.gui.window:GetVisible() and Game:GetState() == GUIState.Game then
        for index, action in ipairs(self.blacklist) do
            if action == args.input then
                return false
            end
        end

        if args.input == Action.GuiPause then
            self:SetWindowVisible(false)
        end
    end

    if not self.vehicleFly then return end
    if LocalPlayer:GetWorld() ~= DefaultWorld or Game:GetState() ~= GUIState.Game then return end

    local vehicle = LocalPlayer:GetVehicle()

    if vehicle and LocalPlayer:InVehicle() then
        if Key:IsDown(90) then
            local vehicleVelocity = vehicle:GetLinearVelocity()

            self:CheckThrust()
            vehicle:SetLinearVelocity(Vector3(vehicleVelocity.x, self.currentThrust, vehicleVelocity.z))
        end
    end
end

function Tuner:SetWindowVisible(visible, sound)
    if self.activeWindow ~= visible then
        self.activeWindow = visible
        self.gui.window:SetVisible(visible)
        Mouse:SetVisible(visible)
    end

    if self.activeWindow then
        local pWorld = LocalPlayer:GetWorld() == DefaultWorld

        self.gui.color.button:SetVisible(pWorld)

        if self.gui.trans.button then
            self.gui.trans.button:SetVisible(pWorld)
        end

        if self.gui.susp.button then
            self.gui.susp.button:SetVisible(pWorld)
        end

        self.gui.aero.button:SetVisible(pWorld)
        self.gui.tabs:SetCurrentTab(self.gui.veh.button)
    end

    if sound then
        local effect = ClientEffect.Play(AssetLocation.Game, {
            effect_id = self.activeWindow and 382 or 383,

            position = Camera:GetPosition(),
            angle = Angle()
        })
    end
end

function Tuner:EnterVehicle(args)
    self:InitGUI()

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.gui.window:SetTitle("▧ Тюнинг")
    end

    if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
    if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
    if not self.KeyUpEvent then self.KeyUpEvent = Events:Subscribe("KeyUp", self, self.KeyUp) end

    if args.is_driver then
        self:InitVehicle(args.vehicle)

        self.currentThrust = 0
        self.carFlyLandThrust = 1
        self.peredacha = 1
    end
end

function Tuner:ExitVehicle(args)
    if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
    if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
    if self.KeyUpEvent then Events:Unsubscribe(self.KeyUpEvent) self.KeyUpEvent = nil end

    if self.veh and args.vehicle == self.veh then
        self:Disable()
    end
end

function Tuner:EntitySpawn(args)
    local entity = args.entity

    if entity.__type == "Vehicle" then
        if entity:GetValue("Neon") then
            self:CreateNeon(entity)
        end
    end
end

function Tuner:EntityDespawn(args)
    local entity = args.entity

    if entity.__type == "Vehicle" then
        if entity == self.veh then
            self:Disable()
        end

        self:RemoveNeon(entity)
    end
end

function Tuner:ModuleUnload()
    for k, v in pairs(self.neons) do
        if IsValid(v) then
            v:Remove()
        end
    end
end

function Tuner:Disable()
    self:SetWindowVisible(false)

    self.veh = nil
    self.trans = nil
    self.aero = nil
    self.susp = nil
    self.peak_s = nil
    self.peak_t = nil
    self.time = nil
    self.timer = nil
end

local tuner = Tuner()