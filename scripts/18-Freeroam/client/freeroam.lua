class 'Freeroam'

function Freeroam:__init()
    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            killedby = "Вы были убиты "
        }
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("GameLoad", self, self.GameLoad)

    Network:Subscribe("EnableAutoPassive", self, self.EnableAutoPassive)
    Network:Subscribe("EnableKillerCamera", self, self.EnableKillerCamera)
    Network:Subscribe("KillerStats", self, self.KillerStats)
end

function Freeroam:Lang()
    self.locStrings = {
        killedby = "You were killed by "
    }
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

    Events:Fire("CastCenterText", {text = self.locStrings["killedby"] .. killer:GetName(), time = 6})
end

function Freeroam:CalcView()
    if not IsValid(self.killer) then
        if self.lastCamPos and self.lastCamAngle then
            Camera:SetPosition(self.lastCamPos)
            Camera:SetAngle(self.lastCamAngle)
        end
        return
    end

    local lpPos = LocalPlayer:GetPosition()
    local kPos = self.killer:GetPosition() + Vector3(0, 1.5, 0)

    local direction = (kPos - lpPos):Normalized()

    if (kPos - lpPos):Length() < 0.1 then
        direction = Vector3.Forward
    end

    local directionXZ = Vector3(direction.x, 0, direction.z):Normalized()
    local targetCamPos = lpPos - directionXZ * 4 + Vector3(0, 1.8, 0)

    self.lastCamPos = self.lastCamPos or Camera:GetPosition()
    local smoothedCamPos = math.lerp(self.lastCamPos, targetCamPos, 0.1)
    Camera:SetPosition(smoothedCamPos)
    self.lastCamPos = smoothedCamPos

    local lookDirection = (kPos - smoothedCamPos):Normalized()
    local newAngle = Angle.FromVectors(Vector3.Forward, lookDirection)
    newAngle.roll = 0

    local pitchLimit = math.rad(45)
    newAngle.pitch = math.clamp(newAngle.pitch, -pitchLimit, pitchLimit)

    Camera:SetAngle(newAngle)

    self.lastCamAngle = newAngle
end

local freeroam = Freeroam()