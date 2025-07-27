class "ResourceItems"

function ResourceItems:__init()
    self.timer = Timer()
    self.numcrates = 0

    self.crates = {}

    Events:Subscribe("PostTick", self, self.PostTick)
    Events:Subscribe("ModuleLoad", self, self.ModuleLoad)

    Network:Subscribe("CrateTaken", self, self.CrateTaken)
    Network:Subscribe("SyncTriggers", self, self.SyncTriggers)
    Network:Subscribe("SyncTriggersRemove", self, self.SyncTriggersRemove)
end

function ResourceItems:ModuleLoad()
    Network:Send("SyncReq", LocalPlayer)
end

function ResourceItems:PostTick()
    if self.timer:GetSeconds() > 1 then
        local playerPosition = LocalPlayer:GetPosition()
        local crates = self.crates
        local maxRadius = 100
        local outlineColor = Color.White

        for i = 1, #crates do
            local crate = crates[i]

            if crate then
                local ent = StaticObject.GetById(crate.id)

                if IsValid(ent) then
                    local radius = ent:GetPosition():Distance(playerPosition)

                    if radius <= maxRadius then
                        if not ent:GetOutlineEnabled() then
                            ent:SetOutlineEnabled(true)
                            ent:SetOutlineColor(outlineColor)
                        end
                    else
                        if ent:GetOutlineEnabled() then
                            ent:SetOutlineEnabled(false)
                        end
                    end
                end
            end
        end
        self.timer:Restart()
    end
end

function ResourceItems:CrateTaken()
    self.numcrates = self.numcrates + 1

    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 19,
        sound_id = 3,
        position = LocalPlayer:GetPosition(),
        angle = Angle()

    })
    sound:SetParameter(0, 1)

    local lang = LocalPlayer:GetValue("Lang")
    Game:ShowPopup(((lang and lang == "RU") and "Ящики: " or "Resource items: ") .. self.numcrates .. "/" .. #self.crates, true)
end

function ResourceItems:SyncTriggers(args)
    local crates = self.crates
    local radius = 1

    for i = 1, #args do
        table.insert(crates, {radius = radius, id = args[i].id})
    end
end

function ResourceItems:SyncTriggersRemove(args)
    local crates = self.crates

    for i = 1, #crates do
        local crate = crates[i]

        if crate and crate.id == args.id then
            table.remove(crates, i)
            break
        end
    end
end

local resourceitems = ResourceItems()