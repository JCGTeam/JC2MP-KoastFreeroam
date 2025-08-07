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

    Network:Subscribe("Notice", self, self.Notice)
    Network:Subscribe("SetTimer", self, self.SetTimer)

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

function Admin:Render()
    if Game:GetState() ~= GUIState.Game then return end
    if LocalPlayer:GetValue("HiddenHUD") then return end

    local gameAlpha = Game:GetSetting(4)

    if gameAlpha <= 1 then return end

    if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

    local sett_alpha = gameAlpha * 2.25

    local text1 = self.titleText
    local color = Color(255, 255, 255, sett_alpha)
    local color2 = Color(185, 215, 255, sett_alpha)
    local colorShadow = Color(25, 25, 25, sett_alpha)
    local position = Vector2(20, Render.Height * 0.49)
    local textSize = 15

    Render:DrawShadowedText(position, text1, color, colorShadow, textSize)

    local remaining = self.remaining

    if remaining > 0 then
        local height = Render:GetTextHeight("A") * 1.2
        position.y = position.y + height

        Render:DrawShadowedText(position, self:SecondsToClock(remaining), color2, colorShadow, textSize)

        position.y = position.y + height * 1.05

        local max_bar_len = 10 * 3
        local progress = math.clamp(remaining / self.timerDuration, 0, 1)
        local bar_len = math.floor(max_bar_len * progress)

        Render:FillArea(position + Vector2.One, Vector2(bar_len, 3), Color(0, 0, 0, sett_alpha))
        Render:FillArea(position, Vector2(max_bar_len, 3), Color(0, 0, 0, sett_alpha / 2))
        Render:FillArea(position, Vector2(bar_len, 3), Color(255, 255, 255, sett_alpha))
    else
        if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end

        self.titleText = nil
        self.endTime = nil
    end
end

function Admin:PreTick()
    local forcePassiveTimer = self.forcePassiveTimer

    if forcePassiveTimer and forcePassiveTimer:GetSeconds() <= 1 then return end

    Network:Send("ToggleForcePassive", true)

    self.forcePassiveTimer:Restart()
end

function Admin:Notice(text)
    self.timer = Timer()
    self.message = text

    Chat:Print(self.locStrings["tag"], self.textColor, self.message, self.textColor2)

    if not self.PostRenderEvent then self.PostRenderEvent = Events:Subscribe("PostRender", self, self.PostRender) end
end

function Admin:SetTimer(args)
    if args.text then
        self.titleText = args.text
    end

    local endTime = args.endTime

    self.remaining = math.floor(endTime - os.time())

    if args.duration then
        self.timerDuration = args.duration
    end

    if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
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

function Admin:SecondsToClock(seconds)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)

    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

local admin = Admin()