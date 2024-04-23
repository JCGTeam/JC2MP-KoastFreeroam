class 'WidgetsManager'

function WidgetsManager:__init()
    Events:Subscribe( "PostTick", self, self.PostTick )
    self.timer = Timer()
    self.valuev = 1
end

function WidgetsManager:PostTick()
    if self.timer:GetSeconds() >= 5 then
        self.valuev = self.valuev + 1
        for player in Server:GetPlayers() do
            player:SetNetworkValue( "GetWidget", self.valuev )
        end
        self.timer:Restart()
        if self.valuev == 3 then
           self.valuev = 0
        end
	end
end

widgetsmanager = WidgetsManager()