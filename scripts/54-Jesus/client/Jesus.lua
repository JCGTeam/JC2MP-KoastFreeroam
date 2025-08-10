class 'Jesus'

function Jesus:__init()
    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            name = "Иисус",
            nameSizer = "Мирный",
            disable = " отключён",
            enable = " включён",
            notusable = "Невозможно использовать это здесь!"
        }
    end

    self.surfaceHeight = 199.8
    self.underWaterOffset = 0.157
    self.maxDistance = 50

    self.visible = LocalPlayer:GetValue("WaterWalk")
    self.animationValue = self.visible and 1 or 0

    self.model = ""
    self.collision = "areaset01.blz/gb245_lod1-d_col.pfx"

    self.surfaces = {}

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("PostTick", self, self.PostTick)
    Events:Subscribe("ModuleUnload", self, self.RemoveAllSurfaces)
    Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
    Events:Subscribe("LocalPlayerChat", self, self.LocalPlayerChat)
    Events:Subscribe("ToggleJesus", self, self.ToggleJesus)
    Events:Subscribe("NetworkObjectValueChange", self, self.ObjectValueChange)
    Events:Subscribe("SharedObjectValueChange", self, self.ObjectValueChange)

    if LocalPlayer:GetValue("JesusModeVisible") or not LocalPlayer:GetValue("HiddenHUD") then
        self.RenderEvent = Events:Subscribe("Render", self, self.Render)
    end
end

function Jesus:Lang()
    self.locStrings = {
        name = "Jesus",
        nameSizer = "Passive",
        disable = " Disabled",
        enable = " Enabled",
        notusable = "You cannot use it here!"
    }
end

function Jesus:PlayerQuit(args)
    self:Remove(args.player)
end

function Jesus:Master(player)
    local waterWalk = player:GetValue("WaterWalk")

    if waterWalk then
        local vehicle = player:GetVehicle()
        local class = vehicle and vehicle:GetClass()

        if class == VehicleClass.Sea then
            self:Remove(player)
            return
        end

        self:Move(player)
    else
        self:Remove(player)
    end
end

function Jesus:Create(player)
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    local pos = self:Position(player)
    local surface = ClientStaticObject.Create({
        position = pos.pos,
        angle = pos.angle,
        model = self.model,
        collision = self.collision
    })

    self.surfaces[player:GetId()] = surface
end

function Jesus:Move(player)
    local surfaces = self.surfaces
    local surface = surfaces[player:GetId()]

    if not (surface or IsValid(surface)) then self:Create(player) return end

    local surfacePos = surface:GetPosition()
    local pPos = player:GetPosition()
    local maxDistance = self.maxDistance

    if Vector3.Distance(surfacePos, pPos) >= maxDistance then
        if self:Remove(player) then
            self:Create(player)
        end
    end

    local pos = self:Position(player)
    surface:SetPosition(pos.pos)
    surface:SetAngle(pos.angle)
end

function Jesus:Position(player)
    local anchor = self:Anchor(player)
    local playerPos = anchor:GetPosition()
    local playerAngle = anchor:GetAngle()
    local effectiveAngle = Angle.Zero
    local effectiveHeight = self.surfaceHeight

    local pState = player:GetState()
    if pState == 1 or pState == 2 or pState == 3 or pState == 5 then
        local playerAngleYaw = playerAngle.yaw
        local pi = math.pi

        effectiveAngle = Angle(playerAngleYaw, 0, 0) * Angle(pi * 1.5, 0, 0)
    end

    local underWaterOffset = self.underWaterOffset
    local inVehicle = player:InVehicle()

    if playerPos.y < effectiveHeight + underWaterOffset and not inVehicle then
        effectiveHeight = playerPos.y - 1
    end

    local speed = math.clamp(player:GetLinearVelocity():Length(), 0, 40)
    if speed > 5 then
        local speedRatio = speed / 150
        effectiveHeight = effectiveHeight + speedRatio
    end

    local effectivePos = Vector3(playerPos.x, effectiveHeight, playerPos.z)

    return {pos = effectivePos, angle = effectiveAngle}
end

function Jesus:Remove(player)
    local pId = player:GetId()

    if IsValid(self.surfaces[pId]) then
        self.surfaces[pId]:Remove()
        self.surfaces[pId] = nil
    end

    return true
end

function Jesus:Anchor(player)
    local vehicle = player:GetVehicle()

    if vehicle and player:InVehicle() then
        if Vector3.Distance(vehicle:GetPosition(), player:GetPosition()) < self.maxDistance / 2 then
            return vehicle
        end
    end

    return player
end

function Jesus:RemoveAllSurfaces()
    for k, v in pairs(self.surfaces) do
        if IsValid(v) then
            v:Remove()
        end
    end
end

function Jesus:PostTick()
    self:Master(LocalPlayer)

    local streamedPlayers = Client:GetStreamedPlayers()

    for p in streamedPlayers do
        self:Master(p)
    end
end

function Jesus:ObjectValueChange(args)
    if args.object.__type ~= "LocalPlayer" then return end

    if args.key == "WaterWalk" then
        if args.value then
            self.visible = true

            if self.fadeOutAnimation then Animation:Stop(self.fadeOutAnimation) self.fadeOutAnimation = nil end
            Animation:Play(0, 1, 0.05, easeInOut, function(value) self.animationValue = value end)
        else
            self.fadeOutAnimation = Animation:Play(self.animationValue, 0, 0.05, easeInOut, function(value) self.animationValue = value end, function() self.visible = nil end)
        end
    end

    if args.key == "JesusModeVisible" or args.key == "HiddenHUD" then
        if LocalPlayer:GetValue("JesusModeVisible") and not LocalPlayer:GetValue("HiddenHUD") then
            if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
        else
            if self.RenderEvent then Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil end
        end
    end
end

function Jesus:Render()
    if not self.visible then return end
    if Game:GetState() ~= GUIState.Game then return end
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

    local locStrings = self.locStrings
    local text = locStrings["nameSizer"]
    local text_size = 18
    local text_width = Render:GetTextWidth(text, text_size)
    local text_height = Render:GetTextHeight(text, text_size)

    local animationValue = self.animationValue
    local posY = math.lerp(-text_height - 2, 0, animationValue)
    local width = Render.Width
    local widthDivided = width / 1.3
    local text_pos = Vector2(widthDivided - text_width / 1.8 + text_width / 5.5, posY + 2)
    local sett_alpha = math.lerp(0, Game:GetSetting(4) * 2.25, animationValue)
    local background_clr = Color(0, 0, 0, sett_alpha / 2.4)

    Render:FillArea(Vector2(widthDivided - text_width / 1.8, posY), Vector2(text_width + 5, text_height + 2), background_clr)

    Render:FillTriangle(Vector2(widthDivided - text_width / 1.8 - 10, posY), Vector2(widthDivided - text_width / 1.8, posY), Vector2(widthDivided - text_width / 1.8, posY + text_height + 2), background_clr)
    Render:FillTriangle(Vector2(widthDivided - text_width / 1.8 + text_width + 15, posY), Vector2(widthDivided - text_width / 1.8 + text_width + 5, posY), Vector2(widthDivided - text_width / 1.8 + text_width + 5, posY + text_height + 2), background_clr)

    Render:DrawShadowedText(text_pos, locStrings["name"], Color(185, 215, 255, sett_alpha), Color(0, 0, 0, sett_alpha), text_size)
end

function Jesus:LocalPlayerChat(args)
    local cmd_args = args.text:split(" ")

    if cmd_args[1] == "/jesus" or cmd_args[1] == "/waterwalk" then
        self:ToggleJesus()
    end
end

function Jesus:ToggleJesus()
    if not LocalPlayer:GetValue("JesusModeEnabled") then return end

    local locStrings = self.locStrings

    if LocalPlayer:GetWorld() ~= DefaultWorld then
        Events:Fire("CastCenterText", {text = locStrings["notusable"], time = 3, color = Color.Red})
        return
    end

    LocalPlayer:SetSystemValue("WaterWalk", not LocalPlayer:GetValue("WaterWalk"))
    Events:Fire("CastCenterText", {text = locStrings["name"] .. (LocalPlayer:GetValue("WaterWalk") and locStrings["disable"] or self.locStrings["enable"]), time = 2, color = Color(185, 215, 255)})
end

function LocalPlayer:SetSystemValue(valueName, value)
    if IsValid(self) and valueName then
        local sendInfo = {}
        sendInfo.player = self
        sendInfo.name = tostring(valueName)
        sendInfo.value = value
        Network:Send("SetSystemValue", sendInfo)
    end
end

local jesus = Jesus()