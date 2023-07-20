class 'HantuIsland'

function HantuIsland:__init()
	Network:Subscribe( "Weather", self, self.Weather )
	Network:Subscribe( "WeatherC", self, self.WeatherC )
end

function HantuIsland:Weather( args, sender )
	sender:SetWeatherSeverity( 2 )
end

function HantuIsland:WeatherC( args, sender )
	sender:SetWeatherSeverity( DefaultWorld:GetWeatherSeverity() )
end

hantuisland = HantuIsland()