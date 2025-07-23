class 'Pigeon'

function Pigeon:__init()
    self.rolls = true
    self.grapple = true
    self.score = 0
    self.superspeed = false

    self:UpdateKeyBinds()

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            press = "Нажмите ",
            name = " или RB чтобы ускориться. Нажмите Ctrl чтобы сбавить скорость.",
            nameTh = "%i км/ч %i метров\n",
            tip = "Нажмите Q, чтобы раскрыть вингсьют.",
            tRecord = "Личный рекорд полета на вингсьюте: ",
            pvpblock = "Вы не можете использовать это во время боя!"
        }
    end

    self.default_speed = 50
    self.default_vertical_speed = -5

    self.max_speed = 139
    self.min_speed = 0

    self.tether_length = 150 -- meters
    self.yaw_gain = 1.5
    self.yaw = 0

    self.camera = 1

    self.speed = self.default_speed
    self.vertical_speed = self.default_vertical_speed

    self.cooltime = 0

    self.blacklist = {
        actions = { -- Actions to block while wingsuit is active
            [Action.LookUp] = true,
            [Action.LookDown] = true,
            [Action.LookLeft] = true,
            [Action.LookRight] = true
        },
        animations = { -- Disallow activation during these base states
            [AnimationState.SDead] = true,
            [AnimationState.SUnfoldParachuteHorizontal] = true,
            [AnimationState.SUnfoldParachuteVertical] = true,
            [AnimationState.SPullOpenParachuteVertical] = true
        }
    }

    self.whitelist = { -- Allow instant activation during these base states
        animations = {
            [AnimationState.SSkydive] = true,
            [AnimationState.SParachute] = true
        }
    }

    self.timers = {grapple = Timer()}

    self.permissions = {
        ["Creator"] = true,
        ["GlAdmin"] = true,
        ["Admin"] = true,
        ["AdminD"] = true,
        ["ModerD"] = true,
        ["Organizer"] = true,
        ["Parther"] = true,
        ["VIP"] = true
    }

    self.subs = {}

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("UpdateKeyBinds", self, self.UpdateKeyBinds)
    Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
    Events:Subscribe("KeyUp", self, self.KeyUp)
    Events:Subscribe("AbortWingsuit", self, self.Abort)
    Events:Subscribe("LocalPlayerWorldChange", self, self.LocalPlayerWorldChange)

    Console:Subscribe("pigeonmod", self, function() print("Данная команда больше ничего не дает, но режим голубя по прежнему доступен для VIP.") end)
    Console:Subscribe("superspeed", self, self.Superspeed)

    Network:Subscribe("onFlyingAttempt", self, self.onFlyingAttempt)
end

function Pigeon:onFlyingAttempt(data)
    self.attempt = data
    self.attempt[3] = 4
end

function Pigeon:Lang()
    self.locStrings = {
        press = "Press ",
        name = " or RB to boost. Press Ctrl to slow down.",
        nameTh = "%i km/h %i m\n",
        tip = "Press Q to use wingsuit.",
        tRecord = "Personal flying record: ",
        pvpblock = "You cannot use this during combat!"
    }
end

function Pigeon:UpdateKeyBinds()
    local keyBinds = LocalPlayer:GetValue("KeyBinds")
    local openWingsuitBind = keyBinds and keyBinds["Wingsuit"]
    local boostBind = keyBinds and keyBinds["VehicleLandBoost"]

    self.openWingsuitKey = openWingsuitBind and openWingsuitBind.type == "Key" and openWingsuitBind.value or 81
    self.boostKey = boostBind and boostBind.type == "Key" and boostBind.value or 16
    self.boostStringKey = boostBind and boostBind.type == "Key" and boostBind.valueString or "Shift"
end

function Pigeon:LocalPlayerInput(args)
    if Game:GetState() ~= GUIState.Game then return end
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    if args.input == Action.Kick then
        if Game:GetSetting(GameSetting.GamepadInUse) == 1 then
            self:OpenWingsuit()
        end
    elseif args.input == Action.VehicleCam and self.subs.camera then
        local elapsedSeconds = Client:GetElapsedSeconds()
        local time = elapsedSeconds

        if time < self.cooltime then
            time = elapsedSeconds
        else
            if self.camera < 5 then
                self.camera = self.camera + 1
            else
                self.camera = 1
            end
        end

        self.cooltime = time + 0.05
        return false
    end
end

function Pigeon:KeyUp(args)
    if Game:GetState() ~= GUIState.Game then return end
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    local timers = self.timers
    local timersActivate = timers.activate

    if args.key == VirtualKey.Control and self.subs.camera and not (timers.camera_start or timers.camera_stop) then
        if not timersActivate or timersActivate:GetMilliseconds() > 300 then
            self.timers.activate = Timer()
        elseif timersActivate:GetMilliseconds() < 500 then
            local ray = Physics:Raycast(LocalPlayer:GetPosition(), LocalPlayer:GetAngle() * Vector3(0, -1, -1), 0, 50)
            LocalPlayer:SetBaseState((ray.distance < 50) and AnimationState.SFall or AnimationState.SSkydive)
            self.timers.camera_stop = Timer()
        end
    end

    if args.key == self.openWingsuitKey then
        self:OpenWingsuit()
    end
end

function Pigeon:OpenWingsuit(args)
    if not LocalPlayer:GetValue("Wingsuit") then return end
    if not LocalPlayer:GetValue("WingsuitEnabled") then return end
    if self.subs.camera or LocalPlayer:GetVehicle() then return end

    local bs = LocalPlayer:GetBaseState()
    if self.blacklist.animations[bs] then return end

    if self.whitelist.animations[bs] then
        if not self.RCtimer then
            self.RCtimer = Timer()
        end

        if LocalPlayer:GetValue("PigeonMod") and LocalPlayer:GetValue("PVPMode") then
            Events:Fire("CastCenterText", {text = self.locStrings["pvpblock"], time = 3, color = Color.Red})
            return
        end

        self.timers.camera_start = Timer()
        self.speed = self.default_speed

        LocalPlayer:SetBaseState(AnimationState.SSkydive)
        LocalPlayer:SetValue("IsPigeonMod", true)

        if not self.subs.wings then self.subs.wings = Events:Subscribe("GameRenderOpaque", self, self.DrawWings) end
        if not self.subs.velocity then self.subs.velocity = Events:Subscribe("Render", self, self.SetVelocity) end
        if not self.subs.camera then self.subs.camera = Events:Subscribe("CalcView", self, self.Camera) end
        if not self.subs.glide then self.subs.glide = Events:Subscribe("InputPoll", self, self.Glide) end
        if not self.subs.input then self.subs.input = Events:Subscribe("LocalPlayerInput", self, self.Input) end
    elseif LocalPlayer:GetValue("PigeonMod") then
        if self.whitelist.animations[bs] then
            local timer = Timer()
            self.timers.camera_start = Timer()
            self.speed = self.default_speed

            if not self.subs.camera then self.subs.camera = Events:Subscribe("CalcView", self, self.Camera) end
            if not self.subs.input then self.subs.input = Events:Subscribe("LocalPlayerInput", self, self.Input) end
            if not self.subs.wings then self.subs.wings = Events:Subscribe("GameRenderOpaque", self, self.DrawWings) end

            self.subs.delay = Events:Subscribe("PreTick", function()
                local dt = timer:GetMilliseconds()
                LocalPlayer:SetBaseState(AnimationState.SSkydive)
                LocalPlayer:SetLinearVelocity(LocalPlayer:GetAngle() * math.lerp(Vector3(0, self.speed, 0), Vector3(0, 0, -self.speed), dt / 1000))
                if dt > 1000 then
                    Events:Unsubscribe(self.subs.delay)
                    self.subs.delay = nil
                    self.subs.velocity = Events:Subscribe("Render", self, self.SetVelocity)
                end
            end)
        end
    end
end

function Pigeon:DrawWings()
    self.dt = math.abs((Game:GetTime() + 12) % 24 - 12) / 12

    local bones = LocalPlayer:GetBones()
    local color = LocalPlayer:GetColor()

    local rightForceArm = bones.ragdoll_RightForeArm.position
    local rightUpLeg = bones.ragdoll_RightUpLeg.position
    local leftForeArm = bones.ragdoll_LeftForeArm.position
    local leftUpLeg = bones.ragdoll_LeftUpLeg.position

    local r = math.lerp(0.1 * color.r, color.r, self.dt)
    local g = math.lerp(0.1 * color.g, color.g, self.dt)
    local b = math.lerp(0.1 * color.b, color.b, self.dt)

    color = Color(r, g, b)

    Render:FillTriangle(bones.ragdoll_RightArm.position, rightForceArm, rightUpLeg, color)
    Render:FillTriangle(bones.ragdoll_LeftArm.position, leftForeArm, leftUpLeg, color)

    local lineColor = Color.Black
    Render:DrawLine(rightForceArm, rightUpLeg, lineColor)
    Render:DrawLine(leftForeArm, leftUpLeg, lineColor)
end

function Pigeon:SetVelocity()
    local bs = LocalPlayer:GetBaseState()

    if bs ~= AnimationState.SSkydive and bs ~= AnimationState.SSkydiveDash then
        self:Abort()
        return
    end

    local angle = LocalPlayer:GetAngle()
    local pigeonMod = LocalPlayer:GetValue("PigeonMod")

    if pigeonMod then
        local freeze = LocalPlayer:GetValue("Freeze")
        local gamepad = Game:GetSetting(GameSetting.GamepadInUse) == 1
        local inputBoost = Input:GetValue(Action.Dash) > 0
        local inputBrake = Input:GetValue(Action.Handbrake) > 0
        local keyBoost = Key:IsDown(self.boostKey)

        if not freeze then
            if (gamepad and inputBoost or keyBoost) and self.speed < self.max_speed then
                self.speed = self.speed + 0.5
            elseif (gamepad and inputBrake or Key:IsDown(VirtualKey.Control)) and self.speed > self.min_speed then
                self.speed = self.speed - 1
            end
        end

        local speed = self.speed - math.sin(angle.pitch) * 20
        LocalPlayer:SetLinearVelocity(angle * Vector3(0, 0, -speed))
    else
        self.score = math.ceil(self.RCtimer:GetSeconds())
        local speed = self.speed - math.sin(angle.pitch) * 20
        if angle.pitch < 0.9 then
            LocalPlayer:SetLinearVelocity(angle * Vector3(0, 0, -speed) + Vector3(0, self.vertical_speed, 0))
        end
    end

    if not self.rolls or self.subs.grapple then return end

    if Input:GetValue(Action.MoveLeft) > 0 then
        if not self.roll_left then
            self.roll_left = true
            if not self.timers.roll_left then
                self.timers.roll_left = Timer()
            elseif self.timers.roll_left:GetMilliseconds() < 500 then
                if not self.subs.roll_left then
                    local timer = Timer()
                    LocalPlayer:SetBaseState(AnimationState.SSkydiveDash)
                    self.subs.roll_left = Events:Subscribe("PreTick", function()
                        if timer:GetMilliseconds() > 750 then
                            LocalPlayer:SetBaseState(AnimationState.SSkydive)
                            Events:Unsubscribe(self.subs.roll_left)
                            self.subs.roll_left = nil
                        end
                    end)
                end
                self.timers.roll_left = nil
            else
                self.timers.roll_left = nil
            end
        end
    else
        self.roll_left = nil
    end

    if Input:GetValue(Action.MoveRight) > 0 then
        if not self.roll_right then
            self.roll_right = true
            if not self.timers.roll_right then
                self.timers.roll_right = Timer()
            elseif self.timers.roll_right:GetMilliseconds() < 500 then
                if not self.subs.roll_right then
                    local timer = Timer()
                    LocalPlayer:SetBaseState(AnimationState.SSkydiveDash)
                    self.subs.roll_right = Events:Subscribe("PreTick", function()
                        if timer:GetMilliseconds() > 750 then
                            LocalPlayer:SetBaseState(AnimationState.SSkydive)
                            Events:Unsubscribe(self.subs.roll_right)
                            self.subs.roll_right = nil
                        end
                    end)
                end
                self.timers.roll_right = nil
            else
                self.timers.roll_right = nil
            end
        end
    else
        self.roll_right = nil
    end

    if Game:GetState() ~= GUIState.Game then return end
    if LocalPlayer:GetValue("HiddenHUD") then return end
    if not pigeonMod then return end

    local locStrings = self.locStrings
    local text = locStrings["press"] .. self.boostStringKey .. locStrings["name"]
    local speed = LocalPlayer:GetLinearVelocity():Length() * 3.6
    local player_pos = LocalPlayer:GetPosition()
    local altitude = player_pos.y - (math.max(200, Physics:GetTerrainHeight(player_pos)))
    Render:SetFont(AssetLocation.Disk, "Archivo.ttf")
    local hud_str = string.format(locStrings["nameTh"], speed, altitude)
    local screen_pos = Vector2(0.5 * Render.Width - 0.5 * Render:GetTextWidth(hud_str, TextSize.Large), Render.Height - Render:GetTextHeight(hud_str, TextSize.Large))
    local boostColor = Color(255, 125, 125, 200)

    Render:DrawShadowedText(screen_pos, hud_str, boostColor, Color(0, 0, 0, 100), TextSize.Large)

    if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

    local textSize = 15
    local size = Render:GetTextSize(text, textSize)
    local pos = Vector2((Render.Width - size.x) / 2, Render.Height - size.y - 10)

    Render:DrawShadowedText(pos, text, Color.White, Color(0, 0, 0, 180), textSize)
end

function Pigeon:Glide()
    if LocalPlayer:GetValue("PigeonMod") then return end

    if not self.hit then
        if Input:GetValue(Action.MoveBackward) > 0 and LocalPlayer:GetAngle().pitch > 0 then
            Input:SetValue(Action.MoveBackward, 0)
        end
    else
        Input:SetValue(Action.MoveBackward, 0.9)

        if self.yaw < 0 then
            Input:SetValue(Action.MoveLeft, -self.yaw_gain * self.yaw)
        elseif self.yaw > 0 then
            Input:SetValue(Action.MoveRight, self.yaw_gain * self.yaw)
        end
    end
end

function Pigeon:Input(args)
    if Game:GetState() ~= GUIState.Game then return end

    if not LocalPlayer:GetValue("PigeonMod") and self.grapple and not LocalPlayer:GetValue("Freeze") and args.input == Action.FireGrapple then
        if self.subs.grapple or self.subs.roll_left or self.subs.roll_right or self.timers.grapple:GetMilliseconds() < 500 then
            return false
        end

        local angle = LocalPlayer:GetAngle()

        if angle.pitch < -0.2 * math.pi then return false end

        LocalPlayer:SetLeftArmState(399)

        self.timers.grapple = Timer()
        local direction = Angle(angle.yaw, 0, 0) * Vector3(-angle.roll, -0.3, -1)

        self.effect = ClientEffect.Create(AssetLocation.Game, {
            effect_id = 11,
            position = LocalPlayer:GetPosition(),
            angle = Angle()
        })

        self.subs.grapple = Events:Subscribe("GameRenderOpaque", function()
            local dt = self.timers.grapple:GetMilliseconds()
            local bone_pos = LocalPlayer:GetBonePosition("ragdoll_LeftForeArm")

            local color = Color(100, 100, 100)
            local r = math.lerp(0.5 * color.r, color.r, self.dt)
            local g = math.lerp(0.5 * color.g, color.g, self.dt)
            local b = math.lerp(0.5 * color.b, color.b, self.dt)

            if not self.hit then
                local distance = self.tether_length * dt / 500
                local ray = Physics:Raycast(bone_pos, direction, 0, distance)

                Render:DrawLine(bone_pos, ray.position, Color(r, g, b, 192))

                if ray.distance < distance - 0.1 and ray.position.y > 199 then
                    self.hit = ray.position
                    self.speed = self.speed + 4
                    self.vertical_speed = -self.vertical_speed
                end

                if dt > 500 then
                    self:EndGrapple()
                end
            else
                Render:DrawLine(bone_pos, self.hit, Color(r, g, b, 192))

                local yaw1 = math.atan2(bone_pos.x - self.hit.x, bone_pos.z - self.hit.z)
                local yaw2 = angle.yaw
                self.yaw = (yaw2 - yaw1 + math.pi) % (2 * math.pi) - math.pi

                if dt > 1500 or math.abs(self.yaw) > 0.2 * math.pi or Vector3.DistanceSqr(bone_pos, self.hit) > self.tether_length ^ 2 then
                    self:EndGrapple()
                end
            end
        end)
        return false
    end
    if self.blacklist.actions[args.input] then
        return false
    end
end

function Pigeon:Superspeed()
    local gettag = LocalPlayer:GetValue("Tag")

    if self.permissions[gettag] then
        self.superspeed = not self.superspeed

        if self.superspeed then
            self.max_speed = 556
            print("Superspeed activated.")
        else
            self.max_speed = 139
            print("Superspeed deactivated.")
        end
    else
        print("Needed VIP status.")
    end
end

function Pigeon:EndGrapple()
    self.timers.grapple:Restart()
    self.effect:Remove()
    LocalPlayer:SetLeftArmState(384)
    Events:Unsubscribe(self.subs.grapple)
    self.subs.grapple = nil
    self.hit = nil
    self.yaw = 0
    self.vertical_speed = self.default_vertical_speed
    self.speed = self.default_speed
end

function Pigeon:Abort()
    local object = NetworkObject.GetByName("Flying")
    if not object or self.score > (object:GetValue("S") or 0) then
        Network:Send("onFlyingRecord", self.score)
    elseif self.score > ((object:GetValue("S") or 0) * 0.6) and (object:GetValue("N") or "None") ~=
        LocalPlayer:GetName() then
        Network:Send("onFlyingAttempt", self.score)
    end

    local shared = SharedObject.Create("Flying")
    if self.score > (shared:GetValue("Record") or 0) then
        shared:SetValue("Record", self.score)
        Network:Send("FlyingRecordTask", self.score)
        Network:Send("UpdateMaxRecord", self.score)
        Game:ShowPopup(self.locStrings["tRecord"] .. self.score, true)
    end

    if self.RCtimer then self.RCtimer = nil end

    self.score = 0
    LocalPlayer:SetValue("IsPigeonMod", nil)

    if self.subs.wings then Events:Unsubscribe(self.subs.wings) self.subs.wings = nil end
    if self.subs.velocity then Events:Unsubscribe(self.subs.velocity) self.subs.velocity = nil end
    if self.subs.glide then Events:Unsubscribe(self.subs.glide) self.subs.glide = nil end
    if self.subs.input then Events:Unsubscribe(self.subs.input) self.subs.input = nil end
    if self.subs.camera then Events:Unsubscribe(self.subs.camera) self.subs.camera = nil end
end

function Pigeon:Camera()
    if LocalPlayer:GetValue("SpectatorMode") then return end

    local player_pos = LocalPlayer:GetPosition()
    local player_angle = LocalPlayer:GetAngle()
    local vector

    if self.camera == 1 then
        vector = Vector3(0, 2, 7)
    elseif self.camera == 2 then
        vector = Vector3(0, 1, 1)
    elseif self.camera == 3 then
        vector = Vector3(0, 0.5, -1)
    elseif self.camera == 4 then
        vector = Vector3(0, 1, 10)
    end

    if self.timers.camera_start then
        local dt = self.timers.camera_start:GetMilliseconds()

        if self.camera < 5 then
            Camera:SetPosition(math.lerp(Camera:GetPosition(), player_pos + player_angle * vector, dt / 1000))
            Camera:SetAngle(Angle.Slerp(Camera:GetAngle(), player_angle, 0.9 * dt / 1000))
        end

        if dt >= 1000 then
            self.timers.camera_start = nil
        end
    elseif self.timers.camera_stop then
        local dt = self.timers.camera_stop:GetMilliseconds()

        if self.camera < 5 then
            Camera:SetPosition(math.lerp(player_pos + player_angle * vector, Camera:GetPosition(), dt / 1000))
            Camera:SetAngle(Angle.Slerp(Camera:GetAngle(), player_angle, 0.9 - 0.9 * dt / 1000))
        end

        if dt >= 1000 then
            self.timers.camera_stop = nil
            self:Abort()
        end
    else
        if self.camera < 5 then
            Camera:SetPosition(player_pos + player_angle * vector)
            Camera:SetAngle(Angle.Slerp(Camera:GetAngle(), player_angle, 0.9))
        end
    end
end

function Pigeon:LocalPlayerWorldChange()
    LocalPlayer:SetValue("PigeonMod", false)
end

local pigeon = Pigeon()