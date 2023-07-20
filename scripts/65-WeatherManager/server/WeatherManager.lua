class 'WeatherManager'

Weathers = { 0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 2 }

function WeatherManager:__init()
	Events:Subscribe( "PostTick", self, self.PostTick )

	self.timer = Timer()
	self.weather = Weathers[math.random(#Weathers)]
end

function WeatherManager:PostTick( args )
	if self.timer:GetHours() <= 1 then return end
	if Weathers[math.random(#Weathers)] == self.weather then
		self.weather = 0
	else
		self.weather = Weathers[math.random(#Weathers)]
	end
	DefaultWorld:SetWeatherSeverity( self.weather )

	print( "Weather set to " .. self.weather )
	Events:Fire( "ToDiscordConsole", { text = "[Weather] Weather set to " .. self.weather })
	self.timer:Restart()
end

weathermanager = WeatherManager()