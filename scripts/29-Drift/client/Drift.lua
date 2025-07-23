class "Drift"

function Drift:__init()
    self.textSize = 30

    Events:Subscribe("Lang", self, self.Lang)
    Events:Subscribe("Render", self, self.Render)

    Events:Subscribe("NetworkObjectValueChange", self, self.NetworkObjectValueChange)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
    Events:Subscribe("LocalPlayerDeath", self, self.LocalPlayerDeath)
    Events:Subscribe("PlayerQuit", self, self.PlayerQuit)

    Network:Subscribe("onDriftAttempt", self, self.onDriftAttempt)

    local lang = LocalPlayer:GetValue("Lang")
    if lang and lang == "EN" then
        self:Lang()
    else
        self.locStrings = {
            tDriftTw = "Дрифт: ",
            tDrift3 = "Продолжай! ",
            tDrift4 = "Малаца! ",
            tDrift5 = "Отличный дрифт! ",
            tDrift6 = "Грациозно! ",
            tDrift7 = "Мастер! ",
            tDrift8 = "Бог дрифта! ",
            tDrift9 = "АСТАНАВИСЬ!!! ",
            tRecord = "Личный дрифт рекорд: "
        }
    end
end

function Drift:Lang()
    self.locStrings = {
        tDriftTw = "Drift: ",
        tDrift3 = "Well done! ",
        tDrift4 = "Do not stop! ",
        tDrift5 = "Great drift! ",
        tDrift6 = "Gracefully! ",
        tDrift7 = "Drift Master! ",
        tDrift8 = "Lord of drift! ",
        tDrift9 = "STOP PLS!!! ",
        tRecord = "Personal drift record: "
    }
end

function Drift:ResetMass()
    if self.mass then
        self.mass = false
        Network:Send("ChangeMass", {veh = LocalPlayer:GetVehicle(), bool = self.mass})
    end
end

function Drift:NetworkObjectValueChange(args)
    if args.key == "DriftPhysics" and args.object.__type == "LocalPlayer" then
        if not args.value then
            if IsValid(LocalPlayer:GetVehicle()) then
                self:ResetMass()
            end
        end
    end
end

function Drift:LocalPlayerExitVehicle()
    if not LocalPlayer:GetValue("DriftPhysics") then return end

    if IsValid(LocalPlayer:GetVehicle()) then
        self:ResetMass()
    end
end

function Drift:LocalPlayerDeath()
    if not LocalPlayer:GetValue("DriftPhysics") then return end

    if IsValid(LocalPlayer:GetVehicle()) then
        self:ResetMass()
    end
end

function Drift:PlayerQuit(args)
    if not LocalPlayer:GetValue("DriftPhysics") then return end

    if args.player == LocalPlayer then
        self:ResetMass()
    end
end

function Drift:Render()
    local object = NetworkObject.GetByName("Drift")
    local driftPhysics = LocalPlayer:GetValue("DriftPhysics")

    if driftPhysics then
        local slide = self.slide

        if slide then
            if slide == 0 then
                if not self.mass then
                    self.mass = true
                    Network:Send("ChangeMass", {veh = LocalPlayer:GetVehicle(), bool = self.mass})
                end
            else
                self:ResetMass()
            end
        else
            self:ResetMass()
        end
    end

    if LocalPlayer:GetValue("SystemFonts") then Render:SetFont(AssetLocation.SystemFont, "Impact") end

    local locStrings = self.locStrings

    if self.score and not self.timer and self.score >= 100 then
        self.slide = self.slide + (1 * self.multipler)
        self.anim_tick = self.anim_tick + 1
        self.sscore = self.score

        local scoreMult = math.ceil(self.score * self.multipler)
        local btext = locStrings["tDriftTw"]
        local text = locStrings["tDriftTw"] .. tostring(scoreMult)
        local text_mult = "x" .. tostring(self.multipler)

        if self.anim_tick < 30 then
            self.size = 122 - self.anim_tick * 2
        elseif self.anim_tick > 29 then
            self.size = 62
        end

        if scoreMult > 5000 then
            btext = locStrings["tDrift3"]
            text = locStrings["tDrift3"] .. scoreMult
        end
        if scoreMult > 10000 then
            btext = locStrings["tDrift4"]
            text = locStrings["tDrift4"] .. scoreMult
        end
        if scoreMult > 50000 then
            btext = locStrings["tDrift5"]
            text = locStrings["tDrift5"] .. scoreMult
        end
        if scoreMult > 100000 then
            btext = locStrings["tDrift6"]
            text = locStrings["tDrift6"] .. scoreMult
        end
        if scoreMult > 500000 then
            btext = locStrings["tDrift7"]
            text = locStrings["tDrift7"] .. scoreMult
        end
        if scoreMult > 1000000 then
            btext = locStrings["tDrift8"]
            text = locStrings["tDrift8"] .. scoreMult
        end
        if scoreMult > 10000000 then
            btext = locStrings["tDrift9"]
            text = locStrings["tDrift9"] .. scoreMult
        end

        if LocalPlayer:GetValue("BestRecordVisible") and not LocalPlayer:GetValue("HiddenHUD") and Game:GetState() == GUIState.Game then
            local textSize = Render:GetTextSize(text, self.textSize)
            local textSize_mult = Render:GetTextSize(text_mult, self.textSize)
            local alpha = 1 - self.slide / 265
            local shadowColor = Color(25, 25, 25, 150 * alpha)

            local position = Vector2(Render.Width / 2, Render.Height * 0.3 * alpha) - textSize / 2
            local position_mult = position + Vector2(textSize.x / 2, textSize.y * 1.6) - textSize_mult / 2

            Render:DrawShadowedText(position, btext, Color(255, 255, 255, 255 * alpha), shadowColor, self.textSize)
            Render:DrawShadowedText(position + Vector2(Render:GetTextWidth(btext, self.textSize), 0), tostring(scoreMult), (object and (scoreMult > (object:GetValue("S") or 0))) and Color(185, 215, 255, 255 * alpha) or Color(175, 175, 175, 255 * alpha), shadowColor, self.textSize)

            Render:DrawShadowedText(position_mult, text_mult, Color(175, 175, 175, 255 * alpha), shadowColor, self.textSize)
        end

        if self.slide >= 255 then
            local object = NetworkObject.GetByName("Drift")

            if not object or scoreMult > (object:GetValue("S") or 0) then
                Network:Send("onDriftRecord", scoreMult)
            elseif scoreMult > ((object:GetValue("S") or 0) * 0.6) and (object:GetValue("N") or "None") ~=
                LocalPlayer:GetName() then
                Network:Send("onDriftAttempt", scoreMult)
            end

            local shared = SharedObject.Create("Drift")
            if scoreMult > (shared:GetValue("Record") or 0) then
                Network:Send("UpdateMaxRecord", scoreMult)
                shared:SetValue("Record", scoreMult)
                Network:Send("DriftRecordTask", scoreMult)
                Network:Send("UpdateMaxRecord", scoreMult)
                Game:ShowPopup(locStrings["tRecord"] .. scoreMult, true)
            end

            self.slide = nil
            self.score = nil
            self.sscore = nil
            self.multipler = 1
        end
    end

    local lpState = LocalPlayer:GetState()

    if lpState ~= PlayerState.InVehicle then
        self.timer = nil
        return
    end

    local vehicle = LocalPlayer:GetVehicle()

    if not IsValid(vehicle) then
        self.timer = nil
        return
    end

    local vClass = vehicle:GetClass()

    if vClass ~= VehicleClass.Land then
        self.timer = nil
        return
    end

    local velocity = vehicle:GetLinearVelocity()
    local horizontalVelocity = Vector3(velocity.x, 0, velocity.z)

    if horizontalVelocity:Length() < 6 then
        self.timer = nil
        return
    end
    local dot = Angle.Dot(Angle(Angle.FromVectors(velocity, Vector3.Forward).yaw, 0, 0), Angle(-vehicle:GetAngle().yaw, 0, 0))

    if math.abs(dot) < 0.1 or math.abs(dot) > 0.99 then
        self.timer = nil
        return
    end

    local vPos = vehicle:GetPosition()
    local raycast = Physics:Raycast(vPos + Vector3(0, 0.5, 0), Vector3.Down, 0, 10)
    local distance = raycast.distance

    if distance > 1 then
        self.timer = nil
        return
    end

    if not self.timer then
        self.timer = Timer()
        self.quality = 0
        if self.sscore then
            self.multipler = self.multipler + 0.1
        end
        self.anim_tick = 1
    end

    self.quality = math.max(math.lerp(self.quality, -45 * math.pow(dot - 0.85, 2) + 1, 0.1), self.quality)

    if self.sscore then
        score = self.sscore + math.ceil(self.timer:GetMilliseconds() * self.quality)
    else
        self.multipler = 1
        score = math.ceil(self.timer:GetMilliseconds() * self.quality)
    end

    if score < 100 then return end

    self.score = score
    self.slide = 0
    self.anim_tick = self.anim_tick + 1

    local scoreMult = math.ceil(self.score * self.multipler)
    local btext = locStrings["tDriftTw"]
    local text = locStrings["tDriftTw"] .. tostring(scoreMult)
    local text_mult = "x" .. tostring(self.multipler)

    self.angular = vehicle:GetAngularVelocity()

    if self.anim_tick < 30 then
        self.size = 1.9 - self.anim_tick * 0.01
    elseif self.anim_tick > 29 then
        self.size = 1.6
    end

    if math.ceil(self.multipler) > 10 then
        self.multipler = 10
    end
    if scoreMult > 5000 then
        btext = locStrings["tDrift3"]
        text = locStrings["tDrift3"] .. scoreMult
    end
    if scoreMult > 10000 then
        btext = locStrings["tDrift4"]
        text = locStrings["tDrift4"] .. scoreMult
    end
    if scoreMult > 50000 then
        btext = locStrings["tDrift5"]
        text = locStrings["tDrift5"] .. scoreMult
    end
    if scoreMult > 100000 then
        btext = locStrings["tDrift6"]
        text = locStrings["tDrift6"] .. scoreMult
    end
    if scoreMult > 500000 then
        btext = locStrings["tDrift7"]
        text = locStrings["tDrift7"] .. scoreMult
    end
    if scoreMult > 1000000 then
        btext = locStrings["tDrift8"]
        text = locStrings["tDrift8"] .. scoreMult
    end
    if scoreMult > 10000000 then
        btext = locStrings["tDrift9"]
        text = locStrings["tDrift9"] .. scoreMult
    end

    local bestRecordsVisible = LocalPlayer:GetValue("BestRecordVisible")
    local hiddenHUD = LocalPlayer:GetValue("HiddenHUD")

    if bestRecordsVisible and not hiddenHUD and Game:GetState() == GUIState.Game then
        local textSize = Render:GetTextSize(text, self.textSize)
        local textSize_mult = Render:GetTextSize(text_mult, self.textSize)
        local shadowColor = Color(25, 25, 25, 150)

        local position = Vector2(Render.Width / 2, Render.Height * 0.3) - textSize / 2
        local position_mult = position + Vector2(textSize.x / 2, textSize.y * self.size) - textSize_mult / 2

        Render:DrawShadowedText(position, btext, Color(255, 255, 255), shadowColor, self.textSize)
        Render:DrawShadowedText(position + Vector2(Render:GetTextWidth(btext, self.textSize), 0), tostring(scoreMult), (IsValid(object) and (scoreMult > (object:GetValue("S") or 0))) and Color(185, 215, 255) or Color(175, 175, 175), shadowColor, self.textSize)

        Render:DrawShadowedText(position_mult, text_mult, Color(175, 175, 175, 255), shadowColor, self.textSize)
    end
end

function Drift:onDriftAttempt(data)
    self.attempt = data
    self.attempt[3] = 4
end

local drift = Drift()