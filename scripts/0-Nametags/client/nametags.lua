class 'Nametags'

function Nametags:__init()
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
	self.player_enabled = true
	self.playerClanTag_enabled = true
	self.vehicle_enabled = false

	self.player_limit = 500
	self.vehicle_limit = 500
	self:UpdateLimits()

	self.zero_health = Color( 255, 0, 0 )
	self.full_health = Color( 20, 220, 20 )
	self.passiveColor = Color( 0, 250, 154 )

	self.size = TextSize.Default

	self:CreateSettings()

	self.visible = LocalPlayer:GetValue( "TagHide" )
	self.animationValue = self.visible and 1 or 0

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.name = "Мирный"
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "NetworkObjectValueChange", self, self.NetworkObjectValueChange )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "OpenNametagsMenu", self, self.Active )
end

function Nametags:Lang()
	self.name = "Passive"
end

function Nametags:UpdateLimits()
	self.player_bias	= self.player_limit / 10
	self.player_max		= self.player_limit * 1.5
	self.vehicle_bias	= self.vehicle_limit / 10
	self.vehicle_max	= self.vehicle_limit * 1.5
end

function Nametags:CreateSettings()
	self.window_open = false

	self.window = Window.Create()
	self.window:SetSize( Vector2( 200, 246 ) )
	self.window:SetPosition( ( Render.Size - self.window:GetSize() ) / 2 )
	self.window:SetTitle( "Настройка тегов" )
	self.window:SetVisible( self.window_open )
	self.window:Subscribe( "WindowClosed", self, self.WindowClosed )

	local enabled_checkbox = LabeledCheckBox.Create( self.window )
	enabled_checkbox:SetSize( Vector2( 320, 20 ) )
	enabled_checkbox:SetDock( GwenPosition.Top )
	enabled_checkbox:GetLabel():SetText( "Включено" )
	enabled_checkbox:GetCheckBox():SetChecked( self.enabled )
	enabled_checkbox:GetCheckBox():Subscribe( "CheckChanged", function() self.enabled = enabled_checkbox:GetCheckBox():GetChecked() end )

	local player_checkbox = LabeledCheckBox.Create( self.window )
	player_checkbox:SetSize( Vector2( 320, 20 ) )
	player_checkbox:SetDock( GwenPosition.Top )
	player_checkbox:GetLabel():SetText( "Теги игроков" )
	player_checkbox:GetCheckBox():SetChecked( self.player_enabled )
	player_checkbox:GetCheckBox():Subscribe( "CheckChanged", function() self.player_enabled = player_checkbox:GetCheckBox():GetChecked() end )

	local playerClanTag_checkbox = LabeledCheckBox.Create( self.window )
	playerClanTag_checkbox:SetSize( Vector2( 320, 20 ) )
	playerClanTag_checkbox:SetDock( GwenPosition.Top )
	playerClanTag_checkbox:GetLabel():SetText( "Теги кланов" )
	playerClanTag_checkbox:GetCheckBox():SetChecked( self.player_enabled )
	playerClanTag_checkbox:GetCheckBox():Subscribe( "CheckChanged", function() self.playerClanTag_enabled = playerClanTag_checkbox:GetCheckBox():GetChecked() end )

	local vehicle_checkbox = LabeledCheckBox.Create( self.window )
	vehicle_checkbox:SetSize( Vector2( 320, 20 ) )
	vehicle_checkbox:SetDock( GwenPosition.Top )
	vehicle_checkbox:GetLabel():SetText( "Названия транспорта" )
	vehicle_checkbox:GetCheckBox():SetChecked( self.vehicle_enabled )
	vehicle_checkbox:GetCheckBox():Subscribe( "CheckChanged", function() self.vehicle_enabled = vehicle_checkbox:GetCheckBox():GetChecked() end )

	local player_text = Label.Create( self.window )
	player_text:SetSize( Vector2( 160, 32 ) )
	player_text:SetDock( GwenPosition.Top )
	player_text:SetText( "Расстояние игрока (м)" )
	player_text:SetAlignment( GwenPosition.CenterV )

	local player_numeric = Numeric.Create( self.window )
	player_numeric:SetSize( Vector2( 160, 32 ) )
	player_numeric:SetDock( GwenPosition.Top )
	player_numeric:SetRange( 0, 500 )
	player_numeric:SetValue( self.player_limit )
	player_numeric:Subscribe( "Changed", function() self.player_limit = player_numeric:GetValue() self:UpdateLimits() end )

	local vehicle_text = Label.Create( self.window )
	vehicle_text:SetSize( Vector2( 160, 32 ) )
	vehicle_text:SetDock( GwenPosition.Top )
	vehicle_text:SetText( "Расстояние до транспорта (м)" )
	vehicle_text:SetAlignment( GwenPosition.CenterV )

	local vehicle_numeric = Numeric.Create( self.window )
	vehicle_numeric:SetSize( Vector2( 160, 32 ) )
	vehicle_numeric:SetDock( GwenPosition.Top )
	vehicle_numeric:SetRange( 0, 500 )
	vehicle_numeric:SetValue( self.vehicle_limit )
	vehicle_numeric:Subscribe( "Changed", function() self.vehicle_limit = vehicle_numeric:GetValue() self:UpdateLimits() end )
end

function Nametags:GetWindowOpen()
	return self.window_open
end

function Nametags:SetWindowOpen( state )
	self.window_open = state
	self.window:SetVisible( self.window_open )
	Mouse:SetVisible( self.window_open )
end

-- Determines whether the following position is being aimed at
function Nametags:AimingAt( pos )
	local cam_pos   = Camera:GetPosition()
	local cam_dir   = Camera:GetAngle() * Vector3( 0, 0, -1 )

	local pos_dir   = (pos - cam_pos):Normalized()
	local diff      = (pos_dir - cam_dir):LengthSqr()

	return diff
end

-- Wrapper function that draws things with the right alpha and scale
function Nametags:DrawText( pos, text, colour, scale, alpha )
	local col = colour
	col.a = alpha

	Render:DrawText( pos, text, col, self.size, scale )
end

-- Similar to Nametags:DrawText, but a shadowed variant
function Nametags:DrawShadowedText( pos, text, colour, scale, alpha )
	local col = colour
	col.a = alpha

	Render:DrawShadowedText( pos, text, col, Color( 0, 0, 0, alpha * 0.6 ), self.size, scale )
end

-- Calculates the alpha for a given distance, bias, maximum and limit
function Nametags:CalculateAlpha( dist, bias, max, limit )
	if dist > limit then return nil end

	local alpha = 1

	if dist > bias then
		alpha =  1.0 - ( dist - bias ) /
					   ( max  - bias )
	end

	return alpha
end

-- Used to draw the health bar
function Nametags:DrawHealthbar( pos_2d, scale, width, height, health, min, max, alpha )
	-- Calculate an intermediate colour based on health
	local col = math.lerp( min, max, health )
	col.a = alpha

	-- Draw the background
	Render:FillArea( pos_2d - Vector2.One, Vector2( width, height ) + Vector2( 2, 2 ), Color( 0, 0, 0, alpha * 0.7 ) )
	-- Draw the actual health section
	Render:FillArea( pos_2d - Vector2.One, Vector2( width * health, height ) + Vector2( 2, 2 ), Color( 0, 0, 0, alpha ) )
	Render:FillArea( pos_2d, Vector2( width * health, height ), col )
end

function Nametags:DrawNametag( pos_3d, player, colour, scale, alpha, health, draw_healthbar )
	-- Calculate the 2D position on-screen from the 3D position
	local pos_2d, success = Render:WorldToScreen( pos_3d )
	local text = player:GetName()

	-- If we succeeded, continue to draw
	if success then
		local width = Render:GetTextWidth( text, self.size, scale )
		local height = Render:GetTextHeight( text, self.size, scale )

		-- Subtract half of the text size from both axis' so that the text is
		-- centered
		pos_2d = pos_2d - Vector2( width, height ) / 2

		-- Draw the name
		self:DrawShadowedText( pos_2d, text, colour, scale, alpha )

		if health then
			if draw_healthbar and scale > 0.75 and health > 0 then
				-- Move the draw position down
				pos_2d.y = pos_2d.y + height + 2

				local actual_width = 40

				local offset = ( actual_width - width ) / 2

				pos_2d.x = pos_2d.x - offset

				self:DrawHealthbar( pos_2d, scale, actual_width, 4 * scale, health, self.zero_health, self.full_health, alpha )
			end
		else
			-- Move the draw position down
			pos_2d.y = pos_2d.y - height - 2

			local actual_width = Render:GetTextWidth( self.name, self.size, scale )

			local offset = ( actual_width - width ) / 2

			pos_2d.x = pos_2d.x - offset
			self:DrawShadowedText( pos_2d, self.name, self.passiveColor, scale, alpha )
		end

		if self.playerClanTag_enabled and player:GetValue( "ClanTag" ) then
			local text = "[" .. player:GetValue( "ClanTag" ) .. "]"

			local width = Render:GetTextWidth( text, self.size, scale )
			local height = Render:GetTextHeight( text, self.size, scale )

			pos_2d = Render:WorldToScreen( pos_3d ) - Vector2( width, height ) / 2
			
			pos_2d.y = pos_2d.y - height * ( health and 1.5 or 2.5 )

			self:DrawShadowedText( pos_2d, text, player:GetValue( "ClanColor" ), scale, alpha )
		end
	end
end

function Nametags:DrawCircle( pos_3d, scale, alpha, colour )
	local radius = 6
	local shadow_radius = radius + 1
	local pos_2d, success = Render:WorldToScreen( pos_3d )
	if not success then return end

	radius = radius * scale
	shadow_radius = shadow_radius * scale

	colour.a = colour.a * alpha
	local shadow_colour = Color( 0, 0, 0, 255 * alpha )

	Render:FillCircle( pos_2d, shadow_radius, shadow_colour )
	Render:FillCircle( pos_2d, radius, colour )
end

function Nametags:DrawFullTag( pos, name, dist, colour, health )
	 -- Calculate the alpha for the player nametag
	local scale = Nametags:CalculateAlpha( dist, self.player_bias, self.player_max, self.player_limit )

	-- Make sure we're supposed to draw
	if not scale then return end

	local alpha = scale * 255

	-- Draw the player nametag!
	self:DrawNametag( pos, name, colour, scale, alpha, health, true )
end

function Nametags:DrawCircleTag( pos, dist, colour )
	local scale = math.lerp( 1, 0, math.clamp( 1, 0, dist/self.player_limit ) )

	-- Make sure we're supposed to draw
	if not scale then return end

	self:DrawCircle( pos, scale, scale, colour )
end

function Nametags:DrawPlayer( player_data )
	local p         = player_data[1]
	local dist      = player_data[2]

	local pos       = p:GetBonePosition( "ragdoll_Head" ) + ( p:GetAngle() * Vector3( 0, 0.3, 0 ) )

	local colour    = p:GetColor()
	if not p:GetValue( "TagHide" ) then
		if self.player_count <= 20 then
			local pVehicle = p:GetVehicle()

			if self:AimingAt( pos ) < 0.1 or (LocalPlayer:InVehicle() and pVehicle == LocalPlayer:GetVehicle()) or self.player_count <= 10 then
				if p:GetState() == PlayerState.InVehicle and pVehicle then
					self.full_health = Color( 255, 200, 100 )
					self:DrawFullTag( pos, p, dist, colour, not ( p:GetValue( "Passive" ) or p:GetValue( "FreecamEnabled" ) ) and pVehicle:GetHealth() )
				else
					self.full_health = Color( 20, 220, 20 )
					self:DrawFullTag( pos, p, dist, colour, not ( p:GetValue( "Passive" ) or p:GetValue( "FreecamEnabled" ) ) and p:GetHealth() )
				end
			elseif not (IsValid(self.highlighted_vehicle) and p:InVehicle() and self.highlighted_vehicle == pVehicle) then
				self:DrawCircleTag( pos, dist, colour )
			end
		else
			if self:AimingAt( pos ) < 0.005 then
				self:DrawFullTag( pos, p, dist, colour, p:GetHealth() )
			else
				self:DrawCircleTag( pos, dist, colour )
			end
		end
	end
end

function Nametags:DrawVehicle( vehicle_data )
	local v             = vehicle_data[1]
	local dist          = vehicle_data[2]
	local aim_dist      = vehicle_data[3]

	-- Get the first colour of the vehicle
	local colour = v:GetColors()

	-- Use a 30% blend of white and the vehicle colour to give a nice
	-- colour with a tinge that corresponds to the vehicle
	colour = math.lerp( Color( 200, 200, 200 ), colour, 0.3 )

	-- Calculate the alpha for the vehicle nametag
	local scale = Nametags:CalculateAlpha( dist, self.vehicle_bias, self.vehicle_max, self.vehicle_limit )

	-- Make sure we're supposed to draw
	if scale ~= nil then
		-- Factor of aim distance from vehicle used to fade in
		local alpha = scale * 255 * (1.0 - (aim_dist * 10))

		-- Draw the vehicle nametag!
		self:DrawNametag( v:GetPosition() + Vector3( 0, 1, 0 ), v, colour, scale, alpha, v:GetHealth(), false )
	end
end

function Nametags:LocalPlayerInput( args )
	if self:GetWindowOpen() and Game:GetState() == GUIState.Game then
		if self.actions[args.input] then
			return false
		end
	end
end

function Nametags:WindowClosed()
	self:SetWindowOpen( false )
end

function Nametags:NetworkObjectValueChange( args )
	if args.key == "TagHide" and args.object.__type == "LocalPlayer" then
		if args.value then
			self.visible = true

			if self.fadeOutAnimation then Animation:Stop( self.fadeOutAnimation ) self.fadeOutAnimation = nil end
			Animation:Play( 0, 1, 0.05, easeIOnut, function( value ) self.animationValue = value end )
		else
			self.fadeOutAnimation = Animation:Play( self.animationValue, 0, 0.05, easeIOnut, function( value ) self.animationValue = value end, function() self.visible = nil end )
		end
	end
end

function Nametags:Render()
	-- If we're not supposed to draw now, then take us out
	if not self.enabled or Game:GetState() ~= GUIState.Game or LocalPlayer:GetValue( "HiddenHUD" ) then return end

	if LocalPlayer:GetValue( "SystemFonts" ) then Render:SetFont( AssetLocation.SystemFont, "Impact" ) end

	if self.visible then
		local text = "/hidetag"
		local text_size = 18
		local text_width = Render:GetTextWidth( text, text_size )
		local text_height = Render:GetTextHeight( text, text_size )
		local posY = math.lerp( -text_height - 2, 0, self.animationValue )
		local text_pos = Vector2( Render.Width / 4 - text_width / 1.8 + text_width / 15, posY + 2 )
		local sett_alpha = math.lerp( 0, Game:GetSetting(4) * 2.25, self.animationValue )
		local background_clr = Color( 0, 0, 0, sett_alpha / 2.4 )

		Render:FillArea( Vector2( Render.Width / 4 - text_width / 1.8, 0 ), Vector2( text_width + 5, text_height + 2 ), background_clr )

		Render:FillTriangle( Vector2( ( Render.Width / 4 - text_width / 1.8 - 10 ), posY ), Vector2( ( Render.Width / 4 - text_width / 1.8 ), posY ), Vector2( (Render.Width / 4 - text_width / 1.8 ), text_height + 2 ), background_clr )
		Render:FillTriangle( Vector2( ( Render.Width / 4 - text_width / 1.8 + text_width + 15 ), posY ), Vector2( ( Render.Width / 4 - text_width / 1.8 + text_width + 5 ), posY ), Vector2( ( Render.Width / 4 - text_width / 1.8 + text_width + 5 ), text_height + 2 ), background_clr )

		Render:DrawShadowedText( text_pos, text, Color( 185, 215, 255, sett_alpha ), Color( 0, 0, 0, sett_alpha ), text_size )
	end

	-- Create some prerequisite variables
	local local_pos = Camera:GetPosition()

	self.highlighted_vehicle = nil

	if self.vehicle_enabled then
		local sorted_vehicles = {}

		for v in Client:GetVehicles() do
			if IsValid(v) then
				local pos = v:GetPosition()
				table.insert( sorted_vehicles, 
					{ v, local_pos:Distance(pos), self:AimingAt(v:GetPosition()) } )
			end
		end

		-- Sort by distance from aim, and distance from player, descending
		table.sort( sorted_vehicles, 
			function( a, b ) 
				local aim1 = a[3] * 5000
				local aim2 = b[3] * 5000
				local dist1 = a[2]
				local dist2 = b[2]

				return (aim1 + dist1) < (aim2 + dist2)
			end )

		if #sorted_vehicles > 0 then
			local vehicle_data  = sorted_vehicles[1]
			local vehicle       = vehicle_data[1]
			local aim_dist      = vehicle_data[3]

			if LocalPlayer:GetVehicle() ~= vehicle and #vehicle:GetOccupants() == 0 and aim_dist < 0.1 then
				self:DrawVehicle( vehicle_data )
				self.highlighted_vehicle = vehicle
			end
		end
	end

	if self.player_enabled and not LocalPlayer:GetValue( "SpectatorMode" ) and LocalPlayer:GetValue( "SpectatorMode" ) ~= 2 then
		local sorted_players = {}

		for p in Client:GetStreamedPlayers() do
			local pos = p:GetPosition()
			table.insert( sorted_players, { p, local_pos:Distance(pos) } )
		end

		-- Sort by distance, descending
		table.sort( sorted_players, 
			function( a, b ) 
				return (a[2] > b[2]) 
			end )

		self.player_count = #sorted_players

		for _, player_data in ipairs( sorted_players ) do
			self:DrawPlayer( player_data )
		end
	end
end

function Nametags:Active()
	self:SetWindowOpen( not self:GetWindowOpen() )
end

script = Nametags()