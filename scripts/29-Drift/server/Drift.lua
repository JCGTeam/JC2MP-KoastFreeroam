class "Drift"

function Drift:__init()
	self:initVars()
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
	Network:Subscribe( "01", self, self.onDriftRecord )
	Network:Subscribe( "02", self, self.onDriftAttempt )
	Network:Subscribe( "03", self, self.DriftRecordTask )
	--Network:Subscribe( "setmas", self, self.SetMas ) -- сука блять, майхем, не ломай физику
end

function Drift:initVars()
	self.timer = Timer()
	self.delay = 240
end

--[[
function Drift:SetMas( args, ply )
	if IsValid(args.veh) then
		if args.bool then
			args.veh:SetMass( args.veh:GetMass()/2 )
		else
			args.veh:SetMass( args.veh:GetMass()*2 )
		end
	else
	end
end
]]--

function Drift:ModuleLoad()
	NetworkObject.Create("Drift")
end

function Drift:PlayerChat( args )
	local object = NetworkObject.GetByName("Drift") or NetworkObject.Create("Drift")
	if args.text == "/cleardrift" then
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

function Drift:PostTick()
	if self.timer:GetSeconds() < self.delay then return end
	self.timer:Restart()
	local object = NetworkObject.GetByName("Drift") or NetworkObject.Create("Drift")
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

function Drift:onDriftRecord( score, player )
	local object = NetworkObject.GetByName("Drift") or NetworkObject.Create("Drift")
	if score < (object:GetValue("S") or 0) then return end
	if object:GetValue("N") ~= player:GetName() then
		if object:GetValue("N") ~= nil then
			player:SetMoney( player:GetMoney() + 50 )
			if player:GetValue( "Lang" ) == "EN" then
				player:SendChatMessage( "[Record] ", Color.White, "Reward: $50 for a new drift record!", Color( 255, 150, 0 ) )
			else
				player:SendChatMessage( "[Рекорд] ", Color.White, "Награда: $50 за новый рекорд дрифта!", Color( 255, 150, 0 ) )
			end

			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "EN" then
					p:SendChatMessage( "[Record] ", Color.White, player:GetName() .. " has broken the player's drift record " .. object:GetValue("N") .. ", his reward: $50!", Color( 255, 150, 0 ) )
				else
					p:SendChatMessage( "[Рекорд] ", Color.White, player:GetName() .. " побил дрифт-рекорд игрока " .. object:GetValue("N") .. ", его награда: $50!", Color( 255, 150, 0 ) )
				end
			end
		else
			player:SetMoney( player:GetMoney() + 50 )
			if player:GetValue( "Lang" ) == "EN" then
				player:SendChatMessage( "[Record] ", Color.White, "Reward: $50 for a new drift record!", Color( 255, 150, 0 ) )
			else
				player:SendChatMessage( "[Рекорд] ", Color.White, "Награда: $50 за новый рекорд дрифта!", Color( 255, 150, 0 ) )
			end

			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "EN" then
					p:SendChatMessage( "[Record] ", Color.White, player:GetName() .. " set a new drift record: " .. score .. "!", Color( 255, 150, 0 ) )
				else
					p:SendChatMessage( "[Рекорд] ", Color.White, player:GetName() .. " установил новый рекорд по дрифту: " .. score .. "!", Color( 255, 150, 0 ) )
				end
			end
		end
	else
		for p in Server:GetPlayers() do
			if p:GetValue( "Lang" ) == "EN" then
				p:SendChatMessage( "[Record] ", Color.White, player:GetName() .. " updated a fantastic drift record: " .. score .. "!", Color( 255, 150, 0 ) )
			else
				p:SendChatMessage( "[Рекорд] ", Color.White, player:GetName() .. " обновил хорошечный рекорд по дрифту: " .. score .. "!", Color( 255, 150, 0 ) )
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

function Drift:onDriftAttempt( score, player )
	Network:Broadcast( "03", {score, player:GetId() + 1} )
end

function Drift:DriftRecordTask( score, player )
	if player:GetValue( "DriftRecord" ) then
		if score <= player:GetValue( "DriftRecord" ) then return end
		player:SetNetworkValue( "DriftRecord", score )
	end
end

function Drift:Reward( name, last )
	for player in Server:GetPlayers() do
		if player:GetName() == name then
			if not last then
				player:SetMoney( player:GetMoney() + 15 )
				if player:GetValue( "Lang" ) == "EN" then
					player:SendChatMessage( "[Record] ", Color.White, "Reward: $15 for keeping drift record!", Color( 255, 150, 0 ) )
				else
					player:SendChatMessage( "[Рекорд] ", Color.White, "Награда: $15 за удержание рекорда по дрифту!", Color( 255, 150, 0 ) )
				end
			else
				player:SetMoney( player:GetMoney() + 500 )
				if player:GetValue( "Lang" ) == "EN" then
					player:SendChatMessage( "[Record] ", Color.White, "You won a fantastic drifter! Your reward: $500!", Color( 255, 150, 0 ) )
				else
					player:SendChatMessage( "[Рекорд] ", Color.White, "Вы победили в хорошечном дрифтере! Ваша награда: $500!", Color( 255, 150, 0 ) )
				end

				for p in Server:GetPlayers() do
					if p:GetValue( "Lang" ) == "EN" then
						p:SendChatMessage( "[Record] ", Color.White, player:GetName() .. " won a fantastic drifter and won $500!", Color( 255, 150, 0 ) )
					else
						p:SendChatMessage( "[Рекорд] ", Color.White, player:GetName() .. " победил в хорошечном дрифтере и выиграл $500!", Color( 255, 150, 0 ) )
					end
				end
			end
		end
	end
end

drift = Drift()