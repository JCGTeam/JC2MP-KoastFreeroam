class 'Freeroam'

function Freeroam:__init()
    Events:Subscribe("GameLoad", self, self.GameLoad)
    Network:Subscribe("EnableAutoPassive", self, self.EnableAutoPassive)
    Network:Subscribe("EnableKillerCamera", self, self.EnableKillerCamera)
    Network:Subscribe("KillerStats", self, self.KillerStats)
end

function Freeroam:GameLoad()
    Events:Fire("RestoreParachute")

    self.killer = nil

    if self.CalcViewEvent then Events:Unsubscribe(self.CalcViewEvent) self.CalcViewEvent = nil end
end

function Freeroam:EnableAutoPassive()
    if not LocalPlayer:GetValue("Passive") then
        if not self.PostTickEvent then
            Network:Send("TogglePassiveAfterSpawn", {enabled = true})

            self.passiveTimer = Timer()
            self.PostTickEvent = Events:Subscribe("PostTick", self, self.PostTick)
        end
    end
end

function Freeroam:PostTick()
    if self.passiveTimer:GetSeconds() >= 10 then
        self.passiveTimer = nil
        Network:Send("TogglePassiveAfterSpawn", {enabled = false})
        if self.PostTickEvent then Events:Unsubscribe(self.PostTickEvent) self.PostTickEvent = nil end
    end
end

function Freeroam:KillerStats(args)
    Events:Fire("CastCenterText", {text = args.text, time = 4})
end

function Freeroam:DrawHotspot(v, dist)
    local text = "/tp " .. v[1]
    local text_size = Render:GetTextSize(text, TextSize.VeryLarge)
end

function Freeroam:EnableKillerCamera(killer)
    self.killer = killer

    if not self.CalcViewEvent then self.CalcViewEvent = Events:Subscribe("CalcView", self, self.CalcView) end
end

function Freeroam:CalcView()
    if not self.killer then return end

    local playerPos = LocalPlayer:GetPosition()
    local actorPos = self.killer:GetPosition()

    local direction = (actorPos - playerPos):Normalized()

    local newAngle = Angle.FromVectors(Vector3.Forward, direction)
    newAngle.roll = 0

    local pitchLimit = math.rad(45)
    newAngle.pitch = math.clamp(newAngle.pitch, -pitchLimit, pitchLimit)

    local distance = (actorPos - playerPos):Length()
    if distance < 5 then newAngle.pitch = 0 end

    Camera:SetAngle(newAngle)
end

local freeroam = Freeroam()