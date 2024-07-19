class 'Speedometer'

function Speedometer:__init()
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

	self.enabled = true
	self.peredacha = false
	self.bottom_aligned = false
	self.center_aligned = false
	self.speedFill = true
	self.unit = 1
	self.position = LocalPlayer:GetPosition()

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.name = "м/с"
		self.nameTw = "км/ч"
		self.nameTh = "миль"
	end

	self.speedScale = 120
	self.speedFactor = 3.6

	self:CreateSettings()
	self.speed_text_size = TextSize.Gigantic
	self.unit_text_size = TextSize.Huge

	self.bHealth = Color( 100, 100, 100 )
	self.zHealth = Color( 255, 150, 150 )
	self.fHealth = Color( 255, 140, 50 )
	self.text_shadow = Color( 0, 0, 0, 100 )

	if LocalPlayer:InVehicle() then
		self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
		self.GameRenderEvent = Events:Subscribe( "Render", self, self.GameRender )
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "PreTick", self, self.PreTick )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )

	Events:Subscribe( "LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
	Events:Subscribe( "OpenSpeedometerMenu", self, self.Active )
end

function Speedometer:LocalPlayerEnterVehicle()
	if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
	if not self.GameRenderEvent then self.GameRenderEvent = Events:Subscribe( "Render", self, self.GameRender ) end
end

function Speedometer:LocalPlayerExitVehicle()
	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	if self.GameRenderEvent then Events:Unsubscribe( self.GameRenderEvent ) self.GameRenderEvent = nil end
end

function Speedometer:Lang()
	self.name = "m/s"
	self.nameTw = "km/h"
	self.nameTh = "mph"
end

function Speedometer:CreateSettings()
	self.window_open = false

	self.window = Window.Create()
	self.window:SetSize( Vector2( 300, 135 ) )
	self.window:SetPosition( (Render.Size - self.window:GetSize())/2 )

	self.window:SetTitle( "Настройка спидометра" )
	self.window:SetVisible( self.window_open )
	self.window:Subscribe( "WindowClosed", self, self.WindowClosed )

	self.widgets = {}

	local enabled_checkbox = LabeledCheckBox.Create( self.window )
	local peredacha_checkbox = LabeledCheckBox.Create( self.window )
	local bottom_checkbox = LabeledCheckBox.Create( self.window )
	local center_checkbox = LabeledCheckBox.Create( self.window )

	enabled_checkbox:SetSize( Vector2( 300, 20 ) )
	enabled_checkbox:SetDock( GwenPosition.Top )
	enabled_checkbox:GetLabel():SetText( "Включено" )
	enabled_checkbox:GetCheckBox():SetChecked( self.enabled )
	enabled_checkbox:GetCheckBox():Subscribe( "CheckChanged", 
		function() self.enabled = enabled_checkbox:GetCheckBox():GetChecked() end )
	
	peredacha_checkbox:SetSize( Vector2( 300, 20 ) )
	peredacha_checkbox:SetDock( GwenPosition.Top )
	peredacha_checkbox:GetLabel():SetText( "Показывать передачу" )
	peredacha_checkbox:GetCheckBox():SetChecked( self.peredacha )
	peredacha_checkbox:GetCheckBox():Subscribe( "CheckChanged", 
		function() self.peredacha = peredacha_checkbox:GetCheckBox():GetChecked() end )

	bottom_checkbox:SetSize( Vector2( 300, 20 ) )
	bottom_checkbox:SetDock( GwenPosition.Top )
	bottom_checkbox:GetLabel():SetText( "Экранный режим" )
	bottom_checkbox:GetCheckBox():SetChecked( self.bottom_aligned )
	bottom_checkbox:GetCheckBox():Subscribe( "CheckChanged", 
		function()
			self.bottom_aligned = bottom_checkbox:GetCheckBox():GetChecked()

			if self.bottom_aligned then
				self.speed_text_size = TextSize.VeryLarge
				self.unit_text_size = TextSize.Large
			else
				self.speed_text_size = TextSize.Gigantic
				self.unit_text_size = TextSize.Huge
			end

			if self.bottom_aligned then
				center_checkbox:GetCheckBox():SetChecked( false )
			end
		end
	)

	center_checkbox:SetSize( Vector2( 300, 20 ) )
	center_checkbox:SetDock( GwenPosition.Top )
	center_checkbox:GetLabel():SetText( "Режим от 1-го лица" )
	center_checkbox:GetCheckBox():SetChecked( self.center_aligned )
	center_checkbox:GetCheckBox():Subscribe( "CheckChanged", 
		function()
			self.center_aligned = center_checkbox:GetCheckBox():GetChecked()

			if self.center_aligned then
				bottom_checkbox:GetCheckBox():SetChecked( false )
			end
		end
	)

   local rbc = RadioButtonController.Create( self.window )
	rbc:SetSize( Vector2( 300, 20 ) )
	rbc:SetDock( GwenPosition.Top )

	local units = { self.name, self.nameTw, self.nameTh }
	for i, v in ipairs( units ) do
		local option = rbc:AddOption( v )
		option:SetSize( Vector2( 100, 20 ) )
		option:SetDock( GwenPosition.Left )

		if i-1 == self.unit then
			option:Select()
		end

		option:GetRadioButton():Subscribe( "Checked",
			function()
				self.unit = i-1
			end )
	end
end

function Speedometer:GetWindowOpen()
	return self.window_open
end

function Speedometer:SetWindowOpen( state )
	self.window_open = state
	self.window:SetVisible( self.window_open )
	Mouse:SetVisible( self.window_open )
end

function Speedometer:GetSpeed( vehicle )
	local speed = vehicle:GetLinearVelocity():Length()

	if self.unit == 0 then
		return speed
	elseif self.unit == 1 then
		return speed * 3.6
	elseif self.unit == 2 then
		return speed * 2.237
	end
end

function Speedometer:GetUnitString()
	if self.unit == 0 then
		return self.name
	elseif self.unit == 1 then
		return self.nameTw
	elseif self.unit == 2 then
		return self.nameTh
	end
end

function Speedometer:DrawShadowedText3( pos, text, colour, size, scale )
	if not scale then scale = 1.0 end
	if not size then size = TextSize.Default end

	local shadow_colour = Color( 0, 0, 0, 150 )
	shadow_colour = shadow_colour * 0.4

	Render:DrawText( pos + Vector3( 5, 5, 3 ), text, shadow_colour, size, scale )
	Render:DrawText( pos, text, colour, size, scale )
end

function Speedometer:DrawShadowedText2( pos, text, colour, size, scale )
	if not scale then scale = 1.0 end
	if not size then size = TextSize.Default end

	local shadow_colour = Color( 0, 0, 0, 255 )
	shadow_colour = shadow_colour * 0.4

	Render:DrawShadowedText( pos, text, colour, shadow_colour, size, scale )
end

function Speedometer:PreTick()
	if LocalPlayer:InVehicle() then
		self.position = LocalPlayer:GetPosition()
	end
end

function Speedometer:Render()
	if Game:GetState() ~= GUIState.Game or not self.enabled or LocalPlayer:GetValue( "HiddenHUD" ) then return end
	if not self.bottom_aligned then return end
	if not LocalPlayer:InVehicle() then return end
	Render:SetFont( AssetLocation.Disk, "Archivo.ttf" )

	local vehicle = LocalPlayer:GetVehicle()

	local speed = self:GetSpeed( vehicle )
	local speed_text = string.format( "%.f", speed )
	local speed_size = Render:GetTextSize( speed_text, self.speed_text_size )

	local vehicleVelocity = -vehicle:GetAngle() * vehicle:GetLinearVelocity()
	local currentGear = vehicle:GetTransmission():GetGear()

	local gearString = "1"

	if self.peredacha then
		if currentGear >= 4 then        
			gearString = tostring(currentGear)
		elseif currentGear == 3 then
			gearString= "3"
		elseif vehicle:GetTransmission():GetGear() == 2 then
			gearString = "2"
		elseif vehicleVelocity.z > 1 then
			gearString = "R"
		end
	end

	local unit_text = self:GetUnitString()
	local unit_size = Render:GetTextSize( unit_text, self.unit_text_size )
	local angle = vehicle:GetAngle() * Angle( math.pi, 0, math.pi )

	local factor = math.clamp( vehicle:GetHealth() - 0.4, 0.0, 0.6 ) * 2.5

	local col = math.lerp( LocalPlayer:GetValue( "VehBrake" ) and self.bHealth or self.zHealth, LocalPlayer:GetValue( "VehBrake" ) and self.bHealth or self.fHealth, factor )
	local textcol = col

	local text_col = Color.White
	local text_size = speed_size + Vector2( unit_size.x + 16, 0 )

	local speed_position = Vector2( Render.Width / 2, Render.Height )

	speed_position.y = speed_position.y - (speed_size.y + 40)
	speed_position.x = speed_position.x - (text_size.x / 2)

	local unit_position = Vector2()

	unit_position.x = speed_position.x + speed_size.x + 10
	unit_position.y = speed_position.y + (( speed_size.y - unit_size.y ) / 2)

	self:DrawShadowedText2( speed_position, speed_text, textcol, self.speed_text_size )
	self:DrawShadowedText2( unit_position, unit_text, text_col, self.unit_text_size )

	local bar_len = 300
	local bar_start = (Render.Width - bar_len) / 2

	local bar_pos = Vector2( bar_start, speed_position.y + text_size.y )
	local final_pos = Vector2( bar_len, 6 )
	if self.peredacha then
		self:DrawShadowedText2( bar_pos - Vector2( 30, 20 ), gearString, text_col, self.unit_text_size )
	end

	bar_len = bar_len * vehicle:GetHealth()
	Render:FillArea( bar_pos, final_pos, self.text_shadow )
	Render:FillArea( bar_pos, Vector2(bar_len, 5), col)
end

function Speedometer:GameRender()
	if Game:GetState() ~= GUIState.Game or not self.enabled or LocalPlayer:GetValue( "HiddenHUD" ) then return end
	if self.bottom_aligned then return end
	if not LocalPlayer:InVehicle() then return end
	Render:SetFont( AssetLocation.Disk, "Archivo.ttf" )

	local vehicle = LocalPlayer:GetVehicle()

	local speed = self:GetSpeed( vehicle )
	local speed_text = string.format( "%.f", speed )
	local speed_size = Render:GetTextSize( speed_text, self.speed_text_size )

	local vehicleVelocity = -vehicle:GetAngle() * vehicle:GetLinearVelocity()
	local currentGear = vehicle:GetTransmission():GetGear()

	local gearString = "1"

	if self.peredacha then
		if currentGear >= 4 then        
			gearString = tostring(currentGear)
		elseif currentGear == 3 then
			gearString= "3"
		elseif vehicle:GetTransmission():GetGear() == 2 then
			gearString = "2"
		elseif vehicleVelocity.z > 1 then
			gearString = "R"
		end
	end

	local unit_text = self:GetUnitString()
	local unit_size = Render:GetTextSize( unit_text, self.unit_text_size )
	local angle = vehicle:GetAngle() * Angle( math.pi, 0, math.pi )

	local factor = math.clamp( vehicle:GetHealth() - 0.4, 0.0, 0.6 ) * 2.5

	local col = math.lerp( LocalPlayer:GetValue( "VehBrake" ) and self.bHealth or self.zHealth, LocalPlayer:GetValue( "VehBrake" ) and self.bHealth or self.fHealth, factor )
	local textcol = col

	local text_col = Color.White
	local text_size = speed_size + Vector2( unit_size.x + 24, 0 )

	local t = Transform3()

	if self.center_aligned then
		local pos_3d = vehicle:GetPosition()
		pos_3d.y = LocalPlayer:GetBonePosition( "ragdoll_Head" ).y

		local scale = 1

		t:Translate( pos_3d )
		t:Scale( 0.0050 * scale )
		t:Rotate( angle )
		t:Translate( Vector3( 0, 0, 2000 ) )
		t:Translate( -Vector3( text_size.x, text_size.y, 0 )/2 )
	else
		local pos_3d = self.position
		angle = angle * Angle( -math.rad(20), 0, 0 )

		local scale = math.clamp( Camera:GetPosition():Distance( pos_3d ), 0, 500 )
		scale = scale / 20

		t = Transform3()
		t:Translate( pos_3d )
		t:Scale( 0.0050 * scale )
		t:Rotate( angle )
		t:Translate( Vector3( text_size.x + 50, text_size.y, -250 ) * -1.5 )
	end

	Render:SetTransform( t )

	self:DrawShadowedText3( Vector3( 0, 0, 0 ), speed_text, textcol, self.speed_text_size )
	self:DrawShadowedText3( Vector3( speed_size.x + 24, (speed_size.y - unit_size.y)/2, 0), unit_text, text_col, self.unit_text_size )

	local bar_pos = Vector3( 0, text_size.y + 4, 0 )
	local bar_len = text_size.x * vehicle:GetHealth()
	if self.peredacha then
		self:DrawShadowedText3( Vector3( bar_pos.x - 60, (speed_size.y - unit_size.y)/0.5, 0), gearString, text_col, self.unit_text_size )
	end

	Render:FillArea( bar_pos + Vector3( 1, 1, 4 ), Vector3( bar_len, 16, 0 ), col )
	Render:FillArea( bar_pos + Vector3( 1, 1, 3 ), Vector3( text_size.x, 20, 0 ), self.text_shadow )
	Render:FillArea( bar_pos, Vector3( bar_len, 16, 0 ), col )
end

function Speedometer:Active()
	self:SetWindowOpen( not self:GetWindowOpen() )
	return true
end

function Speedometer:LocalPlayerInput( args )
	if self:GetWindowOpen() and Game:GetState() == GUIState.Game then
		if self.actions[args.input] then
			return false
		end
	end
end

function Speedometer:WindowClosed()
	self:SetWindowOpen( false )
end

speedometer = Speedometer()