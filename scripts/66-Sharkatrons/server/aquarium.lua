class 'Aquarium'

function Aquarium:__init()
	self.sharks         = {}
	self.timer          = Timer()
	self.time           = 0
	self.lastRenderTime = 0
	subRender           = Events:Subscribe("PreTick", self, self.Ticker)
end

function Aquarium:Ticker()
	self.time = self.timer:GetMilliseconds()
	if self.time - self.lastRenderTime < 1000 / updatesPerSecond then return end
	
	local i = 1
	while i <= #self.sharks do
		self.sharks[i]:Update()
		i = i + 1
	end
	
	self.lastRenderTime = self.time
end

function Aquarium:NewShark(file, height)
	local shark  = Shark()
	local result = shark:Parse(file, height)
	if result then 
		table.insert(self.sharks, shark)
	else
		print(file .. " is not a valid shark file!")
	end
end