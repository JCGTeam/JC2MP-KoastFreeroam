class 'WeatherManager'

function WeatherManager:__init()
    self.weathers = {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 2}

    Events:Subscribe("PostTick", self, self.PostTick)

    self.timer = Timer()
    self.weather = table.randomvalue(self.weathers)
end

function WeatherManager:PostTick()
    if self.timer:GetHours() <= 1 then return end

    local weathers = table.randomvalue(self.weathers)

    if weathers == self.weather then
        self.weather = 0
    else
        self.weather = weathers
    end

    DefaultWorld:SetWeatherSeverity(self.weather)

    local setweather_txt = "Weather set to "

    print(setweather_txt .. self.weather)
    Events:Fire("ToDiscordConsole", {text = setweather_txt .. self.weather})

    self.timer:Restart()
end

local weathermanager = WeatherManager()