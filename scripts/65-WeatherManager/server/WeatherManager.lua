class 'WeatherManager'

Weathers = { 0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 2 }

function WeatherManager:__init()
	Events:Subscribe( "PostTick", self, self.PostTick )

	self.timer = Timer()
	self.weather = Weathers[math.random(#Weathers)]
end

function WeatherManager:PostTick()
	if self.timer:GetHours() <= 1 then return end
	if Weathers[math.random(#Weathers)] == self.weather then
		self.weather = 0
	else
		self.weather = Weathers[math.random(#Weathers)]
	end
	DefaultWorld:SetWeatherSeverity( self.weather )

	local setweather_txt = "Weather set to "

	print( setweather_txt .. self.weather )
	Events:Fire( "ToDiscordConsole", { text = setweather_txt .. self.weather })

	self.timer:Restart()
end

weathermanager = WeatherManager()