class 'Doors'

function Doors:__init()
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "KeyUp", self, self.KeyUp )
	Network:Subscribe( "OpenDoors", self, self.OpenDoors )

	self.ptext = "« Ворота открыты »"

	self.cooldown = 2
	self.cooltime = 0
end

function Doors:Lang()
	self.ptext = "« Doors open »"
end

function Doors:KeyUp( args )
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	if args.key == string.byte("L") then
		local time = Client:GetElapsedSeconds()
		if time < self.cooltime then
			return
		else
			Network:Send( "GetPlayers" )
			Events:Fire( "CastCenterText", { text = self.ptext, time = 1, color = Color.White } )
		end
		self.cooltime = time + self.cooldown
		return false
	end
end

function Doors:OpenDoors()
	Game:FireEvent( "t{go500.01({967466FA-4C87-422A-ACF5-042B67E922B5})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({9695B812-73C4-4D86-86FF-AEC430816869})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({F7CD6FAE-EFCE-4CA4-A1C4-6944D228139F})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({FD92A809-89AC-4D64-BC1C-335FD22F5B83})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({927DC663-1EAA-4D87-810F-36F8581CBE7D})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({8EB05652-74A1-4DA6-B24F-E77803AB4B6B})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({EC54E85D-45ED-46A8-8E31-3B32DEE1D5FC})}::fadeOutGate" )
	Game:FireEvent( "t{go500.01({86D114AF-77FD-44CC-B861-5F6C77ED03A0})}::fadeOutGate" )
	Game:FireEvent( "open.mouth" )
end

doors = Doors()