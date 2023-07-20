class 'Settings'

local Cashes = { 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2100, 2000, 2200, 2300, 2400, 2500, 100, 200, 300, 400, 500, 600, 700, 800, 900 }

function Settings:__init()
	GoCashes = Cashes[math.random(#Cashes)]

	Network:Subscribe( "Cash", self, self.Cash )
	Network:Subscribe( "ToggleHideMe", self, self.ToggleHideMe )

	Events:Subscribe( "PostTick", self, self.PostTick )

	self.timer = Timer()
end

function Settings:PostTick( args )
	if self.timer:GetHours() >= 1 then
		for p in Server:GetPlayers() do
			Network:Send( p, "Bonus" )
		end
		self.timer:Restart()
	end
end

function Settings:Cash( args, sender )
	GoCashes = Cashes[math.random(#Cashes)]
	if sender:GetValue( "MoneyBonus" ) then
		sender:SetMoney( sender:GetMoney() + GoCashes )
	end
end

function Settings:ToggleHideMe( args, sender )
	sender:SetNetworkValue( "HideMe", not sender:GetValue( "HideMe" ) )
end

settings = Settings()