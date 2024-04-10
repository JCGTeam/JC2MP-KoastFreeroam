class 'Tuner'

function Tuner:__init()
	self.planevehicles = { 24, 30, 34, 39, 51, 59, 81, 85 }

	self.blacklist = {
		Action.VehicleFireLeft,
		Action.VehicleFireRight,
		Action.McFire,
		Action.LookRight,
		Action.LookLeft,
		Action.LookUp,
		Action.LookDown
	}

	local vehicle = LocalPlayer:GetVehicle()
	if IsValid(vehicle) then
		local LocalVehicleModel = vehicle:GetModelId()

		if self:CheckList(self.planevehicles, LocalVehicleModel) then
			self.CarFlyActive = true
		else
			self.CarFlyActive = false
		end
	else
		self.CarFlyActive = false
	end

	self.MaxThrust = 5
	self.MinThrust = 0.1
	self.CurrentThrust = 0
	self.CarFlyLandThrust = 2
	self.ThrustIncreaseFactor = 1.05
	self.ThrustDecreaseFactor = 0.9
	self.ThrustDecreaseInteger = 1
	self.ThrustDecreaseTimer = Timer()

	self:InitGUI()
	self.SyncTimer = Timer()

	self.neons = {}

	self.neonEnabled = false
	self.maxValue = 1000000000000000000

	local vehicle = LocalPlayer:GetVehicle()
	if IsValid(vehicle) and vehicle:GetDriver() == LocalPlayer then
		self:InitVehicle(vehicle)
		self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	end

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.gear = "Передача: "

		self.gui.window:SetTitle( "▧ Тюнинг" )
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "ModuleUnload", self, self.RemoveNeon )

	Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe( "LocalPlayerEnterVehicle", self, self.EnterVehicle )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.ExitVehicle )
	Events:Subscribe( "EntityDespawn", self, self.VehicleDespawn )

	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "PostTick", self, self.Thrust )
end

function Tuner:Lang()
	self.gear = "Gear: "

	self.gui.window:SetTitle( "▧ Tuning" )

	if self.gui.veh.labels then
		self.gui.veh.labels[1]:SetText( "Name" )
		self.gui.veh.labels[2]:SetText( "Driver" )
		self.gui.veh.labels[3]:SetText( "Vehicle ID" )
		self.gui.veh.labels[4]:SetText( "Class" )
		self.gui.veh.labels[5]:SetText( "Type" )	
		self.gui.veh.labels[6]:SetText( "Decal" )
		self.gui.veh.labels[7]:SetText( "Health" )
		self.gui.veh.labels[8]:SetText( "Mass" )
		self.gui.veh.labels[9]:SetText( "Wheels" )
		self.gui.veh.labels[10]:SetText( "Max RPM" )
		self.gui.veh.labels[11]:SetText( "Current RPM" )
		self.gui.veh.labels[12]:SetText( "Torque" )
		self.gui.veh.labels[13]:SetText( "Peak torque" )
		self.gui.veh.labels[14]:SetText( "Wheel torque" )
		self.gui.veh.labels[15]:SetText( "Top speed" )
		self.gui.veh.labels[16]:SetText( "Current speed" )
		self.gui.veh.labels[17]:SetText( "Peak speed" )
		self.gui.veh.labels[18]:SetText( "0-100 km/h" )

		for i, label in ipairs( self.gui.veh.labels ) do
			label:SetPosition( Vector2( 5, 5 + 22 * (i - 1) ) )
			label:SizeToContents()
		end
	end

	if self.gui.trans.labels then
		self.gui.trans.labels[1]:SetText( "Upshift RPM" )
		self.gui.trans.labels[2]:SetText( "Downshift RPM" )
		self.gui.trans.labels[3]:SetText( "Max gear" )
		self.gui.trans.labels[4]:SetText( "Is manual (Num 1/2)" )
		self.gui.trans.labels[5]:SetText( "Clutch delay" )
		self.gui.trans.labels[6]:SetText( "Current gear" )
		self.gui.trans.labels[7]:SetText( "1st gear ratio" )
		self.gui.trans.labels[8]:SetText( "2st gear ratio" )
		self.gui.trans.labels[9]:SetText( "3st gear ratio" )
		self.gui.trans.labels[10]:SetText( "4th gear ratio" )
		self.gui.trans.labels[11]:SetText( "5th gear ratio" )
		self.gui.trans.labels[12]:SetText( "6th gear ratio" )
		self.gui.trans.labels[13]:SetText( "Reverse ratio" )
		self.gui.trans.labels[14]:SetText( "Primary ratio" )
		self.gui.trans.labels[15]:SetText( "Wheel 1 torque ratio" )
		self.gui.trans.labels[16]:SetText( "Wheel 2 torque ratio" )
		self.gui.trans.labels[17]:SetText( "Wheel 3 torque ratio" )
		self.gui.trans.labels[18]:SetText( "Wheel 4 torque ratio" )
		self.gui.trans.labels[19]:SetText( "Wheel 5 torque ratio" )
		self.gui.trans.labels[20]:SetText( "Wheel 6 torque ratio" )
		self.gui.trans.labels[21]:SetText( "Wheel 7 torque ratio" )
		self.gui.trans.labels[22]:SetText( "Wheel 8 torque ratio" )

		for i, label in ipairs(self.gui.trans.labels) do
			label:SetPosition( Vector2( 5, 5 + 22 * (i - 1) ) )
			label:SizeToContents()
		end

		self.gui.aero.labels[1]:SetText( "Air density" )
		self.gui.aero.labels[2]:SetText( "Frontal area" )
		self.gui.aero.labels[3]:SetText( "Drag coeff" )
		self.gui.aero.labels[4]:SetText( "Lift coeff" )
		self.gui.aero.labels[5]:SetText( "Extra gravity X" )
		self.gui.aero.labels[6]:SetText( "Extra gravity Y" )
		self.gui.aero.labels[7]:SetText( "Extra gravity Z" )

		for i, label in ipairs(self.gui.aero.labels) do
			label:SetPosition( Vector2( 5, 5 + 22 * (i - 1) )) 
			label:SizeToContents()
		end

	end
	
	if self.gui.susp.labels then
		self.gui.susp.labels[1]:SetText( "Length" )
		self.gui.susp.labels[2]:SetText( "Strength" )
		self.gui.susp.labels[3]:SetText( "Chassis direction X" )
		self.gui.susp.labels[4]:SetText( "Chassis direction Y" )
		self.gui.susp.labels[5]:SetText( "Chassis direction Z" )
		self.gui.susp.labels[6]:SetText( "Chassis position X" )
		self.gui.susp.labels[7]:SetText( "Chassis position Y" )
		self.gui.susp.labels[8]:SetText( "Chassis position Z" )
		self.gui.susp.labels[9]:SetText( "Damping compression" )
		self.gui.susp.labels[10]:SetText( "Damping relaxation" )

		self.gui.susp.labels[11]:SetText( "Length" )
		self.gui.susp.labels[12]:SetText( "Strength" )
		self.gui.susp.labels[13]:SetText( "Chassis direction X" )
		self.gui.susp.labels[14]:SetText( "Chassis direction Y" )
		self.gui.susp.labels[15]:SetText( "Chassis direction Z" )
		self.gui.susp.labels[16]:SetText( "Chassis position X" )
		self.gui.susp.labels[17]:SetText( "Chassis position Y" )
		self.gui.susp.labels[18]:SetText( "Chassis position Z" )
		self.gui.susp.labels[19]:SetText( "Damping compression" )
		self.gui.susp.labels[20]:SetText( "Damping relaxation" )

		for i, label in ipairs(self.gui.susp.labels) do
			label:SetPosition( Vector2( 5, 5 + 22 * (i - 1) ) )
			label:SizeToContents()
		end
	end

	if self.gui.aero.flyT then
		self.gui.aero.flyT:SetText( "Vertical takeoff (Z button)" )
	end
end

function Tuner:CheckList( tableList, modelID )
	for k,v in pairs(tableList) do
		if v == modelID then return true end
	end
	return false
end

function Tuner:ToggleNeon()
	Network:Send( "ToggleSyncNeon" )
end

function Tuner:RemoveNeon()
	for vehId, _ in pairs( self.neons ) do
		if IsValid(self.neons[vehId], false) then self.neons[vehId]:Remove() end
		self.neons[vehId] = nil
	end
end

function Tuner:Render()
	local checked = {}

	for v in Client:GetVehicles() do
		table.insert(checked, v)
	end

	for i = 1, #checked do
		local v = checked[i]

		if IsValid(v) then
			local vehId = v:GetId() + 1
			if v:GetValue( "Neon" ) and v:GetValue( "Owner" ) and not checked[vehId] then
				if self.neons[vehId] then
					self.neons[vehId]:SetPosition( v:GetPosition() + Vector3( 0, 1, 0 ) )
				else
					self.neons[vehId] = ClientLight.Create{
						position = v:GetPosition() + Vector3(0, 1, 0),
						color = v:GetValue("NeonColor") or Color.White,
						constant_attenuation = 0,
						linear_attenuation = 0,
						quadratic_attenuation = 0,
						multiplier = 10.0,
						radius = 4
					}
				end
				checked[vehId] = true
			end
		end
	end

	for vehId, neon in pairs( self.neons ) do
		if not checked[vehId] then
			if IsValid(neon, false) then
				neon:Remove()
			end
			self.neons[vehId] = nil
		end
	end

	local is_visible = self.active and (Game:GetState() == GUIState.Game)

    if self.gui.window:GetVisible() ~= is_visible then
        self.gui.window:SetVisible( is_visible )
    end

    if self.active then
        Mouse:SetVisible( is_visible )
    end
end

function Tuner:PostTick()
	if self.SyncTimer:GetSeconds() <= 1 then return end

	local vehicles = {}

	for v in Client:GetVehicles() do
		table.insert(vehicles, v)
	end

	for _, v in pairs(vehicles) do
		if IsValid(v) then
			if v:GetValue("vehid") then
				if v:GetTransmission() then
					v:GetTransmission():SetClutchDelayTime(v:GetValue("clutch_delay"))

					local gear_ratios = v:GetTransmission():GetGearRatios()
					if v:GetValue( "gear_ratios1" ) ~= nil then gear_ratios[1] = v:GetValue( "gear_ratios1" ) end
					if v:GetValue( "gear_ratios2" ) ~= nil then gear_ratios[2] = v:GetValue( "gear_ratios2" ) end
					if v:GetValue( "gear_ratios3" ) ~= nil then gear_ratios[3] = v:GetValue( "gear_ratios3" ) end
					if v:GetValue( "gear_ratios4" ) ~= nil then gear_ratios[4] = v:GetValue( "gear_ratios4" ) end
					if v:GetValue( "gear_ratios5" ) ~= nil then gear_ratios[5] = v:GetValue( "gear_ratios5" ) end
					if v:GetValue( "gear_ratios6" ) ~= nil then gear_ratios[6] = v:GetValue( "gear_ratios6" ) end
					if v:GetValue( "gear_ratios7" ) ~= nil then gear_ratios[7] = v:GetValue( "gear_ratios7" ) end
					v:GetTransmission():SetGearRatios( gear_ratios )

					local wheel_ratios = v:GetTransmission():GetWheelTorqueRatios()
					for wheel, ratio in ipairs(wheel_ratios) do
						wheel_ratios[wheel] = v:GetValue( "wheel_ratios" .. wheel )
					end
					v:GetTransmission():SetWheelTorqueRatios( wheel_ratios )

					v:GetTransmission():SetReverseGearRatio( v:GetValue( "reverse_ratio" ) )
					v:GetTransmission():SetPrimaryTransmissionRatio( v:GetValue( "primary_transmission_ratio" ) )
				end

				if v:GetAerodynamics() then
					v:GetAerodynamics():SetAirDensity( v:GetValue( "airdensity" ) )
					v:GetAerodynamics():SetFrontalArea( v:GetValue( "frontalarea" ) )
					v:GetAerodynamics():SetDragCoefficient( v:GetValue( "dragcoeff" ) )
					v:GetAerodynamics():SetLiftCoefficient( v:GetValue( "liftcoeff" ) )
					--v:GetAerodynamics():SetExtraGravity( v:GetValue( "gravity" ) )
				end

				if v:GetSuspension() then
					local susp = v:GetSuspension()
					for wheel = 1, v:GetWheelCount() do
						susp:SetLength( wheel, v:GetValue( "wheel" .. wheel .. "_length" ) )
						susp:SetStrength( wheel, v:GetValue( "wheel" .. wheel .. "_strength" ) )
						susp:SetChassisDirection( wheel, v:GetValue( "wheel" .. wheel .. "_direction" ) )
						susp:SetChassisPosition( wheel, v:GetValue( "wheel" .. wheel .. "_position" ) )
						susp:SetDampingCompression( wheel, v:GetValue( "wheel" .. wheel .. "_dampcompression" ) )
						susp:SetDampingRelaxation( wheel, v:GetValue( "wheel" .. wheel .. "_damprelaxation" ) )
					end
				end
			end
		end
	end

	self.SyncTimer:Restart()
end

function Tuner:InitGUI()
	self.peredacha = 1

	self.gui = {veh = {}, trans = {}, aero = {}, neon = {}, susp = {}}

	self.active = false

	self.gui.window = Window.Create()
	self.gui.window:SetVisible( self.active )
	self.gui.window:SetPosition( Vector2( 0.15 * Render.Width, 0.02 * Render.Height ) )
	self.gui.window:SetSize( Vector2( 500, 520 ) )
	self.gui.window:Subscribe( "WindowClosed", self, self.WindowClosed )

	self.gui.tabs = TabControl.Create( self.gui.window )
	self.gui.tabs:SetDock( GwenPosition.Fill )

	self.gui.veh.window = BaseWindow.Create( self.gui.window )
	self.gui.trans.window = BaseWindow.Create( self.gui.window )
	self.gui.aero.window = BaseWindow.Create( self.gui.window )
	self.gui.neon.window = BaseWindow.Create( self.gui.window )
	self.gui.susp.window = BaseWindow.Create( self.gui.window )

	local vehicle = LocalPlayer:GetVehicle()
	if IsValid(vehicle) and vehicle:GetDriver() == LocalPlayer and vehicle:GetClass() == VehicleClass.Land then
		self.gui.veh.window:Subscribe( "Render", self, self.VehicleUpdate )
	else
		self.gui.veh.window:Subscribe( "Render", self, self.OtherVehicleUpdate )
	end
	if IsValid(vehicle) and vehicle:GetClass() == VehicleClass.Land then
		self.gui.trans.window:Subscribe( "Render", self, self.TransmissionUpdate )
		self.gui.susp.window:Subscribe( "Render", self, self.SuspensionUpdate )
		self.gui.aero.window:Subscribe( "Render", self, self.AerodynamicsUpdate )
	end

	self.gui.veh.button = self.gui.tabs:AddPage( "Информация", self.gui.veh.window) 
	self.gui.veh.button:Subscribe( "Press", function()
		self.gui.window:SetSize( Vector2( 360, 465 ) )
	end )

	if IsValid(vehicle) and vehicle:GetClass() == VehicleClass.Land then
		self.gui.trans.button = self.gui.tabs:AddPage("Трансмиссия", self.gui.trans.window)
		self.gui.trans.button:Subscribe( "Press", function()
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
			self.gui.window:SetSize( Vector2( 360, 555 - 22 * (8 - count) ) )
		end )

		self.gui.susp.button = self.gui.tabs:AddPage( "Подвеска", self.gui.susp.window )
		self.gui.susp.button:Subscribe( "Press", function()
			local count = self.veh:GetWheelCount()
			for wheel = 1, count + 1 do
				for _,getter in ipairs(self.gui.susp[wheel].getters) do
					getter:Show()
				end
				for _,setter in ipairs(self.gui.susp[wheel].setters) do
					setter:Show()
				end
			end
			count = count + 1
			for wheel = count + 1, 8 do
				for _,getter in ipairs(self.gui.susp[wheel].getters) do
					getter:Hide()
				end
				for _,setter in ipairs(self.gui.susp[wheel].setters) do
					setter:Hide()
				end
			end
			self.gui.window:SetSize( Vector2( 150 + 80 * count, 510 ) )
		end )
	end

	self.gui.aero.button = self.gui.tabs:AddPage( "Аэродинамика", self.gui.aero.window )
	self.gui.aero.button:Subscribe( "Press", function()
		self.gui.window:SetSize( Vector2( 360, 244 ) )
	end )

	self.gui.neon.button = self.gui.tabs:AddPage( "Неон", self.gui.neon.window )
	local neoncolor = HSVColorPicker.Create( self.gui.neon.window )
	if LocalPlayer:GetValue( "NeonColor" ) then
		neoncolor:SetColor( LocalPlayer:GetValue( "NeonColor" ) )
	end
	neoncolor:SetDock( GwenPosition.Fill )
	local neontoggle = Button.Create( self.gui.neon.window )
	neontoggle:SetText( "Включить/отключить неон" )
	neontoggle:SetToolTip( "Только для транспорта из чёрного рынка" )
	neontoggle:SetTextSize( 15 )
	neontoggle:SetHeight( 30 )
	neontoggle:SetDock( GwenPosition.Bottom )
	neontoggle:Subscribe( "Up", function() Network:Send( "Change") Network:Send( "UpdateNeonColor", { neoncolor = neoncolor:GetColor() } ) self:ToggleNeon() end )
	self.gui.neon.button:Subscribe( "Press", function()
		self.gui.window:SetSize( Vector2( 460, 350 ) )
	end )

	self:InitVehicleGUI()
	if IsValid(vehicle) and vehicle:GetClass() == VehicleClass.Land then
		self:InitTransmissionGUI()
		self:InitSuspensionGUI()
	end
	self:InitAerodynamicsGUI()
end

function Tuner:InitVehicleGUI()
	self.gui.veh.labels = {}
	self.gui.veh.getters = {}
	self.gui.veh.setters = {}

	for i = 1,18 do
		table.insert( self.gui.veh.labels, Label.Create( self.gui.veh.window ) )
		table.insert( self.gui.veh.getters, Label.Create( self.gui.veh.window ) )
	end

	self.gui.veh.labels[1]:SetText( "Название" )
	self.gui.veh.labels[2]:SetText( "Водитель" )
	self.gui.veh.labels[3]:SetText( "ID транспорта" )
	self.gui.veh.labels[4]:SetText( "Класс" )
	self.gui.veh.labels[5]:SetText( "Тип" )	
	self.gui.veh.labels[6]:SetText( "Декаль" )
	self.gui.veh.labels[7]:SetText( "Состояние" )
	self.gui.veh.labels[8]:SetText( "Масса" )
	self.gui.veh.labels[9]:SetText( "Колёса" )
	self.gui.veh.labels[10]:SetText( "Макс. обороты" )
	self.gui.veh.labels[11]:SetText( "Текущие обороты" )
	self.gui.veh.labels[12]:SetText( "Крутящий момент" )
	self.gui.veh.labels[13]:SetText( "Рекорд крут. момента" )
	self.gui.veh.labels[14]:SetText( "Крут. момент колеса" )
	self.gui.veh.labels[15]:SetText( "Макс. скорость" )
	self.gui.veh.labels[16]:SetText( "Текущая скорость" )
	self.gui.veh.labels[17]:SetText( "Рекорд скорости" )
	self.gui.veh.labels[18]:SetText( "Время разгона 100 км/ч" )

	for i, label in ipairs( self.gui.veh.labels ) do
		label:SetPosition( Vector2( 5, 5 + 22 * (i - 1) ) )
		label:SizeToContents()
	end

	for i, getter in ipairs( self.gui.veh.getters ) do
		getter:SetPosition( Vector2( 150, 5 + 22 * (i - 1) ) )
		getter:SetSize( Vector2( 200, 12 ) )
	end
end

function Tuner:InitTransmissionGUI()
	self.gui.trans.labels = {}
	self.gui.trans.getters = {}
	self.gui.trans.setters = {}

	for i = 1,22 do
		table.insert( self.gui.trans.labels, Label.Create( self.gui.trans.window ) )
		table.insert( self.gui.trans.getters, Label.Create( self.gui.trans.window ) )
	end

	self.gui.trans.labels[1]:SetText( "Передачи RPM" )
	self.gui.trans.labels[2]:SetText( "Пониж. передачи RPM" )
	self.gui.trans.labels[3]:SetText( "Макс. передач" )
	self.gui.trans.labels[4]:SetText( "Ручное (Num 1/2)" )
	self.gui.trans.labels[5]:SetText( "Задержка сцепления" )
	self.gui.trans.labels[6]:SetText( "Текущая передача" )
	self.gui.trans.labels[7]:SetText( "1-я передача" )
	self.gui.trans.labels[8]:SetText( "2-я передача" )
	self.gui.trans.labels[9]:SetText( "3-я передача" )
	self.gui.trans.labels[10]:SetText( "4-я передача" )
	self.gui.trans.labels[11]:SetText( "5-я передача" )
	self.gui.trans.labels[12]:SetText( "6-я передача" )
	self.gui.trans.labels[13]:SetText( "Обратное соотношение" )
	self.gui.trans.labels[14]:SetText( "Первичное соотношение" )
	self.gui.trans.labels[15]:SetText( "Крут. момент 1-го колеса" )
	self.gui.trans.labels[16]:SetText( "Крут. момент 2-го колеса" )
	self.gui.trans.labels[17]:SetText( "Крут. момент 3-го колеса" )
	self.gui.trans.labels[18]:SetText( "Крут. момент 4-го колеса" )
	self.gui.trans.labels[19]:SetText( "Крут. момент 5-го колеса" )
	self.gui.trans.labels[20]:SetText( "Крут. момент 6-го колеса" )
	self.gui.trans.labels[21]:SetText( "Крут. момент 7-го колеса" )
	self.gui.trans.labels[22]:SetText( "Крут. момент 8-го колеса" )

	self.gui.trans.setters[4] = CheckBox.Create(self.gui.trans.window)
	self.gui.trans.setters[4]:Subscribe("CheckChanged", function(args)
		self.trans:SetManual(args:GetChecked())
	end)

	self.gui.trans.setters[5] = TextBoxNumeric.Create(self.gui.trans.window)
	self.gui.trans.setters[5]:Subscribe("ReturnPressed", function(args)
		self.trans:SetClutchDelayTime(args:GetValue())
		args:SetText( "" )
		self:SyncTune()
	end)

	self.gui.trans.setters[6] = TextBoxNumeric.Create(self.gui.trans.window)
	self.gui.trans.setters[6]:Subscribe("ReturnPressed", function(args)
		self.trans:SetGear(args:GetValue())
		args:SetText( "" )
		self:SyncTune()
	end)

	for i = 7,12 do 
		self.gui.trans.setters[i] = TextBoxNumeric.Create(self.gui.trans.window)
		self.gui.trans.setters[i]:Subscribe("ReturnPressed", function(args)
			local gear_ratios = self.trans:GetGearRatios()
			gear_ratios[i - 6] = args:GetValue()
			self.trans:SetGearRatios(gear_ratios)
			args:SetText( "" )
			self:SyncTune()
		end)
	end

	self.gui.trans.setters[13] = TextBoxNumeric.Create(self.gui.trans.window)
	self.gui.trans.setters[13]:Subscribe("ReturnPressed", function(args)
		self.trans:SetReverseGearRatio(args:GetValue())
		args:SetText( "" )
		self:SyncTune()
	end)

	self.gui.trans.setters[14] = TextBoxNumeric.Create(self.gui.trans.window)
	self.gui.trans.setters[14]:Subscribe("ReturnPressed", function(args)
		self.trans:SetPrimaryTransmissionRatio(args:GetValue())
		args:SetText( "" )
		self:SyncTune()
	end)

	for i = 15,22 do 
		self.gui.trans.setters[i] = TextBoxNumeric.Create(self.gui.trans.window)
		self.gui.trans.setters[i]:Subscribe("ReturnPressed", function(args)
			local wheel_ratios = self.trans:GetWheelTorqueRatios()
			wheel_ratios[i - 14] = args:GetValue()
			self.trans:SetWheelTorqueRatios(wheel_ratios)
			args:SetText( "" )
			self:SyncTune()
		end)
	end

	for i, label in ipairs(self.gui.trans.labels) do
		label:SetPosition( Vector2( 5, 5 + 22 * (i - 1) ) )
		label:SizeToContents()
	end

	for i, getter in ipairs(self.gui.trans.getters) do
		getter:SetPosition( Vector2( 170, 5 + 22 * (i - 1) ) )
	end

	for i, setter in pairs(self.gui.trans.setters) do
		if setter.__type == "TextBoxNumeric" then
			setter:SetPosition( Vector2( 225, 0 + 22 * (i - 1) ) )
			setter:SetWidth( 57 )
			setter:SetText( "" )
		else
			setter:SetPosition( Vector2( 228, 2 + 22 * (i - 1) ) )
		end
	end
end

function Tuner:InitAerodynamicsGUI()
	local vehicle = LocalPlayer:GetVehicle()

	if IsValid(vehicle) then
		local LocalVehicleModel = vehicle:GetModelId()
		if self:CheckList(self.planevehicles, LocalVehicleModel) then
			self.CarFlyActive = true
		else
			self.CarFlyActive = false
		end
	end

	if IsValid(vehicle) and vehicle:GetClass() == VehicleClass.Land then
		self.gui.aero.labels = {}
		self.gui.aero.getters = {}
		self.gui.aero.setters = {}

		for i = 1,7 do
			table.insert( self.gui.aero.labels, Label.Create( self.gui.aero.window ) )
			table.insert( self.gui.aero.getters, Label.Create( self.gui.aero.window ) )
			table.insert( self.gui.aero.setters, TextBoxNumeric.Create( self.gui.aero.window ) )
		end

		self.gui.aero.labels[1]:SetText( "Плотность воздуха" )
		self.gui.aero.labels[2]:SetText( "Фронтальная зона" )
		self.gui.aero.labels[3]:SetText( "Коэффициент трения" )
		self.gui.aero.labels[4]:SetText( "Коэффициент подъема" )
		self.gui.aero.labels[5]:SetText( "Доп. гравитация X" )
		self.gui.aero.labels[6]:SetText( "Доп. гравитация Y" )
		self.gui.aero.labels[7]:SetText( "Доп. гравитация Z" )

		self.gui.aero.setters[1]:Subscribe( "ReturnPressed", function( args )
			self.aero:SetAirDensity(args:GetValue())
			args:SetText("")
			self:SyncTune()		
		end )

		self.gui.aero.setters[2]:Subscribe( "ReturnPressed", function( args ) 
			self.aero:SetFrontalArea(args:GetValue())
			args:SetText("")
			self:SyncTune()		
		end )

		self.gui.aero.setters[3]:Subscribe( "ReturnPressed", function( args ) 
			self.aero:SetDragCoefficient(args:GetValue())
			args:SetText("")
			self:SyncTune()		
		end )

		self.gui.aero.setters[4]:Subscribe( "ReturnPressed", function( args ) 
			self.aero:SetLiftCoefficient(args:GetValue())
			args:SetText("")
			self:SyncTune()		
		end )

		self.gui.aero.setters[5]:Subscribe( "ReturnPressed", function( args ) 
			local gravity = self.aero:GetExtraGravity()
			self.aero:SetExtraGravity(Vector3(args:GetValue(), gravity.y, gravity.z))
			args:SetText("")	
			self:SyncTune()		
		end )

		self.gui.aero.setters[6]:Subscribe( "ReturnPressed", function( args ) 
			local gravity = self.aero:GetExtraGravity()
			self.aero:SetExtraGravity(Vector3(gravity.x, args:GetValue(), gravity.z))
			args:SetText("")
			self:SyncTune()
		end )

		self.gui.aero.setters[7]:Subscribe ("ReturnPressed", function( args ) 
			local gravity = self.aero:GetExtraGravity()
			self.aero:SetExtraGravity(Vector3(gravity.x, gravity.y, args:GetValue()))
			args:SetText("")
			self:SyncTune()		
		end )
	end

	self.gui.aero.fly = CheckBox.Create( self.gui.aero.window )
	if IsValid(vehicle) and vehicle:GetClass() == VehicleClass.Land then
		self.gui.aero.fly:SetPosition( Vector2( 5, 160 ))
	else
		self.gui.aero.fly:SetPosition( Vector2( 5, 5 ))
	end
	self.gui.aero.fly:SetChecked( self.CarFlyActive )
	self.gui.aero.fly:Subscribe( "CheckChanged",
		function() self.CarFlyActive = not self.CarFlyActive end )

	self.gui.aero.flyT = Label.Create( self.gui.aero.window )
	self.gui.aero.flyT:SetText( "Вертикальный взлёт ( Кнопка Z )" )
	self.gui.aero.flyT:SetPosition( self.gui.aero.fly:GetPosition() + Vector2( 20, 3 ) )
	self.gui.aero.flyT:SizeToContents()

	if IsValid(vehicle) and vehicle:GetClass() == VehicleClass.Land then
		for i, label in ipairs(self.gui.aero.labels) do
			label:SetPosition( Vector2( 5, 5 + 22 * (i - 1) )) 
			label:SizeToContents()
		end

		for i, getter in ipairs(self.gui.aero.getters) do
			getter:SetPosition( Vector2( 150, 5 + 22 * (i - 1) ) )
		end

		for i, setter in pairs(self.gui.aero.setters) do
			setter:SetPosition( Vector2( 225, 0 + 22 * (i - 1) ) )
			setter:SetWidth(57)
			setter:SetText("")
		end
	end
end

function Tuner:InitSuspensionGUI()
	self.gui.susp.labels = {}

	for i = 1,20 do
		table.insert( self.gui.susp.labels, Label.Create( self.gui.susp.window ) )
	end

	for wheel = 1,9 do
		self.gui.susp[wheel] = {}
		self.gui.susp[wheel] = {}
		self.gui.susp[wheel].getters = {}
		self.gui.susp[wheel].setters = {}
		for i = 1,10 do
			table.insert( self.gui.susp[wheel].getters, Label.Create( self.gui.susp.window ) )
			table.insert( self.gui.susp[wheel].setters, TextBoxNumeric.Create( self.gui.susp.window ) )
		end
	end

	self.gui.susp.labels[1]:SetText( "Длина" )
	self.gui.susp.labels[2]:SetText( "Сила" )
	self.gui.susp.labels[3]:SetText( "Направление колеса X" )
	self.gui.susp.labels[4]:SetText( "Направление колеса Y" )
	self.gui.susp.labels[5]:SetText( "Направление колеса Z" )
	self.gui.susp.labels[6]:SetText( "Положение колеса X" )
	self.gui.susp.labels[7]:SetText( "Положение колеса Y" )
	self.gui.susp.labels[8]:SetText( "Положение колеса Z" )
	self.gui.susp.labels[9]:SetText( "Демпфирующее сжатие" )
	self.gui.susp.labels[10]:SetText( "Прижимная сила" )

	self.gui.susp.labels[11]:SetText( "Длина" )
	self.gui.susp.labels[12]:SetText( "Сила" )
	self.gui.susp.labels[13]:SetText( "Направление колеса X" )
	self.gui.susp.labels[14]:SetText( "Направление колеса Y" )
	self.gui.susp.labels[15]:SetText( "Направление колеса Z" )
	self.gui.susp.labels[16]:SetText( "Положение колеса X" )
	self.gui.susp.labels[17]:SetText( "Положение колеса Y" )
	self.gui.susp.labels[18]:SetText( "Положение колеса Z" )
	self.gui.susp.labels[19]:SetText( "Демпфирующее сжатие" )
	self.gui.susp.labels[20]:SetText( "Прижимная сила" )

	for i, label in ipairs(self.gui.susp.labels) do
		label:SetPosition( Vector2( 5, 5 + 22 * (i - 1) ) )
		label:SizeToContents()
	end

	for wheel in ipairs(self.gui.susp) do
		for i, getter in ipairs(self.gui.susp[wheel].getters) do
			getter:SetPosition( Vector2( 150 + 75 * (wheel - 1), 5 + 22 * (i - 1) ) )
			getter:SetWidth( 70 )
		end
	end

	for wheel,v in ipairs(self.gui.susp) do
		v.setters[1]:Subscribe("ReturnPressed", function( args )
			if args:GetValue() >= self.maxValue then
				args:SetText( tostring( self.maxValue ) )
			elseif args:GetValue() <= -self.maxValue then
				args:SetText( tostring( -self.maxValue ) )
			end

			if wheel > self.veh:GetWheelCount() then
				local count = self.veh:GetWheelCount()
				for wh = 1, count do
					self.susp:SetLength( wh, args:GetValue() )
				end
			else
				self.susp:SetLength( wheel, args:GetValue() )
			end
			args:SetText( "" )
			self:SyncTune()
		end)

		v.setters[2]:Subscribe("ReturnPressed", function( args )
			if wheel > self.veh:GetWheelCount() then
				local count = self.veh:GetWheelCount()
				for wh = 1, count do
					self.susp:SetStrength( wh, args:GetValue() )
				end
			else
				self.susp:SetStrength( wheel, args:GetValue() )
			end
			args:SetText( "" )
			self:SyncTune()
		end)

		v.setters[3]:Subscribe("ReturnPressed", function( args )
			if args:GetValue() >= self.maxValue then
				args:SetText( tostring( self.maxValue ) )
			elseif args:GetValue() <= -self.maxValue then
				args:SetText( tostring( -self.maxValue ) )
			end

			if wheel > self.veh:GetWheelCount() then
				local count = self.veh:GetWheelCount()
				for wh = 1, count do
					local direction = self.susp:GetChassisDirection(wh)
					if math.fmod(wh,2)~=0 then
						self.susp:SetChassisDirection( wh, Vector3(args:GetValue(), direction.y, direction.z) )
					else
						self.susp:SetChassisDirection( wh, Vector3(-args:GetValue(), direction.y, direction.z) )
					end
				end
			else
				local direction = self.susp:GetChassisDirection( wheel )
				self.susp:SetChassisDirection( wheel, Vector3( args:GetValue(), direction.y, direction.z ) )
			end
			args:SetText( "" )
			self:SyncTune()
		end)

		v.setters[4]:Subscribe("ReturnPressed", function( args )
			if args:GetValue() >= self.maxValue then
				args:SetText( tostring( self.maxValue ) )
			elseif args:GetValue() <= -self.maxValue then
				args:SetText( tostring( -self.maxValue ) )
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
			args:SetText( "" )
			self:SyncTune()
		end)

		v.setters[5]:Subscribe("ReturnPressed", function( args )
			if args:GetValue() >= self.maxValue then
				args:SetText( tostring( self.maxValue ) )
			elseif args:GetValue() <= -self.maxValue then
				args:SetText( tostring( -self.maxValue ) )
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
			args:SetText( "" )
			self:SyncTune()
		end)

		v.setters[6]:Subscribe("ReturnPressed", function( args )
			if wheel > self.veh:GetWheelCount() then
				local count = self.veh:GetWheelCount()
				for wh = 1, count do
					local position = self.susp:GetChassisPosition(wh)
					if math.fmod(wh,2)~=0 then
						self.susp:SetChassisPosition(wh, Vector3(args:GetValue(), position.y, position.z))
					else
						self.susp:SetChassisPosition(wh, Vector3(-args:GetValue(), position.y, position.z))
					end
				end
			else
				local position = self.susp:GetChassisPosition(wheel)
				self.susp:SetChassisPosition(wheel, Vector3(args:GetValue(), position.y, position.z))
			end
			args:SetText( "" )
			self:SyncTune()
		end)

		v.setters[7]:Subscribe("ReturnPressed", function( args )
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
			args:SetText( "" )
			self:SyncTune()
		end)

		v.setters[8]:Subscribe("ReturnPressed", function( args )
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
			args:SetText( "" )
			self:SyncTune()
		end)

		v.setters[9]:Subscribe("ReturnPressed", function( args )
			if wheel > self.veh:GetWheelCount() then
				local count = self.veh:GetWheelCount()
				for wh = 1, count do
					self.susp:SetDampingCompression(wh, args:GetValue())
				end
			else
				self.susp:SetDampingCompression(wheel, args:GetValue())
			end
			args:SetText( "" )
			self:SyncTune()
		end)

		v.setters[10]:Subscribe("ReturnPressed", function( args )
			if wheel > self.veh:GetWheelCount() then
				local count = self.veh:GetWheelCount()
				for wh = 1, count do
					self.susp:SetDampingRelaxation(wh, args:GetValue())
				end
			else
				self.susp:SetDampingRelaxation(wheel, args:GetValue())
			end
			args:SetText( "" )
			self:SyncTune()
		end)

		for i, setter in ipairs(self.gui.susp[wheel].setters) do
			setter:SetPosition( Vector2( 150 + 75 * (wheel - 1), 220 + 22 * (i - 1) ) )
			setter:SetWidth( 57 )
			setter:SetText( "" )
			self:SyncTune()
		end
	end
end

function Tuner:SyncTune()
	if self.veh == nil or not IsValid(self.veh) then return end
	if self.veh:GetDriver() == LocalPlayer then
		local args = {}

		if self.model then args.model = self.model else return end
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

function Tuner:InitVehicle( vehicle )
	self.veh = vehicle
	self.model = vehicle:GetModelId()
	self.trans = vehicle:GetTransmission()
	self.aero = vehicle:GetAerodynamics()
	self.susp = vehicle:GetSuspension()
	self.mass = vehicle:GetMass()

	local f = string.format
	self.gui.veh.getters[1]:SetText( f("%s", vehicle:GetName()) )
	self.gui.veh.getters[2]:SetText( f("%s", vehicle:GetDriver()) )
	self.gui.veh.getters[3]:SetText( f("%i", vehicle:GetModelId()) )
	self.gui.veh.getters[4]:SetText( f("%i", vehicle:GetClass()) )
	if vehicle:GetTemplate() ~= "" then
		self.gui.veh.getters[5]:SetText( f("%s", vehicle:GetTemplate()) )
	else
		self.gui.veh.getters[5]:SetText( f("%s", "Default") )
	end
	if vehicle:GetDecal() ~= "" then
		self.gui.veh.getters[6]:SetText( f("%s", vehicle:GetDecal()) )
	else
		self.gui.veh.getters[6]:SetText( f("%s", "Default") )
	end
	self.gui.veh.getters[9]:SetText( f("%i", vehicle:GetWheelCount()) )
	self.gui.veh.getters[10]:SetText( f("%i", vehicle:GetMaxRPM()) )
	self.gui.veh.getters[15]:SetText( f("%i м/с", vehicle:GetTopSpeed()) )
end

function Tuner:VehicleUpdate()
	if not self.veh then return end

	local f = string.format 
	local t = self.veh:GetTorque()
	local ratios = self.trans:GetGearRatios()
	local s = self.veh:GetLinearVelocity():Length()
	local wt = t * self.trans:GetPrimaryTransmissionRatio() * ratios[self.trans:GetGear()]

	self.gui.veh.getters[7]:SetText( f("%i%s", self.veh:GetHealth() * 100, "%") )
	self.gui.veh.getters[8]:SetText( f("%s кг", self.veh:GetMass()) )
	self.gui.veh.getters[11]:SetText( f("%i", self.veh:GetRPM()) )
	self.gui.veh.getters[12]:SetText( f("%.f N", t) )

	self.peak_t = self.peak_t or 0
	if t > self.peak_t then 
		self.peak_t = t
		self.gui.veh.getters[13]:SetText( f("%.f N", self.peak_t) )
	end

	self.gui.veh.getters[14]:SetText( f("%.f N", wt ) )
	self.gui.veh.getters[16]:SetText( f("%i м/с, %i км/ч, %i миль/ч", s, s * 3.6, s * 2.234) )

	self.peak_s = self.peak_s or 0
	if s > self.peak_s then
		self.peak_s = s
		self.gui.veh.getters[17]:SetText( f("%i м/с, %i км/ч, %i миль/ч", self.peak_s, self.peak_s * 3.6, self.peak_s * 2.234) )
	end

	if s < 0.1 then 
		self.timer = Timer()
		self.gui.veh.getters[18]:SetText("")
	elseif self.timer and s > 100 / 3.6 then
		self.time = self.timer:GetSeconds()
		self.gui.veh.getters[18]:SetText( f("за %.3f секунд", self.time) )
		self.timer = nil
	end
end

function Tuner:OtherVehicleUpdate()
	if not self.veh then return end

	local f = string.format 
	local t = self.veh:GetTorque()
	local s = self.veh:GetLinearVelocity():Length()

	self.gui.veh.getters[7]:SetText( f("%i%s", self.veh:GetHealth() * 100, "%") )
	self.gui.veh.getters[8]:SetText( f("%s кг", self.veh:GetMass()) )
	self.gui.veh.getters[11]:SetText( f("%i", self.veh:GetRPM()) )
	self.gui.veh.getters[12]:SetText( f("%i N", t) )

	self.peak_t = self.peak_t or 0
	if t > self.peak_t then 
		self.peak_t = t
		self.gui.veh.getters[13]:SetText( f("%i N", self.peak_t) )
	end

	self.gui.veh.getters[16]:SetText( f("%i м/с, %i км/ч, %i миль/ч", s, s * 3.6, s * 2.234) )

	self.peak_s = self.peak_s or 0
	if s > self.peak_s then
		self.peak_s = s
		self.gui.veh.getters[17]:SetText( f("%i м/с, %i км/ч, %i миль/ч", self.peak_s, self.peak_s * 3.6, self.peak_s * 2.234) )
	end

	if s < 0.1 then 
		self.timer = Timer()
		self.gui.veh.getters[18]:SetText("")
	elseif self.timer and s > 100 / 3.6 then
		self.time = self.timer:GetSeconds()
		self.gui.veh.getters[18]:SetText( f("за %.3f секунд", self.time) )
		self.timer = nil
	end
end

function Tuner:TransmissionUpdate()
	if not self.trans then return end

	local f = string.format

	self.gui.trans.setters[4]:SetChecked(self.trans:GetManual())

	self.gui.trans.getters[1]:SetText( f("%i", self.trans:GetUpshiftRPM()) )
	self.gui.trans.getters[2]:SetText( f("%i", self.trans:GetDownshiftRPM()) )
	self.gui.trans.getters[3]:SetText( f("%i", self.trans:GetMaxGear()) )
	self.gui.trans.getters[4]:SetText( f("%s", self.trans:GetManual()) )
	self.gui.trans.getters[5]:SetText( f("%g", self.trans:GetClutchDelayTime()) )
	self.gui.trans.getters[6]:SetText( f("%i", self.trans:GetGear()) )

	local gear_ratios = self.trans:GetGearRatios()
	for wheel, ratio in ipairs(gear_ratios) do
		self.gui.trans.getters[6 + wheel]:SetText(f("%g", ratio))
	end

	self.gui.trans.getters[13]:SetText( f("%g", self.trans:GetReverseGearRatio()) )
	self.gui.trans.getters[14]:SetText( f("%g", self.trans:GetPrimaryTransmissionRatio()) )

	local wheel_ratios = self.trans:GetWheelTorqueRatios()
	for wheel, ratio in ipairs(wheel_ratios) do
		self.gui.trans.getters[14 + wheel]:SetText( f("%g", ratio) )
	end
end

function Tuner:AerodynamicsUpdate()
	if not self.aero then return end

	local f = string.format

	self.gui.aero.getters[1]:SetText( f("%g", self.aero:GetAirDensity()) )
	self.gui.aero.getters[2]:SetText( f("%g", self.aero:GetFrontalArea()) )
	self.gui.aero.getters[3]:SetText( f("%g", self.aero:GetDragCoefficient()) )
	self.gui.aero.getters[4]:SetText( f("%g", self.aero:GetLiftCoefficient()) )

	local gravity = self.aero:GetExtraGravity()
	self.gui.aero.getters[5]:SetText( f("%.6f", gravity.x) )
	self.gui.aero.getters[6]:SetText( f("%.6f", gravity.y) )
	self.gui.aero.getters[7]:SetText( f("%.6f", gravity.z) )
end

function Tuner:SuspensionUpdate()
	if not self.susp then return end

	local f = string.format

	for wheel = 1, self.veh:GetWheelCount() do
		self.gui.susp[wheel].getters[1]:SetText( f("%g", self.susp:GetLength(wheel)) )
		self.gui.susp[wheel].getters[2]:SetText( f("%g", self.susp:GetStrength(wheel)) )

		local direction = self.susp:GetChassisDirection(wheel)
		self.gui.susp[wheel].getters[3]:SetText( f("%.6f", direction.x) )
		self.gui.susp[wheel].getters[4]:SetText( f("%.6f", direction.y) )
		self.gui.susp[wheel].getters[5]:SetText( f("%.6f", direction.z) )

		local position = self.susp:GetChassisPosition(wheel)
		self.gui.susp[wheel].getters[6]:SetText( f("%.6f", position.x) )
		self.gui.susp[wheel].getters[7]:SetText( f("%.6f", position.y) )
		self.gui.susp[wheel].getters[8]:SetText( f("%.6f", position.z) )

		self.gui.susp[wheel].getters[9]:SetText( f("%g", self.susp:GetDampingCompression(wheel)) )
		self.gui.susp[wheel].getters[10]:SetText( f("%g", self.susp:GetDampingRelaxation(wheel)) )
	end
end

function Tuner:KeyUp( args )
	if Game:GetState() ~= GUIState.Game then return end

	if args.key == string.byte("N") and IsValid( self.veh ) then
		if LocalPlayer:GetWorld() ~= DefaultWorld then return end
		self:SetWindowVisible( not self.active )
		self.timer = nil
		if self.active then
			self.gui.tabs:SetCurrentTab( self.gui.veh.button )

			ClientEffect.Create(AssetLocation.Game, {
				effect_id = 382,

				position = Camera:GetPosition(),
				angle = Angle()
			})
		else
			ClientEffect.Create(AssetLocation.Game, {
				effect_id = 383,

				position = Camera:GetPosition(),
				angle = Angle()
			})
		end
	end

	if self.trans and self.trans:GetManual() and IsValid( self.veh ) then
		if args.key == VirtualKey.Numpad1 then
			if self.peredacha < self.trans:GetMaxGear() then
				self.peredacha = self.peredacha + 1
				self.trans:SetGear( self.peredacha )
				Game:ShowPopup( self.gear .. self.peredacha, false )
			end
		elseif args.key == VirtualKey.Numpad2 then
			if self.peredacha > 1 then
				self.peredacha = self.peredacha - 1
				self.trans:SetGear( self.peredacha )
				Game:ShowPopup( self.gear .. self.peredacha, false )
			end
		end
	end
end

function Tuner:WindowClosed()
	self:SetWindowVisible( false )
	ClientEffect.Create(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

function Tuner:LocalPlayerInput( args )
	if ( self.gui.window:GetVisible() and Game:GetState() == GUIState.Game ) then
		for index, action in ipairs(self.blacklist) do
			if action == args.input then
				return false
			end
		end
		if args.input == Action.GuiPause then
			self:SetWindowVisible( false )
		end
	end
end

function Tuner:SetWindowVisible( visible )
    if self.active ~= visible then
		self.active = visible
		self.gui.window:SetVisible( visible )
		Mouse:SetVisible( visible )
	end
end

function Tuner:CheckThrust()
	self.CurrentThrust = self.CurrentThrust * self.ThrustIncreaseFactor
	if self.CurrentThrust < self.MinThrust then
		self.CurrentThrust = self.MinThrust
	elseif self.CurrentThrust > self.MaxThrust then
		self.CurrentThrust = self.MaxThrust
	end
end

function Tuner:Thrust( args )
	if LocalPlayer:GetWorld() ~= DefaultWorld or Game:GetState() ~= GUIState.Game then return end

	local vehicle = LocalPlayer:GetVehicle()
	if LocalPlayer:GetState() == PlayerState.InVehicle and IsValid(vehicle) and vehicle:GetDriver() == LocalPlayer then

	local VehicleVelocity = vehicle:GetLinearVelocity()
		if self.CarFlyActive then
			if Key:IsDown(90) then
				self:CheckThrust()
				local SetThrust = Vector3( VehicleVelocity.x, self.CurrentThrust, VehicleVelocity.z )
				local SendInfo = {}
					SendInfo.Player = LocalPlayer
					SendInfo.Vehicle = vehicle
					SendInfo.Thrust = SetThrust
				Network:Send(  "ActivateThrust", SendInfo )
			end
		end
	end
end

function Tuner:EnterVehicle( args )
	self:InitGUI()

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.gui.window:SetTitle( "▧ Тюнинг" )
	end

	if not self.LocalPlayerInputEvent then
		self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	end

	if args.is_driver then
		self:InitVehicle(args.vehicle)
		self.CurrentThrust = 0
		self.CarFlyLandThrust = 1
		self.peredacha = 1
	end
end

function Tuner:ExitVehicle( args )
	if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end

	if self.veh and args.vehicle == self.veh then
		self:Disable()
		if LocalPlayer:GetValue( "Neon" ) then
			Network:Send( "ToggleSyncNeon", { value = nil } )
			self.neonEnabled = false
		end
	end
end

function Tuner:VehicleDespawn( args )
	if args.entity.__type == "Vehicle" and args.entity == self.veh then
		self:Disable()
	end
end

function Tuner:Disable()
	self:SetWindowVisible( false )

	self.veh = nil
	self.trans = nil
	self.aero = nil
	self.susp = nil
	self.peak_s = nil
	self.peak_t = nil
	self.time = nil
	self.timer = nil
end

Tuner = Tuner()