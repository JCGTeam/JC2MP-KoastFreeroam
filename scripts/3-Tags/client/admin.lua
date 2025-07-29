class 'Admin'

function Admin:__init()
    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            tag = "[Объявление] "
        }
    end

    self.textColor = Color(255, 210, 0)
    self.textColor2 = Color.White

    if LocalPlayer:GetValue("ForcePassive") then
        self.forcePassiveTimer = Timer()

        if not self.PreTickEvent then self.PreTickEvent = Events:Subscribe("PreTick", self, self.PreTick) end
    end

    Events:Subscribe("Lang", self, self.Lang)

    Network:Subscribe("Notice", self, self.ClientFunction)
    Network:Subscribe("ToggleForcePassive", self, self.ToggleForcePassive)
    Network:Subscribe("EnableForcePassive", self, self.EnableForcePassive)
end

function Admin:Lang()
    self.locStrings = {
        tag = "[Notice] "
    }
end

function Admin:PostRender()
    local timer = self.timer
    local message = self.message

    if timer and message then
        if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

        local locStrings = self.locStrings
        local lsTag = locStrings["tag"]
        local size = 30
        local testpos = Vector2(Render.Size.x / 2 - Render:GetTextWidth(lsTag .. message, size) / 2, 80)
        local shadowColor = Color(0, 0, 0)

        Render:DrawShadowedText(testpos, lsTag, self.textColor, shadowColor, size)

        testpos.x = testpos.x + Render:GetTextWidth(lsTag, size)

        Render:DrawShadowedText(testpos, message, self.textColor2, shadowColor, size)

        if timer:GetSeconds() > 10 then
            self.timer = nil
            self.message = nil

            if self.PostRenderEvent then Events:Unsubscribe(self.PostRenderEvent) self.PostRenderEvent = nil end
        end
    end
end

function Admin:PreTick()
    local forcePassiveTimer = self.forcePassiveTimer

    if forcePassiveTimer and forcePassiveTimer:GetSeconds() <= 1 then return end

    Network:Send("ToggleForcePassive", true)

    self.forcePassiveTimer:Restart()
end

function Admin:ClientFunction(args)
    self.timer = Timer()
    self.message = args.text

    Chat:Print(self.locStrings["tag"], self.textColor, self.message, self.textColor2)

    if not self.PostRenderEvent then self.PostRenderEvent = Events:Subscribe("PostRender", self, self.PostRender) end
end

function Admin:ToggleForcePassive(forcePassive)
    if forcePassive then
        self.forcePassiveTimer = nil

        if self.PreTickEvent then Events:Unsubscribe(self.PreTickEvent) self.PreTickEvent = nil end

        Network:Send("ToggleForcePassive", false)
    else
        self.forcePassiveTimer = Timer()

        if not self.PreTickEvent then self.PreTickEvent = Events:Subscribe("PreTick", self, self.PreTick) end

        Network:Send("ToggleForcePassive", true)
    end
end

function Admin:EnableForcePassive()
    Events:Fire("TogglePassive", true)
end

local admin = Admin()