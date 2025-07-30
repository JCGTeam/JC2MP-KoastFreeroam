class 'OpenGates'

function OpenGates:__init()
    self.places = {}

    self.tipDistance = 40

    self:UpdateKeyBinds()

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            press = "Нажмите",
            toopengate = "чтобы открыть ворота"
        }
    end

    self.cooldown = 2
    self.cooltime = 0

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("UpdateKeyBinds", self, self.UpdateKeyBinds)
    Events:Subscribe("NetworkObjectValueChange", self, self.ObjectValueChange)
    Events:Subscribe("SharedObjectValueChange", self, self.ObjectValueChange)
    Events:Subscribe("KeyUp", self, self.KeyUp)

    if LocalPlayer:GetValue("OpenDoorsTipsVisible") or not LocalPlayer:GetValue("HiddenHUD") then
        self.GameRenderEvent = Events:Subscribe("GameRender", self, self.GameRender)
    end

    Network:Subscribe("Places", self, self.Places)
    Network:Subscribe("OpenDoors", self, self.OpenDoors)
end

function OpenGates:Lang()
    self.locStrings = {
        press = "Press",
        toopengate = "to open gate"
    }
end

function OpenGates:UpdateKeyBinds()
    local keyBinds = LocalPlayer:GetValue("KeyBinds")
    local bind = keyBinds and keyBinds["OpenGates"]

    self.expectedKey = bind and bind.type == "Key" and bind.value or 76
    self.stringKey = bind and bind.type == "Key" and bind.valueString or "L"
end

function OpenGates:ObjectValueChange(args)
    if args.object.__type ~= "LocalPlayer" then return end

    if args.key == "OpenDoorsTipsVisible" or args.key == "HiddenHUD" then
        if LocalPlayer:GetValue("OpenDoorsTipsVisible") and not LocalPlayer:GetValue("HiddenHUD") then
            if not self.GameRenderEvent then self.GameRenderEvent = Events:Subscribe("GameRender", self, self.GameRender) end
        else
            if self.GameRenderEvent then Events:Unsubscribe(self.GameRenderEvent) self.GameRenderEvent = nil end
        end
    end
end

function OpenGates:Places(args)
    self.places = args
end

function OpenGates:DrawShadowedText(pos, text, colour, size, scale)
    if not scale then scale = 1.0 end
    if not size then size = TextSize.Default end

    local shadow_colour = Color(0, 0, 0, colour.a)
    shadow_colour = shadow_colour * 0.4

    Render:DrawText(pos + Vector3(1, 1, 2), text, shadow_colour, size, scale)
    Render:DrawText(pos, text, colour, size, scale)
end

function OpenGates:DrawHotspot(v, dist)
    local pi = math.pi
    local cameraAngle = Camera:GetAngle()
    local cameraAngleYaw = cameraAngle.yaw
    local angle = Angle(cameraAngleYaw, 0, pi) * Angle(pi, 0, 0)

    local tipDistance = self.tipDistance
    local normalizedDist = dist / (LocalPlayer:InVehicle() and tipDistance * 3 or tipDistance)
    local alpha_factor = 255 - math.clamp(normalizedDist * 255 * 2.25, 0, 255)

    local locStrings = self.locStrings
    local text = locStrings["press"] .. " «" .. self.stringKey .. "» " .. locStrings["toopengate"]
    local textSize = 50
    local textColor = Color(255, 255, 255, alpha_factor)

    local getTextSize = Render:GetTextSize(text, textSize)

    local t = Transform3()
    t:Translate(v[2])
    t:Scale(0.0045)
    t:Rotate(angle)
    t:Translate(-Vector3(getTextSize.x, getTextSize.y, 0) / 2)

    Render:SetTransform(t)

    self:DrawShadowedText(Vector3.Zero, text, textColor, textSize)
end

function OpenGates:GameRender()
    if Game:GetState() ~= GUIState.Game then return end
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    local cameraPos = Camera:GetPosition()
    local inVehicle = LocalPlayer:InVehicle()
    local places = self.places
    local tipDistance = self.tipDistance

    if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

    for _, v in ipairs(places) do
        local dist = v[2]:Distance(cameraPos)

        if dist < (inVehicle and tipDistance * 3 or tipDistance) then
            self:DrawHotspot(v, dist)
        end
    end
end

function OpenGates:KeyUp(args)
    if Game:GetState() ~= GUIState.Game then return end
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    if args.key == self.expectedKey then
        local time = Client:GetElapsedSeconds()

        if time > self.cooltime then
            Network:Send("GetPlayers")

            self.cooltime = time + self.cooldown
        end
    end
end

function OpenGates:OpenDoors()
    Game:FireEvent("t{go500.01({967466FA-4C87-422A-ACF5-042B67E922B5})}::fadeOutGate")
    Game:FireEvent("t{go500.01({9695B812-73C4-4D86-86FF-AEC430816869})}::fadeOutGate")
    Game:FireEvent("t{go500.01({F7CD6FAE-EFCE-4CA4-A1C4-6944D228139F})}::fadeOutGate")
    Game:FireEvent("t{go500.01({FD92A809-89AC-4D64-BC1C-335FD22F5B83})}::fadeOutGate")
    Game:FireEvent("t{go500.01({927DC663-1EAA-4D87-810F-36F8581CBE7D})}::fadeOutGate")
    Game:FireEvent("t{go500.01({8EB05652-74A1-4DA6-B24F-E77803AB4B6B})}::fadeOutGate")
    Game:FireEvent("t{go500.01({EC54E85D-45ED-46A8-8E31-3B32DEE1D5FC})}::fadeOutGate")
    Game:FireEvent("t{go500.01({86D114AF-77FD-44CC-B861-5F6C77ED03A0})}::fadeOutGate")

    Game:FireEvent("open.mouth")
    Game:FireEvent("km04.pumpdoor.open")
    Game:FireEvent("km04.hangarGateOpen")
    Game:FireEvent("km04.baseCliffGateOpen")
    Game:FireEvent("km06.gate.forceDestroy")
end

local opengates = OpenGates()