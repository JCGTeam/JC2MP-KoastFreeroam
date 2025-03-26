class "Pigeon"

function Pigeon:__init()
	self:initVars()

	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )

	Network:Subscribe( "onFlyingRecord", self, self.onFlyingRecord )
	Network:Subscribe( "onFlyingAttempt", self, self.onFlyingAttempt )
	Network:Subscribe( "FlyingRecordTask", self, self.FlyingRecordTask )
	Network:Subscribe( "UpdateMaxRecord", self, self.UpdateMaxRecord )

	self.tag_clr = Color.White
	self.text_clr = Color( 185, 215, 255 )
	self.text2_clr = Color( 251, 184, 41 )
end

function Pigeon:initVars()
	self.timer = Timer()
	self.delay = 240
end

function Pigeon:ModuleLoad()
	NetworkObject.Create("Flying")
end

function Pigeon:PlayerChat( args )
	local object = NetworkObject.GetByName("Flying") or NetworkObject.Create("Flying")
	if args.text == "/clearpigeon" then
		if args.player:GetValue( "Tag" ) == "Creator" or args.player:GetValue("Tag") == "GlAdmin" then
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

function Pigeon:PostTick()
	if self.timer:GetSeconds() < self.delay then return end
	self.timer:Restart()
	local object = NetworkObject.GetByName("Flying") or NetworkObject.Create("Flying")
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

function Pigeon:onFlyingRecord( score, player )
	local object = NetworkObject.GetByName("Flying") or NetworkObject.Create("Flying")
	local pName = player:GetName()
	local objectN = object:GetValue("N")

	if score < (object:GetValue("S") or 0) then return end
	if objectN ~= pName then
		if objectN ~= nil then
			player:SetMoney( player:GetMoney() + 50 )
			if player:GetValue( "Lang" ) == "EN" then
				player:SendChatMessage( "[Record] ", self.tag_clr, "Reward: $50 for a new wingsuit flying record!", self.text2_clr )
			else
				player:SendChatMessage( "[Рекорд] ", self.tag_clr, "Награда: $50 за новый рекорд по полётам на вингсьюте!", self.text2_clr )
			end

			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "EN" then
					p:SendChatMessage( "[Record] ", self.tag_clr, pName .. " has broken the player's flying record " .. objectN .. ", his reward: $50!", self.text_clr )
				else
					p:SendChatMessage( "[Рекорд] ", self.tag_clr, pName .. " побил рекорд по полётам игрока " .. objectN .. ", его награда: $50!", self.text_clr )
				end
			end
		else
			player:SetMoney( player:GetMoney() + 50 )
			if player:GetValue( "Lang" ) == "EN" then
				player:SendChatMessage( "[Record] ", self.tag_clr, "Reward: $50 for a new flying record!", self.text2_clr )
			else
				player:SendChatMessage( "[Рекорд] ", self.tag_clr, "Награда: $50 за новый рекорд по полётам!", self.text2_clr )
			end

			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "EN" then
					p:SendChatMessage( "[Record] ", self.tag_clr, pName .. " set a new wingsuit flying record: " .. score .. "!", self.text_clr )
				else
					p:SendChatMessage( "[Рекорд] ", self.tag_clr, pName .. " установил новый рекорд по полётам на вингсьюте: " .. score .. "!", self.text_clr )
				end
			end
		end
	else
		for p in Server:GetPlayers() do
			if p:GetValue( "Lang" ) == "EN" then
				p:SendChatMessage( "[Record] ", self.tag_clr, pName .. " updated a fantastic flying record: " .. score .. "!", self.text_clr )
			else
				p:SendChatMessage( "[Рекорд] ", self.tag_clr, pName .. " обновил хорошечный рекорд по полётам на вингсьюте: " .. score .. "!", self.text_clr )
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

function Pigeon:onFlyingAttempt( score, player )
	Network:Broadcast( "onFlyingAttempt", {score, player:GetId() + 1} )
end

function Pigeon:FlyingRecordTask( score, player )
	if player:GetValue( "FlyingRecord" ) then
		if score <= player:GetValue( "FlyingRecord" ) then return end
		player:SetNetworkValue( "FlyingRecord", score )
	end
end

function Pigeon:UpdateMaxRecord( score, player )
	if tonumber( player:GetValue( "MaxRecordInBestFlight" ) or 0 ) >= score then return end
	player:SetNetworkValue( "MaxRecordInBestFlight", score )
end

function Pigeon:Reward( name, last )
	for player in Server:GetPlayers() do
		if player:GetName() == name then
			if not last then
				player:SetMoney( player:GetMoney() + 15 )
				if player:GetValue( "Lang" ) == "EN" then
					player:SendChatMessage( "[Record] ", self.tag_clr, "Reward: $15 for keeping flying record!", self.text2_clr )
				else
					player:SendChatMessage( "[Рекорд] ", self.tag_clr, "Награда: $15 за удержание рекорда по полёту!", self.text2_clr )
				end
			else
				player:SetMoney( player:GetMoney() + 500 )
				if player:GetValue( "Lang" ) == "EN" then
					player:SendChatMessage( "[Record] ", self.tag_clr, "You won a fantastic flying! Your reward: $500!", self.text2_clr )
				else
					player:SendChatMessage( "[Рекорд] ", self.tag_clr, "Вы победили в хорошечном полете! Ваша награда: $500!", self.text2_clr )
				end

				local pName = player:GetName()
				for p in Server:GetPlayers() do
					if p:GetValue( "Lang" ) == "EN" then
						p:SendChatMessage( "[Record] ", self.tag_clr, pName .. " won a fantastic flying and won $500!", self.text_clr )
					else
						p:SendChatMessage( "[Рекорд] ", self.tag_clr, pName .. " победил в хорошечном полете и выиграл $500!", self.text_clr )
					end
				end
			end
		end
	end
end

pigeon = Pigeon()