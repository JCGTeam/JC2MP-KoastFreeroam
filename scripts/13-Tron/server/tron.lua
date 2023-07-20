class "Tron"

function Tron:__init()
	self.lobbies = {}

	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
	Events:Subscribe( "PreTick", self, self.PreTick )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function Tron.SendMessage( player, message, color )
	Chat:Send( player, "[Трон] ", Color.White, message, color )
end

function Tron.Broadcast( message, color )
	for player in Server:GetPlayers() do
		Tron.SendMessage( player, message, color )
	end
end

function Tron:ModuleUnload()
	for k, lobby in ipairs(self.lobbies) do
		lobby:Disband()
	end
end

function Tron:PreTick()
	for k, lobby in ipairs(self.lobbies) do
		if lobby:GetState() == GamemodeState.ENDED then
			table.remove(self.lobbies, k)
		end
	end

	if #self.lobbies == 0 then
		table.insert(self.lobbies, Lobby(TronConfig.Maps[math.random(1, #TronConfig.Maps)]))
	end
end

function Tron:PlayerChat( args )
	local player = args.player
	local message = args.text

	if message:sub(0, 1) == "/" then
		local invalidCommand = false
		local args = Utils.GetArgs(message:sub(2))

		if args[1] == "tron" then
			local targetLobby = false

			for k, lobby in ipairs(self.lobbies) do
				if lobby:GetState() == GamemodeState.WAITING and lobby:GetQueue():GetSize() < lobby.maxPlayers then
					if lobby:GetQueue():Contains(player) then
						lobby:RemoveFromQueue(player)
						Tron.SendMessage( player, "Вы были удалены из очереди на трон (Карта: " .. lobby.name .. ")", Color( 228, 142, 56 ) )

						if not args[2] or lobby.name:lower():match(args[2]:lower()) then
							return false
						end
					elseif not targetLobby then
						if not args[2] or lobby.name:lower():match(args[2]:lower()) then
							targetLobby = lobby
						end
					end
				elseif lobby:GetState() > GamemodeState.WAITING then
					if lobby.world then
						for cPlayer in lobby.world:GetPlayers() do
							if player == cPlayer then
								targetLobby = lobby
								break
							end
						end
					end
				end
			end

			if not targetLobby then
				local index = false

				if args[2] then
					for k, map in ipairs(TronConfig.Maps) do
						if map.name:lower():match(args[2]:lower()) then
							index = k
							break
						end
					end
				else
					index = math.random(1, #TronConfig.Maps)
				end

				if index then
					targetLobby = Lobby(TronConfig.Maps[index])
					table.insert(self.lobbies, targetLobby)
				else
					Tron.SendMessage( player, "Не нашли карту с именем " .. args[2] .. "!", Color( 228, 142, 56 ) )
					return false
				end
			end

			if targetLobby:GetState() > GamemodeState.WAITING then
				player:SetWorld(DefaultWorld)
				player:SetNetworkValue( "GameMode", "FREEROAM" )
			else
				if player:GetWorld() == DefaultWorld then
					targetLobby:AddToQueue(player)
					Tron.SendMessage( player, "Вы были добавлены в очередь на трон (Карта: " .. targetLobby.name .. ")", Color( 228, 142, 56 ) )
				else
					Tron.SendMessage( player, "Пожалуйста, выйдите из текущего мода!", Color( 228, 142, 56 ) )
				end
			end
		elseif args[1] == "forcetron" then
			if player:GetValue( "Tag" ) == "Creator" or player:GetValue( "Tag" ) == "GlAdmin" then
				for k, lobby in pairs(self.lobbies) do
					lobby:Disband()
				end

				local config = TronConfig.Maps[math.random(1, #TronConfig.Maps)]

				if not args[2] then
					config.maxPlayers = tonumber(Config:GetValue("Server", "MaxPlayers"))
				else
					local index = math.random(1, #TronConfig.Maps)

					for k, map in ipairs(TronConfig.Maps) do
						if map.name:lower():match(tostring(args[2]):lower()) then
							index = k
							break
						end
					end

					config = TronConfig.Maps[index]
				end

				local lobby = Lobby(config)

				for player in Server:GetPlayers() do
					if player:GetWorld() == DefaultWorld then
						lobby:GetQueue():Add(player)
						Network:Send(player, "EnterLobby")
					end
				end

				lobby.startingTime = lobby.timer:GetSeconds()

				table.insert(self.lobbies, lobby)
			else
				Tron.SendMessage( player, "У вас нет разрешения, чтобы сделать это!", Color.Red )
			end
		elseif args[1] == "tronlobbies" then
			local lobbyCount = #self.lobbies
			local playerCount = 0

			for k, lobby in pairs(self.lobbies) do
				if lobby:GetState() == GamemodeState.WAITING then
					playerCount = playerCount + lobby:GetQueue():GetSize()
				else
					playerCount = playerCount + lobby:GetPlayerCount()
				end
			end

			function plural(count, plural, notPlural)
				if count ~= 1 then
					return plural
				else
					return notPlural
				end
			end

			Tron.SendMessage( player, "Сейчас есть " .. lobbyCount .. " лобби в процессе ожидания и " .. playerCount .. " активны" .. plural(playerCount, "х", "й") .. " " .. plural(playerCount, "игроков", "игрок") .. ".", Color( 228, 142, 56 ) )
		elseif args[1] == "tronlist" then
			local mapstrings = {""}

			for k, map in ipairs(TronConfig.Maps) do
				if #mapstrings[#mapstrings] > 0 then
					mapstrings[#mapstrings] = mapstrings[#mapstrings] .. ", "
				end

				if #mapstrings[#mapstrings] + #map.name < 100 then
					mapstrings[#mapstrings] = mapstrings[#mapstrings] .. map.name
				elseif k <= #TronConfig.Maps then
					mapstrings[#mapstrings + 1] = map.name
				end
			end

			Tron.SendMessage( player, "Лист:", Color( 228, 142, 56 ) )

			for k, string in ipairs(mapstrings) do
				player:SendChatMessage( string, Color.DarkGray )
			end
		elseif args[1] == "tronhelp" then
			Tron.SendMessage( player, "Список Команд:", Color( 228, 142, 56 ) )

			player:SendChatMessage( "/tron - зайти в лобби.", Color.DarkGray )
			player:SendChatMessage( "/tronlist - лист локаций.", Color.DarkGray )
			player:SendChatMessage( "/tronlobbies - активные игры.", Color.DarkGray )
		else
			invalidCommand = true
		end

		if not invalidCommand then
			return false
		end
	end
end

Tron()