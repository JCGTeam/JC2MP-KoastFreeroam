class "KingHil"

function KingHil:__init()
	self.state = GamemodeState.WAITING
	self.inLobby = false
	self.queue = {}
	self.queueMin = 0
	self.queueMax = 0

	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.nameT = "Игроки"
		self.nameTTw = "Очередь"
		self.nameTTh = "Ожидание других игроков..."
		self.nameTFo = "Доберитесь до чекпоинта первым и отбивайтесь ракетницей от соперников!"
		self.nameTFi = "За границами "
		self.lobbyneeds_txt = "Нужно на "
		self.lobbymore_txt = " больше"
		self.lobbyplayer_txt = "игроков)"
	end

	self.spec = {
		listOffset = 1,
		player = false,
		angle = Angle(),
		zoom = 1
	}
	self.timer = Timer()
	self.segments = {}

	Network:Subscribe( "EnterLobby", self, self.EnterLobby )
	Network:Subscribe( "StateChange", self, self.StateChange )
	Network:Subscribe( "UpdateQueue", self, self.UpdateQueue )
	Network:Subscribe( "ExitLobby", self, self.ExitLobby )

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "InputPoll", self, self.InputPoll )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "LocalPlayerWorldChange", self, self.LocalPlayerWorldChange )
	Events:Subscribe( "PreTick", self, self.PreTick )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "GameRender", self, self.GameRender )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
end

function KingHil:Lang()
	self.nameT = "Players"
	self.nameTTw = "Current Queue"
	self.nameTTh = "Waiting for other players..."
	self.nameTFo = "Get to checkpoint first and fight off your rivals with a rocket launcher!"
	self.nameTFi = "Out of bounds "
	self.lobbyneeds_txt = "We need "
	self.lobbymore_txt = " more"
	self.lobbyplayer_txt = "players)"
end

function KingHil:AddSegment( segments, segment )
	segment.time = self.timer:GetSeconds()

	table.insert(segments, segment)

	if #segments > 8 then
		table.remove(segments, 1)
	end
end

function DrawCenteredShadowedText( position, text, color, textsize )
	local textsize = textsize or TextSize.Default
	local bounds = Render:GetTextSize( text, textsize )

	if not IsNaN( position ) then
		Render:DrawShadowedText( position - ( bounds / 2 ), text, color, Color( 25, 25, 25, 150 ), textsize )
	end
end

function KingHil:EnterLobby()
	self.inLobby = true
	self.state = GamemodeState.WAITING
	self.queue = {}
	self.queueMin = 0
	self.queueMax = 0
	self.spec = {
		listOffset = 1,
		player = false,
		angle = Angle(),
		zoom = 1
	}
end

function KingHil:StateChange( args )
	self.state = args.state
	self.stateArgs = args.stateArgs

	if self.state > GamemodeState.PREPARING and self.state < GamemodeState.ENDING then
		self.timer:Restart()
	end
end

function KingHil:UpdateQueue( args )
	self.position = args.position
	self.maxRadius = args.maxRadius
	self.queue = args.queue
	self.queueMin = args.min
	self.queueMax = args.max
end

function KingHil:ExitLobby()
	Game:FireEvent("ply.parachute.enable")
	Waypoint:Remove()
	self.inLobby = false
end

function KingHil:InputPoll()
	if not self.inLobby then return end

	if self.state == GamemodeState.INPROGRESS then
	elseif self.state == GamemodeState.PREPARING or self.state == GamemodeState.COUNTDOWN then
		Input:SetValue(Action.Handbrake, 1)
	end
end

function KingHil:LocalPlayerInput()
	if not self.inLobby then return end
	if Game:GetState() ~= GUIState.Game then return end

	local gamepad = Game:GetSetting(GameSetting.GamepadInUse) == 1

	if self.state == GamemodeState.PREPARING or self.state == GamemodeState.COUNTDOWN then
		return false
	end
end

function KingHil:LocalPlayerWorldChange( args )
	if args.new_world == DefaultWorld and self.inLobby then
		self:ExitLobby()
	end
end

function KingHil:PreTick()
	if not self.inLobby then return end

	if self.state == GamemodeState.INPROGRESS then
		Game:FireEvent("ply.parachute.disable")

		local players = {LocalPlayer}

		for player in Client:GetPlayers() do
			table.insert(players, player)
		end

		local distance = LocalPlayer:GetPosition():Distance(self.stateArgs.position)

		if distance <= self.stateArgs.maxRadius then
			self.timer:Restart()
		end

		if self.timer:GetSeconds() > 5 then
			Network:Send( "Collision" )
		end
	end
end

function KingHil:Render()
	if not self.inLobby or Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end

	local gamepad = Game:GetSetting(GameSetting.GamepadInUse) == 1

	if self.state == GamemodeState.WAITING then
		local playersNeeded = math.max(self.queueMin - #self.queue, 0)

		DrawCenteredShadowedText( Vector2( Render.Width / 2, 70 ), #self.queue .. ' / ' .. self.queueMax, Color.White, TextSize.Large )

		if playersNeeded > 0 then
			DrawCenteredShadowedText( Vector2( Render.Width / 2, 70 + TextSize.Large ), '(' .. self.lobbyneeds_txt .. playersNeeded .. self.lobbymore_txt .. (playersNeeded ~= 1 and self.lobbyplayer_txt or " " .. self.lobbyplayer_txt), Color( 165, 165, 165 ), 25 )
		end

		if self.queue then
			for k, player in ipairs(self.queue) do
				DrawCenteredShadowedText( Vector2( Render.Width - 75, Render.Height - 75 - (k * 20) ), player:GetName(), player:GetColor() )
			end

			DrawCenteredShadowedText( Vector2( Render.Width - 75, Render.Height - 75 - ((#self.queue + 1) * 20) ), self.nameTTw, Color.White, 20 )
		end
	elseif self.state == GamemodeState.PREPARING then
		DrawCenteredShadowedText( Vector2( Render.Width / 2, 70 ), self.nameTTh, Color.White, TextSize.Large )
	elseif self.state == GamemodeState.COUNTDOWN then
		DrawCenteredShadowedText( Vector2( Render.Width / 2, 70 ), math.max(math.ceil(5 - self.timer:GetSeconds()), 1) .. "", Color.White, TextSize.Huge )
	elseif self.state == GamemodeState.INPROGRESS then
		DrawCenteredShadowedText( Vector2( Render.Width / 2, Render.Height - 35 ), self.nameTFo, Color.Yellow )

		Waypoint:SetPosition(self.stateArgs.finish)

		local distance = LocalPlayer:GetPosition():Distance(self.stateArgs.position)

		if self.timer:GetSeconds() > 0 and distance >= self.stateArgs.maxRadius then
			DrawCenteredShadowedText( Render.Size / 2, self.nameTFi .. math.max(math.ceil(5 - self.timer:GetSeconds()), 1) .. "...", Color.Red, TextSize.Huge )
		end
	end

	if self.state >= GamemodeState.PREPARING and self.state <= GamemodeState.ENDING then
		local players = {LocalPlayer}

		for player in Client:GetPlayers() do
			if player:GetWorld() == LocalPlayer:GetWorld() then
				table.insert(players, player)
			end
		end

		for k, player in ipairs(players) do
			color = player:GetColor()

			DrawCenteredShadowedText( Vector2( Render.Width - 75, Render.Height - 75 - (k * 20) ), player:GetName(), color )
		end

		DrawCenteredShadowedText( Vector2( Render.Width - 75, Render.Height - 75 - ((#players + 1) * 20) ), self.nameT, Color.White, 20 )
	end
end

function KingHil:GameRender()
	if self.state == GamemodeState.INPROGRESS then
		for k, segments in pairs(self.segments) do
			for k, segment in ipairs(segments) do
				segment:Render()
			end
		end
	end
end

function KingHil:ModuleUnload()
	self:ExitLobby()
end

KingHil()