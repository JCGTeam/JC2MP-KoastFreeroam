class 'Clock'

function Clock:__init()
    self:ObjectValueChange()

    Events:Subscribe("NetworkObjectValueChange", self, self.ObjectValueChange)
    Events:Subscribe("SharedObjectValueChange", self, self.ObjectValueChange)

    if LocalPlayer:GetValue("ClockVisible") or not LocalPlayer:GetValue("HiddenHUD") then
        self.RenderEvent = Events:Subscribe("Render", self, self.Render)
    end
end

function Clock:ObjectValueChange(args)
    if args and args.object.__type ~= "LocalPlayer" then return end

    self.ClockPendosFormatValue = LocalPlayer:GetValue("ClockPendosFormat")

    if args then
        if args.key == "ClockVisible" or args.key == "HiddenHUD" then
            if LocalPlayer:GetValue("ClockVisible") and not LocalPlayer:GetValue("HiddenHUD") then
                if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
            else
                if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
            end
        end
    end
end

function Clock:Render()
    if Game:GetState() ~= GUIState.Game then return end

    local gameAlpha = Game:GetSetting(4)
    if gameAlpha <= 1 then return end

    local format = self.ClockPendosFormatValue and "%I:%M:%S %p" or "%X"

    local time_txt = os.date(format)
    local date_txt = os.date("%d/%m/%Y")

    local sett_alpha = gameAlpha * 2.25
    local shadowColor = Color(25, 25, 25, sett_alpha)
    local timeColor = Color(255, 255, 255, sett_alpha)
    local dateColor = Color(185, 215, 255, sett_alpha)

    local position = Vector2(20, Render.Height * 0.31)

    Render:SetFont(AssetLocation.Disk, "Archivo.ttf")
    Render:DrawShadowedText(position, time_txt, timeColor, shadowColor, 22)

    local height = Render:GetTextHeight("A") * 1.4
    position.y = position.y + height

    Render:DrawShadowedText(position, date_txt, dateColor, shadowColor, 15)
end

local clock = Clock()