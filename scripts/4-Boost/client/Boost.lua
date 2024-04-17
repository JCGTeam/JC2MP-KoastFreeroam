class 'Boost'

function Boost:__init()
	self.defaultLandBoost = true
	self.defaultBoatBoost = true
	self.defaultHeliBoost = true
	self.defaultPlaneBoost = true
	self.defaultTextEnabled = true
	self.defaultPadEnabled = true
	self.defaultBrakeEnabled = true
	self.defaultStrength = 80

	self.controllerAction = Action.VehicleFireLeft

	self.landBoost    = self.defaultLandBoost
	self.boatBoost    = self.defaultBoatBoost
	self.heliBoost    = self.defaultHeliBoost
	self.planeBoost   = self.defaultPlaneBoost
	self.textEnabled  = self.defaultTextEnabled
	self.padEnabled   = self.defaultPadEnabled
	self.brake   	  = self.defaultBrakeEnabled
	self.strength	  = self.defaultStrength
	self.windowOpen   = false
	self.delta        = 0

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.name = "Нажмите "
		self.nameTw = "или LB "
		self.nameTh = "для супер-ускорения. "
		self.nameFo = "Нажмите F для мгновенной заморозки."
	end

	self.boats = {
		[5] = true, [6] = true, [16] = true, [19] = true,
		[25] = true, [27] = true, [28] = true, [38] = true,
		[45] = true, [50] = true, [53] = true, [69] = true,
		[80] = true, [88] = true
		}
	self.helis = {
		[3] = true, [14] = true, [37] = true, [57] = true,
		[62] = true, [64] = true, [65] = true, [67] = true
		}
	self.planes = {
		[24] = true, [30] = true, [34] = true, [39] = true,
		[51] = true, [59] = true, [81] = true, [85] = true
		}
		
	self.settingSub = Network:Subscribe( "UpdateSettings", self, self.UpdateSettings )

	if LocalPlayer:InVehicle() then
		self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
		self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
end

function Boost:Lang()
	self.name = "Press "
	self.nameTw = "or LB "
	self.nameTh = "to boost. "
	self.nameFo = "Press F to brake."
end

function Boost:UpdateSettings( settings )
	Network:Unsubscribe( self.settingSub )

	self.settingSub = nil

	if settings then
		for setting, value in pairs(settings) do
			self[setting] = ( setting == "strength" ) and value or value == 1
		end
	end

	self.window = Window.Create()
	self.window:SetSize( Vector2( 250, 240 ) )
	self.window:SetTitle( "Настройки супер-ускорения" )
	self.window:SetVisible( false )
	self.window:Subscribe( "WindowClosed", function() self:SetWindowOpen( false ) end )
	self:ResolutionChange()

	self:AddSetting( "Супер-ускорение для машин", "landBoost", self.landBoost, self.defaultLandBoost )
	self:AddSetting( "Супер-ускорение для лодок", "boatBoost", self.boatBoost, self.defaultBoatBoost )
	self:AddSetting( "Супер-ускорение для вертолётов", "heliBoost", self.heliBoost, self.defaultHeliBoost )
	self:AddSetting( "Супер-ускорение для самолётов", "planeBoost", self.planeBoost, self.defaultPlaneBoost )
	self:AddSetting( "Показывать подсказку", "textEnabled", self.textEnabled, self.defaultTextEnabled )
	self:AddSetting( "Разрешить использование геймпада", "padEnabled", self.padEnabled, self.defaultPadEnabled )
	self:AddSetting( "Мгновенная заморозка", "brake", self.brake, self.defaultBrakeEnabled )

	local strength_text = Label.Create( self.window )
	strength_text:SetSize( Vector2( 160, 32 ) )
	strength_text:SetDock( GwenPosition.Top )
	strength_text:SetText( "Сила разгона" )
	strength_text:SetAlignment( GwenPosition.CenterV )

	local strength_numeric = Numeric.Create( self.window )
	strength_numeric:SetSize( Vector2( 160, 32 ) )
	strength_numeric:SetDock( GwenPosition.Top )
	strength_numeric:SetRange( 10, 100 )
	strength_numeric:SetValue( self.strength )
	strength_numeric:Subscribe( "Changed", function()
		self.strength = strength_numeric:GetValue()
		Network:Send( "ChangeSetting", { setting = "strength", value = strength_numeric:GetValue() } )
	end )

	Events:Subscribe( "BoostSettings", self, self.BoostSettings )
	Events:Subscribe( "ResolutionChange", self, self.ResolutionChange )
end

function Boost:GetWindowOpen()
	return self.windowOpen
end

function Boost:SetWindowOpen( state )
	self.windowOpen = state
	self.window:SetVisible( state )
	Mouse:SetVisible( state )
end

function Boost:BoostSettings()
	self:SetWindowOpen( not self:GetWindowOpen() )
	return false
end

function Boost:LocalPlayerInput( args )
	if Game:GetState() ~= GUIState.Game then return end
	if self.windowOpen then return false end

	if self.padEnabled and args.input == self.controllerAction and LocalPlayer:GetWorld() == DefaultWorld and Game:GetSetting(GameSetting.GamepadInUse) == 1 then
		local vehicle = LocalPlayer:GetVehicle()
		if IsValid(vehicle) and vehicle:GetDriver() == LocalPlayer and (self:LandCheck(vehicle) or self:BoatCheck(vehicle) or self:HeliCheck(vehicle) or self:PlaneCheck(vehicle)) then
			self:Boost(vehicle)
		end
	end
end

function Boost:Render( args )
	local alpha = 255

	if self.hinttimer and self.hinttimer:GetSeconds() > 12 then
		alpha = math.clamp( 255 - ( ( self.hinttimer:GetSeconds() - 12 ) * 500 ), 0, 255 )

		if self.hinttimer:GetSeconds() > 14 then
			self.hinttimer = nil
		end
	end

	if not LocalPlayer:GetValue( "Boost" ) then return end
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	local vehicle = LocalPlayer:GetVehicle()
	if not IsValid( vehicle ) then return end
	if vehicle:GetDriver() ~= LocalPlayer then return end

	self.delta  = args.delta
	local land  = self:LandCheck(vehicle)
	local boat  = self:BoatCheck(vehicle)
	local heli  = self:HeliCheck(vehicle)
	local plane = self:PlaneCheck(vehicle)

	if not LocalPlayer:GetValue( "VehBrake" ) and not LocalPlayer:GetValue( "Freeze" ) then
		if land or boat then
			if Key:IsDown(160) then -- LShift
				self:Boost( vehicle )
			end
		elseif heli or plane then
			if Key:IsDown(81) then -- Q
				self:Boost( vehicle )
			end
		end
	end

	if self.brake and not LocalPlayer:GetValue( "Freeze" )then
		if Key:IsDown(70) then -- F
			if not LocalPlayer:GetValue( "VehBrake" ) then
				LocalPlayer:SetValue( "VehBrake", true )
			end
			vehicle:SetLinearVelocity( Vector3.Zero )
			self.vpos = self.vpos or vehicle:GetPosition()
			vehicle:SetPosition( self.vpos )
		else
			if LocalPlayer:GetValue( "VehBrake" ) then
				LocalPlayer:SetValue( "VehBrake", nil )
			end
			self.vpos = nil
		end
	end

	if Game:GetState() ~= GUIState.Game or LocalPlayer:GetValue( "HiddenHUD" ) then return end
	if not self.hinttimer then return end
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	if self.textEnabled and (land or boat or heli or plane) then
		local text = self.name
		if land or boat then
			text = text .. "Shift "
		elseif heli or plane then
			text = text .. "Q "
		end
		if self.padEnabled then
			text = text .. self.nameTw
		end
		text = text .. self.nameTh
		if self.brake then
			text = text .. self.nameFo
		end

		local size = Render:GetTextSize( text, 15 )
		local pos = Vector2( ( Render.Width - size.x ) / 2, Render.Height - size.y - 10 )

		Render:DrawShadowedText( pos, text, Color( 255, 255, 255, alpha ), Color( 0, 0, 0, alpha ), 15 )
	end
end

function Boost:ResolutionChange()
	self.window:SetPositionRel( Vector2( 0.5, 0.5 ) - self.window:GetSizeRel() / 2 )
end

function Boost:AddSetting( text, setting, value, default )
	local checkBox = LabeledCheckBox.Create( self.window )
	checkBox:SetSize( Vector2( 200, 20 ) )
	checkBox:SetDock( GwenPosition.Top )
	checkBox:GetLabel():SetText( text )
	checkBox:GetCheckBox():SetChecked( value )
	checkBox:GetCheckBox():Subscribe( "CheckChanged", function(box)
		self:UpdateSetting( setting, box:GetChecked(), default )
	end )
end

function Boost:UpdateSetting( setting, value, default )
	self[setting] = value

	-- Translate for DB
	if value == default then
		value = nil
	else
		value = value and 1 or 0
	end

	Network:Send( "ChangeSetting", { setting = setting, value = value } )
end

function Boost:Boost( vehicle )
	vehicle:SetLinearVelocity( vehicle:GetLinearVelocity() + vehicle:GetAngle() * Vector3( 0, 0, - self.strength * self.delta ) )
end

function Boost:LandCheck( vehicle )
	local id = vehicle:GetModelId()

	if not LocalPlayer:GetValue( "Boost" ) then return end
	if LocalPlayer:GetValue( "Boost" ) >= 1 then
		return self.landBoost and not self.boats[id] and not self.helis[id] and not self.planes[id]
	end
end

function Boost:BoatCheck( vehicle )
	if not LocalPlayer:GetValue( "Boost" ) then return end
	if LocalPlayer:GetValue( "Boost" ) >= 2 then
		return self.boatBoost and self.boats[vehicle:GetModelId()]
	end
end

function Boost:HeliCheck( vehicle )
	if not LocalPlayer:GetValue( "Boost" ) then return end
	if LocalPlayer:GetValue( "Boost" ) >= 3 then
		return self.heliBoost and self.helis[vehicle:GetModelId()]
	end
end

function Boost:PlaneCheck( vehicle )
	if not LocalPlayer:GetValue( "Boost" ) then return end
	if LocalPlayer:GetValue( "Boost" ) >= 3 then
		return self.planeBoost and self.planes[vehicle:GetModelId()]
	end
end

function Boost:LocalPlayerEnterVehicle( args )
	if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
	if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end

	if not self.hinttimer then
		self.hinttimer = Timer()
	else
		self.hinttimer:Restart()
	end
end

function Boost:LocalPlayerExitVehicle()
	LocalPlayer:SetValue( "VehBrake", nil )

	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
end

boost = Boost()