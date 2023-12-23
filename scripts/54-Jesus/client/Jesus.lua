class 'Jesus'

function Jesus:__init()
	self.name = "Иисус"
	self.nameSizer = "Мирный"

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "ENG" then
		self:Lang()
	else
		self.disabletxt = " отключён"
		self.enabletxt = " включён"
		self.notusable = "Невозможно использовать это здесь!"
	end

	self.SurfaceHeight = 199.8
	self.UnderWaterOffset = 0.157
	self.MaxDistance = 50

	self.Model = ""
	self.Collision = "areaset01.blz/gb245_lod1-d_col.pfx"

	self.NoSurfaceVehicles = { 80, 88, 16, 5, 27, 38, 6, 19, 45, 28, 53, 25, 69, 5, 50 }
	self.Surfaces = {}

	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "ModuleUnload", self, self.RemoveAllSurfaces )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "JesusToggle", self, self.JesusToggle )
end

function Jesus:Lang()
	self.name = "Jesus"
	self.nameSizer = "Passive"
	self.disabletxt = " disabled"
	self.enabletxt = " enabled"
	self.notusable = "You cannot use it here!"
end

function Jesus:PlayerQuit( args )
	self:Remove(args.player)
end

function Jesus:Master( player )
	if player:GetValue( "WaterWalk" ) then
		local PlayerVehicle	 = player:GetVehicle()
		if PlayerVehicle and IsValid(PlayerVehicle) then
			local PlayerVehicleID = PlayerVehicle:GetModelId()
			if self:CheckList(self.NoSurfaceVehicles, PlayerVehicleID) then
				self:Remove(player)
				return
			end
		end
		self:Move(player)
	else
		self:Remove(player)
	end
end

function Jesus:Create( player )
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	local Position = self:Position(player)
	local Surface = ClientStaticObject.Create({
		position = Position.Position,
		angle = Position.Angle,
		model = self.Model,
		collision = self.Collision
	})
	self.Surfaces[player:GetId()] = Surface
end

function Jesus:Move( player )
	local Surface = self.Surfaces[player:GetId()]
	if not Surface and not IsValid(Surface) then
		self:Create(player)
		return
	end
	if Vector3.Distance(Surface:GetPosition(), player:GetPosition()) >= self.MaxDistance then
		if self:Remove(player) then
			self:Create(player)
		end
	end

	local Position = self:Position(player)
	Surface:SetPosition(Position.Position)
	Surface:SetAngle(Position.Angle)
end

function Jesus:Position( player )
	local Anchor = self:Anchor(player)
	local PlayerPosition = Anchor:GetPosition()
	local PlayerAngle = Anchor:GetAngle()
	local EffectiveAngle = Angle( 0, 0, 0 )
	local EffectiveHeight = self.SurfaceHeight

	if player:GetState() == 1 or player:GetState() == 2 or player:GetState() == 3 or player:GetState() == 5 then
		EffectiveAngle = Angle( PlayerAngle.yaw, 0, 0 ) * Angle( math.pi * 1.5, 0, 0 )
	end

	if PlayerPosition.y < EffectiveHeight + self.UnderWaterOffset and not player:InVehicle() then
		EffectiveHeight	= PlayerPosition.y - 1
	end

	local Speed	= math.clamp(player:GetLinearVelocity():Length(), 0, 40)
	if Speed > 5 then
		local SpeedRatio = Speed / 150
		EffectiveHeight	= EffectiveHeight + SpeedRatio
	end

	local EffectivePosition	= Vector3(PlayerPosition.x, EffectiveHeight, PlayerPosition.z)

	return {Position = EffectivePosition, Angle = EffectiveAngle}
end

function Jesus:Remove( player )
	if self.Surfaces[player:GetId()] and IsValid(self.Surfaces[player:GetId()]) then
		self.Surfaces[player:GetId()]:Remove()
		self.Surfaces[player:GetId()] = nil
	end
	return true
end

function Jesus:Anchor( player )
	local PlayerVehicle	= player:GetVehicle()
	if PlayerVehicle and IsValid(PlayerVehicle) and player:InVehicle() then
		if Vector3.Distance(PlayerVehicle:GetPosition(), player:GetPosition()) < self.MaxDistance / 2 then
			return PlayerVehicle
		end
	end
	return player
end

function Jesus:RemoveAllSurfaces()
	for k, v in pairs(self.Surfaces) do
		if v and IsValid(v) then
			v:Remove()
		end
	end
end

function Jesus:PostTick()
	self:Master(LocalPlayer)
	for players in Client:GetStreamedPlayers() do
		self:Master(players)
	end
end

function Jesus:Render()
	if Game:GetState() ~= GUIState.Game then return end
	if not LocalPlayer:GetValue( "JesusModeEnabled" ) then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if not LocalPlayer:GetValue( "JesusModeVisible" ) or LocalPlayer:GetValue( "HiddenHUD" ) then return end
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end

    local width = Render:GetTextWidth( self.name )
    local text_pos = Vector2( Render.Width/1.3 - width/1.8 + Render:GetTextWidth( self.nameSizer, 18 ) / 5.5, 2 )

	Render:FillArea( Vector2( Render.Width/1.3 - width/1.8, 0 ), Vector2( Render:GetTextWidth( self.nameSizer, 18 ) + 5, Render:GetTextHeight( self.name, 18 ) + 2 ), Color( 0, 0, 0, Game:GetSetting(4) * 2.25 / 2.4 ) )

	Render:FillTriangle( Vector2( (Render.Width / 1.3 - width/1.8 - 10), 0 ), Vector2( (Render.Width / 1.3 - width/1.8), 0 ), Vector2( (Render.Width / 1.3 - width/1.8), Render:GetTextHeight( self.name, 18 ) + 2 ), Color( 0, 0, 0, Game:GetSetting(4) * 2.25 / 2.4 ) )
	Render:FillTriangle( Vector2( (Render.Width / 1.3 - width/1.8 + Render:GetTextWidth( self.nameSizer, 18 ) + 15), 0 ), Vector2( (Render.Width / 1.3 - width/1.8 + Render:GetTextWidth( self.nameSizer, 18 ) + 5), 0 ), Vector2( (Render.Width / 1.3 - width/1.8 + Render:GetTextWidth( self.nameSizer, 18 ) + 5 ), Render:GetTextHeight( self.name, 18 ) + 2 ), Color( 0, 0, 0, Game:GetSetting(4) * 2.25 / 2.4 ) )

	local waterwalk_enabled = LocalPlayer:GetValue( "WaterWalk" )

	if waterwalk_enabled then
		Render:DrawText( text_pos + Vector2.One, self.name, Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ), 18 )
	end

	Render:DrawText( text_pos, self.name, waterwalk_enabled and Color( 173, 216, 230, Game:GetSetting(4) * 2.25 ) or Color( 255, 255, 255, Game:GetSetting(4) * 2.25 / 4 ), 18 )
end

function Jesus:CheckList( tableList, modelID )
	for k,v in pairs( tableList ) do
		if v == modelID then return true end
	end
	return false
end

function Jesus:JesusToggle( args )
	if LocalPlayer:GetWorld() ~= DefaultWorld then
		Events:Fire( "CastCenterText", { text = self.notusable, time = 3, color = Color.Red } )
		return
	end

	LocalPlayer:SetSystemValue( "WaterWalk", not LocalPlayer:GetValue( "WaterWalk" ) )
	Events:Fire( "CastCenterText", { text = self.name .. ( LocalPlayer:GetValue( "WaterWalk" ) and self.disabletxt or self.enabletxt ), time = 2, color = Color.LightBlue } )
end

function LocalPlayer:SetSystemValue( valueName, value )
	if self and IsValid(self) and valueName then
		local SendInfo = {}
			SendInfo.player	= self
			SendInfo.name = tostring( valueName )
			SendInfo.value = value
		Network:Send( "SetSystemValue", SendInfo )
	end
end

jesus = Jesus()