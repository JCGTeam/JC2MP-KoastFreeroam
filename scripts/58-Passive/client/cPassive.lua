class 'Passive'

function Passive:__init()
	self.cooldown = 10
	self.tagOffset = 10
	self.textSize = 16

	self.visible = LocalPlayer:GetValue( "Passive" )
	self.animationValue = self.visible and 1 or 0

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.locStrings = {
			name = "Мирный",
			passivemode = "Мирный режим ",
			enabled = "отключён",
			disabled = "включён",
			pvpblock = "Вы не можете использовать мирный режим во время боя!",
			w = "Подождите ",
			ws = " секунд, чтобы включить/отключить мирный!",
			notusable = "Невозможно использовать это здесь!"
		}
	end

	self.cooltime = 0
	self.actions  = {
		[11] = true, [12] = true, [13] = true, [14] = true,
		[15] = true, [137] = true, [138] = true, [139] = true
		}

	Events:Subscribe( "LocalPlayerChat", self, self.LocalPlayerChat )
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
	self.locStrings = {
		name = "Passive",
		passivemode = "Passive mode ",
		enabled = "disabled",
		disabled = "enabled",
		pvpblock = "You cannot use Passive Mode during combat!",
		w = "Wait ",
		ws = " seconds to toggle passive mode!",
		notusable = "You cannot use it here!"
	}
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

function Passive:LocalPlayerChat( args )
	local cmd_args = args.text:split( " " )

	if cmd_args[1] == "/passive" or cmd_args[1] == "/peace" or cmd_args[1] == "/god" then self:TogglePassive() end
end

function Passive:TogglePassive()
	if LocalPlayer:GetWorld() ~= DefaultWorld then
		Events:Fire( "CastCenterText", { text = self.locStrings["notusable"], time = 3, color = Color.Red } )
		return
	end

	local state = LocalPlayer:GetValue( "Passive" )
	local time = Client:GetElapsedSeconds()

	if not state then
		if LocalPlayer:GetValue( "PVPMode" ) then
			Events:Fire( "CastCenterText", { text = self.locStrings["pvpblock"], time = 6, color = Color.Red } )
			return false
		end

		if time < self.cooltime then
			Events:Fire( "CastCenterText", { text = self.locStrings["w"] .. math.ceil( self.cooltime - time ) .. self.locStrings["ws"], time = 6, color = Color.Red } )
			return false
		end
	end

	Network:Send( "Toggle", not state )

	Events:Fire( "CastCenterText", { text = self.locStrings["passivemode"] .. ( state and self.locStrings["enabled"] or self.locStrings["disabled"] ), time = 3, color = Color( 0, 222, 0, 250 ) } )

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
			Events:Fire( "AntiCheat", false )
			self.visible = true

			if self.fadeOutAnimation then Animation:Stop( self.fadeOutAnimation ) self.fadeOutAnimation = nil end
			Animation:Play( 0, 1, 0.05, easeIOnut, function( value ) self.animationValue = value end )
		else
			Game:FireEvent( "ply.vulnerable" )
			Events:Fire( "AntiCheat", true )

			self.fadeOutAnimation = Animation:Play( self.animationValue, 0, 0.05, easeIOnut, function( value ) self.animationValue = value end, function() self.visible = nil end )
		end
	end
end

function Passive:Render()
	if self.pvpTimer and self.pvpTimer:GetSeconds() >= 10 then
		Network:Send( "TogglePVPMode", { enabled = false } )
		self.pvpTimer = nil
	end

	if not self.visible then return end
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
    local text_width = Render:GetTextWidth( self.locStrings["name"], text_size )
	local text_height = Render:GetTextHeight( self.locStrings["name"], text_size )
	local posY = math.lerp( -text_height - 2, 0, self.animationValue )
    local text_pos = Vector2( Render.Width / 1.52 - text_width / 1.8 + text_width / 25, posY + 2 )
	local sett_alpha = math.lerp( 0, Game:GetSetting(4) * 2.25, self.animationValue )
	local background_clr = Color( 0, 0, 0, sett_alpha / 2.4 )

	Render:FillArea( Vector2( Render.Width / 1.52 - text_width / 1.8, posY ), Vector2( text_width + 5, text_height + 2 ), background_clr )

	Render:FillTriangle( Vector2( ( Render.Width / 1.52 - text_width / 1.8 - 10 ), posY ), Vector2( ( Render.Width / 1.52 - text_width / 1.8 ), posY ), Vector2( ( Render.Width / 1.52 - text_width / 1.8 ), posY + text_height + 2 ), background_clr )
	Render:FillTriangle( Vector2( ( Render.Width / 1.52 - text_width / 1.8 + text_width + 15 ), posY ), Vector2( ( Render.Width / 1.52 - text_width / 1.8 + text_width + 5 ), posY ), Vector2( ( Render.Width / 1.52 - text_width / 1.8 + text_width + 5 ), posY + text_height + 2 ), background_clr )

	Render:DrawShadowedText( text_pos, self.locStrings["name"], Color( 0, 250, 154, sett_alpha ), Color( 0, 0, 0, sett_alpha ), text_size )
end

passive = Passive()