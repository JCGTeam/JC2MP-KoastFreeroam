class 'Tips'

function Tips:__init()
    self.active = true

    self:UpdateKeyBinds()

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            tip = "Чат: T  I Меню сервера: ",
            tip2 = " I Меню действий: ",
            adstag = "[Реклама] "
        }

        Network:Send("GetAds", {file = "adsRU.txt"})
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("UpdateKeyBinds", self, self.UpdateKeyBinds)
    Events:Subscribe("Render", self, self.Render)

    Network:Subscribe("LoadAds", self, self.AddAds)
    Network:Subscribe("SendMessage", self, self.SendMessage)
end

function Tips:Lang()
    self.locStrings = {
        tip = "Chat: T  I Server Menu: ",
        tip2 = " I Actions Menu: ",
        adstag = "[Advertising] "
    }

    Network:Send("GetAds", {file = "adsEN.txt"})
end

function Tips:UpdateKeyBinds()
    local keyBinds = LocalPlayer:GetValue("KeyBinds")
    local serverMenuBind = keyBinds and keyBinds["ServerMenu"]
    local actionsMenuBind = keyBinds and keyBinds["ActionsMenu"]

    self.serverMenuStringKey = serverMenuBind and serverMenuBind.type == "Key" and serverMenuBind.valueString or "B"
    self.actionsMenuStringKey = actionsMenuBind and actionsMenuBind.type == "Key" and actionsMenuBind.valueString or "V"
end

function Tips:Render()
    local gameState = Game:GetState()

    if self.active and gameState == GUIState.PDA then
        Chat:SetEnabled(false)
        self.activeTw = true
    end

    if self.activeTw and gameState ~= GUIState.PDA then
        Chat:SetEnabled(true)
        self.active = true
        self.activeTw = false
    end

    if Chat:GetEnabled() and Chat:GetUserEnabled() and not Chat:GetActive() then
        local locStrings = self.locStrings
        local text = locStrings["tip"] .. self.serverMenuStringKey .. locStrings["tip2"] .. self.actionsMenuStringKey
        local chatPos = Chat:GetPosition()

        if LocalPlayer:GetValue("ChatBackgroundVisible") then
            Render:FillArea(chatPos + Vector2(-4, 0), Vector2(508, -Render:GetTextHeight(text) * 13.5), Color(0, 0, 0, 80))
        end

        if LocalPlayer:GetValue("ChatTipsVisible") then
            local color = Color(215, 215, 215)
            local lineSize = Vector2(500, 1)
            local linePos = chatPos + Vector2(0, 3)

            Render:FillArea(linePos + Vector2.One, lineSize, Color(25, 25, 25, 100))
            Render:FillArea(linePos, lineSize, color)

            if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

            local textpos = chatPos + Vector2(1, 11)
            Render:DrawShadowedText(textpos, text, color, Color(25, 25, 25, 150), 14)
        end
    end
end

function Tips:AddAds(lines)
    self.ads = {}

    for i, line in ipairs(lines) do
        self.adCount = i
        self.ads[i] = line
    end
end

function Tips:SendMessage()
    if not self.ads then return end

    local defaultValue = 1

    Chat:Print(self.locStrings["adstag"], Color.White, self.ads[math.random(defaultValue, self.adCount or defaultValue)], Color.DarkGray)
end

local tips = Tips()