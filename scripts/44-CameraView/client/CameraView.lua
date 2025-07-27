class 'CameraView'

function CameraView:__init()
    self.enabled = true
    self.camera = 3
    self.selectedViews = {
        [0] = true,
        [1] = true,
        [2] = true,
        [3] = true
    }
    self.antiSnap = false

    self.reverse = false
    self.zoom = 0
    self.lastTime = 0
    self.timer = Timer()

    self.cooltime = 0

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.names = {
            [0] = "Вид спереди",
            [1] = "Вид сзади",
            [2] = "Вид сверху",
            [3] = "Стандартный вид"
        }
    end

    if LocalPlayer:InVehicle() then
        self.CalcViewEvent = Events:Subscribe("CalcView", self, self.CalcView)
        self.MouseScrollEvent = Events:Subscribe("MouseScroll", self, self.MouseScroll)
        self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
        self.InputPollEvent = Events:Subscribe("InputPoll", self, self.InputPoll)
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("ToggleCamZoom", self, self.ToggleCamZoom)
    Events:Subscribe("ZoomReset", self, self.ZoomReset)
    Events:Subscribe("LocalPlayerEnterVehicle", self, self.EnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)

    self.vehicles = {}

    -- y, z, x (height, depth, horizontal offset)
    -- Land Vehicles
    self.vehicles[2] = {1.5, -0.1, 0, 1.2, 0.4, -0.25, 2.5, 5, 0} -- ON DEFAULT BUY LIST
    self.vehicles[4] = {1.75, -4, 0, 2.5, -3, -0.55, 5.5, 7.5, 0}
    self.vehicles[11] = {1.05, -0.4, 0, 1.8, 1, 0, 2.5, 5, 0}
    self.vehicles[13] = {1.2, 0, 0, 1.25, 0.57, -0.35, 2.25, 5, 0}
    self.vehicles[18] = {2.35, -2.3, 0, 2.4, -1.5, 0, 4, 5.5, 0}
    self.vehicles[21] = {1.15, -0.25, 0, 1.75, 1, 0, 2, 3, 0}
    self.vehicles[22] = {1.3, -0.75, 0, 1.55, -0.2, 0, 3, 4, 0}
    self.vehicles[35] = {1.30, -0.4, 0, 1.1, 0.25, -0.25, 2, 4, 0}
    self.vehicles[43] = {1.15, -0.25, 0, 1.75, 1, 0, 1.65, 2.75, 0}
    self.vehicles[46] = {1.8, -0.5, 0, 1.6, 0, -0.5, 3, 6, 0}
    self.vehicles[54] = {1.4, -0.2, 0, 1.2, 0.5, -0.3, 2, 4, 0}
    self.vehicles[56] = {2, -2.1, 0, 2.4, -1.3, 0, 4.5, 5.5, 0}
    self.vehicles[72] = {1.75, -0.55, 0, 1.575, 0, -0.5, 3.2, 5, 0}
    self.vehicles[76] = {2.5, -1.5, 0, 2.5, -0.55, -0.5, 4.5, 6, 0}
    self.vehicles[77] = {1.65, -1, 0, 1.5, 0, -0.3, 3, 5, 0}
    self.vehicles[78] = {1.45, -0.2, 0, 1.2, 0.5, -0.3, 2, 4, 0}
    self.vehicles[79] = {1.75, -3.5, 0, 2.1, -2.5, -0.4, 5, 7, 0}
    self.vehicles[87] = {1.8, 0.2, 0, 1.65, 0.6, -0.3, 3, 4, 0}
    self.vehicles[89] = {1.15, -0.25, 0, 1.75, 1, 0, 1.75, 2.5, 0}
    self.vehicles[91] = {1.3, -0.2, 0, 1.2, 0.5, -0.3, 2, 4, 0}

    self.vehicles[1] = {1.8, 0, 0, 1.8, 1.05, 0, 2.35, 3.85, 0} -- CUSTOM BUY LISTS
    self.vehicles[7] = {1.45, -0.2, 0, 1.15, 0.65, -0.2, 2.2, 5.5, 0}
    self.vehicles[8] = {1.45, -1.25, 0, 1.3, -0.45, -0.25, 2.3, 6, 0}
    self.vehicles[9] = {1.6, -0.6, 0, 1.75, 1, 0, 2.75, 3.6, 0}
    self.vehicles[10] = {2, -0.7, 0, 1.77, 0.05, -0.25, 2.7, 4.5, 0}
    self.vehicles[12] = {1.75, -5.3, 0, 1.85, -4.15, -0.35, 5.1, 10.1, 0}
    self.vehicles[15] = {1.4, -0.1, 0, 1.3, 0.55, -0.25, 2.25, 5, 0}
    self.vehicles[23] = {1.6, -0.8, 0, 1.35, -0.1, -0.25, 2.75, 5, 0}
    self.vehicles[26] = {1.7, -0.65, 0, 1.4, 0, -0.2, 2.2, 4.55, 0}
    self.vehicles[29] = {1.4, -0.1, 0, 1.25, 0.6, -0.25, 2.25, 5, 0}
    self.vehicles[31] = {3.25, -2.6, 0, 3.3, -1.5, -0.7, 5, 8, 0}
    self.vehicles[32] = {1.15, -0.1, 0, 1.75, 1, 0, 2, 3, 0}
    self.vehicles[33] = {1.7, -0.65, 0, 1.333, 0, -0.2, 3.08, 4.8, 0}
    self.vehicles[36] = {1.2, -0.3, 0, 1.8, 1.3, 0, 2.2, 3.5, 0}
    self.vehicles[40] = {2.5, -1.7, 0, 2.35, -0.85, -0.45, 4.25, 8.7, 0}
    self.vehicles[41] = {2, -2.25, 0, 2.1, -1.3, -0.35, 4.35, 7.55, 0}
    self.vehicles[42] = {2.1, -2.25, 0, 2.15, -1.25, -0.3, 3.45, 7.55, 0}
    self.vehicles[44] = {1.4, -0.05, 0, 1.25, 0.5, -0.25, 1.85, 3.6, 0}
    self.vehicles[47] = {1.25, -0.15, 0, 1.75, 1, 0, 2, 3.6, 0}
    self.vehicles[48] = {1.45, -0.15, 0, 1.45, 0.75, 0, 2.5, 5.05, 0}
    self.vehicles[49] = {2.1, -2.25, 0, 2.1, -1.25, -0.35, 3.85, 7.25, 0}
    self.vehicles[52] = {2, -0.7, 0, 1.8, 0.15, -0.3, 2.7, 4.5, 0}
    self.vehicles[55] = {1.4, -0.1, 0, 1.3, 0.55, -0.25, 2.25, 5, 0}
    self.vehicles[60] = {1.4, -0.25, 0, 1.25, 0.7, -0.1, 2.25, 4.5, 0}
    self.vehicles[61] = {1.2, 0.05, 0, 1.75, 1, 0, 2, 3, 0}
    self.vehicles[63] = {1.6, -0.7, 0, 1.35, -0.1, -0.15, 2.4, 4.75, 0}
    self.vehicles[66] = {2.55, -2.3, 0, 2.45, -1.55, -0.4, 4.25, 8.2, 0}
    self.vehicles[68] = {1.7, -0.65, 0, 1.35, -0.1, -0.2, 2.9, 5.25, 0}
    self.vehicles[70] = {1.4, -0.1, 0, 1.3, 0.55, -0.25, 2.25, 5, 0}
    self.vehicles[71] = {2, -2.25, 0, 2.05, -1.3, -0.35, 4, 8, 0}
    self.vehicles[73] = {1.7, -.65, 0, 1.4, 0, -0.2, 2.45, 4.55, 0}
    self.vehicles[74] = {1.33, -0.35, 0, 1.75, 1, 0, 1.8, 2.8, 0}
    self.vehicles[83] = {1.25, -0.15, 0, 1.75, 1, 0, 2, 3, 0}
    self.vehicles[84] = {1.85, -0.4, 0, 1.65, 0.15, -0.4, 2.75, 5.25, 0}
    self.vehicles[86] = {1.85, -0.55, 0, 1.575, 0, -0.25, 2.65, 4.8, 0}
    self.vehicles[90] = {1.15, -0.1, 0, 1.75, 1, 0, 2, 3, 0}

    -- Sea Vehicles
    self.vehicles[5] = {2, -2.1, 0, 1.4, 3, 0, 3, 7, 0} -- ON DEFAULT BUY LIST
    self.vehicles[16] = {1.4, -3.2, 0, 2, 0.2, 0, 3, 6, 0}
    self.vehicles[25] = {2.75, -5.75, 0, 5.65, 7, 0, 7.5, 14, 0}
    self.vehicles[27] = {1.5, -6, 0, 1.6, -0.5, -0.65, 2.8, 8, 0}
    self.vehicles[28] = {1.5, -2.5, 0.075, 1.675, 0, 0, 3, 7, 0}
    self.vehicles[50] = {4.5, -7, 0, 5, 9, -2.5, 8, 20, 0}
    self.vehicles[69] = {2.75, -4, 0, 2.7, 0.55, 0, 4.5, 9, 0}
    self.vehicles[80] = {1.3, -2.2, 0, 1.2, 0.4, -0.45, 2.5, 5.5, 0}
    self.vehicles[88] = {1.5, -1, 0, 1.1, 0.2, 0, 2.5, 6, 0}

    self.vehicles[6] = {1.8, -3.2, 0, 1.65, 0.05, 0, 3.4, 9.6, 0} -- CUSTOM BUY LISTS
    self.vehicles[19] = {1.8, -3.2, 0, 1.85, 0.3, 0, 3.55, 9.1, 0}
    self.vehicles[38] = {2.15, -5.4, 0, 2.55, 5.4, 0, 3.4, 9.6, 0}
    self.vehicles[45] = {2, -3.6, 0, 3.4, 1.65, 0, 3.55, 9.1, 0}

    -- Air Vehicles
    self.vehicles[3] = {0.35, -1.2, 0, 1.5, -0.5, 0, 4, 8, 0} -- ON DEFAULT BUY LIST
    self.vehicles[30] = {1.5, -7.1, 0, 2.75, -3.5, 0, 4.5, 9, 0}
    self.vehicles[34] = {2.75, -7, 0, 4.85, -2, 0, 7, 19, 0}
    self.vehicles[64] = {0.36, -2, 0, 2.6, -3.3, 0, 6, 12, 0}
    self.vehicles[65] = {-1.0, -5, 0, 0, -3.5, 0, 3, 12, 0}
    self.vehicles[81] = {1.4, -3.7, 0, 2.01, 0, 0, 3.2, 4, 0}
    self.vehicles[85] = {4, -11.1, 0, 6.1, -10, 0, 10, 38, 0}

    self.vehicles[14] = {0.15, -0.2, 0, 1.8, -0.55, 0, 4, 10.6, 0} -- CUSTOM BUY LISTS
    self.vehicles[37] = {1.2, -5, 0, 2.3, -2.3, 0, 4.6, 11.2, 0}
    self.vehicles[39] = {4.5, -11.2, 0, 4.45, -9.6, 0, 8.65, 31.6, 0}
    self.vehicles[51] = {2.3, -2.05, 0, 2.05, -0.5, 0, 3.1, 9.7, 0}
    self.vehicles[57] = {1.2, -5, 0, 2.3, -2.3, 0, 4.6, 11.2, 0}
    self.vehicles[59] = {2.55, -2.9, 0, 2.5, 0.15, 0, 3.5, 6.7, 0}
    self.vehicles[62] = {1.25, -2.2, 0, 1.75, -0.6, -0.3, 4.4, 10.9, 0}
    self.vehicles[67] = {0.15, -0.1, 0, 1.8, -0.55, 0, 4, 10.6, 0}

    -- DLC Vehicles
    self.vehicles[20] = {2.45, -0.5, 0, 2.2, 0.25, -0.4, 3.45, 5.35, 0} -- CUSTOM BUY LISTS
    self.vehicles[24] = {1.1, -6.8, 0, 2.45, -3.75, 0, 4.15, 7.2, 0}
    self.vehicles[53] = {2.1, -2.65, 0, 2.25, -1.3, -0.5, 4, 7.35, 0}
    self.vehicles[58] = {1.5, -0.1, 0, 1.2, 0.5, -0.25, 2.2, 4.95, 0}
    self.vehicles[75] = {1.6, -0.65, 0, 1.6, -0.05, 0, 2.8, 4.1, 0}
    self.vehicles[82] = {1.6, -0.8, 0, 1.35, 0.05, -0.2, 3.05, 4.8, 0}
end

function CameraView:Lang()
    self.names = {
        [0] = "Front View",
        [1] = "Back View",
        [2] = "Top View",
        [3] = "Standard View"
    }
end

function CameraView:ToggleCamZoom(args)
    self.enabled = args.zoomcam
end

function CameraView:CastCenterText(text)
    self.timerF = Timer()
    self.textF = text
    self.timeF = 2

    if self.fadeOutAnimation then Animation:Stop(self.fadeOutAnimation) self.fadeOutAnimation = nil end

    Animation:Play(0, 1, 0.15, easeIOnut, function(value) self.animationValue = value end)

    if not self.RenderEvent then self.RenderEvent = Events:Subscribe("Render", self, self.Render) end
end

function CameraView:Render()
    if Game:GetState() ~= GUIState.Game then return end

    local textF = self.textF

    if self.timerF and textF then
        local timerFSeconds = self.timerF:GetSeconds()

        if timerFSeconds > self.timeF then
            self.fadeOutAnimation = Animation:Play(self.animationValue, 0, 0.75, easeIOnut, function(value) self.animationValue = value end, function()
                self.textF = nil
                self.timeF = nil
                self.animationValue = nil
                self.fadeOutAnimation = nil

                if self.RenderEvent then
                    Events:Unsubscribe(self.RenderEvent)
                    self.RenderEvent = nil
                end
            end)

            self.timerF = nil
        end
    end

    if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

    local size = 15
    local pos = Vector2(Render.Width / 2, Render.Height / 1.075) - Render:GetTextSize(textF, size) / 2
    local color = Color.White
    local shadowColor = Color.Black

    local animationValue = self.animationValue
    local textColor = Color(color.r, color.g, color.b, math.lerp(0, color.a, animationValue))
    local textShadow = Color(shadowColor.r, shadowColor.g, shadowColor.b, math.lerp(0, shadowColor.a, animationValue))

    Render:DrawShadowedText(pos, textF, textColor, textShadow, size)
end

function CameraView:CalcView()
    if LocalPlayer:GetValue("SpectatorMode") then return end

    if not LocalPlayer:InVehicle() then return end

    local camera = self.camera
    local zoom = self.zoom
    local reverse = self.reverse

    local position = LocalPlayer:GetPosition()
    local vehicle = LocalPlayer:GetVehicle()
    local vid = vehicle:GetModelId()
    local angle = vehicle:GetAngle()

    local cam_pos = Vector3()
    local t = Vector3()
    local s = 0

    if Game:GetState() == GUIState.Game and self.enabled then
        local keyDown = Key:IsDown(4)

        if keyDown and not self.keyWasDown then
            if zoom ~= 0 then
                self:ZoomReset()
            else
                self.reverse = true
                Events:Fire("CameraState", {enabled = self.enabled, camera = self.names[camera], altview = reverse})
            end
        end

        if not keyDown and self.keyWasDown and reverse then
            self.reverse = false
            Events:Fire("CameraState", {enabled = self.enabled, camera = self.names[camera], altview = reverse})
        end

        self.keyWasDown = keyDown
    end

    if reverse then
        local vehicles = self.vehicles
        local vId = vehicles[vid]
        local pos_3d = vehicle:GetPosition()

        t = Vector3((vId[9]), (vId[7]), (vId[8]))
        angle = angle * Angle(math.pi, 0, 0)
        cam_pos = pos_3d + (angle * t)
        angle = angle * Angle(0, -0.10, 0)
    elseif camera == 0 then -- Bumper/Hood Cam
        local vehicles = self.vehicles
        local vId = vehicles[vid]
        local pos_3d = vehicle:GetPosition()

        t = Vector3((vId[3]), (vId[1]), (vId[2]))
        cam_pos = pos_3d + (angle * t)
    elseif camera == 1 then -- Chase Cam
        local vehicles = self.vehicles
        local vId = vehicles[vid]
        local pos_3d = vehicle:GetPosition()

        t = Vector3((vId[9]), (vId[7]), (vId[8]))
        cam_pos = pos_3d + (angle * t)
        angle = angle * Angle(0, -0.10, 0)
    elseif camera == 2 then -- Bird's Eye View
        angle = LocalPlayer:GetAngle()
        angle.pitch = 0
        angle.roll = 0

        cam_pos = position + Vector3(0, 5, 0)

        if reverse then
            cam_pos.y = cam_pos.y + 500
        else
            cam_pos.y = cam_pos.y + 42 + ((s ^ 0.5 + s) / 2.5)
        end

        angle.pitch = math.pi * 1.51
        angle.yaw = 0
    elseif camera == 3 then -- Standard Camera
        angle = Camera:GetAngle()
        cam_pos = Camera:GetPosition()
        t = Vector3(0, 0, zoom)
        cam_pos = cam_pos + (angle * t)
    end

    if camera ~= 3 or (zoom ~= 0 or reverse) then
        if not angle:IsNaN() then
            Camera:SetAngle(angle)
        end

        Camera:SetPosition(cam_pos)
    end
end

function CameraView:ZoomReset()
    self.zoom = 0
end

function CameraView:InputPoll()
    if self.enabled then
        if self.antiSnap and Game:GetState() == GUIState.Game and LocalPlayer:InVehicle() and self.camera == 3 and Input:GetValue(Action.LookLeft) == 0 and Input:GetValue(Action.LookRight) == 0 then
            if self.as_toggle then
                Input:SetValue(Action.LookLeft, 0.0005)
            else
                Input:SetValue(Action.LookRight, 0.0005)
            end

            self.as_toggle = not self.as_toggle
        end
    end
end

function CameraView:MouseScroll(args)
    if Game:GetState() ~= GUIState.Game then return end
    if LocalPlayer:GetValue("SpectatorMode") then return end
    if LocalPlayer:GetValue("VehCameraScroll") then return end

    if self.enabled then
        self.zoom = math.clamp(self.zoom + (args.delta * 0.25), 0, 15)
    end
end

function CameraView:EnterVehicle()
    Events:Fire("CameraState", {enabled = self.enabled, camera = self.names[self.camera], altview = self.reverse})

    if not self.CalcViewEvent then self.CalcViewEvent = Events:Subscribe("CalcView", self, self.CalcView) end
    if not self.MouseScrollEvent then self.MouseScrollEvent = Events:Subscribe("MouseScroll", self, self.MouseScroll) end
    if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
    if not self.InputPollEvent then self.InputPollEvent = Events:Subscribe("InputPoll", self, self.InputPoll) end
end

function CameraView:LocalPlayerExitVehicle()
    if self.CalcViewEvent then Events:Unsubscribe(self.CalcViewEvent) self.CalcViewEvent = nil end
    if self.MouseScrollEvent then Events:Unsubscribe(self.MouseScrollEvent) self.MouseScrollEvent = nil end
    if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
    if self.InputPollEvent then Events:Unsubscribe(self.InputPollEvent) self.InputPollEvent = nil end
end

function CameraView:LocalPlayerInput(args)
    if Game:GetState() ~= GUIState.Game then return end
    if LocalPlayer:GetValue("SpectatorMode") then return end

    if LocalPlayer:InVehicle() then
        if args.input == Action.VehicleCam then
            local elapsedSeconds = Client:GetElapsedSeconds()
            local time = elapsedSeconds

            if time < self.cooltime then
                time = elapsedSeconds
            else
                local timer = self.timer
                local milliseconds = timer:GetMilliseconds()

                if (milliseconds - self.lastTime) > 50 then
                    self:CycleViews()

                    Events:Fire("CameraState", {enabled = self.enabled, camera = self.names[self.camera], altview = self.reverse})
                end

                self.lastTime = milliseconds
            end

            self.cooltime = time + 0.05
            return false
        end

        if args.input == Action.NextWeapon or args.input == Action.PrevWeapon or args.input == Action.EquipTwohanded then
            return false
        end
    end
end

function CameraView:CycleViews()
    local all_disabled = true

    for k = 0, 3 do
        if self.selectedViews[k] then
            all_disabled = false
        end
    end

    if all_disabled then
        self.camera = 3
        return
    end

    if self.camera == 3 then
        if self.selectedViews[1] then
            self.camera = 1
        elseif self.selectedViews[0] then
            self.camera = 0
        elseif self.selectedViews[2] then
            self.camera = 2
        end
    elseif self.camera == 1 then
        if self.selectedViews[0] then
            self.camera = 0
        elseif self.selectedViews[2] then
            self.camera = 2
        elseif self.selectedViews[3] then
            self.camera = 3
        end
    elseif self.camera == 0 then
        if self.selectedViews[2] then
            self.camera = 2
        elseif self.selectedViews[3] then
            self.camera = 3
        elseif self.selectedViews[1] then
            self.camera = 1
        end
    elseif self.camera == 2 then
        if self.selectedViews[3] then
            self.camera = 3
        elseif self.selectedViews[1] then
            self.camera = 1
        elseif self.selectedViews[0] then
            self.camera = 0
        end
    end

    self:CastCenterText(self.names[self.camera])
end

local cameralock = CameraView()