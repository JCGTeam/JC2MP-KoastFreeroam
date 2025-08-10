class("Mode", RaceModules)

function RaceModules.Mode:__init()
    EGUSM.SubscribeUtility.__init(self)

    self.timer = nil
    self.timerControl = nil

    self:EventSubscribe("RaceEnd", self.RaceOrSpectateEnd)
    self:EventSubscribe("SpectateEnd", self.RaceOrSpectateEnd)
    self:NetworkSubscribe("RaceWillEndIn")
end

-- Events

function RaceModules.Mode:RaceOrSpectateEnd()
    if self.timerControl then self.timerControl:Remove() end

    self:Destroy()
end

-- Network events

function RaceModules.Mode:RaceWillEndIn(endTime)
    if self.timerControl then
        self.timerControl:Restart()
    else
        self.timerControl = RaceMenuUtility.CreateTimer(settings.locStrings["untilnextracestart"], endTime)
    end
end