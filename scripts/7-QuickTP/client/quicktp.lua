class 'QuickTP'

function QuickTP:__init()
    self:UpdateKeyBinds()

    self.menuOpen = false

    Events:Subscribe("UpdateKeyBinds", self, self.UpdateKeyBinds)

    Network:Subscribe("WarpDoPoof", self, self.WarpDoPoof)

    self.subRecTP = Network:Subscribe("TPList", self, self.ReceiveTPList)

    Network:Send("RequestTPList")
end

function QuickTP:WarpDoPoof(position)
    local effect = ClientEffect.Play(AssetLocation.Game, {
        effect_id = 250,
        position = position,
        angle = Angle()
    })
end

function QuickTP:ReceiveTPList(args)
    self.collection = args

    if not self.subKey then self.subKey = Events:Subscribe("KeyDown", self, self.KeyDown) end

    if self.subRecTP then Network:Unsubscribe(self.subRecTP) self.subRecTP = nil end
end

function QuickTP:UpdateKeyBinds()
    local keyBinds = LocalPlayer:GetValue("KeyBinds")
    local bind = keyBinds and keyBinds["QuickTP"]

    self.expectedKey = bind and bind.type == "Key" and bind.value or 74
end

function QuickTP:KeyDown(args)
    if args.key == self.expectedKey and Game:GetState() == GUIState.Game then
        if self.subKey then Events:Unsubscribe(self.subKey) self.subKey = nil end

        if not self.subKey then self.subKey = Events:Subscribe("KeyUp", self, self.KeyUp) end

        self:OpenMenu()
    end
end

function QuickTP:KeyUp(args)
    if args.key == self.expectedKey then
        if self.subKey then Events:Unsubscribe(self.subKey) self.subKey = nil end

        if self.timerF then self.timerF = nil end

        if not self.subKey then self.subKey = Events:Subscribe("KeyDown", self, self.KeyDown) end

        if self.menuOpen then
            self:CloseMenu()
        end
    end
end

function QuickTP:MouseDown(args)
    if type(self.menu[self.selection + 2]) == "table" then
        self.menu = self.menu[self.selection + 2]
        self.sound = ClientSound.Create(AssetLocation.Game, {
            bank_id = 18,
            sound_id = 1,
            position = Camera:GetPosition(),
            angle = Angle()
        })

        self.sound:SetParameter(0, 1)
        return
    end

    local sendArgs = {}
    sendArgs.target = self.menu[self.selection + 2]
    sendArgs.button = args.button

    Network:Send("QuickTP", sendArgs)

    self:CloseMenu()
end

function QuickTP:OpenMenu()
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    if not self.subRender then self.subRender = Events:Subscribe("PostRender", self, self.PostRender) end
    if not self.subMouse then self.subMouse = Events:Subscribe("MouseDown", self, self.MouseDown) end

    Animation:Play(0, 1, 0.15, easeIOnut, function(value) self.animationValue = value end)

    Mouse:SetPosition(Vector2(Render.Width / 2, Render.Height / 2))
    Mouse:SetVisible(true)
    Input:SetEnabled(false)

    self.menu = self.collection
    self.menuOpen = true
end

function QuickTP:CloseMenu()
    if self.subRender then Events:Unsubscribe(self.subRender) self.subRender = nil end
    if self.subMouse then Events:Unsubscribe(self.subMouse) self.subMouse = nil end

    Mouse:SetVisible(false)
    Input:SetEnabled(true)

    if self.sound then self.sound = nil end

    self.menuOpen = false
end

function QuickTP:PostRender()
    if Game:GetState() ~= GUIState.Game then return end

    if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

    local fontSize = 42
    local menu = self.menu
    local count = #menu - 1
    local size = fontSize - count * 1.4
    if size < 12 then size = 12 end

    local radius = (Render.Height / 2) - fontSize
    local pi = math.pi
    local angle = pi / count
    local center = Vector2(Render.Width / 2, Render.Height / 2)
    local drawRad = 2200

    local current = count % 2 == 1 and pi / 2 or 0

    local mouseP = Mouse:GetPosition()
    local mouseA = math.atan2(mouseP.y - center.y, mouseP.x - center.x)
    self.selection = math.floor(((mouseA + angle - current) / (pi * 2)) * count)

    if self.selection < 0 then self.selection = self.selection + count end

    local fontColor = Color(255, 255, 255)
    local fontShadow = Color(25, 25, 25)
    local animationValue = self.animationValue
    local fontAlpha = math.lerp(0, fontColor.a, animationValue)

    local menuColor = Color(185, 215, 255, 170)
    local backgroundColor = Color(10, 10, 10, 200)
    local highlightColor = Color(185, 215, 255, 120)

    local backgroundFinalColor = Color(backgroundColor.r, backgroundColor.g, backgroundColor.b, math.lerp(0, backgroundColor.a, animationValue))
    local highlightFinalColor = Color(highlightColor.r, highlightColor.g, highlightColor.b, math.lerp(0, highlightColor.a, animationValue))
    local menuFinalColor = Color(menuColor.r, menuColor.g, menuColor.b, math.lerp(0, menuColor.a, animationValue))

    if self.sound then
        local cameraPos = Camera:GetPosition()

        self.sound:SetPosition(cameraPos)
    end

    Render:FillArea(Vector2.Zero, Render.Size, backgroundFinalColor)

    if count < 3 then
        Render:FillArea(Vector2((self.selection == 0 and count == 2) and center.x or 0, 0), Vector2(count == 1 and Render.Width or center.x, Render.Height), highlightFinalColor)
    else
        Render:FillTriangle(center, Vector2(math.cos(self.selection * (angle * 2) - angle + current) * drawRad, math.sin(self.selection * (angle * 2) - angle + current) * drawRad) + center, Vector2(math.cos(self.selection * (angle * 2) + angle + current) * drawRad, math.sin(self.selection * (angle * 2) + angle + current) * drawRad) + center, highlightFinalColor)
    end

    local innerRadius = 50
    local fontUpper = true
    local showGroupCount = true

    for i = 2, #menu, 1 do
        local t = menu[i]
        if type(t) == "table" then
            t = t[1] .. (showGroupCount and " (" .. tostring(#t - 1) .. ")" or "")
        end

        if fontUpper then t = string.upper(t) end

        local textSize = Render:GetTextSize(t, size)
        local coord = Vector2(math.cos(current) * radius + center.x - textSize.x / 2, math.sin(current) * radius + center.y - textSize.y / 2) current = current + angle

        Render:DrawShadowedText(coord, t, Color(fontColor.r, fontColor.g, fontColor.b, fontAlpha), Color(fontShadow.r, fontShadow.g, fontShadow.b, fontAlpha), size)
        Render:DrawLine(Vector2(math.cos(current) * innerRadius, math.sin(current) * innerRadius) + center, Vector2(math.cos(current) * drawRad, math.sin(current) * drawRad) + center, menuFinalColor)

        current = current + angle
    end

    Render:FillCircle(center, innerRadius, backgroundFinalColor)
    Render:DrawCircle(center, innerRadius, menuFinalColor)
end

local quicktp = QuickTP()