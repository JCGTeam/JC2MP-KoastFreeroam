class 'Banner'

function Banner:__init()
	self.refreshTimer = Timer()
	self.timeDelay = 0.2 -- in minutes
	self.imageIndex = 0

	Events:Subscribe( "PostTick", self, self.PostTick )
end

function Banner:PostTick()
	if self.refreshTimer:GetMinutes() > self.timeDelay then
		if self.imageIndex < 21 then
			self.imageIndex = self.imageIndex + 1
		else
			self.imageIndex = 1
		end

		for p in Server:GetPlayers() do
			Network:Send( p, "GetImage", tostring( self.imageIndex ) )
		end

		self.refreshTimer:Restart()
	end
end

banner = Banner()