class 'ServerTetris'

function ServerTetris:__init()
	self.leaderboard = {}
	self.sortedLeaderboard = {}
	self.names = {}

	Network:Subscribe( "NewScore", self, self.NewScore )
	Network:Subscribe( "TopScores", self, self.TopScores )

	self:initVars()

	Events:Subscribe( "PostTick", self, self.onPostTick )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
	Events:Subscribe( "ModuleLoad", self, self.onModuleLoad )

	Network:Subscribe( "001", self, self.onTetrisRecord )
	Network:Subscribe( "002", self, self.onTetrisAttempt )
end

function ServerTetris:onModuleLoad()
	NetworkObject.Create("Tetris")
end

function ServerTetris:PlayerChat( args )
	local object = NetworkObject.GetByName("Tetris") or NetworkObject.Create("Tetris")
	if args.text == "/cleartetris" then
		if args.player:GetValue("Tag") == "Creator" or args.player:GetValue("Tag") == "GlAdmin" then
			self:Reward(object:GetValue("N"), true)
			object:SetNetworkValue("S", nil)
			object:SetNetworkValue("N", nil)
			object:SetNetworkValue("P", nil)
			object:SetNetworkValue("E", nil)
			object:SetNetworkValue("C", nil)
			object:SetNetworkValue("I", nil)
		return
		end
	end
end

function ServerTetris:initVars()
	self.timer = Timer()
	self.delay = 240
end

function ServerTetris:onPostTick()
	if self.timer:GetSeconds() < self.delay then return end
	self.timer:Restart()
	local object = NetworkObject.GetByName("Tetris") or NetworkObject.Create("Tetris")
	if not object:GetValue("E") then return end
	local expire = object:GetValue("E") - 1
	if expire < 1 then
		self:Reward(object:GetValue("N"), true)
		object:SetNetworkValue("S", nil)
		object:SetNetworkValue("N", nil)
		object:SetNetworkValue("P", nil)
		object:SetNetworkValue("E", nil)
		object:SetNetworkValue("C", nil)
		object:SetNetworkValue("I", nil)
		return
	else
		self:Reward(object:GetValue("N"), false)
	end
	object:SetNetworkValue("E", expire)
end

function ServerTetris:onTetrisRecord( score, player )
	local object = NetworkObject.GetByName("Tetris") or NetworkObject.Create("Tetris")
	if score < (object:GetValue("S") or 0) then return end
	if object:GetValue("N") ~= player:GetName() then
		if object:GetValue("N") ~= nil then
			player:SetMoney( player:GetMoney() + 50 )
			if player:GetValue( "Lang" ) == "ENG" then
				player:SendChatMessage( "[Record] ", Color.White, "Reward: $50 for a new tetris record!", Color( 255, 150, 0 ) )
			else
				player:SendChatMessage( "[Рекорд] ", Color.White, "Награда: $50 за новый рекорд по тетрису!", Color( 255, 150, 0 ) )
			end

			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "ENG" then
					p:SendChatMessage( "[Record] ", Color.White, player:GetName() .. " has broken the player's tetris record " .. object:GetValue("N") .. ", his reward: $150!", Color( 255, 150, 0 ) )
				else
					p:SendChatMessage( "[Рекорд] ", Color.White, player:GetName() .. " побил рекорд по тетрису игрока " .. object:GetValue("N") .. ", его награда: $150!", Color( 255, 150, 0 ) )
				end
			end
		else
			player:SetMoney( player:GetMoney() + 50 )
			if player:GetValue( "Lang" ) == "ENG" then
				player:SendChatMessage( "[Record] ", Color.White, "Reward: $50 for a new tetris record!", Color( 255, 150, 0 ) )
			else
				player:SendChatMessage( "[Рекорд] ", Color.White, "Награда: $50 за новый рекорд по тетрису!", Color( 255, 150, 0 ) )
			end

			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "ENG" then
					p:SendChatMessage( "[Record] ", Color.White, player:GetName() .. " set a new tetris record: " .. score .. "!", Color( 255, 150, 0 ) )
				else
					p:SendChatMessage( "[Рекорд] ", Color.White, player:GetName() .. " установил новый рекорд по тетрису: " .. score .. "!", Color( 255, 150, 0 ) )
				end
			end
		end
	else
		for p in Server:GetPlayers() do
			if p:GetValue( "Lang" ) == "ENG" then
				p:SendChatMessage( "[Record] ", Color.White, player:GetName() .. " updated a tetris record: " .. score .. "!", Color( 255, 150, 0 ) )
			else
				p:SendChatMessage( "[Рекорд] ", Color.White, player:GetName() .. " обновил хорошечный рекорд по тетрису: " .. score .. "!", Color( 255, 150, 0 ) )
			end
		end
	end

	object:SetNetworkValue("S", score)
	object:SetNetworkValue("N", player:GetName())
	object:SetNetworkValue("P", player)
	object:SetNetworkValue("E", 10)
	object:SetNetworkValue("C", player:GetColor())
	object:SetNetworkValue("I", player:GetSteamId())
	self.timer:Restart()
end

function ServerTetris:onTetrisAttempt( score, player )
	Network:Broadcast( "003", {score, player:GetId() + 1} )
end

function ServerTetris:Reward( name, last )
	for player in Server:GetPlayers() do
		if player:GetName() == name then
			if not last then
				player:SetMoney( player:GetMoney() + 15 )
				if player:GetValue( "Lang" ) == "ENG" then
					player:SendChatMessage( "[Record] ", Color.White, "Reward: $15 for keeping tetris record!", Color( 255, 150, 0 ) )
				else
					player:SendChatMessage( "[Рекорд] ", Color.White, "Награда: $15 за удержание рекорда по тетрису!", Color( 255, 150, 0 ) )
				end
			else
				player:SetMoney( player:GetMoney() + 500 )
				if player:GetValue( "Lang" ) == "ENG" then
					player:SendChatMessage( "[Record] ", Color.White, "You won a fantastic tetris! Your reward: $500!", Color( 255, 150, 0 ) )
				else
					player:SendChatMessage( "[Рекорд] ", Color.White, "Вы победили в хорошечном тетрисе! Ваша награда: $500!", Color( 255, 150, 0 ) )
				end

				for p in Server:GetPlayers() do
					if p:GetValue( "Lang" ) == "ENG" then
						p:SendChatMessage( "[Record] ", Color.White, player:GetName() .. " won a fantastic tetris and won $500!", Color( 255, 150, 0 ) )
					else
						p:SendChatMessage( "[Рекорд] ", Color.White, player:GetName() .. " победил в хорошечном тетрисе и выиграл $500!", Color( 255, 150, 0 ) )
					end
				end
			end
		end
	end
end

function ServerTetris:NewScore( score, player )
	if self.leaderboard[player:GetSteamId().id] and self.leaderboard[player:GetSteamId().id] > score then
	else
		self.leaderboard[player:GetSteamId().id] = score
		self.names[player:GetSteamId().id] = player:GetName()
		self:SortLeaderboard()
	end

	if player:GetValue( "TetrisRecord" ) then
		player:SetNetworkValue( "TetrisRecord", score )
	end
end

function ServerTetris:TopScores( args, player )
	Network:Send( player, "NewLeaderboard", self.sortedLeaderboard )
end

function ServerTetris:SortLeaderboard()
	local tData = {}
	for u,v in pairs(self.leaderboard) do
		table.insert(tData,{name=self.names[u],score=v})
	end
	self.sortedLeaderboard = quicksort(tData)
	Network:Broadcast( "NewLeaderboard", self.sortedLeaderboard )
end

function quicksort( array )
	if #array <= 1 then
		return array
	end
	local pivot = array[math.floor(#array/2)]
	table.remove(array, math.floor(#array/2))
	local less = {}
	local greater = {}
	for _,x in pairs(array) do
		if x.score <= pivot.score then
			less[#less+1] = x
		else
			greater[#greater+1] = x
		end
	end
	local ret = quicksort(greater)
	ret[#ret+1] = pivot
	for _, k in pairs(quicksort(less)) do
		ret[#ret+1] = k
	end
	return ret
end

serverTetris = ServerTetris()