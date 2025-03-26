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
	Network:Subscribe( "UpdateTotalScore", self, self.UpdateTotalScore )
	Network:Subscribe( "UpdateMaxRecord", self, self.UpdateMaxRecord )

	self.tag_clr = Color.White
	self.text_clr = Color( 185, 215, 255 )
	self.text2_clr = Color( 251, 184, 41 )
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

function ServerTetris:onTetrisRecord( args, player )
	local object = NetworkObject.GetByName("Tetris") or NetworkObject.Create("Tetris")
	local pName = player:GetName()
	local objectN = object:GetValue("N")
	local score = player:GetValue( "TetrisTotalScore" )

	if score < (object:GetValue("S") or 0) then return end
	if objectN ~= pName then
		if objectN ~= nil then
			player:SetMoney( player:GetMoney() + 50 )
			if player:GetValue( "Lang" ) == "EN" then
				player:SendChatMessage( "[Record] ", self.tag_clr, "Reward: $50 for a new tetris record!", self.text2_clr )
			else
				player:SendChatMessage( "[Рекорд] ", self.tag_clr, "Награда: $50 за новый рекорд по тетрису!", self.text2_clr )
			end

			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "EN" then
					p:SendChatMessage( "[Record] ", self.tag_clr, pName .. " has broken the player's tetris record " .. objectN .. ", his reward: $50!", self.text_clr )
				else
					p:SendChatMessage( "[Рекорд] ", self.tag_clr, pName .. " побил рекорд по тетрису игрока " .. objectN .. ", его награда: $50!", self.text_clr )
				end
			end
		else
			player:SetMoney( player:GetMoney() + 50 )
			if player:GetValue( "Lang" ) == "EN" then
				player:SendChatMessage( "[Record] ", self.tag_clr, "Reward: $50 for a new tetris record!", self.text2_clr )
			else
				player:SendChatMessage( "[Рекорд] ", self.tag_clr, "Награда: $50 за новый рекорд по тетрису!", self.text2_clr )
			end

			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "EN" then
					p:SendChatMessage( "[Record] ", self.tag_clr, pName .. " set a new tetris record: " .. score .. "!", self.text_clr )
				else
					p:SendChatMessage( "[Рекорд] ", self.tag_clr, pName .. " установил новый рекорд по тетрису: " .. score .. "!", self.text_clr )
				end
			end
		end
	else
		for p in Server:GetPlayers() do
			if p:GetValue( "Lang" ) == "EN" then
				p:SendChatMessage( "[Record] ", self.tag_clr, pName .. " updated a tetris record: " .. score .. "!", self.text_clr )
			else
				p:SendChatMessage( "[Рекорд] ", self.tag_clr, pName .. " обновил хорошечный рекорд по тетрису: " .. score .. "!", self.text_clr )
			end
		end
	end

	object:SetNetworkValue("S", score)
	object:SetNetworkValue("N", pName)
	object:SetNetworkValue("P", player)
	object:SetNetworkValue("E", 10)
	object:SetNetworkValue("C", player:GetColor())
	object:SetNetworkValue("I", player:GetSteamId())

	self.timer:Restart()
end

function ServerTetris:onTetrisAttempt( args, player )
	Network:Broadcast( "003", {player:GetValue( "TetrisTotalScore" ), player:GetId() + 1} )
end

function ServerTetris:UpdateTotalScore( args, sender )
	if args and args.score then
		sender:SetNetworkValue( "TetrisTotalScore", args.score )
	else
		sender:SetNetworkValue( "TetrisTotalScore", ( sender:GetValue( "TetrisTotalScore" ) or 0 ) + 10 )
	end
end

function ServerTetris:UpdateMaxRecord( score, player )
	if tonumber( player:GetValue( "MaxRecordInBestTetris" ) or 0 ) >= score then return end
	player:SetNetworkValue( "MaxRecordInBestTetris", score )
end

function ServerTetris:Reward( name, last )
	for player in Server:GetPlayers() do
		if player:GetName() == name then
			if not last then
				player:SetMoney( player:GetMoney() + 15 )
				if player:GetValue( "Lang" ) == "EN" then
					player:SendChatMessage( "[Record] ", self.tag_clr, "Reward: $15 for keeping tetris record!", self.text2_clr )
				else
					player:SendChatMessage( "[Рекорд] ", self.tag_clr, "Награда: $15 за удержание рекорда по тетрису!", self.text2_clr )
				end
			else
				player:SetMoney( player:GetMoney() + 500 )
				if player:GetValue( "Lang" ) == "EN" then
					player:SendChatMessage( "[Record] ", self.tag_clr, "You won a fantastic tetris! Your reward: $500!", self.text2_clr )
				else
					player:SendChatMessage( "[Рекорд] ", self.tag_clr, "Вы победили в хорошечном тетрисе! Ваша награда: $500!", self.text2_clr )
				end

				local pName = player:GetName()
				for p in Server:GetPlayers() do
					if p:GetValue( "Lang" ) == "EN" then
						p:SendChatMessage( "[Record] ", self.tag_clr, pName .. " won a fantastic tetris and won $500!", self.text_clr )
					else
						p:SendChatMessage( "[Рекорд] ", self.tag_clr, pName .. " победил в хорошечном тетрисе и выиграл $500!", self.text_clr )
					end
				end
			end
		end
	end
end

function ServerTetris:NewScore( args, player )
	local steamId = player:GetSteamId().id
	local score = player:GetValue( "TetrisTotalScore" )

	if self.leaderboard[steamId] and self.leaderboard[steamId] > score then
	else
		self.leaderboard[steamId] = score
		self.names[steamId] = player:GetName()
		self:SortLeaderboard()
	end

	if player:GetValue( "TetrisRecord" ) then
		player:SetNetworkValue( "TetrisRecord", score )
	end

	self:UpdateMaxRecord( score, player )
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