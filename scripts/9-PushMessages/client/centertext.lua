class 'CenterText'

function CenterText:__init()
    Events:Subscribe("CastCenterText", self, self.CastCenterText)
    Network:Subscribe("CastCenterText", self, self.CastCenterText)
end

function CenterText:CastCenterText(args)
    self.timerF = Timer()
    self.textF = args.text
    self.timeF = args.time or 1
    self.color = args.color or Color.White

    if self.fadeOutAnimation then Animation:Stop(self.fadeOutAnimation) self.fadeOutAnimation = nil end

    Animation:Play(0, 1, 0.15, easeInOut, function(value) self.animationValue = value end)

    if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
end

function CenterText:Render()
    if Game:GetState() ~= GUIState.Game then return end

    local textF = self.textF

    if not textF then return end

    if self.timerF then
        local timerFSeconds = self.timerF:GetSeconds()

        if timerFSeconds > self.timeF then
            self.fadeOutAnimation = Animation:Play(self.animationValue, 0, 0.75, easeInOut, function(value) self.animationValue = value end, function()
                self.textF = nil
                self.timeF = nil
                self.color = nil
                self.animationValue = nil
                self.fadeOutAnimation = nil

                if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
            end)

            self.timerF = nil
        end
    end

    if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

    local size = 30
    local pos = Vector2(Render.Width / 2, Render.Height * 0.42) - Render:GetTextSize(textF, size) / 2
    local color = self.color
    local shadowColor = Color(0, 0, 0, 80)

    local animationValue = self.animationValue
    local textColor = Color(color.r, color.g, color.b, math.lerp(0, color.a, animationValue))
    local textShadow = Color(shadowColor.r, shadowColor.g, shadowColor.b, math.lerp(0, shadowColor.a, animationValue))

    Render:DrawShadowedText(pos, textF, textColor, textShadow, size)
end

local centertext = CenterText()