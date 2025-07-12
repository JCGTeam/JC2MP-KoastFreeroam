local max = math.max
local insert = table.insert

class 'Map'

function Map:__init()
    self.players = {}
    self.viewers = {}

    self.timer = Timer()
    self.delay = 1

    Network:Subscribe("InitialTeleport", self, self.Teleport)
    Network:Subscribe("CorrectedTeleport", self, self.Teleport)
    Network:Subscribe("MapShown", self, self.MapShown)
    Network:Subscribe("MapHidden", self, self.MapHidden)
    Events:Subscribe("PostTick", self, self.BroadcastUpdate)
    Events:Subscribe("ModuleLoad", self, self.ModuleLoad)
    Events:Subscribe("PlayerSpawn", self, self.PlayerSpawn)
    Events:Subscribe("PlayerDeath", self, self.PlayerDeath)
    Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
    Events:Subscribe("PlayerWorldChange", self, self.PlayerWorldChange)
end

function Map:Teleport(args, sender)
    if offset == nil then
        offset = 250
    end

    Network:SendNearby(sender, "WarpDoPoof", sender:GetPosition())

    sender:SetPosition(Vector3(args.position.x, max(args.position.y, 200) + offset, args.position.z))
end

function Map:AddViewer(viewer)
    self.viewers[viewer:GetId()] = viewer
end

function Map:RemoveViewer(viewer)
    self.viewers[viewer:GetId()] = nil
end

function Map:AddPlayer(player)
    self.players[player:GetId()] = player
end

function Map:RemovePlayer(player)
    self.players[player:GetId()] = nil
end

function Map:MapShown(_, sender)
    self:AddViewer(sender)
end

function Map:MapHidden(_, sender)
    self:RemoveViewer(sender)
end

function Map:PlayerSpawn(args)
    self:AddPlayer(args.player)
end

function Map:PlayerDeath(args)
    self:RemovePlayer(args.player)
end

function Map:PlayerQuit(args)
    self:RemoveViewer(args.player)
    self:RemovePlayer(args.player)
end

function Map:PlayerWorldChange(args)
    args.player:SetNetworkValue("HideMe", false)
end

function Map:BroadcastUpdate()
    if self.timer:GetSeconds() < self.delay then return end

    self.timer:Restart()

    if not next(self.viewers) then return end

    local send_args = {}

    for _, player in pairs(self.players) do
        local playerId = player:GetId()
        if not player:GetValue("HideMe") then
            if IsValid(player) then
                local data = {
                    id = player:GetId(),
                    name = player:GetName(),
                    pos = player:GetPosition(),
                    col = player:GetColor(),
                    worldId = player:GetWorld():GetId()
                }

                insert(send_args, data)
            end
        end
    end

    Network:SendToPlayers(self.viewers, "PlayerUpdate", send_args)
end

function Map:ModuleLoad()
    for player in Server:GetPlayers() do
        self.players[player:GetId()] = player
    end
end

map = Map()