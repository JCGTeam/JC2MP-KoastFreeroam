class "PDA"

PDA.ToggleDelay = 0.25

function PDA:__init()
    circletime = 0
    oldsize = Render.Height * 0.007

    InitTimer = Timer()
    CircleTimer = nil

    self.actions = {
        [3] = true,
        [4] = true,
        [5] = true,
        [6] = true,
        [11] = true,
        [12] = true,
        [13] = true,
        [14] = true,
        [17] = true,
        [18] = true,
        [105] = true,
        [137] = true,
        [138] = true,
        [139] = true,
        [16] = true,
        [114] = true,
        [115] = true,
        [117] = true,
        [51] = true,
        [52] = true,
        [116] = true
    }

    self.extraction_speed = 5000 -- meters per second

    self.world_fadeout_delay = 1000 -- milliseconds
    self.map_fadeout_delay = 1000 -- milliseconds
    self.world_fadein_delay = 1000 -- milliseconds

    rendermap = true

    self.active = false
    self.mouseDown = false
    self.dragging = false
    self.lastMousePosition = Mouse:GetPosition()

    self:UpdateKeyBinds()

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        locStrings = {
            MTSetWp = "[СКМ] / [1] - поставить точку назначения",
            MTPToggle = "[ПКМ] - показать/скрыть имена игроков",
            MTExtract = "[R] - телепортация"
        }
    end

    labels = 0

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("UpdateKeyBinds", self, self.UpdateKeyBinds)

    self.KeyUpEvent = Events:Subscribe("KeyUp", self, self.KeyUp)

    Network:Subscribe("WarpDoPoof", self, self.WarpDoPoof)
end

function PDA:Lang()
    locStrings = {
        MTSetWp = "[Middle Click] / [1] - Set Waypoint",
        MTPToggle = "[Right Click] - Show/Hide players names",
        MTExtract = "[R] - Teleportation"
    }
end

function PDA:UpdateKeyBinds()
    local keyBinds = LocalPlayer:GetValue("KeyBinds")
    local bind = keyBinds and keyBinds["ServerMap"]

    self.expectedKey = bind and bind.type == "Key" and bind.value or 113
end

function PDA:PlayerUpdate(args)
    Map.Players = args
end

function PDA:IsUsingGamepad()
    return Game:GetSetting(GameSetting.GamepadInUse) ~= 0
end

function PDA:Toggle()
    self.active = not self.active
    Mouse:SetVisible(not PDA:IsUsingGamepad() and self.active)

    if self.active then
        LocalPlayer:SetValue("ServerMap", 1)
        if not self.EventPostRender then self.EventPostRender = Events:Subscribe("PostRender", self, self.PostRender) end
        if not self.PlayerUpdateNetwork then self.PlayerUpdateNetwork = Network:Subscribe("PlayerUpdate", self, self.PlayerUpdate) end
        if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
        if not self.MouseDownEvent then self.MouseDownEvent = Events:Subscribe("MouseDown", self, self.MouseDown) end
        if not self.MouseMoveEvent then self.MouseMoveEvent = Events:Subscribe("MouseMove", self, self.MouseMove) end
        if not self.MouseUpEvent then self.MouseUpEvent = Events:Subscribe("MouseUp", self, self.MouseUp) end

        Events:Fire("ToggleCamZoom", {zoomcam = false})
        Network:Send("MapShown")
        CircleTimer = Timer()
        FadeInTimer = Timer()

        Animation:Play(0, 1, 0.15, easeIOnut, function(value) animationValue = value end)
    else
        LocalPlayer:SetValue("ServerMap", nil)
        if self.EventPostRender then Events:Unsubscribe(self.EventPostRender) self.EventPostRender = nil end
        if self.PlayerUpdateNetwork then Network:Unsubscribe(self.PlayerUpdateNetwork) self.PlayerUpdateNetwork = nil end

        if not self.world_fadein_timer then
            if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
            if self.MouseDownEvent then Events:Unsubscribe(self.MouseDownEvent) self.MouseDownEvent = nil end
            if self.MouseMoveEvent then Events:Unsubscribe(self.MouseMoveEvent) self.MouseMoveEvent = nil end
            if self.MouseUpEvent then Events:Unsubscribe(self.MouseUpEvent) self.MouseUpEvent = nil end
        end

        Events:Fire("ToggleCamZoom", {zoomcam = true})
        Network:Send("MapHide")
        CircleTimer = nil
        FadeOutTimer = nil
        DelayTimer = nil
        FadeInTimer = nil
        circletime = 0
        oldsize = 0
    end
end

function PDA:ExtractionSequence()
    if not extraction_sequence then return end

    if self.world_fadeout_timer then
        if self.world_fadeout_timer:GetMilliseconds() > self.world_fadeout_delay then
            Network:Send("InitialTeleport", {position = next_position})
            self.world_fadeout_timer = nil
            extraction_timer = Timer()
            self.teleporting = true
        end
    elseif self.teleporting then
        if LocalPlayer:GetPosition() ~= previous_position then
            self.teleporting = false
            self.loading = true
            Map.Border = false
            Map.Ramka = false
            rendermap = false

            if self.MouseDownEvent then Events:Unsubscribe(self.MouseDownEvent) self.MouseDownEvent = nil end
            if self.MouseUpEvent then Events:Unsubscribe(self.MouseUpEvent) self.MouseUpEvent = nil end
            if self.MouseMoveEvent then Events:Unsubscribe(self.MouseMoveEvent) self.MouseMoveEvent = nil end
        end
    elseif self.loading then
        if LocalPlayer:GetLinearVelocity() ~= Vector3.Zero then
            self.loading = false
        end
    end

    if extraction_timer then
        if extraction_timer:GetSeconds() > extraction_delay then
            extraction_timer = nil
            -- locationsvisible = false
            self.map_fadeout_timer = Timer()
        end
    elseif self.map_fadeout_timer then
        local dt = self.map_fadeout_timer:GetMilliseconds()
        local delay = self.map_fadeout_delay
        local alpha = math.clamp(1 - dt / delay, 0, 1)
        local alpha2 = math.clamp(1 - dt / delay * 10, 0, 1)

        Map.Image:SetAlpha(alpha)
        -- Map.RamkaAlpha = alpha2
        -- Location.Icon.Sheet:SetAlpha( alpha2 )

        if dt > delay then
            self.map_fadeout_timer = nil
        end
    end

    if not (self.world_fadeout_timer or self.world_fadein_timer or self.teleporting or self.loading or extraction_timer or self.map_fadeout_timer) then
        self.world_fadein_timer = Timer()
        local ray = Physics:Raycast(Vector3(next_position.x, 2100, next_position.z), Vector3.Down, 0, 2100)
        Network:Send("CorrectedTeleport", {position = ray.position})
    end

    if self.world_fadein_timer then
        if self.world_fadein_timer:GetMilliseconds() > self.world_fadein_delay then
            Events:Unsubscribe(extraction_sequence)
            Game:FireEvent("ply.makevulnerable")
            Map.Image:SetAlpha(1)
            -- Map.RamkaAlpha = 1
            -- Location.Icon.Sheet:SetAlpha( 1 )
            rendermap = true
            PDA:Toggle()
            Map.Border = true
            Map.Ramka = true
            self.world_fadein_timer = nil
            extraction_sequence = nil
            extraction_render = nil
            previous_position = nil
            next_position = nil

            if not self.KeyUpEvent then self.KeyUpEvent = Events:Subscribe("KeyUp", self, self.KeyUp) end
        end
    end
end

function PDA:MouseDown(args)
    if self.active then
        self.mouseDown = args.button
    end

    self.lastMousePosition = Mouse:GetPosition()
end

function PDA:MouseMove(args)
    if self.active and self.mouseDown then
        Map.Offset = Map.Offset + ((args.position - self.lastMousePosition) / Map.Zoom)
        self.dragging = true
    end

    self.lastMousePosition = args.position
end

function PDA:MouseUp(args)
    if self.mouseDown == args.button then
        if args.button == 2 then
            labels = labels < 1 and labels + 1 or 0
        end

        if args.button == 3 then
            Map:ToggleWaypoint(Map.ActiveLocation and Map.ActiveLocation.position or Map:ScreenToWorld(Mouse:GetPosition()))
        end

        self.mouseDown = false
        self.dragging = false
    end

    self.lastMousePosition = Mouse:GetPosition()
end

function PDA:KeyUp(args)
    if args.key == self.expectedKey and Game:GetState() == GUIState.Game then
        PDA:Toggle()

        if self.active then
            Map.Zoom = 1.5

            Map.Image:SetSize(Vector2.One * Render.Height * Map.Zoom)

            local position = LocalPlayer:GetPosition()
            Map.Offset = Vector2(position.x, position.z) / 16384
            Map.Offset = -Vector2(Map.Offset.x * (Map.Image:GetSize().x / 2), Map.Offset.y * (Map.Image:GetSize().y / 2)) / Map.Zoom
        end
    end

    if self.active and args.key == 82 then
        if LocalPlayer:GetWorld() ~= DefaultWorld then
            PDA:Toggle()
            -- and Map.ActiveLocation
            Events:Fire("CastCenterText", {text = LocalPlayer:GetValue("Lang") == "EN" and "Can't use it here!" or "Невозможно использовать это здесь!", time = 3, color = Color.Red})
            return
        end

        local position = Map:ScreenToWorld(Mouse:GetPosition())
        if position.x >= -16384 and position.x <= 16383 and position.z >= -16384 and position.z <= 16383 then
            previous_position = LocalPlayer:GetPosition()
            next_position = position
            extraction_delay = Vector3.Distance(previous_position, next_position) / self.extraction_speed
            extraction_sequence = Events:Subscribe("PreTick", self, self.ExtractionSequence)
            self.world_fadeout_timer = Timer()
            Game:FireEvent("ply.makeinvulnerable")
            CircleTimer = nil
            FadeOutTimer = nil
            DelayTimer = nil
            FadeInTimer = nil
            circletime = 0
            oldsize = 0
            Map.Zoom = 0.98
            Map.Offset = Vector2.Zero
            Mouse:SetVisible(false)

            if self.KeyUpEvent then Events:Unsubscribe(self.KeyUpEvent) self.KeyUpEvent = nil end
            if self.MouseMoveEvent then Events:Unsubscribe(self.MouseMoveEvent) self.MouseMoveEvent = nil end
            if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
        end
    end

    if self.active and string.char(args.key) == "1" then
        Map:ToggleWaypoint(Map.ActiveLocation and Map.ActiveLocation.position or Map:ScreenToWorld(Mouse:GetPosition()))
    end
end

function PDA:LocalPlayerInput(args)
    if self.active then
        if self.actions[args.input] then
            return false
        end
        if (args.input == Action.GuiPDAZoomIn or args.input == Action.GuiPDAZoomOut) and args.state > 0.15 then
            local oldZoom = Map.Zoom

            Map.Zoom = math.max(math.min(Map.Zoom - (0.1 * args.state * (PDA:IsUsingGamepad() and -1 or 1) * (args.input == Action.GuiPDAZoomIn and 1 or -1)), 3), 0.98)

            local zoomFactor = Map.Zoom - oldZoom
            local zoomProduct = oldZoom * oldZoom + oldZoom * zoomFactor
            local zoomTarget = ((PDA:IsUsingGamepad() and (Render.Size / 2) or Mouse:GetPosition()) - (Render.Size / 2))

            Map.Offset = Map.Offset - ((zoomTarget * zoomFactor) / zoomProduct)
        elseif (args.input == Action.GuiAnalogDown or args.input == Action.GuiDown) and args.state > 0.15 then
            Map.Offset = Map.Offset - (Vector2.Down * 8.5 * math.pow(args.state, 2) / Map.Zoom)
        elseif (args.input == Action.GuiAnalogUp or args.input == Action.GuiUp) and args.state > 0.15 then
            Map.Offset = Map.Offset - (Vector2.Up * 8.5 * math.pow(args.state, 2) / Map.Zoom)
        elseif (args.input == Action.GuiAnalogLeft or args.input == Action.GuiLeft) and args.state > 0.15 then
            Map.Offset = Map.Offset - (Vector2.Left * 8.5 * math.pow(args.state, 2) / Map.Zoom)
        elseif (args.input == Action.GuiAnalogRight or args.input == Action.GuiRight) and args.state > 0.15 then
            Map.Offset = Map.Offset - (Vector2.Right * 8.5 * math.pow(args.state, 2) / Map.Zoom)
        end
    end
end

function PDA:PostRender()
    if Game:GetState() ~= GUIState.Game then
        if self.active then
            PDA:Toggle()
        end

        return
    end

    if extraction_sequence then
        local worldFadeOutTimer = self.world_fadeout_timer

        if worldFadeOutTimer then
            local dt = worldFadeOutTimer:GetMilliseconds()
            local delay = self.world_fadeout_delay

            if dt < delay then
                Render:FillArea(Vector2.Zero, Render.Size, self:ColorA(Color.Black, 255 * (dt / delay)))
            end
        end

        if self.teleporting or self.loading or extraction_timer or self.map_fadeout_timer then
            Render:FillArea(Vector2.Zero, Render.Size, Color.Black)
        end

        local worldFadeInTimer = self.world_fadein_timer

        if worldFadeInTimer then
            local dt = worldFadeInTimer:GetMilliseconds()
            local delay = self.world_fadein_delay

            if dt < delay then
                Render:FillArea(Vector2.Zero, Render.Size, self:ColorA(Color.Black, 255 * (1 - dt / delay)))
            end
        end
    end

    if self.active then
        Map:Draw()
    end
end

function PDA:WarpDoPoof(position)
    local effect = ClientEffect.Play(AssetLocation.Game, {
        effect_id = 250,
        position = position,
        angle = Angle()
    })
end

function PDA:ColorA(color, alpha)
    color.a = alpha
    return color
end

PDA = PDA()