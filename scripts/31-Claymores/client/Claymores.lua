class "Claymores"

function Claymores:__init()
    self:initVars()
    self:SharedObjectValueChange()
    self:NetworkObjectValueChange()

    Events:Subscribe("SharedObjectValueChange", self, self.SharedObjectValueChange)
    Events:Subscribe("NetworkObjectValueChange", self, self.NetworkObjectValueChange)
    Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
    Events:Subscribe("PostTick", self, self.PostTick)
    Events:Subscribe("WorldNetworkObjectCreate", self, self.WorldNetworkObjectCreate)
    Events:Subscribe("WorldNetworkObjectDestroy", self, self.WorldNetworkObjectDestroy)
    Events:Subscribe("ModuleUnload", self, self.ModuleUnload)

    Network:Subscribe("EffectClay", self, self.EffectClay)
end

function Claymores:initVars()
    self.claymores = {}
    self.delay = 800 -- Time to place a claymore in ms
    self.cooldown = 1000 -- Time between placing claymores in ms
    self.ignore = 500 -- Time to ignore triggers in ms
    self.timer = Timer()
end

function Claymores:SharedObjectValueChange(args)
    if args and args.object.__type ~= "LocalPlayer" then return end

    self.FreezeValue = LocalPlayer:GetValue("Freeze")
    self.ServerMapValue = LocalPlayer:GetValue("ServerMap")
    self.ExplosiveValue = LocalPlayer:GetValue("Explosive")
end

function Claymores:NetworkObjectValueChange(args)
    if args and args.object.__type ~= "LocalPlayer" then return end

    self.PassiveValue = LocalPlayer:GetValue("Passive")
end

function Claymores:EffectClay(args)
    local effect = ClientEffect.Play(AssetLocation.Game, {
        effect_id = 33,
        position = args.position,
        angle = args.angle
    })

    local effect = ClientEffect.Play(AssetLocation.Game, {
        effect_id = 19,
        position = args.position,
        angle = args.angle
    })
end

function Claymores:LocalPlayerInput(args)
    if self.FreezeValue then return end
    if self.PassiveValue then return end
    if self.ServerMapValue then return end
    if Game:GetState() ~= GUIState.Game then return end

    if args.input == Action.ThrowGrenade and self.ExplosiveValue == 3 then
        if self.placing then return end
        if self.timer:GetMilliseconds() < self.cooldown then return end
        if LocalPlayer:GetBaseState() ~= AnimationState.SUprightIdle then return end

        LocalPlayer:SetBaseState(AnimationState.SCoverEntering)
        self.placing = Timer()
        local sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 18,
            sound_id = 5,
            position = LocalPlayer:GetPosition(),
            angle = Angle()
        })

        sound:SetParameter(0, 1)
    end
end

function Claymores:PostTick()
    local placing = self.placing

    if not placing then return end

    local milliseconds = placing:GetMilliseconds()
    local delay = self.delay

    if milliseconds < delay then return end

    LocalPlayer:SetBaseState(AnimationState.SUprightIdle)
    Network:Send("01")

    self.timer:Restart()
    self.placing = nil
end

function Claymores:WorldNetworkObjectCreate(args)
    local class = args.object:GetValue("C")

    if class == Class.ClaymoreTrigger then
        if self.timer:GetMilliseconds() < self.ignore then return end

        local position = args.object:GetPosition()
        local angle = args.object:GetAngle()

        Network:Send("02", {
            id = args.object:GetId(),
            position = position,
            angle = angle
        })

        return
    end

    if class ~= Class.ClaymoreObject then return end

    local object = ClientStaticObject.Create({
        model = "km05.blz/gp703-a.lod",
        collision = "",
        position = args.object:GetPosition(),
        angle = args.object:GetAngle(),
        fixed = true
    })

    self.claymores[args.object:GetId()] = object
end

function Claymores:WorldNetworkObjectDestroy(args)
    local class = args.object:GetValue("C")

    if class ~= Class.ClaymoreObject then return end

    local object = self.claymores[args.object:GetId()]

    if not object then return end

    object:Remove()
end

function Claymores:ModuleUnload()
    for _, claymore in pairs(self.claymores) do
        if IsValid(claymore) then
            claymore:Remove()
        end
    end
end

local claymores = Claymores()