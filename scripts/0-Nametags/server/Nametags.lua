class 'Nametags'

function Nametags:__init()
	self.interval = 2 -- Seconds (Default: 2)

	self.timer = Timer()

	Network:Subscribe( "ToggleMinimap", self, self.ToggleMinimap )

	Events:Subscribe( "PostTick", self, self.PostTick )
end

function Nametags:ToggleMinimap( state, sender )
	sender:SetValue( "MinimapDisabled", not state or nil )
end

function Nametags:PostTick()
	if self.timer:GetSeconds() > self.interval then
		for p in Server:GetPlayers() do
			local pos = not p:GetValue( "MinimapDisabled" ) and p:GetPosition() or nil
			if p:GetValue( "Position" ) ~= pos then
				p:SetNetworkValue( "Position", pos )
			end
		end
	self.timer:Restart()
	end
end

local nametags = Nametags()