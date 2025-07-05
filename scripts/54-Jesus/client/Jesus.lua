class 'Jesus'

function Jesus:__init()
	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.locStrings = {
			name = "Иисус",
			nameSizer = "Мирный",
			disable = " отключён",
			enable = " включён",
			notusable = "Невозможно использовать это здесь!"
		}
	end

	self.SurfaceHeight = 199.8
	self.UnderWaterOffset = 0.157
	self.MaxDistance = 50

	self.visible = LocalPlayer:GetValue( "WaterWalk" )
	self.animationValue = self.visible and 1 or 0

	self.Model = ""
	self.Collision = "areaset01.blz/gb245_lod1-d_col.pfx"

	self.Surfaces = {}

	Events:Subscribe( "NetworkObjectValueChange", self, self.NetworkObjectValueChange )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "ModuleUnload", self, self.RemoveAllSurfaces )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "LocalPlayerChat", self, self.LocalPlayerChat )
	Events:Subscribe( "ToggleJesus", self, self.ToggleJesus )
end

function Jesus:Lang()
	self.locStrings = {
		name = "Jesus",
		nameSizer = "Passive",
		disable = " disabled",
		enable = " enabled",
		notusable = "You cannot use it here!"
	}
end

function Jesus:PlayerQuit( args )
	self:Remove(args.player)
end

function Jesus:Master( player )
	if player:GetValue( "WaterWalk" ) then
		local vehicle = player:GetVehicle()

		if vehicle and vehicle:GetClass() == VehicleClass.Sea then
			self:Remove(player)
			return
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
	local EffectiveAngle = Angle.Zero
	local EffectiveHeight = self.SurfaceHeight

	local pState = player:GetState()
	if pState == 1 or pState == 2 or pState == 3 or pState == 5 then
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
	local pId = player:GetId()

	if IsValid(self.Surfaces[pId]) then
		self.Surfaces[pId]:Remove()
		self.Surfaces[pId] = nil
	end
	return true
end

function Jesus:Anchor( player )
	local vehicle = player:GetVehicle()

	if vehicle and player:InVehicle() then
		if Vector3.Distance(vehicle:GetPosition(), player:GetPosition()) < self.MaxDistance / 2 then
			return vehicle
		end
	end
	return player
end

function Jesus:RemoveAllSurfaces()
	for k, v in pairs(self.Surfaces) do
		if IsValid(v) then
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

function Jesus:NetworkObjectValueChange( args )
	if args.key == "WaterWalk" and args.object.__type == "LocalPlayer" then
		if args.value then
			self.visible = true

			if self.fadeOutAnimation then Animation:Stop( self.fadeOutAnimation ) self.fadeOutAnimation = nil end
			Animation:Play( 0, 1, 0.05, easeIOnut, function( value ) self.animationValue = value end )
		else
			self.fadeOutAnimation = Animation:Play( self.animationValue, 0, 0.05, easeIOnut, function( value ) self.animationValue = value end, function() self.visible = nil end )
		end
	end
end

function Jesus:Render()
	if not self.visible then return end
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if not LocalPlayer:GetValue( "JesusModeVisible" ) or LocalPlayer:GetValue( "HiddenHUD" ) then return end
	if LocalPlayer:GetValue( "SystemFonts" ) then Render:SetFont( AssetLocation.SystemFont, "Impact" ) end

	local text_size = 18
    local text_width = Render:GetTextWidth( self.locStrings["nameSizer"], text_size )
	local text_height = Render:GetTextHeight( self.locStrings["nameSizer"], text_size )
	local posY = math.lerp( -text_height - 2, 0, self.animationValue )
    local text_pos = Vector2( Render.Width / 1.3 - text_width / 1.8 + text_width / 5.5, posY + 2 )
	local sett_alpha = math.lerp( 0, Game:GetSetting(4) * 2.25, self.animationValue )
	local background_clr = Color( 0, 0, 0, sett_alpha / 2.4 )

	Render:FillArea( Vector2( Render.Width / 1.3 - text_width / 1.8, posY ), Vector2( text_width + 5, text_height + 2 ), background_clr )

	Render:FillTriangle( Vector2( ( Render.Width / 1.3 - text_width / 1.8 - 10 ), posY ), Vector2( ( Render.Width / 1.3 - text_width / 1.8 ), posY ), Vector2( ( Render.Width / 1.3 - text_width / 1.8 ), posY + text_height + 2 ), background_clr )
	Render:FillTriangle( Vector2( ( Render.Width / 1.3 - text_width / 1.8 + text_width + 15 ), posY ), Vector2( ( Render.Width / 1.3 - text_width / 1.8 + text_width + 5 ), posY ), Vector2( ( Render.Width / 1.3 - text_width / 1.8 + text_width + 5 ), posY + text_height + 2 ), background_clr )

	Render:DrawShadowedText( text_pos, self.locStrings["name"], Color( 185, 215, 255, sett_alpha ), Color( 0, 0, 0, sett_alpha ), text_size )
end

function Jesus:LocalPlayerChat( args )
	local cmd_args = args.text:split( " " )

	if cmd_args[1] == "/jesus" or cmd_args[1] == "/waterwalk" then self:ToggleJesus() end
end

function Jesus:ToggleJesus()
	if not LocalPlayer:GetValue( "JesusModeEnabled" ) then return end

	if LocalPlayer:GetWorld() ~= DefaultWorld then
		Events:Fire( "CastCenterText", { text = self.locStrings["notusable"], time = 3, color = Color.Red } )
		return
	end

	LocalPlayer:SetSystemValue( "WaterWalk", not LocalPlayer:GetValue( "WaterWalk" ) )
	Events:Fire( "CastCenterText", { text = self.locStrings["name"] .. ( LocalPlayer:GetValue( "WaterWalk" ) and self.locStrings["disable"] or self.locStrings["enable"] ), time = 2, color = Color( 185, 215, 255 ) } )
end

function LocalPlayer:SetSystemValue( valueName, value )
	if IsValid(self) and valueName then
		local SendInfo = {}
			SendInfo.player	= self
			SendInfo.name = tostring( valueName )
			SendInfo.value = value
		Network:Send( "SetSystemValue", SendInfo )
	end
end

jesus = Jesus()