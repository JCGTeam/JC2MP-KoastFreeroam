class 'DevKit'

function DevKit:__init()
    Events:Subscribe( "SharedObjectValueChange", self, self.SharedObjectValueChange )

    if LocalPlayer:GetValue( "DEBUGShowOSD" ) then
        self.text_clr = Color.White
        self.text_shadow = Color.Black
        self.text_size = 15

       self.PostRenderEvent = Events:Subscribe( "PostRender", self, self.PostRender )
	end
end

function DevKit:SharedObjectValueChange( args )
	if args.key == "DEBUGShowOSD" and args.object.__type == "LocalPlayer" then
		if args.value then
            self.text_clr = Color.White
            self.text_shadow = Color.Black
            self.text_size = 15

            if not self.PostRenderEvent then self.PostRenderEvent = Events:Subscribe( "PostRender", self, self.PostRender ) end
		else
            if self.PostRenderEvent then Events:Unsubscribe( self.PostRenderEvent ) self.PostRenderEvent = nil end

            self.text_clr = nil
            self.text_shadow = nil
            self.text_size = nil
        end
	end
end

function DevKit:PostRender()
    if not LocalPlayer:GetValue( "DEBUGShowOSD" ) then return end

    local pos = Vector2( 250, 20 )

    if LocalPlayer:GetValue( "DEBUGShowPlayerInfo" ) then
        Render:DrawShadowedText( pos, "NAME: " .. tostring( LocalPlayer:GetName() ), LocalPlayer:GetColor(), self.text_shadow, self.text_size )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "COLOR (RGBA): " .. tostring( LocalPlayer:GetColor() ), self.text_clr, self.text_shadow, self.text_size )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "ID: " .. tostring( LocalPlayer:GetId() ), self.text_clr, self.text_shadow, self.text_size )
        pos.y = pos.y + 20
        local steamId = LocalPlayer:GetSteamId()
        Render:DrawShadowedText( pos, "SteamID: " .. tostring( steamId.string ) .. " / " .. tostring( steamId.id ), self.text_clr, self.text_shadow, self.text_size )

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "POS: " .. tostring( LocalPlayer:GetPosition() ), self.text_clr, self.text_shadow, self.text_size )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "ANGLE: " .. tostring( LocalPlayer:GetAngle() ), self.text_clr, self.text_shadow, self.text_size )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "LINEAR VELOCITY: " .. tostring( LocalPlayer:GetLinearVelocity() ), self.text_clr, self.text_shadow, self.text_size )

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "STATE: " .. tostring( LocalPlayer:GetState() ), self.text_clr, self.text_shadow, self.text_size )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "BaseState: " .. tostring( LocalPlayer:GetBaseState() ), self.text_clr, self.text_shadow, self.text_size )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "UpperBodyState: " .. tostring( LocalPlayer:GetUpperBodyState() ), self.text_clr, self.text_shadow, self.text_size )

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        local health = LocalPlayer:GetHealth()
        Render:DrawShadowedText( pos, "HEALTH: " .. tostring( health ) .. " / " .. tostring( health * 100 ), Color.Aquamarine, self.text_shadow, self.text_size )
        pos.y = pos.y + 20
        local oxygen = LocalPlayer:GetOxygen()
        Render:DrawShadowedText( pos, "OXYGEN: " .. tostring( oxygen ) .. " / " .. tostring( oxygen * 100 ), Color.CornflowerBlue, self.text_shadow, self.text_size )

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "EquippedSlot: " .. tostring( LocalPlayer:GetEquippedSlot() ), self.text_clr, self.text_shadow, self.text_size )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "EquippedWeapon: " .. "ID: " .. tostring( LocalPlayer:GetEquippedWeapon().id ) .. ", AmmpClip: " .. tostring( LocalPlayer:GetEquippedWeapon().ammo_clip ) .. ", AmmoReserve: " .. tostring( LocalPlayer:GetEquippedWeapon().ammo_reserve ), self.text_clr, self.text_shadow, self.text_size )

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "WORLD ID: " .. tostring( LocalPlayer:GetWorld():GetId() ), self.text_clr, self.text_shadow, self.text_size )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "ClimateZone: " .. tostring( LocalPlayer:GetClimateZone() ), self.text_clr, self.text_shadow, self.text_size )

        if LocalPlayer:GetValue( "GameMode" ) then
            pos.y = pos.y + 20
            Render:DrawShadowedText( pos, "GAMEMODE: " .. tostring( LocalPlayer:GetValue( "GameMode" ) ), self.text_clr, self.text_shadow, self.text_size )
        end

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "Balance: " .. "$" .. tostring( LocalPlayer:GetMoney() ), Color.Orange, self.text_shadow, self.text_size )

        if LocalPlayer:GetValue( "PlayerLevel" ) then
            pos.y = pos.y + 20
            Render:DrawShadowedText( pos, "LEVEL: " .. tostring( LocalPlayer:GetValue( "PlayerLevel" ) ), self.text_clr, self.text_shadow, self.text_size )
        end

        if LocalPlayer:GetValue( "Kills" ) then
            pos.y = pos.y + 20
            Render:DrawShadowedText( pos, "KILLS: " .. tostring( LocalPlayer:GetValue( "Kills" ) ), self.text_clr, self.text_shadow, self.text_size )
        end

        if LocalPlayer:GetValue( "ClanTag" ) then
            pos.y = pos.y + 20
            Render:DrawShadowedText( pos, "CLAN TAG: " .. tostring( LocalPlayer:GetValue( "ClanTag" ) ), self.text_clr, self.text_shadow, self.text_size )
        end

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "AIM TARGET: " .. tostring( LocalPlayer:GetAimTarget().position ) .. " / " .. tostring( LocalPlayer:GetAimTarget().entity ), self.text_clr, self.text_shadow, self.text_size )
    end

    local vehicle = LocalPlayer:GetVehicle()
    if vehicle and LocalPlayer:GetValue( "DEBUGShowVehicleInfo" ) then
        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "VEHICLE NAME: " .. tostring( vehicle:GetName() ), self.text_clr, self.text_shadow, self.text_size )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "VEHICLE COLOR (RGBA): " .. tostring( vehicle:GetColors() ), self.text_clr, self.text_shadow, self.text_size )
        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "VEHICLE ID: " .. tostring( vehicle:GetId() ), self.text_clr, self.text_shadow, self.text_size )

        pos.y = pos.y + 20

        pos.y = pos.y + 20
        Render:DrawShadowedText( pos, "SEAT: " .. tostring( LocalPlayer:GetSeat() ) .. " (Locked: " .. tostring( vehicle:GetSeatLocked( LocalPlayer:GetSeat() ) ) .. ")", self.text_clr, self.text_shadow, self.text_size )
    end
end

devkit = DevKit()