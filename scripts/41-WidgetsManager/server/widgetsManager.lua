class 'WidgetsManager'

function WidgetsManager:__init()
    Events:Subscribe( "PostTick", self, self.PostTick )

    self.timer = Timer()

    self.updateDelay = 5
    self.widget = 0
    self.maxWidgets = 2
end

function WidgetsManager:PostTick()
    if self.timer:GetSeconds() >= self.updateDelay then
        self.widget = ( self.widget >= self.maxWidgets ) and 0 or self.widget + 1

        Network:Broadcast( "UpdateBestScoreWidget", self.widget )

        self.timer:Restart()
	end
end

widgetsmanager = WidgetsManager()