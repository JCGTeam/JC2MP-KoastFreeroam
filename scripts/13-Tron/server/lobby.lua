class "Lobby"

values = { 100, 150, 200, 250, 300, 350, 400, 450, 500 }

function Lobby:__init( config )
	self.state = GamemodeState.WAITING
	self.world = World.Create()
	self.timer = Timer()
	self.queue = Set()
	self.playerOrigins = {}
	self.startingTime = 0
	self.waitingTime = 30

	vmoney = values[math.random(#values)]

	self.name = config.name
	self.position = config.position
	self.deathPosition = config.deathPosition or (config.position + (Vector3.Up * 1000))
	self.radius = config.radius or TronConfig.Defaults.Radius
	self.maxRadius = config.maxRadius or TronConfig.Defaults.MaxRadius
	self.vehicles = config.vehicles or TronConfig.Defaults.Vehicles
	self.minPlayers = math.max(config.minPlayers or TronConfig.Defaults.MinPlayers, 2)
	self.maxPlayers = math.max(config.maxPlayers or TronConfig.Defaults.MaxPlayers, self.minPlayers)

	self.world:SetTime( 0 )
	self.world:SetTimeStep( 0 )

	for k, args in ipairs(config.props or {}) do
		args.world = self.world
		StaticObject.Create(args)
	end

	self.networkEvents = {
		Network:Subscribe( "Collision", self, self.Collision ),
		Network:Subscribe( "Firing", self, self.Firing )
	}

	self.events = {
		Events:Subscribe( "PreTick", self, self.PreTick ),
		Events:Subscribe( "PlayerQuit", self, self.PlayerQuit ),
		Events:Subscribe( "PlayerWorldChange", self, self.PlayerWorldChange )
	}
end

function Lobby:GetQueue()
	return self.queue
end

function Lobby:AddToQueue( player )
	self:GetQueue():Add(player)

	if self:GetQueue():GetSize() >= self.minPlayers then
		self:Broadcast( player:GetName() .. " присоединился.", Color( 228, 142, 56 ), player )

		if self:GetQueue():GetSize() == self.maxPlayers then
			self:SetState(GamemodeState.PREPARING)
		else
			self.startingTime = self.timer:GetSeconds() + 30

			if self:GetQueue():GetSize() == self.minPlayers then
				self:Broadcast( "Игра начинается через: " .. math.ceil(self.startingTime - self.timer:GetSeconds()) .. " секунд.", Color( 228, 142, 56 ) )
			else
				--self:Broadcast("Wait time extended.", Color.Yellow, player)
			end
		end
	else
		self.timer:Restart()
	end

	Network:Send( player, "EnterLobby" )
	self:NetworkBroadcast( "UpdateQueue", {
		queue = self:GetQueue():GetItems(),
		min = self.minPlayers,
		max = self.maxPlayers
	} )
end

function Lobby:RemoveFromQueue( player )
	self:GetQueue():Remove(player)

	self:Broadcast( player:GetName() .. " вышел.", Color( 228, 142, 56 ), player )

	if self:GetQueue():GetSize() < self.minPlayers then
		self:Broadcast( "Недостаточно игроков для начала, обратный отсчет остановлен.", Color( 228, 142, 56 ), player )

		self.startingTime = 0
		self.timer:Restart()
	end

	Network:Send( player, "ExitLobby" )
	self:NetworkBroadcast( "UpdateQueue", {
		queue = self:GetQueue():GetItems(),
		min = self.minPlayers,
		max = self.maxPlayers
	} )
end

function Lobby:GetState()
	return self.state
end

function Lobby:SetState( state, stateArgs )
	self.state = state

	self:NetworkBroadcast( "StateChange", {
		state = state,
		stateArgs = stateArgs or {}
	} )
end

function Lobby:GetPlayers()
	return self.world:GetPlayers()
end

function Lobby:GetPlayerCount()
	local count = 0

	for player in self:GetPlayers() do
		count = count + 1
	end

	return count
end

function Lobby:Broadcast( message, color, sender )
	if self:GetState() == GamemodeState.WAITING then
		for k, player in ipairs(self:GetQueue():GetItems()) do
			if player ~= sender then
				Tron.SendMessage( player, message, color )
			end
		end
	else
		for player in self:GetPlayers() do
			if player ~= sender then
				Tron.SendMessage( player, message, color )
			end
		end
	end
end

function Lobby:NetworkBroadcast( event, args )
	if self:GetQueue():GetSize() > 0 then
		for k, player in ipairs(self:GetQueue():GetItems()) do
			Network:Send( player, event, args )
		end
	else
		for player in self:GetPlayers() do
			Network:Send( player, event, args )
		end
	end
end

function Lobby:Collision( args, sender )
	for player in self:GetPlayers() do
		if player == sender then
			if args.fell then
				self:Broadcast( player:GetName() .. " упал со своего транспортного средства.", Color( 228, 142, 56 ), player )
				Tron.SendMessage( player, "Ты упал со своего транспортного средства.", Color( 228, 142, 56 ), player )

				args.vehicle:Remove()
			else
				if args.killer and args.killer:GetDriver() then
					if args.killer:GetDriver() == player then
						self:Broadcast( player:GetName() .. " врезался в собственный след! Эпический провал!", Color( 228, 142, 56 ), player )
						Tron.SendMessage( player, "Вы врезались в свой собственный след! Эпический провал!", Color( 228, 142, 56 ), player )
					else
						self:Broadcast( player:GetName() .. " врезался в след " .. args.killer:GetDriver():GetName() .. ".", Color( 228, 142, 56 ), player )
						Tron.SendMessage( player, "Вы врезались в след " .. args.killer:GetDriver():GetName() .. ". Сожалеем, но вы проиграли :(", Color( 228, 142, 56 ), player )
					end
				else
					self:Broadcast( player:GetName() .. " взорвался.", Color( 228, 142, 56 ), player )
					Tron.SendMessage( player, "Вы взорвались", Color( 228, 142, 56 ), player  )
				end

				args.vehicle:SetHealth( 0 )
			end

			player:SetHealth( 1 )
			player:SetPosition( self.deathPosition )
		end
	end
end

function Lobby:Firing( args, sender )
	for player in self:GetPlayers() do
		if player == sender then
			sender:SetNetworkValue( "TronFiring", args.TronFiring )
		end
	end
end

function Lobby:PreTick()
	local state = self:GetState()

	if state == GamemodeState.WAITING then
		if self.timer:GetSeconds() >= self.startingTime and self.startingTime ~= 0 then
			self:Broadcast( "Запуск трона с " .. self:GetQueue():GetSize() .. " игроками!", Color( 228, 142, 56 ) )
			self:SetState(GamemodeState.PREPARING)
		elseif self.startingTime == 0 and self.timer:GetSeconds() > 600 then
			local playerCount = self:GetQueue():GetSize()

			if playerCount == 0 then
				Tron.Broadcast( "Присоединяйся в трон! Главный приз: $" .. vmoney .. "! ( Карта: " .. self.name .. " )", Color( 228, 142, 56 ) )
			else
				Tron.Broadcast( "Трон с " .. playerCount .. " игрок" .. (playerCount == 1 and "ом" or "мя") .. " в ожидание начала! ( Карта: " .. self.name .. " )", Color( 228, 142, 56 ) )
			end

			self.timer:Restart()
		end
	elseif state == GamemodeState.PREPARING then
		if self:GetQueue():GetSize() > 0 then
			local center = self.position
			local hue = math.random(360)
			local theta = math.random() * math.pi * 2

			for k, player in ipairs(self:GetQueue():GetItems()) do
				local angle = Angle(theta, 0, 0)
				local position = center + (angle * (Vector3.Forward * self.radius))
				local color = Color.FromHSV(hue, 1, 1)

				local vehicleArgs = {
					model_id = 43,
					position = position,
					angle = angle,
					world = self.world,
					tone1 = color,
					tone2 = color,
					invulnerable = true
				}

				for k, v in pairs(self.vehicles[math.random(1, #self.vehicles)]) do
					vehicleArgs[k] = v
				end

				local vehicle = Vehicle.Create(vehicleArgs)

				player:SetWorld(self.world)
				player:SetNetworkValue( "GameMode", "Трон" )
				player:SetPosition(position + (Vector3.Up * 5))
				player:ClearInventory()

				player:SetValue("TronVehicle", vehicle:GetId())
				player:SetNetworkValue("TronFiring", true)

				theta = theta + ((math.pi * 2) / self:GetQueue():GetSize()) % (math.pi * 2)
				hue = math.floor(hue + (360 / self:GetQueue():GetSize())) % 360
			end

			self:GetQueue():Clear()
		else
			local playerCount = self:GetPlayerCount()
			local playersInVehicles = self:GetPlayersInVehicles()

			for player in self:GetPlayers() do
				local vehicle = Vehicle.GetById(player:GetValue("TronVehicle"))

				if not player:GetVehicle() and IsValid(vehicle) then
					player:EnterVehicle(vehicle, VehicleSeat.Driver)
				end
			end

			if playerCount == #playersInVehicles or (self.timer:GetSeconds() - self.startingTime) >= self.waitingTime then
				for player in self:GetPlayers() do
					if not table.find(playersInVehicles, player) then
						Tron.SendMessage( player, "К сожалению, вы были удалены из лобби, чтобы предотвратить высокое время загрузки других игроков(", Color( 228, 142, 56 ) )
						player:SetNetworkValue( "GameMode", "FREEROAM" )
						player:SetWorld(DefaultWorld)
					end
				end

				for vehicle in self.world:GetVehicles() do
					vehicle:SetUnoccupiedRemove( true )
					vehicle:SetUnoccupiedRespawnTime( 1 )

					if not vehicle:GetDriver() then
						vehicle:Remove()
					end
				end

				if #self:GetPlayersInVehicles() >= self.minPlayers then
					self.timer:Restart()
					self:SetState(GamemodeState.COUNTDOWN)
				else
					self:Broadcast( "Недостаточно игроков для продолжения. Сожалеем(", Color( 228, 142, 56 ) )
					self:Disband()
				end
			end
		end
	elseif state == GamemodeState.COUNTDOWN then
		if self.timer:GetSeconds() > 3 then
			self:SetState(GamemodeState.INPROGRESS, {
				position = self.position,
				maxRadius = self.maxRadius,
			})
		end
	elseif state == GamemodeState.INPROGRESS then
		local playerCount = self:GetPlayerCount()
		local playersInVehicles = self:GetPlayersInVehicles()

		if #playersInVehicles == 1 then
			self:Disband(playersInVehicles[1])
		elseif #playersInVehicles == 0 and playerCount > 1 then -- Corner case.. this shouldn't ever happen -- but there's no reliable way to prevent it
			self:Broadcast( "Игра завершилась в ничью!", Color( 228, 142, 56 ) )
			self:Disband()
		elseif playerCount == 1 then
			for player in self:GetPlayers() do
				self:Disband(player)
			end
		elseif playerCount == 0 then
			self:Disband()
		end
	elseif state == GamemodeState.ENDING then
		if self:GetPlayerCount() == 0 then
			self:Remove()
		end
	end
end

function Lobby:PlayerQuit( args )
	local player = args.player

	if self:GetState() > GamemodeState.WAITING then
		local players = {}

		for player in self:GetPlayers() do
			table.insert(players, player)
		end

		if table.find(players, player) then
			self:Broadcast( player:GetName() .. " отсоединены.", Color( 228, 142, 56 ), player )
		end
	elseif self:GetQueue():Contains(player) then
		self:RemoveFromQueue(player)
	end
end

function Lobby:PlayerWorldChange( args )
	local player = args.player

	if self.world == args.new_world then
		self.playerOrigins[player:GetId()] = {
			position = player:GetPosition() + (Vector3.Up * 5),
			angle = player:GetAngle(),
			inventory = player:GetInventory()
		}
	elseif self.world == args.old_world then
		player:SetPosition(self.playerOrigins[player:GetId()].position)
		player:SetAngle(self.playerOrigins[player:GetId()].angle)

		for slot, weapon in pairs(self.playerOrigins[player:GetId()].inventory) do
			player:GiveWeapon(slot, weapon)
		end

		if self:GetState() < GamemodeState.ENDING then
			self:Broadcast( player:GetName() .. " покинул лобби.", Color( 228, 142, 56 ), player )
			Tron.SendMessage( args.player, "Вы покинули лобби.", Color( 228, 142, 56 ) )
			player:SetNetworkValue( "GameMode", "FREEROAM" )
		end
	elseif self:GetState() == GamemodeState.WAITING and self:GetQueue():Contains(player) then -- Catch people switching worlds during waiting period
		self:RemoveFromQueue(player)
		Tron.SendMessage( player, "Мир игры изменился, удалив вас из очереди(", Color( 228, 142, 56 ) )
	end
end

function Lobby:GetPlayersInVehicles()
	local players = {}

	for player in self:GetPlayers() do
		if player:InVehicle() and player:GetVehicle():GetHealth() > 0 then -- Note: The > 0 checks results in some matches ending without a collision being detected for some reasons.. but we need it
			table.insert(players, player)
		end
	end

	return players
end

function Lobby:Disband( winner )
	self:SetState(GamemodeState.ENDING)
	vmoney = values[math.random(#values)]

	if winner then
		self:Broadcast( winner:GetName() .. " победил!", Color( 228, 142, 56 ) )
		winner:SetMoney( winner:GetMoney() + vmoney )
		Chat:Broadcast( "[Трон] ", Color.White, winner:GetName(), winner:GetColor(), " победил в трон и выиграл $" .. vmoney .. "!", Color( 228, 142, 56 ) )
		if winner:GetValue( "TronWins" ) then
			winner:SetNetworkValue( "TronWins", winner:GetValue( "TronWins" ) + 1 )
		end
	end

	for player in self:GetPlayers() do
		player:SetNetworkValue( "GameMode", "FREEROAM" )
		player:SetWorld(DefaultWorld)
	end
end

function Lobby:Remove()
	self:SetState(GamemodeState.ENDED)
	self.world:Remove()

	for k, event in ipairs(self.networkEvents) do
		Network:Unsubscribe(event)
	end

	for k, event in ipairs(self.events) do
		Events:Unsubscribe(event)
	end
end