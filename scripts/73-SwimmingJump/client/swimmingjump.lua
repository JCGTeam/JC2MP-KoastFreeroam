class 'SwimmingJump'

function SwimmingJump:__init()
    self.jumpheight = 7

    self.cooldown = 1
	self.cooltime = 0

    if not LocalPlayer:InVehicle() then
        self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
    end

    Events:Subscribe( "LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
end

function SwimmingJump:LocalPlayerEnterVehicle()
	if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
end

function SwimmingJump:LocalPlayerExitVehicle()
	if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end
end

function SwimmingJump:LocalPlayerInput( args )
    if args.input == Action.Jump then
        local bs = LocalPlayer:GetBaseState()

        if bs == AnimationState.SSwimIdle or bs == AnimationState.SSwimNavigation then
            local ray = Physics:Raycast( LocalPlayer:GetPosition(), LocalPlayer:GetAngle() * Vector3.Forward, 0, 3 )

            if ray.distance < 3 then
                local time = Client:GetElapsedSeconds()

                if time > self.cooltime then
                    LocalPlayer:SetBaseState( 7 )
                    LocalPlayer:SetLinearVelocity( Vector3( 0, self.jumpheight, 0 ) )

                    self.cooltime = time + self.cooldown
                end
            end
        end
    end
end

swimmingjump = SwimmingJump()