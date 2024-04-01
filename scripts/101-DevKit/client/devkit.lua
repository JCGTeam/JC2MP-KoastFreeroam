class 'DevKit'

function DevKit:__init()
    Events:Subscribe( "PostRender", self, self.Render )
end

function DevKit:Render()
    if not LocalPlayer:GetValue( "DEBUGShowOSD" ) then return end

    local textSize = 15
    local pos = Vector2( 250, 20 )

    if LocalPlayer:GetValue( "DEBUGShowPlayerInfo" ) then
        Render:DrawShadowedText( pos, "NAME: " .. tostring( LocalPlayer:GetName() ), LocalPlayer:GetColor(), Color.Black, textSize )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "COLOR (RGBA): " .. tostring( LocalPlayer:GetColor() ), Color.White, Color.Black, textSize )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "ID: " .. tostring( LocalPlayer:GetId() ), Color.White, Color.Black, textSize )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "SteamID: " .. tostring( LocalPlayer:GetSteamId().string ) .. " / " .. tostring( LocalPlayer:GetSteamId().id ), Color.White, Color.Black, textSize )

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "POS: " .. tostring( LocalPlayer:GetPosition() ), Color.White, Color.Black, textSize )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "ANGLE: " .. tostring( LocalPlayer:GetAngle() ), Color.White, Color.Black, textSize )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "LINEAR VELOCITY: " .. tostring( LocalPlayer:GetLinearVelocity() ), Color.White, Color.Black, textSize )

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "STATE: " .. tostring( LocalPlayer:GetState() ), Color.White, Color.Black, textSize )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "BaseState: " .. tostring( LocalPlayer:GetBaseState() ), Color.White, Color.Black, textSize )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "UpperBodyState: " .. tostring( LocalPlayer:GetUpperBodyState() ), Color.White, Color.Black, textSize )

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "HEALTH: " .. tostring( LocalPlayer:GetHealth() ) .. " / " .. tostring( LocalPlayer:GetHealth() * 100 ), Color.Aquamarine, Color.Black, textSize )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "OXYGEN: " .. tostring( LocalPlayer:GetOxygen() ) .. " / " .. tostring( LocalPlayer:GetOxygen() * 100 ), Color.CornflowerBlue, Color.Black, textSize )

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "EquippedSlot: " .. tostring( LocalPlayer:GetEquippedSlot() ), Color.White, Color.Black, textSize )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "EquippedWeapon: " .. "ID: " .. tostring( LocalPlayer:GetEquippedWeapon().id ) .. ", AmmpClip: " .. tostring( LocalPlayer:GetEquippedWeapon().ammo_clip ) .. ", AmmoReserve: " .. tostring( LocalPlayer:GetEquippedWeapon().ammo_reserve ), Color.White, Color.Black, textSize )

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "WORLD ID: " .. tostring( LocalPlayer:GetWorld():GetId() ), Color.White, Color.Black, textSize )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "ClimateZone: " .. tostring( LocalPlayer:GetClimateZone() ), Color.White, Color.Black, textSize )

        if LocalPlayer:GetValue( "GameMode" ) then
            pos.y = pos.y + 20
            Render:DrawShadowedText( pos, "GAMEMODE: " .. tostring( LocalPlayer:GetValue( "GameMode" ) ), Color.White, Color.Black, textSize )
        end

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "MONEY: " .. "$" .. tostring( LocalPlayer:GetMoney() ), Color.Orange, Color.Black, textSize )

        if LocalPlayer:GetValue( "PlayerLevel" ) then
            pos.y = pos.y + 20
            Render:DrawShadowedText( pos, "LEVEL: " .. tostring( LocalPlayer:GetValue( "PlayerLevel" ) ), Color.White, Color.Black, textSize )
        end

        if LocalPlayer:GetValue( "Kills" ) then
            pos.y = pos.y + 20
            Render:DrawShadowedText( pos, "KILLS: " .. tostring( LocalPlayer:GetValue( "Kills" ) ), Color.White, Color.Black, textSize )
        end

        if LocalPlayer:GetValue( "ClanTag" ) then
            pos.y = pos.y + 20
            Render:DrawShadowedText( pos, "CLAN TAG: " .. tostring( LocalPlayer:GetValue( "ClanTag" ) ), Color.White, Color.Black, textSize )
        end

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "AIM TARGET: " .. tostring( LocalPlayer:GetAimTarget().position ) .. " / " .. tostring( LocalPlayer:GetAimTarget().entity ), Color.White, Color.Black, textSize )
    end

    local vehicle = LocalPlayer:GetVehicle()
    if vehicle and LocalPlayer:GetValue( "DEBUGShowVehicleInfo" ) then
        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "VEHICLE NAME: " .. tostring( vehicle:GetName() ), Color.White, Color.Black, textSize )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "VEHICLE COLOR (RGBA): " .. tostring( vehicle:GetColors() ), Color.White, Color.Black, textSize )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "VEHICLE ID: " .. tostring( vehicle:GetId() ), Color.White, Color.Black, textSize )

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "SEAT: " .. tostring( LocalPlayer:GetSeat() ), Color.White, Color.Black, textSize )
    end
end

devkit = DevKit()