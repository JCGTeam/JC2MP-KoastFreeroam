class 'SwimmingJump'

function SwimmingJump:__init()
    self.jumpheight = 7

    self.cooldown = 1
	self.cooltime = 0

    Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
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