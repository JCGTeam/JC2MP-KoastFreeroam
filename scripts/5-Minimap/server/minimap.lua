class "BetterMinimap"

function BetterMinimap:__init()
    self.interval = 2 -- Seconds (Default: 2)
    self.timer = Timer()

    Events:Subscribe("PostTick", self, self.PostTick)
end

function BetterMinimap:PostTick()
    if self.timer:GetSeconds() > self.interval then
        local playerPositions = {}

        for p in Server:GetPlayers() do
            local playerId = p:GetId()

            if not p:GetValue("HideMe") then
                playerPositions[playerId] = {
                    position = p:GetPosition(),
                    color = p:GetColor(),
                    worldId = p:GetWorld():GetId(),
                    tringle = "none"
                }
            end
        end

        self.timer:Restart()
        Network:Broadcast("BMPlayerPositions", playerPositions)
    end
end

local betterminimap = BetterMinimap()