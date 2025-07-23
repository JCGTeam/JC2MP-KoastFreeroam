class "WidgetsManager"

function WidgetsManager:__init()
    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("NetworkObjectValueChange", self, self.ObjectValueChange)
    Events:Subscribe("SharedObjectValueChange", self, self.ObjectValueChange)

    if LocalPlayer:GetValue("BestRecordVisible") or not LocalPlayer:GetValue("HiddenHUD") then
        self.RenderEvent = Events:Subscribe("Render", self, self.Render)
    end

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            fantastic = "Хорошечный",
            drift = "Дрифтер",
            tetris = "Тетрис",
            flying = "Полет"
        }
    end

    self:UpdateBestScoreWidget(0)

    Network:Subscribe("UpdateBestScoreWidget", self, self.UpdateBestScoreWidget)
end

function WidgetsManager:Lang()
    self.locStrings = {
        fantastic = "Fantastic",
        drift = "Drift",
        tetris = "Tetris",
        flying = "Flying"
    }
end

function WidgetsManager:ObjectValueChange(args)
    if args.object.__type ~= "LocalPlayer" then return end

    if args.key == "Lang" then
        self:UpdateBestScoreWidget(self.currentWidget)
    end

    if args.key == "BestRecordVisible" or args.key == "HiddenHUD" then
        if LocalPlayer:GetValue("BestRecordVisible") and not LocalPlayer:GetValue("HiddenHUD") then
            if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
        else
            if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
        end
    end
end

function WidgetsManager:UpdateBestScoreWidget(widget)
    self.currentWidget = widget

    if widget == 0 then
        self.object = NetworkObject.GetByName("Drift")
        self.text2 = self.locStrings["drift"]
    elseif widget == 1 then
        self.object = NetworkObject.GetByName("Tetris")
        self.text2 = self.locStrings["tetris"]
    elseif widget == 2 then
        self.object = NetworkObject.GetByName("Flying")
        self.text2 = self.locStrings["flying"]
    end
end

function WidgetsManager:Render()
    if Game:GetState() ~= GUIState.Game then return end

    local gameAlpha = Game:GetSetting(4)

    if gameAlpha >= 1 then
        if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

        local sett_alpha = gameAlpha * 2.25
        local object = self.object

        if object then
            local record = object:GetValue("S")
            local locStrings = self.locStrings
            local text1 = locStrings["fantastic"]
            local text2 = self.text2

            local color = Color(255, 255, 255, sett_alpha)
            local color2 = Color(185, 215, 255, sett_alpha)
            local colorShadow = Color(25, 25, 25, sett_alpha)
            local position = Vector2(20, Render.Height * 0.4)
            local textSize = 15

            Render:DrawShadowedText(position, text1, color, colorShadow, textSize)
            Render:DrawShadowedText(position + Vector2(Render:GetTextWidth(text1 .. " ", textSize), 0), text2, color2, colorShadow, textSize)

            local height = Render:GetTextHeight("A") * 1.2
            position.y = position.y + height

            local text = "–"

            if record then
                Render:DrawShadowedText(position, tostring(record), color2, colorShadow, textSize)
                Render:DrawShadowedText(position + Vector2(Render:GetTextWidth(tostring(record), textSize), 0), " - ", color, colorShadow, textSize)
                if object:GetValue("C") then
                    Render:DrawShadowedText(position + Vector2(Render:GetTextWidth(tostring(record) .. " - ", textSize), 0), object:GetValue("N"), object:GetValue("C") + Color(0, 0, 0, sett_alpha), colorShadow, textSize)
                end

                position.y = position.y + height * 1.05

                local bar_len = (object:GetValue("E") or 0) * 3
                Render:FillArea(position + Vector2.One, Vector2(bar_len, 3), Color(0, 0, 0, sett_alpha))
                Render:FillArea(position, Vector2(30, 3), Color(0, 0, 0, sett_alpha / 2))
                Render:FillArea(position, Vector2(bar_len, 3), Color(255, 255, 255, sett_alpha))

                local attempt = self.attempt

                if attempt then
                    local player = Player.GetById(attempt[2] - 1)

                    if player then
                        local alpha = math.min(attempt[3], 1)

                        position.y = position.y + height * 0.6
                        text = tostring(attempt[1]) .. " - " .. player:GetName()
                        Render:DrawShadowedText(position, text, Color(255, 255, 255, 255 * alpha), Color(25, 25, 25, 150 * alpha), textSize)
                        text = tostring(attempt[1])
                        Render:DrawShadowedText(position, text, Color(240, 220, 70, 255 * alpha), Color(25, 25, 25, 150 * alpha), textSize)

                        attempt[3] = attempt[3] - 0.02
                        if attempt[3] < 0.02 then
                            attempt = nil
                        end
                    end
                end
            else
                Render:DrawShadowedText(position, text, Color(200, 200, 200, sett_alpha), colorShadow, textSize)
            end
        end
    end
end

local widgetsmanager = WidgetsManager()