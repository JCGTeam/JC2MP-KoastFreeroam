class 'SkydivingStats'

function SkydivingStats:__init()
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
	self.unit = 1

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.name = " м/с"
		self.nameTw = " км/ч"
		self.nameTh = " миль"
		self.nameFo = " м"
		self.nameFi = " секунд"
	end

	self.flight_timer = Timer()
	self.last_state = 0

	self.average_speed = nil
	self.average_angle = nil
	self.average_distance = nil

	self.text_size = TextSize.VeryLarge
	self.x_offset = 1

	self:CreateSettings()

	self.text_clr = Color.White
	self.text_clr2 = Color.DarkGray
	self.text_shadow = Color( 0, 0, 0, 100 )

	if not LocalPlayer:InVehicle() then
		self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
	end

	Events:Subscribe( "Lang", self, self.Lang )	
	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )

	Events:Subscribe( "LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
	Events:Subscribe( "OpenSkydivingStatsMenu", self, self.Active )
end

function SkydivingStats:LocalPlayerEnterVehicle()
	if self.RenderEvent then
		Events:Unsubscribe( self.RenderEvent )
		self.RenderEvent = nil
	end
end

function SkydivingStats:LocalPlayerExitVehicle()
	if not self.RenderEvent then
		self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
	end
end

function SkydivingStats:Lang()
	self.name = " m/s"
	self.nameTw = " km/h"
	self.nameTh = " mph"
	self.nameFo = " m"
	self.nameFi = " seconds"
end

function SkydivingStats:CreateSettings()
	self.window_open = false

	self.window = Window.Create()
	self.window:SetSize( Vector2( 300, 70 ) )
	self.window:SetPosition( (Render.Size - self.window:GetSize())/2 )

	self.window:SetTitle( "Настройка спидометра" )
	self.window:SetVisible( self.window_open )
	self.window:Subscribe( "WindowClosed", function() self:SetWindowOpen( false ) end )

	self.widgets = {}

	local enabled_checkbox = LabeledCheckBox.Create( self.window )
	enabled_checkbox:SetSize( Vector2( 300, 20 ) )
	enabled_checkbox:SetDock( GwenPosition.Top )
	enabled_checkbox:GetLabel():SetText( "Включено" )
	enabled_checkbox:GetCheckBox():SetChecked( self.enabled )
	enabled_checkbox:GetCheckBox():Subscribe( "CheckChanged", 
		function() self.enabled = enabled_checkbox:GetCheckBox():GetChecked() end )

	local rbc = RadioButtonController.Create( self.window )
	rbc:SetSize( Vector2( 300, 20 ) )
	rbc:SetDock( GwenPosition.Top )

	local units = { "м/с", "км/ч", "миль" }
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

function SkydivingStats:GetWindowOpen()
	return self.window_open
end

function SkydivingStats:SetWindowOpen( state )
	self.window_open = state
	self.window:SetVisible( self.window_open )
	Mouse:SetVisible( self.window_open )
end

function SkydivingStats:GetMultiplier()
	if self.unit == 0 then
		return 1
	elseif self.unit == 1 then
		return 3.6
	elseif self.unit == 2 then
		return 2.237
	end
end

function SkydivingStats:GetUnitString()
	if self.unit == 0 then
		return self.name
	elseif self.unit == 1 then
		return self.nameTw
	elseif self.unit == 2 then
		return self.nameTh
	end
end

function SkydivingStats:DrawText( text, textTw )
	Render:DrawText( Vector3( 2, 2, 2 ), text .. textTw, self.text_shadow, self.text_size )
	Render:DrawText( Vector3.Zero, text, self.text_clr, self.text_size )
	Render:DrawText( Vector3.Zero + Vector3( Render:GetTextWidth( text, self.text_size ), 0, 0 ), textTw, self.text_clr2, self.text_size )
end

function SkydivingStats:DrawSpeedometer( t )
	local speed = LocalPlayer:GetLinearVelocity():Length()
	Render:SetFont( AssetLocation.Disk, "Archivo.ttf" )

	if self.average_speed == nil then
		self.average_speed = speed
	else
		self.average_speed = (self.average_speed + speed)/2
	end

	local text = string.format( "%.02f", speed * self:GetMultiplier(), self:GetUnitString() )
	local textTw = self.nameTw
	local text_vsize = Render:GetTextSize( text, self.text_size )
	local text_vsize_3d = Vector3( text_vsize.x, text_vsize.y, 0 )
	local ang = Camera:GetAngle()

	local right = Copy( t )
	right:Translate( Vector3( self.x_offset, -0.4, -5 ) )
	right:Rotate( Angle( math.pi - math.rad(30), 0, math.pi ) )
	right:Scale( 0.002 )

	Render:SetTransform( right )

	self:DrawText( text, textTw )
end

function SkydivingStats:DrawAngle( t )
	local angle = math.deg(LocalPlayer:GetAngle().pitch)

	if self.average_angle == nil then
		self.average_angle = angle
	else
		self.average_angle = (self.average_angle + angle)/2
	end

	local text = string.format( "%.02f", angle )
	local textTw = string.format( " \176" )
	local text_vsize = Render:GetTextSize( text, self.text_size )
	local text_vsize_3d = Vector3( text_vsize.x, text_vsize.y, 0 )
	local ang = Camera:GetAngle()

	local right = Copy( t )
	right:Translate( Vector3( self.x_offset, -0.6, -5 ) )
	right:Rotate( Angle( math.pi - math.rad(30), 0, math.pi ) )
	right:Scale( 0.002 )

	Render:SetTransform( right )

	self:DrawText( text, textTw )
end

function SkydivingStats:DrawDistance( t )
	local pos = LocalPlayer:GetBonePosition( "ragdoll_Spine" )
	local dir = LocalPlayer:GetAngle() * Vector3( 0, -1, 1 )

	local distance = pos.y - ( math.max( 200, Physics:GetTerrainHeight(pos) ) )

	local text = string.format( "%.02f", distance )
	local textTw = self.nameFo
	local text_vsize = Render:GetTextSize( text, self.text_size )
	local text_vsize_3d = Vector3( text_vsize.x, text_vsize.y, 0 )
	local ang = Camera:GetAngle()

	local right = Copy( t )
	right:Translate( Vector3( self.x_offset, -0.8, -5 ) )
	right:Rotate( Angle( math.pi - math.rad(30), 0, math.pi ) )
	right:Scale( 0.002 )

	Render:SetTransform( right )

	self:DrawText( text, textTw )
end

function SkydivingStats:DrawTimer( t )
	local text = string.format( "%.02f", self.flight_timer:GetSeconds() )
	local textTw = self.nameFi
	local text_vsize = Render:GetTextSize( text, self.text_size )
	local text_vsize_3d = Vector3( text_vsize.x, text_vsize.y, 0 )
	local ang = Camera:GetAngle()

	local right = Copy( t )
	right:Translate( Vector3( self.x_offset, -0.2, -5 ) )
	right:Rotate( Angle( math.pi - math.rad(30), 0, math.pi ) )
	right:Scale( 0.002 )

	Render:SetTransform( right )

	self:DrawText( text, textTw )
end

function SkydivingStats:Render()
	if not self.enabled or LocalPlayer:GetValue( "HiddenHUD" ) then return end
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetValue( "SpectatorMode" ) then return end

	if LocalPlayer:GetBaseState() ~= AnimationState.SSkydive and LocalPlayer:GetBaseState() ~= AnimationState.SSkydiveDash then return end

	local position = LocalPlayer:GetBonePosition( "ragdoll_Head" )

	local t = Transform3()
	t:Translate( Camera:GetPosition() )	
	t:Rotate( Camera:GetAngle() )

	self:DrawSpeedometer( t )
	self:DrawAngle( t )
	self:DrawDistance( t )
	self:DrawTimer( t )
end

function SkydivingStats:PostTick()
	if not self.enabled or LocalPlayer:GetValue( "HiddenHUD" ) then return end
	if LocalPlayer:GetBaseState() == last_bs then return end

	if not LocalPlayer:GetValue( "IsPigeonMod" ) then
		self.flight_timer:Restart()
	end
	last_bs = LocalPlayer:GetBaseState()
end

function SkydivingStats:Active()
	self:SetWindowOpen( not self:GetWindowOpen() )
end

function SkydivingStats:LocalPlayerInput( args )
	if self:GetWindowOpen() and Game:GetState() == GUIState.Game then
		if self.actions[args.input] then
			return false
		end
	end
end

skydivingstats = SkydivingStats()