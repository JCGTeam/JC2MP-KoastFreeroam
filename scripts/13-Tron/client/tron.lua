class "Tron"

function Tron:__init()
	self.state = GamemodeState.WAITING
	self.inLobby = false
	self.queue = {}
	self.queueMin = 0
	self.queueMax = 0

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.nameT = "Игроки"
		self.nameTTw = "Очередь"
		self.nameTTh = "Ожидание других игроков..."
		self.nameTFo = "Самоуничтожиться через "
		self.nameTFi = "За границами "
		self.lobbyneeds_txt = "Нужно на "
		self.lobbymore_txt = " больше"
		self.lobbyplayer_txt = "игроков)"
		self.tip1_txt = "Нажмите RB, чтобы заморозить свой след."
		self.tip2_txt = "Нажмите правой кнопкой мыши, чтобы заморозить свой след."
		self.tip3_txt = "Вы проиграли. Нажмите LB или RB, чтобы начать слежку за другим игроком."
		self.tip4_txt = "Вы проиграли. Нажмите левой или правой кнопкой мыши, чтобы начать слежку за другим игроком."
	end

	self.spec = {
		listOffset = 1,
		player = false,
		angle = Angle(),
		zoom = 1
	}
	self.collisionFired = false
	self.timer = Timer()
	self.blockedActions = {Action.StuntJump, Action.StuntposEnterVehicle, Action.ParachuteOpenClose, Action.ExitVehicle, Action.EnterVehicle, Action.UseItem}
	self.segments = {}

	Network:Subscribe( "EnterLobby", self, self.EnterLobby )
	Network:Subscribe( "StateChange", self, self.StateChange )
	Network:Subscribe( "UpdateQueue", self, self.UpdateQueue )
	Network:Subscribe( "ExitLobby", self, self.ExitLobby )

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
	Events:Subscribe( "LocalPlayerWorldChange", self, self.LocalPlayerWorldChange )
	Events:Subscribe( "PlayerNetworkValueChange", self, self.PlayerNetworkValueChange )
	Events:Subscribe( "EntityDespawn", self, self.EntityDespawn )
	Events:Subscribe( "PreTick", self, self.PreTick )
	Events:Subscribe( "Render", self, self.Render )
end

function Tron:Lang()
	self.nameT = "Players"
	self.nameTTw = "Current Queue"
	self.nameTTh = "Waiting for other players..."
	self.nameTFo = "Self-destruct in "
	self.nameTFi = "Out of bounds "
	self.lobbyneeds_txt = "We need "
	self.lobbymore_txt = " more"
	self.lobbyplayer_txt = "players)"
	self.tip1_txt = "Press RB to freeze your trail."
	self.tip2_txt = "Right click to freeze your trail."
	self.tip3_txt = "You lose. Press LB or RB to spectate another player."
	self.tip4_txt = "You lose. Click the left or right mouse button to start spying on another player."
end

function Tron:AddSegment( segments, segment )
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
		Render:DrawShadowedText( position - (bounds / 2), text, color, Color( 25, 25, 25, 150 ), textsize )
	end
end

function Tron:EnterLobby()
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
	self.collisionFired = false

	if not self.GameRenderOpaqueEvent then self.GameRenderOpaqueEvent = Events:Subscribe( "GameRenderOpaque", self, self.GameRenderOpaque ) end
	if not self.CaclViewEvent then self.CaclViewEvent = Events:Subscribe( "CalcView", self, self.CalcView ) end
	if not self.InputPollEvent then self.InputPollEvent = Events:Subscribe( "InputPoll", self, self.InputPoll ) end
	if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end
end

function Tron:StateChange( args )
	self.state = args.state
	self.stateArgs = args.stateArgs

	if self.state > GamemodeState.PREPARING and self.state < GamemodeState.ENDING then
		self.timer:Restart()
	end
end

function Tron:UpdateQueue( args )
	self.position = args.position
	self.maxRadius = args.maxRadius
	self.queue = args.queue
	self.queueMin = args.min
	self.queueMax = args.max
end

function Tron:ExitLobby()
	Game:FireEvent("ply.vulnerable")
	self.inLobby = false

	if self.GameRenderOpaqueEvent then Events:Unsubscribe( self.GameRenderOpaqueEvent ) self.GameRenderOpaqueEvent = nil end
	if self.CaclViewEvent then Events:Unsubscribe( self.CaclViewEvent ) self.CaclViewEvent = nil end
	if self.InputPollEvent then Events:Unsubscribe( self.InputPollEvent ) self.InputPollEvent = nil end
	if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end

	LocalPlayer:SetValue( "ServerMap", nil )
	LocalPlayer:SetValue( "SpectatorMode", nil )
end

function Tron:CalcView()
	if not self.inLobby then return end

	if self.state == GamemodeState.INPROGRESS then
		if not LocalPlayer:InVehicle() then
			local players = {}

			for player in Client:GetPlayers() do
				if player:GetWorld() == LocalPlayer:GetWorld() and player:InVehicle() then
					table.insert(players, player)
				end
			end

			if #players > 0 then
				self.spec.listOffset = self.spec.listOffset >= 0 and self.spec.listOffset % #players or #players + self.spec.listOffset

				local player = players[self.spec.listOffset + 1]

				if self.spec.player and IsValid(self.spec.player) and player ~= self.spec.player then
					self.spec.listOffset = table.find(players, self.spec.player)

					if self.spec.listOffset then
						self.spec.listOffset = self.spec.listOffset - 1
					else
						self.spec.listOffset = 0
					end
				elseif not self.spec.player or not IsValid(self.spec.player) then
					self.spec.player = player
				end

				local position = player:GetPosition()
				local targetPosition = position - ((Angle(player:GetAngle().yaw, 0, 0) * self.spec.angle) * ((Vector3.Forward * 40) + (Vector3.Up * 15)))
				local direction = targetPosition - player:GetPosition()
				local length = direction:Length() * self.spec.zoom
				local raycast = Physics:Raycast(position, direction:Normalized(), 2, length)
				local distance = IsNaN(raycast.distance) or raycast.distance == length and length or raycast.distance - 0.1

				Camera:SetPosition(position + (direction:Normalized() * distance))

				local angle = Angle.FromVectors(Vector3.Forward, position - Camera:GetPosition())

				if not IsNaN(angle) then
					angle.roll = 0 -- Fucking I hate angles and Jman100 also TheStatPow (Ну ок)
					Camera:SetAngle( angle )
				end

				LocalPlayer:SetValue( "SpectatorMode", 2 )
			end

			return false
		end
	end
end

function Tron:InputPoll()
	if not self.inLobby then return end

	if self.state == GamemodeState.INPROGRESS then
		local vehicle = LocalPlayer:GetVehicle()

		if LocalPlayer:InVehicle() and vehicle:GetHealth() == 0 then
			-- Force the player out
			Input:SetValue(Action.UseItem, 1)
			Input:SetValue(Action.ExitVehicle, 1)
		elseif LocalPlayer:InVehicle() then
			-- Tweak controls
			Input:SetValue(Action.Accelerate, math.max(0.65, Input:GetValue(Action.Accelerate)))

			if vehicle:GetLinearVelocity():Length() < 10 then
				Input:SetValue(Action.Reverse, 0)
			end

			Input:SetValue(Action.Handbrake, 0)
		end
	elseif self.state == GamemodeState.PREPARING or self.state == GamemodeState.COUNTDOWN then
		Input:SetValue(Action.Handbrake, 1)
		LocalPlayer:SetValue( "ServerMap", 1 )
	end
end

function Tron:LocalPlayerInput( args )
	if not self.inLobby then return end
	if Game:GetState() ~= GUIState.Game then return end

	local gamepad = Game:GetSetting(GameSetting.GamepadInUse) == 1

	if self.state == GamemodeState.PREPARING or self.state == GamemodeState.COUNTDOWN then
		return false
	elseif self.state == GamemodeState.INPROGRESS then
		if table.find(self.blockedActions, args.input) then
			return false
		elseif LocalPlayer:InVehicle() then
			local toggleAction = gamepad and Action.ZoomIn or Action.FireLeft

			if args.input == toggleAction and Input:GetValue(toggleAction) == 0 then
				Network:Send( "Firing", {TronFiring = not LocalPlayer:GetValue("TronFiring")} )
			end
		else
			if Input:GetValue(args.input) == 0 then
				if args.input == Action.FireLeft then
					self.spec.listOffset = self.spec.listOffset - 1
					self.spec.player = false
				elseif args.input == Action.FireRight then
					self.spec.listOffset = self.spec.listOffset + 1
					self.spec.player = false
				end
			end

			local sensitivity = {
				x = (Game:GetSetting(gamepad and GameSetting.GamepadSensitivityX or GameSetting.MouseSensitivityX) * (Game:GetSetting(gamepad and GameSetting.GamepadInvertX or GameSetting.MouseInvertX) and -1 or 1)) / 100 / (math.pi * 2),
				y = (Game:GetSetting(gamepad and GameSetting.GamepadSensitivityY or GameSetting.MouseSensitivityY) * (Game:GetSetting(gamepad and GameSetting.GamepadInvertY or GameSetting.MouseInvertY) and -1 or 1)) / 100 / (math.pi * 2)
			}

			if args.input == Action.LookLeft then
				self.spec.angle.yaw = self.spec.angle.yaw - (args.state * sensitivity.x)
			elseif args.input == Action.LookRight then
				self.spec.angle.yaw = self.spec.angle.yaw + (args.state * sensitivity.x)
			elseif args.input == Action.LookDown then
				self.spec.angle.pitch = self.spec.angle.pitch - (args.state * sensitivity.y)
			elseif args.input == Action.LookUp then
				self.spec.angle.pitch = self.spec.angle.pitch + (args.state * sensitivity.y)
			end

			if gamepad then
				if args.input == Action.MoveForward then
					self.spec.zoom = self.spec.zoom + (args.state * sensitivity.y)
				elseif args.input == Action.MoveBackward then
					self.spec.zoom = self.spec.zoom - (args.state * sensitivity.y)
				end
			else
				if args.input == Action.NextWeapon then
					self.spec.zoom = self.spec.zoom + 0.1
				elseif args.input == Action.PrevWeapon then
					self.spec.zoom = self.spec.zoom - 0.1
				end
			end

			self.spec.zoom = math.clamp(self.spec.zoom, 0.15, 1.5)
			self.spec.angle.pitch = math.clamp(self.spec.angle.pitch, -1.5, -0.4)
		end
	end
end

function Tron:LocalPlayerExitVehicle( args )
	if not self.inLobby then return end

	if self.state == GamemodeState.INPROGRESS and not self.collisionFired then
		Network:Send( "Collision", {
			vehicle = args.vehicle,
			fell = true
		} )
		self.collisionFired = true
	end
end

function Tron:LocalPlayerWorldChange( args )
	if args.new_world == DefaultWorld and self.inLobby then
		self:ExitLobby()
	end
end

function Tron:PlayerNetworkValueChange( args )
	if args.value == true and args.key == "TronFiring" and args.player:InVehicle() and self.segments[args.player:GetVehicle():GetId()] then
		local vehicle = args.player:GetVehicle()
		local vehicleId = vehicle:GetId()
		local vehAngle = vehicle:GetAngle()

		local point = Point(vehicle:GetPosition() - vehAngle * Vector3.Forward * 1.5, vehAngle)
		local segment = self.segments[vehicleId][#self.segments[vehicleId]]

		if segment then
			self:AddSegment(self.segments[vehicleId], LineSegment(point, point, segment.height, segment.color))
		end
	end
end

function Tron:EntityDespawn( args )
	if args.entity.__type == "Vehicle" then
		self.segments[args.entity:GetId()] = nil
	end
end

function Tron:PreTick()
	if not self.inLobby then return end

	if self.state == GamemodeState.INPROGRESS then
		Game:FireEvent("ply.invulnerable")

		local players = {LocalPlayer}

		for player in Client:GetPlayers() do
			table.insert(players, player)
		end

		for k, player in ipairs(players) do
			local vehicle = player:GetVehicle()

			if IsValid(player) and player:InVehicle() and IsValid(vehicle) and player == vehicle:GetDriver() then
				local vehicleId = vehicle:GetId()

				if not self.segments[vehicleId] then
					self.segments[vehicleId] = {}
				end
			end
		end

		for k, segments in pairs(self.segments) do
			local vehicle = Vehicle.GetById(k)

			if IsValid(vehicle) then
				local vehAngle = vehicle:GetAngle()

				local point = Point(vehicle:GetPosition() - vehAngle * Vector3.Forward * 1.5, vehAngle)
				local height = 1
				local vehColors = vehicle:GetColors()
				local color = Color(vehColors.r, vehColors.g, vehColors.b, 100)

				if (#segments == 0 or segments[#segments]:Length() > 10) and vehicle:GetDriver() and vehicle:GetDriver():GetValue("TronFiring") then
					self:AddSegment(segments, LineSegment(segments[#segments] and segments[#segments].endPoint or point, point, height, color))
				end

				for k, segment in ipairs(segments) do
					if k == #segments and vehicle:GetDriver() and vehicle:GetDriver():GetValue("TronFiring") then
						segment.endPoint = point
					end

					local vehicle = LocalPlayer:GetVehicle()

					if LocalPlayer:InVehicle() and IsValid(vehicle) and vehicle:GetDriver() == LocalPlayer then
						if vehicle ~= vehicle or k < #segments then
							local vehPos = vehicle:GetPosition()
							local vehAngle = vehicle:GetAngle()

							local startPoint = Point(vehPos - vehAngle * Vector3.Forward * 1.5, vehAngle)
							local endPoint = Point(vehPos + vehAngle * Vector3.Forward * 1.5, vehAngle)

							if segment:Intersects(LineSegment(startPoint, endPoint, height, color)) then
								if not self.collisionFired then
									Network:Send("Collision", {
										vehicle = vehicle,
										killer = vehicle
									})

									self.collisionFired = true
									self.spec.player = vehicle:GetDriver()
								end
							end
						end
					end

					if self.timer:GetSeconds() - segment.time > 30 then
						table.remove(segments, k)
					end
				end
			end
		end

		if LocalPlayer:InVehicle() then
			local vehicle = LocalPlayer:GetVehicle()
			local distance = LocalPlayer:GetPosition():Distance(self.stateArgs.position)

			if vehicle:GetLinearVelocity():Length() > 8 and distance <= self.stateArgs.maxRadius then
				self.timer:Restart()
			end

			if self.timer:GetSeconds() > 5 and not self.collisionFired then
				Network:Send( "Collision", {
					vehicle = vehicle
				} )
				self.collisionFired = true
			end
		end
	end
end

function Tron:Render()
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
		DrawCenteredShadowedText( Vector2( Render.Width / 2, 70 ), math.max(math.ceil(3 - self.timer:GetSeconds()), 1) .. "", Color( 255, 255, 255 ), TextSize.Huge )
	elseif self.state == GamemodeState.INPROGRESS then

		if LocalPlayer:InVehicle() then
			if gamepad then
				DrawCenteredShadowedText( Vector2( Render.Width / 2, Render.Height - 35 ), self.tip1_txt, Color.Yellow )
			else
				DrawCenteredShadowedText( Vector2( Render.Width / 2, Render.Height - 35 ), self.tip2_txt, Color.Yellow )
			end
		else
			if gamepad then
				DrawCenteredShadowedText( Vector2( Render.Width / 2, Render.Height - 35 ), self.tip3_txt, Color.Yellow )
			else
				DrawCenteredShadowedText( Vector2( Render.Width / 2, Render.Height - 35 ), self.tip4_txt, Color.Yellow )
			end
		end

		if LocalPlayer:InVehicle() then
			local distance = LocalPlayer:GetPosition():Distance(self.stateArgs.position)

			if self.timer:GetSeconds() > 2 and distance < self.stateArgs.maxRadius then
				DrawCenteredShadowedText( Render.Size / 2, self.nameTFo .. math.max(math.ceil(5 - self.timer:GetSeconds()), 1) .. "...", Color.Red, TextSize.Huge )
			elseif self.timer:GetSeconds() > 0 and distance >= self.stateArgs.maxRadius then
				DrawCenteredShadowedText( Render.Size / 2, self.nameTFi .. math.max(math.ceil(5 - self.timer:GetSeconds()), 1) .. "...", Color.Red, TextSize.Huge )
			end
		end

		if not LocalPlayer:InVehicle() then
			for player in Client:GetPlayers() do
				if player:InVehicle() then
					local position, visible = Render:WorldToScreen(player:GetPosition())
					local vehicle = player:GetVehicle()

					if visible then
						local color1, color2 = vehicle:GetColors()
						DrawCenteredShadowedText( position, player:GetName(), color1 )
					end
				end
			end
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
			local color = self.state ~= GamemodeState.PREPARING and Color.Black or Color.Gray

			if player:InVehicle() then
				color = player:GetVehicle():GetColors()
			end

			DrawCenteredShadowedText( Vector2( Render.Width - 75, Render.Height - 75 - (k * 20) ), player:GetName(), color )
		end

		DrawCenteredShadowedText( Vector2( Render.Width - 75, Render.Height - 75 - ((#players + 1) * 20) ), self.nameT, Color.White, 20 )
	end
end

function Tron:GameRenderOpaque()
	if self.state == GamemodeState.INPROGRESS then
		for k, segments in pairs(self.segments) do
			for k, segment in ipairs(segments) do
				segment:Render()
			end
		end
	end
	if self.state == GamemodeState.INPROGRESS or self.state == GamemodeState.COUNTDOWN or self.state == GamemodeState.PREPARING then
		Render:FillArea( Vector2.Zero, Render.Size, Color( 0, 0, 255, 20 ) )
	end
end

Tron()