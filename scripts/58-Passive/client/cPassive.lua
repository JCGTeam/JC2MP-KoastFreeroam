class 'Passive'

function Passive:__init()
	self.cooldown = 10
	self.tagOffset = 10
	self.textSize = 16

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.name = "Мирный"
		self.passivemode = "Мирный режим "
		self.enabled = "отключён"
		self.disabled = "включён"
		self.pvpblock = "Вы не можете использовать мирный режим во время боя!"
		self.w = "Подождите "
		self.ws = " секунд, чтобы включить/отключить мирный!"
		self.notusable = "Невозможно использовать это здесь!"
	end

	self.cooltime = 0
	self.actions  = {
		[11] = true, [12] = true, [13] = true, [14] = true,
		[15] = true, [137] = true, [138] = true, [139] = true
		}

	Events:Subscribe( "TogglePassive", self, self.TogglePassive )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "InputPoll", self, self.InputPoll )
	Events:Subscribe( "LocalPlayerBulletHit", self, self.LocalPlayerDamage )
	Events:Subscribe( "LocalPlayerExplosionHit", self, self.LocalPlayerDamage )
	Events:Subscribe( "LocalPlayerForcePulseHit", self, self.LocalPlayerDamage )
	Events:Subscribe( "NetworkObjectValueChange", self, self.NetworkObjectValueChange )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "LocalPlayerWorldChange", self, self.LocalPlayerWorldChange )
end

function Passive:Lang()
	self.name = "Passive"
	self.passivemode = "Passive mode "
	self.enabled = "disabled"
	self.disabled = "enabled"
	self.pvpblock = "You cannot use Passive Mode during combat!"
	self.w = "Wait "
	self.ws = " seconds to toggle passive mode!"
	self.notusable = "You cannot use it here!"
end

function Passive:LocalPlayerWorldChange()
	if not LocalPlayer:GetValue( "Passive" ) then return end

	Network:Send( "Toggle", not LocalPlayer:GetValue( "Passive" ) )
end

function Passive:LocalPlayerInput( args )
	if self.actions[args.input] and (LocalPlayer:GetValue( "Passive" ) or LocalPlayer:InVehicle() and LocalPlayer:GetVehicle():GetInvulnerable()) then
		return false
	end
end

function Passive:InputPoll()
	if not LocalPlayer:GetValue( "Passive" ) then return end

	Input:SetValue( Action.VehicleFireLeft, 0 )
	Input:SetValue( Action.VehicleFireRight, 0 )
	Input:SetValue( Action.FireRight, 0 )
	Input:SetValue( Action.FireLeft, 0 )
end

function Passive:TogglePassive()
	if LocalPlayer:GetWorld() ~= DefaultWorld then
		Events:Fire( "CastCenterText", { text = self.notusable, time = 3, color = Color.Red } )
		return
	end

	local state = LocalPlayer:GetValue( "Passive" )
	local time = Client:GetElapsedSeconds()

	if not state then
		if LocalPlayer:GetValue( "PVPMode" ) then
			Events:Fire( "CastCenterText", { text = self.pvpblock, time = 6, color = Color.Red } )
			return false
		end

		if time < self.cooltime then
			Events:Fire( "CastCenterText", { text = self.w .. math.ceil( self.cooltime - time ) .. self.ws, time = 6, color = Color.Red } )
			return false
		end
	end

	Network:Send( "Toggle", not state )

	Events:Fire( "CastCenterText", { text = self.passivemode .. ( state and self.enabled or self.disabled ), time = 3, color = Color( 0, 222, 0, 250 ) } )

	self.cooltime = time + self.cooldown
	return false
end

function Passive:LocalPlayerDamage( args )
	if LocalPlayer:GetValue( "Passive" ) or args.attacker and args.attacker.__type == 'Player' and ( args.attacker:GetValue( "Passive" ) or args.attacker:InVehicle() and args.attacker:GetVehicle():GetInvulnerable() ) then
		return false
	end

	if not LocalPlayer:GetValue( "Passive" ) then
		if not self.pvpTimer then
			self.pvpTimer = Timer()
			Network:Send( "TogglePVPMode", { enabled = true } )
		else
			self.pvpTimer:Restart()
		end
	end
end

function Passive:NetworkObjectValueChange( args )
	if args.key == "Passive" and args.object.__type == "LocalPlayer" then
		if args.value then
			Game:FireEvent( "ply.invulnerable" )
			Events:Fire( "GetGod", {godactive = true} )
			Events:Fire( "AntiCheat", {acActive = false} )
		else
			Game:FireEvent( "ply.vulnerable" )
			Events:Fire( "GetGod", {godactive = false} )
			Events:Fire( "AntiCheat", {acActive = true} )
		end
	end
end

function Passive:Render()
	if self.pvpTimer and self.pvpTimer:GetSeconds() >= 10 then
		Network:Send( "TogglePVPMode", { enabled = false } )
		self.pvpTimer = nil
	end

	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if not LocalPlayer:GetValue( "PassiveModeVisible" ) or LocalPlayer:GetValue( "HiddenHUD" ) then return end
	if LocalPlayer:GetValue( "SystemFonts" ) then Render:SetFont( AssetLocation.SystemFont, "Impact" ) end

	--if LocalPlayer:GetValue("Passive") then
	--	if LocalPlayer:GetVehicle() then
	--		if LocalPlayer:GetVehicle():GetLinearVelocity():Length() >= 20 then
	--			Network:Send( "CheckPassive" )
	--		end
	--	end
	--end

	local text_size = 18
    local text_width = Render:GetTextWidth( self.name, text_size )
	local text_height = Render:GetTextHeight( self.name, text_size )
    local text_pos = Vector2( Render.Width / 1.52 - text_width / 1.8 + text_width / 25, 2 )
	local sett_alpha = Game:GetSetting(4) * 2.25
	local background_clr = Color( 0, 0, 0, sett_alpha / 2.4 )

	Render:FillArea( Vector2( Render.Width / 1.52 - text_width / 1.8, 0 ), Vector2( text_width + 5, text_height + 2 ), background_clr )

	Render:FillTriangle( Vector2( ( Render.Width / 1.52 - text_width / 1.8 - 10 ), 0 ), Vector2( ( Render.Width / 1.52 - text_width / 1.8 ), 0 ), Vector2( ( Render.Width / 1.52 - text_width / 1.8 ), text_height + 2 ), background_clr )
	Render:FillTriangle( Vector2( ( Render.Width / 1.52 - text_width / 1.8 + text_width + 15 ), 0 ), Vector2( ( Render.Width / 1.52 - text_width / 1.8 + text_width + 5 ), 0 ), Vector2( ( Render.Width / 1.52 - text_width / 1.8 + text_width + 5 ), text_height + 2 ), background_clr )

	local passive_enabled = LocalPlayer:GetValue( "Passive" ) or LocalPlayer:GetValue( "FreecamEnabled" )

	if passive_enabled then
		Render:DrawText( text_pos + Vector2.One, self.name, Color( 0, 0, 0, sett_alpha ), text_size )
	end

	Render:DrawText( text_pos, self.name, passive_enabled and Color( 0, 250, 154, sett_alpha ) or Color( 255, 255, 255, sett_alpha / 4 ), text_size )
end

passive = Passive()