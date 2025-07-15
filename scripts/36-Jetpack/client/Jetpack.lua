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
    Events:Subscribe("Render", self, self.onRender)
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

    Events:Fire("CastCenterText", {text = LocalPlayer:GetValue("JP") and self.locStrings["off"] or self.locStrings["on"], time = 2})
end

function Jetpack:onRender()
    if LocalPlayer:GetWorld() ~= DefaultWorld then return end

    local checked = {}
    local players = {LocalPlayer}

    for player in Client:GetStreamedPlayers() do
        table.insert(players, player)
    end

    for _, player in pairs(players) do
        if IsValid(player) then
            local playerId = player:GetId() + 1

            if player:GetValue("JP") then
                if self.jetpacksBottom[playerId] then
                    local pos = player:GetBonePosition("ragdoll_Spine1")
                    local angle = player:GetBoneAngle("ragdoll_Spine1")

                    self.jetpacksBottom[playerId]:SetPosition(pos + angle * Vector3(0.001, 0.4, 0.2))
                    self.jetpacksBottom[playerId]:SetAngle(angle * Angle(0, 0, math.pi))
                    self.jetpacksTop[playerId]:SetPosition(pos + angle * Vector3(0, -0.4, 0.2))
                    self.jetpacksTop[playerId]:SetAngle(angle)
                    local velocity = player:GetLinearVelocity()

                    if not LocalPlayer:GetVehicle() then
                        local effect = ClientEffect.Play(AssetLocation.Game, {
                            effect_id = (velocity.y > 1) and 41 or 42,
                            position = pos + angle * Vector3(0, -0.5, 0.2) + velocity * 0.11,
                            angle = angle * Angle(0, 1.57, 0),
                            timeout = 0.001
                        })
                    end
                else
                    self.jetpacksBottom[playerId] = ClientStaticObject.Create({
                        model = "general.bl/rotor1-axelsmall.lod",
                        collision = "",
                        position = player:GetPosition(),
                        angle = Angle(),
                        fixed = true
                    })
                    self.jetpacksTop[playerId] = ClientStaticObject.Create({
                        model = "general.bl/rotor1-axelsmall.lod",
                        collision = "",
                        position = player:GetPosition(),
                        angle = Angle(),
                        fixed = true
                    })
                end
                checked[playerId] = true
            end
        end
    end

    for playerId, _ in pairs(self.jetpacksBottom) do
        if not checked[playerId] then
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

    if not LocalPlayer:GetValue("JP") then return end
    if LocalPlayer:GetVehicle() then return end
    if self.impulse == Vector3.Zero then return end

    LocalPlayer:SetBaseState(AnimationState.SUprightIdle)
    LocalPlayer:SetAngle(Angle.Slerp(LocalPlayer:GetAngle(), Angle(Camera:GetAngle().yaw, 0, 0), 0.1))

    self.impulse = self.impulse + Vector3(0, math.sin(self.timer:GetSeconds()) * 0.02, 0)
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