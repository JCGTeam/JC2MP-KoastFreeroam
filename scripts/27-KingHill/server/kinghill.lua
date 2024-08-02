class "KingHill"

function KingHill:__init()
	self.lobbies = {}
	self.admins = {"STEAM_0:0:90087002"}

	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
	Events:Subscribe( "PreTick", self, self.PreTick )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function KingHill.SendMessage( player, message, color )
	Chat:Send( player, "[Царь Горы] ", Color.White, message, color )
end

function KingHill.Broadcast( message, color )
	for player in Server:GetPlayers() do
		KingHill.SendMessage( player, message, color )
	end
end

function KingHill:ModuleUnload()
	for k, lobby in ipairs(self.lobbies) do
		lobby:Disband()
	end
end

function KingHill:PreTick()
	for k, lobby in ipairs(self.lobbies) do
		if lobby:GetState() == GamemodeState.ENDED then
			table.remove(self.lobbies, k)
		end
	end

	if #self.lobbies == 0 then
		table.insert(self.lobbies, Lobby(KingHillConfig.Maps[math.random(1, #KingHillConfig.Maps)]))
	end
end

function KingHill:PlayerChat( args )
	local player = args.player
	local message = args.text

	if message:sub(0, 1) == "/" then
		local invalidCommand = false
		local args = Utils.GetArgs(message:sub(2))

		if args[1] == "khill" then
			local targetLobby = false

			for k, lobby in ipairs(self.lobbies) do
				if lobby:GetState() == GamemodeState.WAITING and lobby:GetQueue():GetSize() < lobby.maxPlayers then
					if lobby:GetQueue():Contains(player) then
						lobby:RemoveFromQueue(player)
						KingHill.SendMessage( player, "Вы были удалены из очереди на Царь Горы (Карта: " .. lobby.name .. "!", Color( 228, 142, 56 ) )

						if not args[2] or lobby.name:lower():match(args[2]:lower()) then
							return false
						end
					elseif not targetLobby then
						if not args[2] or lobby.name:lower():match(args[2]:lower()) then
							targetLobby = lobby
						end
					end
				elseif lobby:GetState() > GamemodeState.WAITING then
					for cPlayer in lobby.world:GetPlayers() do
						if player == cPlayer then
							targetLobby = lobby
							break
						end
					end
				end
			end

			if not targetLobby then
				local index = false

				if args[2] then
					for k, map in ipairs(KingHillConfig.Maps) do
						if map.name:lower():match(args[2]:lower()) then
							index = k
							break
						end
					end
				else
					index = math.random(1, #KingHillConfig.Maps)
				end

				if index then
					targetLobby = Lobby(KingHillConfig.Maps[index])
					table.insert(self.lobbies, targetLobby)
				else
					KingHill.SendMessage( player, "Не нашли карту с именем " .. args[2] .. "!", Color( 228, 142, 56 ) )
					return false
				end
			end

			if targetLobby:GetState() > GamemodeState.WAITING then
				player:SetWorld(DefaultWorld)
				player:SetNetworkValue( "GameMode", "FREEROAM" )
			else
				if player:GetWorld() == DefaultWorld then
					targetLobby:AddToQueue(player)
					KingHill.SendMessage( player, "Вы были добавлены в очередь на Царь Горы (Карта: " .. targetLobby.name .. ")", Color( 228, 142, 56 ) )
				else
					KingHill.SendMessage( player, "Пожалуйста, выйдите из текущего мода!", Color( 228, 142, 56 ) )
				end
			end
		elseif args[1] == "forcekhill" then
			if player:GetValue( "Tag" ) == "Creator" or player:GetValue( "Tag" ) == "GlAdmin" then
				for k, lobby in pairs(self.lobbies) do
					lobby:Disband()
				end

				local config = KingHillConfig.Maps[math.random(1, #KingHillConfig.Maps)]

				if not args[2] then
					config.maxPlayers = tonumber(Config:GetValue("Server", "MaxPlayers"))
				else
					local index = math.random(1, #KingHillConfig.Maps)

					for k, map in ipairs(KingHillConfig.Maps) do
						if map.name:lower():match(tostring(args[2]):lower()) then
							index = k
							break
						end
					end

					config = KingHillConfig.Maps[index]
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
			end
		elseif args[1] == "khilllobbies" then
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

			KingHill.SendMessage( player, "Сейчас есть " .. lobbyCount .. " лобби в процессе ожидания и " .. playerCount .. " активны" .. plural(playerCount, "х", "й") .. " " .. plural(playerCount, "игроков", "игрок") .. ".", Color( 228, 142, 56 ) )
		elseif args[1] == "khilllist" then
			local mapstrings = {""}

			for k, map in ipairs(KingHillConfig.Maps) do
				if #mapstrings[#mapstrings] > 0 then
					mapstrings[#mapstrings] = mapstrings[#mapstrings] .. ", "
				end

				if #mapstrings[#mapstrings] + #map.name < 100 then
					mapstrings[#mapstrings] = mapstrings[#mapstrings] .. map.name
				elseif k <= #KingHillConfig.Maps then
					mapstrings[#mapstrings + 1] = map.name
				end
			end

			KingHill.SendMessage( player, "Лист:", Color( 228, 142, 56 ) )

			for k, string in ipairs(mapstrings) do
				player:SendChatMessage( string, Color.DarkGray )
			end
		elseif args[1] == "khillhelp" then
			KingHill.SendMessage( player, "Список Команд:", Color( 228, 142, 56 ) )

			player:SendChatMessage( "/khill - зайти в лобби.", Color.DarkGray )
			player:SendChatMessage( "/khilllist - лист локаций.", Color.DarkGray )
			player:SendChatMessage( "/khilllobbies - активные игры.", Color.DarkGray )
		else
			invalidCommand = true
		end

		if not invalidCommand then
			return false
		end
	end
end

KingHill()