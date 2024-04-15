class 'Doors'

function Doors:__init()
	self.places = {}

	self.tipDistance = 40

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.ptext = "Нажмите «L», чтобы открыть ворота крепости"
	end

	self.cooldown = 2
	self.cooltime = 0

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "GameRender", self, self.GameRender )
	Events:Subscribe( "KeyUp", self, self.KeyUp )

	Network:Subscribe( "Places", self, self.Places )
	Network:Subscribe( "OpenDoors", self, self.OpenDoors )
end

function Doors:Lang()
	self.ptext = "Press «L» to open stronghold doors"
end

function Doors:Places( args )
	self.places = args
end

function Doors:DrawShadowedText( pos, text, colour, size, scale )
    if scale == nil then scale = 1.0 end
    if size == nil then size = TextSize.Default end

    local shadow_colour = Color( 0, 0, 0, colour.a )
    shadow_colour = shadow_colour * 0.4

    Render:DrawText( pos + Vector3( 1, 1, 2 ), text, shadow_colour, size, scale )
    Render:DrawText( pos, text, colour, size, scale )
end

function Doors:DrawHotspot( v, dist )
	local angle = Angle( Camera:GetAngle().yaw, 0, math.pi ) * Angle( math.pi, 0, 0 )

	local textSize = 50

	local getTextSize = Render:GetTextSize( self.ptext, textSize )

	local t = Transform3()
	t:Translate( v[2] )
	t:Scale( 0.0045 )
    t:Rotate( angle )
    t:Translate( -Vector3( getTextSize.x, getTextSize.y, 0 )/2 )

    Render:SetTransform( t )

	local normalizedDist = dist / ( LocalPlayer:InVehicle() and self.tipDistance * 3 or self.tipDistance )
 	local alpha_factor = 255 - math.clamp( normalizedDist * 255 * 2.25, 0, 255 )

	self:DrawShadowedText( Vector3.Zero, self.ptext, Color( 255, 255, 255, alpha_factor ), textSize )
end

function Doors:GameRender()
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if not LocalPlayer:GetValue( "OpenDoorsTipsVisible" ) then return end

	local cameraPos = Camera:GetPosition()
	local inVehicle = LocalPlayer:InVehicle()

	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end

	for _, v in ipairs( self.places ) do
		local dist = v[2]:Distance( cameraPos )
		if dist < ( inVehicle and self.tipDistance * 3 or self.tipDistance ) then
			self:DrawHotspot( v, dist )
		end
	end
end

function Doors:KeyUp( args )
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	if args.key == string.byte( "L" ) then
		local time = Client:GetElapsedSeconds()

		if time > self.cooltime then
			Network:Send( "GetPlayers" )

			self.cooltime = time + self.cooldown
		end
	end
end

function Doors:OpenDoors()
	Game:FireEvent( "t{go500.01({967466FA-4C87-422A-ACF5-042B67E922B5})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({9695B812-73C4-4D86-86FF-AEC430816869})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({F7CD6FAE-EFCE-4CA4-A1C4-6944D228139F})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({FD92A809-89AC-4D64-BC1C-335FD22F5B83})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({927DC663-1EAA-4D87-810F-36F8581CBE7D})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({8EB05652-74A1-4DA6-B24F-E77803AB4B6B})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({EC54E85D-45ED-46A8-8E31-3B32DEE1D5FC})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({86D114AF-77FD-44CC-B861-5F6C77ED03A0})}::fadeOutGate" )
	Game:FireEvent( "open.mouth" )
end

doors = Doors()