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
	self.finish = config.finish
	self.deathPosition = config.deathPosition or (config.position )
	self.radius = config.radius or KingHillConfig.Defaults.Radius
	self.maxRadius = config.maxRadius or KingHillConfig.Defaults.MaxRadius
	self.minPlayers = math.max(config.minPlayers or KingHillConfig.Defaults.MinPlayers, 2)
	self.maxPlayers = math.max(config.maxPlayers or KingHillConfig.Defaults.MaxPlayers, self.minPlayers)

	self.world:SetTime( 12 )
	self.world:SetTimeStep( 5 )

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
		Events:Subscribe( "PlayerDeath", self, self.PlayerDeath ),
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
				self.inventory = player:GetInventory()
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
				KingHill.SendMessage( player, message, color )
			end
		end
	else
		for player in self:GetPlayers() do
			if player ~= sender then
				KingHill.SendMessage( player, message, color )
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
			player:SetHealth( 1 )
			player:SetPosition( self.deathPosition )
		end
	end
end

function Lobby:Firing( args, sender )
	for player in self:GetPlayers() do
		if player == sender then
			sender:SetNetworkValue( "KhillFiring", args.KhillFiring )
		end
	end
end

function Lobby:PreTick()
	local state = self:GetState()

	if state == GamemodeState.WAITING then
		if self.timer:GetSeconds() >= self.startingTime and self.startingTime ~= 0 then
			self:Broadcast( "Запуск Царь Горы с " .. self:GetQueue():GetSize() .. " игроками!", Color( 228, 142, 56 ) )
			self:SetState(GamemodeState.PREPARING)
		elseif self.startingTime == 0 and self.timer:GetSeconds() > 900 then
			local playerCount = self:GetQueue():GetSize()

			if playerCount == 0 then
				KingHill.Broadcast( "Присоединяйся в царь горы! Главный приз: $" .. vmoney .. "! ( Карта: " .. self.name .. " )", Color( 228, 142, 56 ) )
			else
				KingHill.Broadcast( "Царь Горы с " .. playerCount .. " игрок" .. (playerCount == 1 and "ом" or "ами") .. " в ожидание начала! ( Карта: " .. self.name .. " )", Color( 228, 142, 56 ) )
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

				player:SetWorld(self.world)
				player:SetNetworkValue( "GameMode", "Царь Горы" )
				player:SetPosition(position + (Vector3.Up * 5))
				player:SetAngle(angle)
				player:SetHealth( 1 )
				player:ClearInventory()
				player:GiveWeapon( 2, Weapon(Weapon.PanayRocketLauncher) )

				player:SetNetworkValue("KhillFiring", true)

				theta = theta + ((math.pi * 2) / self:GetQueue():GetSize()) % (math.pi * 2)
				hue = math.floor(hue + (360 / self:GetQueue():GetSize())) % 360
			end

			self:GetQueue():Clear()
		else
			local playerCount = self:GetPlayerCount()

			if (self.timer:GetSeconds() - self.startingTime) >= self.waitingTime then
				if self.minPlayers then
					self.timer:Restart()
					self:SetState(GamemodeState.COUNTDOWN)
				else
					self:Broadcast( "Недостаточно игроков для продолжения. Сожалеем(", Color( 228, 142, 56 ) )
					self:Disband()
				end
			end
		end
	elseif state == GamemodeState.COUNTDOWN then
		if self.timer:GetSeconds() > 5 then
			self:SetState(GamemodeState.INPROGRESS, {
				position = self.position,
				finish = self.finish,
				maxRadius = self.maxRadius,
			})
		end
	elseif state == GamemodeState.INPROGRESS then
		local playerCount = self:GetPlayerCount()

		for player in self:GetPlayers() do
			if self.finish:Distance(player:GetPosition()) < 20 then
				self:Disband(player)
			elseif playerCount == 0 then
				self:Disband()
				self:Remove()
			end
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
			self:Broadcast( player:GetName() .. " отсоединен.", Color( 228, 142, 56 ), player )
		end
	elseif self:GetQueue():Contains(player) then
		self:RemoveFromQueue(player)
	end
end

function Lobby:PlayerDeath( args )
	for player in self:GetPlayers() do
		if args.killer and args.killer:GetSteamId() ~= player:GetSteamId() then
			args.killer:SetMoney( args.killer:GetMoney() + 30 )
		end
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
			KingHill.SendMessage( args.player, "Вы покинули лобби.", Color( 228, 142, 56 ) )
			player:SetNetworkValue( "GameMode", "FREEROAM" )
			player:ClearInventory()
			for k,v in pairs(self.inventory) do
				player:GiveWeapon( k, v )
			end
		end
	elseif self:GetState() == GamemodeState.WAITING and self:GetQueue():Contains(player) then -- Catch people switching worlds during waiting period
		self:RemoveFromQueue(player)
		KingHill.SendMessage( player, "Мир игры изменился, удалив вас из очереди :(", Color( 228, 142, 56 ) )
	end
end

function Lobby:Disband( winner )
	self:SetState(GamemodeState.ENDING)
	vmoney = values[math.random(#values)]

	if winner then
		self:Broadcast( winner:GetName() .. " победил!", Color.Yellow )
		winner:SetMoney( winner:GetMoney() + vmoney )
		Chat:Broadcast( "[Царь Горы] ", Color.White, winner:GetName(), winner:GetColor(), " забрался на вершину первым и выиграл $" .. vmoney .. "!", Color( 228, 142, 56 ) )
		winner:ClearInventory()
	end

	for player in self:GetPlayers() do
		player:SetWorld(DefaultWorld)
		player:SetNetworkValue( "GameMode", "FREEROAM" )
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