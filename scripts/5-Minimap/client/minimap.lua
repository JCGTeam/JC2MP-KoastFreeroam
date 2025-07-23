class "BetterMinimap"

function BetterMinimap:__init()
    self.playerPositions = {}
    self.currentPlayerId = LocalPlayer:GetId()

    Network:Subscribe("BMPlayerPositions", self, self.PlayerPositions)

    Events:Subscribe("NetworkObjectValueChange", self, self.ObjectValueChange)
    Events:Subscribe("SharedObjectValueChange", self, self.ObjectValueChange)

    if LocalPlayer:GetValue("PlayersMarkersVisible") or not LocalPlayer:GetValue("HiddenHUD") then
        self.RenderEvent = Events:Subscribe("Render", self, self.Render)
    end
end

function BetterMinimap:PlayerPositions(positions)
    self.playerPositions = positions

    local lpPos = LocalPlayer:GetPosition()

    for playerId, data in pairs(positions) do
        data.triangle = self:GetTriangle(lpPos.y, data.position.y)
    end
end

function BetterMinimap:ObjectValueChange(args)
    if args.object.__type ~= "LocalPlayer" then return end

    if args.key == "PlayersMarkersVisible" or args.key == "HiddenHUD" then
        if LocalPlayer:GetValue("PlayersMarkersVisible") and not LocalPlayer:GetValue("HiddenHUD") then
            if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
        else
            if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
        end
    end
end

function BetterMinimap:Render()
    if Game:GetState() ~= GUIState.Game then return end

    if Game:GetSetting(4) >= 1 then
        local lpPos = LocalPlayer:GetPosition()
        local streamedPlayers = Client:GetStreamedPlayers()
        local updatedPlayers = {}

        for p in streamedPlayers do
            local position = p:GetPosition()

            if not position:IsNaN() then
                local pColor = p:GetColor()
                local pId = p:GetId()

                updatedPlayers[pId] = true

                local triangle = self:GetTriangle(lpPos.y, position.y)

                self:DrawPlayer(lpPos, position, triangle, pColor)
            end
        end

        local lpWorldId = LocalPlayer:GetWorld():GetId()
        local playerPositions = self.playerPositions
        local currentPlayerId = self.currentPlayerId

        for playerId, data in pairs(playerPositions) do
            if not updatedPlayers[playerId] and currentPlayerId ~= playerId and lpWorldId == data.worldId then
                self:DrawPlayer(lpPos, data.position, data.triangle, data.color)
            end
        end
    end
end

function BetterMinimap:DrawPlayer(lpPos, pos, triangle, color)
    local pos, ok = Render:WorldToMinimap(pos)
    local playerPos = LocalPlayer:GetPosition()
    local distance = Vector3.Distance(playerPos, pos)

    if distance <= 5000 then
        local sett_alpha = Game:GetSetting(4) * 2.25
        local color = Color(color.r, color.g, color.b, sett_alpha)
        local shadowColor = Color(0, 0, 0, sett_alpha)

        local sizeX = Render.Size.x
        local size = sizeX / 350
        local shadowSize = sizeX / 300

        local posX, posY = pos.x, pos.y

        if triangle == 1 then
            Render:FillTriangle(Vector2(posX, posY - shadowSize - 3), Vector2(posX - shadowSize - 1, posY + shadowSize - 1), Vector2(posX + shadowSize, posY + shadowSize - 1), shadowColor)
            Render:FillTriangle(Vector2(posX, posY - size - 2), Vector2(posX - size - 1, posY + size - 1), Vector2(posX + size, posY + size - 1), color)
        elseif triangle == -1 then
            Render:FillTriangle(Vector2(posX, posY + shadowSize), Vector2(posX - shadowSize - 1, posY - shadowSize - 1), Vector2(posX + shadowSize - 1, posY - shadowSize - 1), shadowColor)
            Render:FillTriangle(Vector2(posX, posY + size - 1), Vector2(posX - size - 1, posY - size - 1), Vector2(posX + size - 1, posY - size - 1), color)
        else
            Render:FillCircle(pos, size, color)
            Render:DrawCircle(pos, size, shadowColor)
        end
    end
end

function BetterMinimap:GetTriangle(lpY, posY)
    local posP = posY + 30
    local posM = posY - 30

    if lpY > posP then
        return -1
    elseif lpY < posM then
        return 1
    else
        return 0
    end
end

local betterminimap = BetterMinimap()