class 'HantuIsland'

function HantuIsland:__init()
	self.island = Vector3( -13715.291015625, 647.15295410156, -14165.701171875 )

	self.timer = Timer()

	Events:Subscribe( "PostTick", self, self.PostTick )
end

function HantuIsland:PostTick()
	if self.timer:GetSeconds() <= 4 then return end

	local dist = LocalPlayer:GetPosition():DistanceSqr2D( self.island )

	if dist <= 4000000 then
		if not self.hantuisland then
			Network:Send( "Weather" )
			self.hantuisland = true
		end
	else
		if self.hantuisland then
			Network:Send( "WeatherC" )
			self.hantuisland = nil
		end
	end

	self.timer:Restart()
end

hantuisland = HantuIsland()