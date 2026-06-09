class 'SuperGrapple'

function SuperGrapple:__init()
    self.timer = Timer()
    self.distance = 80
    self.destroyTimer = Timer()
    self.disttext = "%i м"

    if not LocalPlayer:InVehicle() then
        self:LocalPlayerExitVehicle()
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
    Events:Subscribe("ModuleUnload", self, self.ModuleUnload)
end

function SuperGrapple:Lang()
    self.disttext = "%i m"
end

function SuperGrapple:LocalPlayerEnterVehicle()
    if not self.eventsLoaded then return end

    Events:Unsubscribe(self.SharedObjectValueChangeEvent) self.SharedObjectValueChangeEvent = nil
    Events:Unsubscribe(self.NetworkObjectValueChangeEvent) self.NetworkObjectValueChangeEvent = nil
    Events:Unsubscribe(self.RenderEvent) self.RenderEvent = nil
    Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil

    self.eventsLoaded = nil

    self.HiddenHUDValue = nil
    self.LongerGrappleValue = nil
    self.LongerGrappleEnabledValue = nil
    self.LongerGrappleVisibleValue = nil
end

function SuperGrapple:LocalPlayerExitVehicle()
    if self.eventsLoaded then return end

    self:SharedObjectValueChange()
    self:NetworkObjectValueChange()

    self.SharedObjectValueChangeEvent = Events:Subscribe("SharedObjectValueChange", self, self.SharedObjectValueChange)
    self.NetworkObjectValueChangeEvent = Events:Subscribe("NetworkObjectValueChange", self, self.NetworkObjectValueChange)
    self.RenderEvent = Events:Subscribe("Render", self, self.Render)
    self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)

    self.eventsLoaded = true
end

function SuperGrapple:SharedObjectValueChange(args)
    if args and args.object.__type ~= "LocalPlayer" then return end

    self.HiddenHUDValue = LocalPlayer:GetValue("HiddenHUD")
end

function SuperGrapple:NetworkObjectValueChange(args)
    if args and args.object.__type ~= "LocalPlayer" then return end

    self.LongerGrappleValue = LocalPlayer:GetValue("LongerGrapple")
    self.LongerGrappleEnabledValue = LocalPlayer:GetValue("LongerGrappleEnabled")
    self.LongerGrappleVisibleValue = LocalPlayer:GetValue("LongerGrappleVisible")
end

function SuperGrapple:Render()
    local longerGrapple = self.LongerGrappleValue

    if self.LongerGrappleEnabledValue and longerGrapple then
        if LocalPlayer:InVehicle() or LocalPlayer:GetWorld() ~= DefaultWorld then return end

        local object = self.object
        local velocity = -(-LocalPlayer:GetAngle() * LocalPlayer:GetLinearVelocity()).z

        if not object then
            local cameraPos = Camera:GetPosition()
            local cameraAngle = Camera:GetAngle()
            local ray = Physics:Raycast(cameraPos, cameraAngle * Vector3.Forward, 0, longerGrapple)
            local distance = ray.distance

            if distance < longerGrapple and distance > 1 then
                self.distance = ray.distance
                self.position = ray.position
                self.normal = ray.normal
            else
                self.distance = 0
            end
        end

        local bs = LocalPlayer:GetBaseState()
        local distance = self.distance

        if distance > 1 and (distance > 80 or (velocity > 20 and bs ~= AnimationState.SSkydive)) then
            if self.LongerGrappleVisibleValue and not self.HiddenHUDValue and Game:GetState() == GUIState.Game then
                if bs ~= 45 and bs ~= 43 and bs ~= 41 and bs ~= 208 and bs ~= 38 and bs ~= 47 and bs ~= 42 and bs ~= 191 and bs ~= 56 and bs ~= 143 and bs ~= 142 then
                    Render:SetFont(AssetLocation.Disk, "Archivo.ttf")

                    local str = "> " .. string.format(self.disttext, tostring(distance)) .. " <"
                    local size = Render.Size.x / 100
                    local pos = Vector2(Render.Size.x / 2 - Render:GetTextWidth(str, size) / 2, 30)
                    local sett_alpha = Game:GetSetting(4) * 2.25
                    local color = Color(0, 0, 0, sett_alpha)

                    Render:DrawShadowedText(pos, str, Color(255, 255, 255, sett_alpha), color, size)
                end
            end
        end

        local fire = self.fire

        if fire and not object and distance > 80 then
            local cameraAngle = Camera:GetAngle()
            local args = {
                collision = "km02.towercomplex.flz/key013_01_lod1-g_col.pfx",
                model = "",
                position = Camera:GetPosition() + (cameraAngle * (Vector3.Forward * 30)),
                angle = cameraAngle
            }
            self.object = ClientStaticObject.Create(args)
            self.endposition = self.position + cameraAngle * Vector3.Forward * 1.5
            self.startposition = args.position
            self.fire = nil
        elseif object and self.endposition then
            local lpPos = LocalPlayer:GetPosition()
            local objPos = self.object:GetPosition()
            local dist = Vector3.Distance(lpPos, objPos)

            if dist < 15 then
                local normal = self.normal
                local pi = math.pi
                local angle = Angle.FromVectors(Vector3.Up, normal) * Angle(0, pi / 2, 0)

                self.object:SetPosition(self.endposition - (angle * (Vector3.Forward * 2)))
                self.object:SetAngle(angle)
                self.endposition = nil
                self.object:Remove()
                self.object = nil
                self.destroyTimer:Restart()
            end
        end
    end
end

function SuperGrapple:ModuleUnload()
    if self.object then self.object:Remove() end
    if self.fx then self.fx:Remove() end
end

function SuperGrapple:LocalPlayerInput(args)
    if self.LongerGrappleEnabledValue then
        local gamepadInUse = Game:GetSetting(GameSetting.GamepadInUse)

        if gamepadInUse == 0 then
            if args.input == Action.FireGrapple and self.timer:GetSeconds() > 3 then
                self.destroyTimer:Restart()
                if self.object then self.object:Remove() self.object = nil end
                self.fire = true
                self.timer:Restart()
            elseif self.destroyTimer:GetSeconds() > 3 then
                if self.object then self.object:Remove() self.object = nil end
            elseif args.input == Action.GrapplingAction then
                self.grappling = true
            else
                self.fire = false
                self.grappling = false
            end
        end

        if gamepadInUse == 1 then
            if Input:GetValue(Action.FireGrapple) > 0 then
                self.destroyTimer:Restart()
                if self.object then self.object:Remove() self.object = nil end
                self.fire = true
                self.timer:Restart()
            elseif self.destroyTimer:GetSeconds() > 3 then
                if self.object then self.object:Remove() self.object = nil end
            elseif args.input == Action.GrapplingAction then
                self.grappling = true
            else
                self.fire = false
                self.grappling = false
            end
        end
    end
end

local supergrapple = SuperGrapple()