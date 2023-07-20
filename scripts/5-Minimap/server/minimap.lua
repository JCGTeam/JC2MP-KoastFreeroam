class "BetterMinimap"

function BetterMinimap:__init()
	self.interval = 2 -- Seconds (Default: 2)
	self.timer = Timer()

	Events:Subscribe( "PostTick", self, self.PostTick )
end

function BetterMinimap:PostTick()
	if self.timer:GetSeconds() > self.interval then
        local playerPositions = {}

        for player in Server:GetPlayers() do
            local playerId = player:GetId()
            if not player:GetValue( "HideMe" ) then
                playerPositions[playerId] = { position = player:GetPosition(), color = player:GetColor(), worldId = player:GetWorld():GetId(), tringle = "none" }
            end
        end
        self.timer:Restart()
    	Network:Broadcast( "BMPlayerPositions", playerPositions )
    end
end

betterminimap = BetterMinimap()