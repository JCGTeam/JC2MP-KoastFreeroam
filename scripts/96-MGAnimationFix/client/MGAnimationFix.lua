class 'MGAnimationFix'

function MGAnimationFix:__init()
    if LocalPlayer:GetValue( "UsedMinigun" ) then
        LocalPlayer:SetValue( "UsedMinigun", nil )
    end

    self.whitelist = { 
        [AnimationState.SUprightIdle] = true,
        [AnimationState.SUprightBasicNavigation] = true,
        [AnimationState.SUprightStop] = true,
        [AnimationState.SUprightTurn180] = true,
        [AnimationState.SParachute] = true,
        [AnimationState.SPullOpenParachuteVertical] = true,
        [AnimationState.SUprightStrafe] = true,
        [AnimationState.SUprightRotateCw] = true,
        [AnimationState.SUprightRotateCwInterupt] = true,
        [AnimationState.SCrouch] = true,
        [AnimationState.SFall] = true,
        [AnimationState.SUnfoldParachuteHorizontal] = true
    }

    self.mglist = { 
        [AnimationState.SIdleMg] = true,
        [AnimationState.SWalkMg] = true
    }

    if not self.checkTimer then self.checkTimer = Timer() end
	if not self.PostTickEvent then self.PostTickEvent = Events:Subscribe( "PostTick", self, self.PostTick ) end
    if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end

    Events:Subscribe( "LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
end

function MGAnimationFix:LocalPlayerEnterVehicle()
    if self.checkTimer then self.checkTimer = nil end
	if self.PostTickEvent then Events:Unsubscribe( self.PostTickEvent ) self.PostTickEvent = nil end
    if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
end

function MGAnimationFix:LocalPlayerExitVehicle()
    if not self.checkTimer then self.checkTimer = Timer() end
    if not self.PostTickEvent then self.PostTickEvent = Events:Subscribe( "PostTick", self, self.PostTick ) end
    if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end
end

function MGAnimationFix:CheckMinigun()
    local minigunstate = AnimationState.SIdleMg
    local bs = LocalPlayer:GetBaseState()

    if not LocalPlayer:GetVehicle() then
        if self.whitelist[bs] then
            if LocalPlayer:GetEquippedWeapon() == Weapon( Weapon.Minigun ) and bs ~= minigunstate then
                LocalPlayer:SetBaseState( minigunstate )
                LocalPlayer:SetValue( "UsedMinigun", 1 )
            end
        else
            if LocalPlayer:GetValue( "UsedMinigun" ) then
                if LocalPlayer:GetEquippedWeapon() ~= Weapon( Weapon.Minigun ) and self.mglist[bs] then
                    LocalPlayer:SetBaseState( AnimationState.SDash )
                    LocalPlayer:SetValue( "UsedMinigun", nil )
                end
            end
        end
    end
end

function MGAnimationFix:PostTick()
    if self.checkTimer:GetSeconds() >= 2 then
        self:CheckMinigun()

        self.checkTimer:Restart()
    end
end

function MGAnimationFix:LocalPlayerInput( args )
    if Game:GetState() ~= GUIState.Game then return end

    if args.input == Action.FireRight then
        self:CheckMinigun()
    end
end

mganimationfix = MGAnimationFix()