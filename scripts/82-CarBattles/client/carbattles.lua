class 'CarBattles'

function CarBattles:__init()
	self.check = true

	self.pts = 0
	self.scores = {}

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.name = "Загрузка..."
		self.nameTw = "Загрузка идет слишком долго? Перезайдите на сервер."
		self.healtxt = "++ Восстановление ++"
		self.yourscorestxt = "Ваши очки: "
		self.leaderboardtxt = "[Лидеры]"
	end

	self.cooldown = 20
	self.cooltime = 0

	--Network:Subscribe( "GetTime", self, self.GetTime )
	Network:Subscribe( "RespawnTimer", self, self.RespawnTimer )
	Network:Subscribe( "MapFinished", self, self.MapFinished )
	Network:Subscribe( "Enter", self, self.Enter )
	Network:Subscribe( "Exit", self, self.Exit )
	Network:Subscribe( "Sound", self, self.Sound )
	Network:Subscribe( "HealSound", self, self.HealSound )
	Network:Subscribe( "CarBattlesUpdatePoints", self, self.UpdatePoints )
	Network:Subscribe( "CarBattlesUpdateScores", self, self.UpdateScores )

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "GoCB", self, self.GoCB )
end

function CarBattles:GetTime( args )
	self.Time = args.MapTime
end

function CarBattles:RespawnTimer()
	if not self.PostTickEvent then
		self.timer = Timer()
		self.PostTickEvent = Events:Subscribe( "PostTick", self, self.PostTick )
		LocalPlayer:SetOutlineColor( Color( 0, 255, 0 ) )
		LocalPlayer:SetOutlineEnabled( true )
	end
end

function CarBattles:PostTick()
	if self.timer:GetSeconds() >= 15 then
		Network:Send( "EnableCollision" )
		if self.PostTickEvent then
			Events:Unsubscribe( self.PostTickEvent )
			self.PostTickEvent = nil
			LocalPlayer:SetOutlineEnabled( false )
		end
		self.timer = nil
	end
end

function CarBattles:Lang()
	self.name = "Loading..."
	self.nameTw = "Loading very long? Reconnect to the server."
	self.healtxt = "++ Healing ++"
	self.yourscorestxt = "Your points: "
	self.leaderboardtxt = "[Leaders]"
end

function CarBattles:GoCB()
	Network:Send( "GoCB" )
end

function CarBattles:MapFinished()
	Mouse:SetVisible( true )
	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.2, 0.2 ) )
	self.window:SetMinimumSize( Vector2( 500, 200 ) )
	self.window:SetPositionRel( Vector2( 0.7, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetVisible( true )
	self.window:SetTitle( "Игра окончена!" )
	self.window:Subscribe( "WindowClosed", self, self.Exit )

	self.errorText = Label.Create( self.window )
	self.errorText:SetPosition( Vector2( 20, 30 ) )
	self.errorText:SetSize( Vector2( 450, 100 ) )
	self.errorText:SetText( "Победитель:" )
	self.errorText:SetTextSize( 20 )

	self.leaveButton = Button.Create( self.window )
	self.leaveButton:SetSize( Vector2( 100, 40 ) )
	self.leaveButton:SetDock( GwenPosition.Bottom )
	self.leaveButton:SetText( "Продолжить" )
	self.leaveButton:Subscribe( "Press", self, self.Exit )
end

function CarBattles:Sound()
	local sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 17,
			sound_id = 13,
			position = LocalPlayer:GetPosition(),
			angle = Angle()
	})

	sound:SetParameter(0,0)
	sound:SetParameter(1,0)
	sound:SetParameter(2,1)
	sound:SetParameter(3,0)
end

function CarBattles:HealSound()
	local sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 19,
			sound_id = 30,
			position = LocalPlayer:GetPosition(),
			angle = Angle()
	})

	sound:SetParameter(0,1)
	Events:Fire( "CastCenterText", { text = self.healtxt, time = 4, color = Color.GreenYellow } )
end

function CarBattles:Enter()
	self.LocalPlayerInputEvent =		Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	self.LocalPlayerExitVehicleEvent =	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
	self.RenderEvent =					Events:Subscribe( "Render", self, self.Render )
	self.GameRenderEvent =				Events:Subscribe( "GameRender", self, self.GameRender )
	self.LocalPlayerDeathEvent =		Events:Subscribe( "LocalPlayerDeath", self, self.LocalPlayerDeath )
	self.GameLoadEvent =				Events:Subscribe( "GameLoad", self, self.GameLoad )
	self.KeyUpEvent =					Events:Subscribe( "KeyUp", self, self.KeyUp )
	self.RespawnEvent = 				Events:Subscribe( "LocalPlayerInput", self, self.Respawn )
	self.antifly = true
end

function CarBattles:Exit()
	Events:Unsubscribe( self.LocalPlayerInputEvent )
	Events:Unsubscribe( self.LocalPlayerExitVehicleEvent )
	Events:Unsubscribe( self.RenderEvent )
	Events:Unsubscribe( self.GameRenderEvent )
	Events:Unsubscribe( self.LocalPlayerDeathEvent )
	Events:Unsubscribe( self.GameLoadEvent )
	Events:Unsubscribe( self.KeyUpEvent )
	Events:Unsubscribe( self.RespawnEvent )

	if LocalPlayer:GetOutlineEnabled() == true then
		Network:Send( "EnableCollision" )
		LocalPlayer:SetOutlineEnabled( false )
	end

	Game:FireEvent( "ply.unpause" )
end

function CarBattles:LocalPlayerInput( args )
	if args.input == Action.StuntJump or args.input == Action.ParachuteOpenClose or args.input == Action.UseItem or args.input == Action.ExitVehicle then return false end

	local vehicle = LocalPlayer:GetVehicle()

	if vehicle then
		if vehicle:GetHealth() >= 0.3 then
			if args.input == Action.FireLeft or args.input == Action.VehicleFireRight or args.input == Action.VehicleFireLeft or args.input == Action.FireVehicleWeapon then return true end
		else
			if args.input == Action.FireLeft or args.input == Action.VehicleFireRight or args.input == Action.VehicleFireLeft or args.input == Action.FireVehicleWeapon then return false end
		end
	end
end

function CarBattles:UpdatePoints( pts )
	self.pts = pts
end

function CarBattles:UpdateScores( scores )
	self.scores = scores
end

function CarBattles:RightText( msg, y, color )
	local w = Render:GetTextWidth( msg, TextSize.Default )
	Render:DrawText( Vector2(Render.Width - w - 5, y), msg, color, TextSize.Default )
end

function CarBattles:Render()
	local vehicle = LocalPlayer:GetVehicle()

	Network:Send( "Health" )

	if self.check then
		if not LocalPlayer:InVehicle() then
			self.warning = true
			Game:FireEvent( "ply.pause" )
		else
			if self.antifly then
				if vehicle then
					vehicle:SetLinearVelocity( Vector3.Zero )
				end
				self.antifly = nil
			end
			self.warning = false
			Game:FireEvent( "ply.unpause" )
		end
	end

	if vehicle then
		if vehicle:GetHealth() <= 0.1 then
			Network:Send( "NoVehicle" )
		end
	end

	if Game:GetState() ~= GUIState.Game then return end

	local color = Color.White
	local shadowColor = Color.Black

	self:RightText( self.yourscorestxt .. self.pts, Render:GetTextHeight( "A" ) * 3.5 + 1, shadowColor )
	self:RightText( self.leaderboardtxt, Render:GetTextHeight( self.yourscorestxt .. self.pts ) * 5 + 1, shadowColor )

	self:RightText( self.yourscorestxt .. self.pts, Render:GetTextHeight( "A" ) * 3.5, Color( 255, 255, 0 ) )
	self:RightText( self.leaderboardtxt, Render:GetTextHeight( self.yourscorestxt .. self.pts ) * 5, Color( 255, 255, 0 ) )

	for i = 1, math.min(#self.scores, 10), 1 do
		self:RightText( ""..i..". "..self.scores[i].name..": "..self.scores[i].pts, Render:GetTextHeight( self.leaderboardtxt ) * 5 + 1 + i * 16, shadowColor )
		self:RightText( ""..i..". "..self.scores[i].name..": "..self.scores[i].pts, Render:GetTextHeight( self.leaderboardtxt ) * 5 + i * 16, self.scores[i].it and Color( 255, 170, 0 ) or color )
	end

	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end

--	local text = "До конца игры: " .. self.Time
--	if self.Time then
--		local pos = Vector2 ((Render.Size.x / 2) - (Render:GetTextSize(text, 18).x / 2), 30 )
--		Render:DrawShadowedText( pos, tostring( text ), Color.White, Color.Black, 18 )
--	end

	if self.warning then
		local text_width = Render:GetTextWidth( self.name, TextSize.VeryLarge )
		local text_height = Render:GetTextHeight( self.name, TextSize.VeryLarge )
		local pos = Vector2( ( Render.Width - text_width )/2, ( Render.Height - text_height - 200 ) / 2 )
		Render:DrawShadowedText( pos, self.name, Color.White, Color( 25, 25, 25, 150 ), TextSize.VeryLarge )

		pos.y = pos.y + 45
		pos.x = ( Render.Width - Render:GetTextWidth( self.nameTw, TextSize.Default ) ) / 2
		Render:DrawShadowedText( pos, self.nameTw, Color.DarkGray, Color( 25, 25, 25, 150 ), TextSize.Default )
	end
end

function CarBattles:GameRender()
	Render:FillArea( Vector2.Zero, Render.Size, Color( 20, 25, 0, 100 ) )
end

function CarBattles:LocalPlayerExitVehicle( args )
	self.check = false
	Network:Send( "NoVehicle" )
end

function CarBattles:LocalPlayerDeath( args )
	self.check = false
	Game:FireEvent( "ply.invulnerable" )
	self.antiboom = true
end

function CarBattles:KeyUp( args )
	if self.antiboom then
		Game:FireEvent( "ply.vulnerable" )
		self.antiboom = false
	end
end

function CarBattles:GameLoad( args )
	self.check = true
end

function CarBattles:Respawn( args )
	if args.input == Action.Reload then
		local time = Client:GetElapsedSeconds()
		if time < self.cooltime then return end
		Network:Send( "Respawn" )
		self.cooltime = time + self.cooldown
		return false
	end
end

carbattles = CarBattles()