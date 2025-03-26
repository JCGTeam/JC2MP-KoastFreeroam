class "Drift"

function Drift:__init()
	self:initVars()

	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )

	Network:Subscribe( "onDriftRecord", self, self.onDriftRecord )
	Network:Subscribe( "onDriftAttempt", self, self.onDriftAttempt )
	Network:Subscribe( "DriftRecordTask", self, self.DriftRecordTask )
	Network:Subscribe( "UpdateMaxRecord", self, self.UpdateMaxRecord )
	Network:Subscribe( "ChangeMass", self, self.ChangeMass )

	self.tag_clr = Color.White
	self.text_clr = Color( 185, 215, 255 )
	self.text2_clr = Color( 251, 184, 41 )
end

function Drift:initVars()
	self.timer = Timer()
	self.delay = 240
end

function Drift:ChangeMass( args, sender )
	if IsValid(args.veh) then
		if args.bool then
			args.veh:SetMass( args.veh:GetMass()/2 )
		else
			args.veh:SetMass( args.veh:GetMass()*2 )
		end
	end
end

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
	local pName = player:GetName()
	local objectN = object:GetValue("N")

	if score < (object:GetValue("S") or 0) then return end
	if objectN ~= pName then
		if objectN ~= nil then
			player:SetMoney( player:GetMoney() + 50 )
			if player:GetValue( "Lang" ) == "EN" then
				player:SendChatMessage( "[Record] ", self.tag_clr, "Reward: $50 for a new drift record!", self.text2_clr )
			else
				player:SendChatMessage( "[Рекорд] ", self.tag_clr, "Награда: $50 за новый рекорд дрифта!", self.text2_clr )
			end

			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "EN" then
					p:SendChatMessage( "[Record] ", self.tag_clr, pName .. " has broken the player's drift record " .. objectN .. ", his reward: $50!", self.text_clr )
				else
					p:SendChatMessage( "[Рекорд] ", self.tag_clr, pName .. " побил дрифт-рекорд игрока " .. objectN .. ", его награда: $50!", self.text_clr )
				end
			end
		else
			player:SetMoney( player:GetMoney() + 50 )
			if player:GetValue( "Lang" ) == "EN" then
				player:SendChatMessage( "[Record] ", self.tag_clr, "Reward: $50 for a new drift record!", self.text2_clr )
			else
				player:SendChatMessage( "[Рекорд] ", self.tag_clr, "Награда: $50 за новый рекорд дрифта!", self.text2_clr )
			end

			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "EN" then
					p:SendChatMessage( "[Record] ", self.tag_clr, pName .. " set a new drift record: " .. score .. "!", self.text_clr )
				else
					p:SendChatMessage( "[Рекорд] ", self.tag_clr, pName .. " установил новый рекорд по дрифту: " .. score .. "!", self.text_clr )
				end
			end
		end
	else
		for p in Server:GetPlayers() do
			if p:GetValue( "Lang" ) == "EN" then
				p:SendChatMessage( "[Record] ", self.tag_clr, pName .. " updated a fantastic drift record: " .. score .. "!", self.text_clr )
			else
				p:SendChatMessage( "[Рекорд] ", self.tag_clr, pName .. " обновил хорошечный рекорд по дрифту: " .. score .. "!", self.text_clr )
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

function Drift:onDriftAttempt( score, player )
	Network:Broadcast( "onDriftAttempt", { score, player:GetId() + 1 } )
end

function Drift:DriftRecordTask( score, player )
	if player:GetValue( "DriftRecord" ) then
		if score <= player:GetValue( "DriftRecord" ) then return end
		player:SetNetworkValue( "DriftRecord", score )
	end
end

function Drift:UpdateMaxRecord( score, player )
	if tonumber( player:GetValue( "MaxRecordInBestDrift" ) or 0 ) >= score then return end
	player:SetNetworkValue( "MaxRecordInBestDrift", score )
end

function Drift:Reward( name, last )
	for player in Server:GetPlayers() do
		if player:GetName() == name then
			if not last then
				player:SetMoney( player:GetMoney() + 15 )
				if player:GetValue( "Lang" ) == "EN" then
					player:SendChatMessage( "[Record] ", self.tag_clr, "Reward: $15 for keeping drift record!", self.text2_clr )
				else
					player:SendChatMessage( "[Рекорд] ", self.tag_clr, "Награда: $15 за удержание рекорда по дрифту!", self.text2_clr )
				end
			else
				player:SetMoney( player:GetMoney() + 500 )
				if player:GetValue( "Lang" ) == "EN" then
					player:SendChatMessage( "[Record] ", self.tag_clr, "You won a fantastic drifter! Your reward: $500!", self.text2_clr )
				else
					player:SendChatMessage( "[Рекорд] ", self.tag_clr, "Вы победили в хорошечном дрифтере! Ваша награда: $500!", self.text2_clr )
				end

				local pName = player:GetName()
				for p in Server:GetPlayers() do
					if p:GetValue( "Lang" ) == "EN" then
						p:SendChatMessage( "[Record] ", self.tag_clr, pName .. " won a fantastic drifter and won $500!", self.text_clr )
					else
						p:SendChatMessage( "[Рекорд] ", self.tag_clr, pName .. " победил в хорошечном дрифтере и выиграл $500!", self.text_clr )
					end
				end
			end
		end
	end
end

drift = Drift()