class 'DevKit'

function DevKit:__init()
    Events:Subscribe("SharedObjectValueChange", self, self.SharedObjectValueChange)

    if LocalPlayer:GetValue("DEBUGShowOSD") then
        self.PostRenderEvent = Events:Subscribe("PostRender", self, self.PostRender)
    end
end

function DevKit:SharedObjectValueChange(args)
    if args.key == "DEBUGShowOSD" and args.object.__type == "LocalPlayer" then
        if args.value then
            if not self.PostRenderEvent then self.PostRenderEvent = Events:Subscribe("PostRender", self, self.PostRender) end
        else
            if self.PostRenderEvent then Events:Unsubscribe(self.PostRenderEvent) self.PostRenderEvent = nil end
        end
    end
end

function DevKit:PostRender()
    if not LocalPlayer:GetValue("DEBUGShowOSD") then return end

    local text_clr = Color.White
    local text_shadow = Color.Black
    local text_size = 15
    local pos = Vector2(250, 20)

    if LocalPlayer:GetValue("DEBUGShowPlayerInfo") then
        local lpColor = LocalPlayer:GetColor()
        Render:DrawShadowedText(pos, "NAME: " .. tostring(LocalPlayer:GetName()), lpColor, text_shadow, text_size)
        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "COLOR (RGBA): " .. tostring(lpColor), text_clr, text_shadow, text_size)
        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "ID: " .. tostring(LocalPlayer:GetId()), text_clr, text_shadow, text_size)
        pos.y = pos.y + 20
        local steamId = LocalPlayer:GetSteamId()
        Render:DrawShadowedText(pos, "SteamID: " .. tostring(steamId.string) .. " / " .. tostring(steamId.id), text_clr, text_shadow, text_size)

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "POS: " .. tostring(LocalPlayer:GetPosition()), text_clr, text_shadow, text_size)
        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "ANGLE: " .. tostring(LocalPlayer:GetAngle()), text_clr, text_shadow, text_size)
        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "LINEAR VELOCITY: " .. tostring(LocalPlayer:GetLinearVelocity()), text_clr, text_shadow, text_size)

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "STATE: " .. tostring(LocalPlayer:GetState()), text_clr, text_shadow, text_size)
        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "BaseState: " .. tostring(LocalPlayer:GetBaseState()), text_clr, text_shadow, text_size)
        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "LeftArmState: " .. tostring(LocalPlayer:GetLeftArmState()), text_clr, text_shadow, text_size)
        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "UpperBodyState: " .. tostring(LocalPlayer:GetUpperBodyState()), text_clr, text_shadow, text_size)

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        local health = LocalPlayer:GetHealth()
        Render:DrawShadowedText(pos, "HEALTH: " .. tostring(health) .. " / " .. tostring(health * 100), Color.Aquamarine, text_shadow, text_size)
        pos.y = pos.y + 20
        local oxygen = LocalPlayer:GetOxygen()
        Render:DrawShadowedText(pos, "OXYGEN: " .. tostring(oxygen) .. " / " .. tostring(oxygen * 100), Color.CornflowerBlue, text_shadow, text_size)

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "EquippedSlot: " .. tostring(LocalPlayer:GetEquippedSlot()), text_clr, text_shadow, text_size)
        pos.y = pos.y + 20
        local weapon = LocalPlayer:GetEquippedWeapon()
        Render:DrawShadowedText(pos, "EquippedWeapon: " .. "ID: " .. tostring(weapon.id) .. ", AmmpClip: " .. tostring(weapon.ammo_clip) .. ", AmmoReserve: " .. tostring(weapon.ammo_reserve), text_clr, text_shadow, text_size)

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "WORLD ID: " .. tostring(LocalPlayer:GetWorld():GetId()), text_clr, text_shadow, text_size)
        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "ClimateZone: " .. tostring(LocalPlayer:GetClimateZone()), text_clr, text_shadow, text_size)

        if LocalPlayer:GetValue("GameMode") then
            pos.y = pos.y + 20
            Render:DrawShadowedText(pos, "GAMEMODE: " .. tostring(LocalPlayer:GetValue("GameMode")), text_clr, text_shadow, text_size)
        end

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "Balance: " .. "$" .. tostring(LocalPlayer:GetMoney()), Color.Orange, text_shadow, text_size)

        if LocalPlayer:GetValue("PlayerLevel") then
            pos.y = pos.y + 20
            Render:DrawShadowedText(pos, "LEVEL: " .. tostring(LocalPlayer:GetValue("PlayerLevel")), text_clr, text_shadow, text_size)
        end

        if LocalPlayer:GetValue("Kills") then
            pos.y = pos.y + 20
            Render:DrawShadowedText(pos, "KILLS: " .. tostring(LocalPlayer:GetValue("Kills")), text_clr, text_shadow, text_size)
        end

        if LocalPlayer:GetValue("ClanTag") then
            pos.y = pos.y + 20
            Render:DrawShadowedText(pos, "CLAN TAG: " .. tostring(LocalPlayer:GetValue("ClanTag")), text_clr, text_shadow, text_size)
        end

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "AIM TARGET: " .. tostring(LocalPlayer:GetAimTarget().position) .. " / " .. tostring(LocalPlayer:GetAimTarget().entity), text_clr, text_shadow, text_size)
    end

    local vehicle = LocalPlayer:GetVehicle()
    if vehicle and LocalPlayer:GetValue("DEBUGShowVehicleInfo") then
        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "VEHICLE NAME: " .. tostring(vehicle:GetName()), text_clr, text_shadow, text_size)
        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "VEHICLE COLOR (RGBA): " .. tostring(vehicle:GetColors()), text_clr, text_shadow, text_size)
        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "VEHICLE ID: " .. tostring(vehicle:GetId()), text_clr, text_shadow, text_size)

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText(pos, "SEAT: " .. tostring(LocalPlayer:GetSeat()) .. " (Locked: " .. tostring(vehicle:GetSeatLocked(LocalPlayer:GetSeat())) .. ")", text_clr, text_shadow, text_size)
    end
end

local devkit = DevKit()