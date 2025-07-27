class "Jetpack"

function Jetpack:__init()
    self.jetpacksBottom = {}
    self.jetpacksTop = {}
    self.timer = Timer()
    self.impulse = Vector3.Zero

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            on = "Реактивный ранец включён",
            off = "Реактивный ранец отключён"
        }
    end

    if not LocalPlayer:InVehicle() then
        self.InputPollEvent = Events:Subscribe("InputPoll", self, self.onInputPoll)
    end

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("UseJetpack", self, self.UseJetpack)
    Events:Subscribe("Render", self, self.Render)
    Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
    Events:Subscribe("ModuleUnload", self, self.onModuleUnload)
end

function Jetpack:Lang()
    self.locStrings = {
        on = "Jetpack enabled",
        off = "Jetpack disabled"
    }
end

function Jetpack:LocalPlayerEnterVehicle()
    if self.InputPollEvent then Events:Unsubscribe(self.InputPollEvent) self.InputPollEvent = nil end
end

function Jetpack:LocalPlayerExitVehicle()
    if not self.InputPollEvent then self.InputPollEvent = Events:Subscribe("InputPoll", self, self.onInputPoll) end
end

function Jetpack:UseJetpack()
    Network:Send("EnableJetpack")

    local locStrings = self.locStrings

    Events:Fire("CastCenterText", {text = LocalPlayer:GetValue("JP") and locStrings["off"] or locStrings["on"], time = 2})
end

function Jetpack:Render()
    local lpWorld = LocalPlayer:GetWorld()

    if lpWorld ~= DefaultWorld then return end

    local checked = {}
    local players = {LocalPlayer}
    local streamedPlayers = Client:GetStreamedPlayers()
    local jetpacksBottom = self.jetpacksBottom
    local jetpacksTop = self.jetpacksTop
    local pi = math.pi
    local lpVehicle = LocalPlayer:GetVehicle()

    for p in streamedPlayers do
        table.insert(players, p)
    end

   for _, p in pairs(players) do
        if IsValid(p) then
            local pId = p:GetId() + 1

            if p:GetValue("JP") then
                if jetpacksBottom[pId] then
                    local pos = p:GetBonePosition("ragdoll_Spine1")
                    local angle = p:GetBoneAngle("ragdoll_Spine1")

                    self.jetpacksBottom[pId]:SetPosition(pos + angle * Vector3(0.001, 0.4, 0.2))
                    self.jetpacksBottom[pId]:SetAngle(angle * Angle(0, 0, pi))
                    self.jetpacksTop[pId]:SetPosition(pos + angle * Vector3(0, -0.4, 0.2))
                    self.jetpacksTop[pId]:SetAngle(angle)
                    local velocity = p:GetLinearVelocity()

                    if not lpVehicle then
                        local effect = ClientEffect.Play(AssetLocation.Game, {
                            effect_id = (velocity.y > 1) and 41 or 42,
                            position = pos + angle * Vector3(0, -0.5, 0.2) + velocity * 0.11,
                            angle = angle * Angle(0, 1.57, 0),
                            timeout = 0.001
                        })
                    end
                else
                    self.jetpacksBottom[pId] = ClientStaticObject.Create({
                        model = "general.bl/rotor1-axelsmall.lod",
                        collision = "",
                        position = p:GetPosition(),
                        angle = Angle(),
                        fixed = true
                    })
                    self.jetpacksTop[pId] = ClientStaticObject.Create({
                        model = "general.bl/rotor1-axelsmall.lod",
                        collision = "",
                        position = p:GetPosition(),
                        angle = Angle(),
                        fixed = true
                    })
                end
                checked[pId] = true
            end
        end
    end

    for pId, _ in pairs(jetpacksBottom) do
        if not checked[pId] then
            if IsValid(jetpacksBottom[pId], false) then
                self.jetpacksBottom[pId]:Remove()
            end

            if IsValid(jetpacksTop[pId], false) then
                self.jetpacksTop[pId]:Remove()
            end

            self.jetpacksBottom[pId] = nil
            self.jetpacksTop[pId] = nil
        end
    end

    local JP = LocalPlayer:GetValue("JP")

    if not JP then return end
    if lpVehicle then return end

    local impulse = self.impulse

    if impulse == Vector3.Zero then return end

    local pAngle = LocalPlayer:GetAngle()
    local cameraAngle = Camera:GetAngle()
    local cameraAngleYaw = cameraAngle.yaw
    local angle = Angle.Slerp(pAngle, Angle(cameraAngleYaw, 0, 0), 0.1)


    LocalPlayer:SetAngle(angle)

    local timer = self.timer
    local seconds = timer:GetSeconds()

    self.impulse = self.impulse + Vector3(0, math.sin(seconds) * 0.02, 0)
end

function Jetpack:onInputPoll()
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end
    if not LocalPlayer:GetValue("JP") then return end
    if LocalPlayer:GetVehicle() then return end

    local velocity = Vector3.Zero
    local raycast = Physics:Raycast(LocalPlayer:GetPosition() + Vector3(0, 0.1, 0), Vector3.Down, 0, 3)

    if self.impulse:Length() < 20 then
        if Input:GetValue(Action.HeliDecAltitude) > 0 then
            self.impulse = self.impulse + 0.6 * Vector3.Down
        end

        if Input:GetValue(Action.HeliIncAltitude) > 0 then
            self.impulse = self.impulse + 0.3 * Vector3.Up
        end

        if raycast.distance > 2 then
            local angle = Angle(Camera:GetAngle().yaw, 0, 0)

            if Input:GetValue(Action.MoveForward) > 0 then
                self.impulse = self.impulse + angle * (0.8 * Vector3.Forward)
            end

            if Input:GetValue(Action.MoveBackward) > 0 then
                self.impulse = self.impulse + angle * (0.8 * Vector3.Backward)
            end

            if Input:GetValue(Action.MoveLeft) > 0 then
                self.impulse = self.impulse + angle * (0.8 * Vector3.Left)
            end

            if Input:GetValue(Action.MoveRight) > 0 then
                self.impulse = self.impulse + angle * (0.8 * Vector3.Right)
            end
        end
    end

    self.impulse = self.impulse * 0.98
    velocity = velocity + self.impulse

    if Input:GetValue(Action.HeliIncAltitude) < 1 and raycast.distance < 2 then
        self.impulse = Vector3.Zero
        return
    end

    LocalPlayer:SetBaseState(AnimationState.SUprightIdle)
    LocalPlayer:SetLinearVelocity(velocity)
end

function Jetpack:onModuleUnload()
    for playerId, _ in pairs(self.jetpacksBottom) do
        if IsValid(self.jetpacksBottom[playerId], false) then
            self.jetpacksBottom[playerId]:Remove()
        end

        if IsValid(self.jetpacksTop[playerId], false) then
            self.jetpacksTop[playerId]:Remove()
        end

        self.jetpacksBottom[playerId] = nil
        self.jetpacksTop[playerId] = nil
    end
end

local jetpack = Jetpack()