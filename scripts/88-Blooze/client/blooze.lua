class 'BloozeMod'

function BloozeMod:__init()
    self.default_fov = Camera:GetFOV()

    Events:Subscribe( "BloozingStart", self, self.BloozingStart )
    Events:Subscribe( "LocalPlayerDeath", function() self:BloozingStop() end )
    Events:Subscribe( "LocalPlayerWorldChange", function() self:BloozingStop() end )
    Events:Subscribe( "ModuleUnload", function() self:BloozingStop() end )
end

function BloozeMod:InputPoll()
	if Input:GetValue( Action.TurnRight ) == 0 and Input:GetValue( Action.TurnLeft ) == 0 then
		if self.timer:GetSeconds() <= 5 then
			Input:SetValue( Action.TurnRight, self.num )
		else
			Input:SetValue( Action.TurnLeft, self.num )
		end
	end
end

function BloozeMod:CalcView()
    if not LocalPlayer:InVehicle() then
        Camera:SetFOV( self.default_fov + 0.2 )
    end

    local bs = LocalPlayer:GetBaseState()
    if bs ~= 208 then
        if self.naklon == 1 then
            Camera:SetAngle( Camera:GetAngle() * Angle( self.value, self.value, self.value ) )
        else
            Camera:SetAngle( Camera:GetAngle() * Angle( - self.value, -self.value, - self.value ) )
            self.naklon = 0
        end
    end

    local timerSeconds = self.timer:GetSeconds()
    if timerSeconds <= 5 then
        self.value = self.value + timerSeconds * 0.0002
    else
        if self.value >= 0 then
            self.value = self.value - timerSeconds * 0.0002
        else
            self.timer:Restart()
            self.naklon = self.naklon + 1

            if bs == 6 or bs == 7 or bs == 9 and not LocalPlayer:GetVehicle() then
                local animations = { bs, AnimationState.SSkydive, bs }
                LocalPlayer:SetBaseState( animations[math.random(#animations)] )

                if bs == AnimationState.SSkydive then
                    Game:FireEvent( "ply.reacthitfly" )
                end
            end
        end
    end

    if self.bloozingtimer:GetMinutes() >= 3 then
        self:BloozingStop()
    end
end

function BloozeMod:BloozingStart()
    Network:Send( "MinusHP" )

	local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 12,
        sound_id = 19,
        position = LocalPlayer:GetPosition(),
        angle = LocalPlayer:GetAngle()
    })

    sound:SetParameter(0,1)

    local sound = ClientSound.Create(AssetLocation.Game, {
        bank_id = 12,
        sound_id = 1,
        position = LocalPlayer:GetPosition(),
        angle = LocalPlayer:GetAngle()
    })

    sound:SetParameter(2,1)

    if not self.bloozingtimer then
        self.backfov = Camera:GetFOV()

        self.num = 0.2
        self.timer = Timer()
        self.value = 0
        self.naklon = 0

        self.bloozingtimer = Timer()

        self.InputPollEvent = Events:Subscribe( "InputPoll", self, self.InputPoll )
        self.CalcViewEvent = Events:Subscribe( "CalcView", self, self.CalcView )
    else
        self.bloozingtimer:Restart()
    end
end

function BloozeMod:BloozingStop()
    if self.bloozingtimer then
        self.bloozingtimer = nil

        if self.backfov then
            Camera:SetFOV( self.backfov )
        end

        self.backfov = nil
    
        self.num = nil
        self.timer = nil
        self.value = nil
        self.naklon = nil

        if self.InputPollEvent then Events:Unsubscribe( self.InputPollEvent ) self.InputPollEvent = nil end
        if self.CalcViewEvent then Events:Unsubscribe( self.CalcViewEvent ) self.CalcViewEvent = nil end
    end
end

bloozemod = BloozeMod()