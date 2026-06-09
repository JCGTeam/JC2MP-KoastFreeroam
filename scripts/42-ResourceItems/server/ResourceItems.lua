class "ResourceItems"

function ResourceItems:__init()
    self.resptime = 24

    self.timer = Timer()

    Events:Subscribe("PlayerEnterCheckpoint", self, self.PlayerEnterCheckpoint)
    Events:Subscribe("PostTick", self, self.PostTick)
    Events:Subscribe("ModuleUnload", self, self.ModuleUnload)

    Network:Subscribe("SyncReq", self, self.SyncPlayerData)

    self:CreateCrates()
end

function ResourceItems:CreateCrates()
    self.ents = {}
    self.needsRespawn = false

    local count = 0
    local file = io.open("lootspawns.txt", "r")

    if file then
        local args = {}
        args.world = DefaultWorld

        for line in file:lines() do
            line = line:trim()

            if string.len(line) > 0 then
                line = line:gsub("LootSpawn%(", "")
                line = line:gsub("%)", "")
                line = line:gsub(" ", "")

                local tokens = line:split(",")
                local model = tostring(tokens[1])

                if model == "pickup.boost.cash.eez/pu05-a.lod" then
                    local pos = Vector3(tonumber(tokens[3]), tonumber(tokens[4]), tonumber(tokens[5]))
                    local ang = Angle(tonumber(tokens[6]), tonumber(tokens[7]), tonumber(tokens[8]))
                    local col_str = tokens[2]

                    if pos:Distance2D(Vector3(-6568, 208, -3442)) > 650 and pos:Distance2D(Vector3(13199, 1094, -4928)) > 250 and pos:Distance2D(Vector3(2150, 711, 1397)) > 300 and pos:Distance2D(Vector3(-1573, 358, 990)) > 750 and pos:Distance2D(Vector3(13753, 270, -2373)) > 900 and pos:Distance2D(Vector3(-13603, 422, -13746)) > 900 then
                        args.position = pos
                        args.angle = ang
                        args.model = model
                        args.collision = col_str
                        args.world = DefaultWorld

                        local ent = StaticObject.Create(args)
                        ent:SetStreamDistance(200)
                        ent:SetNetworkValue("Cash", true)

                        local checkpoint = Checkpoint.Create(ent:GetPosition() + Vector3(0, 0.75, 0))
                        checkpoint:SetWorld(DefaultWorld)
                        checkpoint:SetCreateIndicator(false)
                        checkpoint:SetCreateCheckpoint(false)
                        checkpoint:SetType(12)
                        checkpoint:SetCreateTrigger(true)
                        checkpoint:SetDespawnOnEnter(false)
                        checkpoint:SetStreamDistance(25)
                        checkpoint:SetActivationBox(Vector3.One)

                        local objid = ent:GetId()
                        local mult = math.random(0, 4)
                        local cash = 5

                        if mult == 0 then
                            cash = 25
                        elseif mult == 1 then
                            cash = 25
                        elseif mult == 2 then
                            cash = 25
                        elseif mult == 3 then
                            cash = 25
                        elseif mult == 4 then
                            cash = 50
                        end

                        table.insert(self.ents, {ent = ent, cash = cash, checkpoint = checkpoint})
                        count = count + 1
                    end
                end
            end
        end

        file:close()
        print("Loaded " .. count .. " crates.")
    else
        print("Error: Could not load loot from file")
    end
end

function ResourceItems:PlayerEnterCheckpoint(args)
    if args.player:GetWorld() ~= DefaultWorld then return end

    local cpId = args.checkpoint:GetId()

    for i, ent2 in pairs(self.ents) do
        if ent2 and ent2.checkpoint then
            if IsValid(ent2.checkpoint) then
                if ent2.checkpoint:GetId() == cpId then
                    args.player:SetMoney(args.player:GetMoney() + 10)
                    args.player:SetNetworkValue("CollectedResourceItemsCount", (args.player:GetValue("CollectedResourceItemsCount") or 0) + 1)

                    Network:Broadcast("SyncTriggersRemove", {id = ent2.ent:GetId()})

                    local count = 0
                    Network:Send(args.player, "CrateTaken", count)

                    ent2.ent:Remove()
                    ent2.checkpoint:Remove()

                    self.ents[i] = nil
                    self.needsRespawn = true
                    break
                end
            end
        end
    end
end

function ResourceItems:PostTick()
    if self.timer:GetHours() >= self.resptime then
        if self.needsRespawn then
            print("All crates has been respawned")
            self:ModuleUnload()
            self:CreateCrates()
        end

        self.timer:Restart()
    end
end

function ResourceItems:onSyncRequest(source)
    self:SyncPlayerData(source)
end

function ResourceItems:SyncPlayerData(player)
    local poss = {}

    for _, ent2 in pairs(self.ents) do
        if IsValid(ent2.ent) then
            table.insert(poss, {pos = ent2.ent:GetPosition(), id = ent2.ent:GetId()})
        end
    end

    if player then
        Network:Send(player, "SyncTriggers", poss)
    end
end

function ResourceItems:ModuleUnload()
    if self.ents then
        for _, ent2 in pairs(self.ents) do
            if ent2 then
                if IsValid(ent2.ent) then
                    ent2.ent:Remove()
                end

                if IsValid(ent2.checkpoint) then
                    ent2.checkpoint:Remove()
                end
            end
        end
        self.ents = nil
    end
end

local resourceitems = ResourceItems()