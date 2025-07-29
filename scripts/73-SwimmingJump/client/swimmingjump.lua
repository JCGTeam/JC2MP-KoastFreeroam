class 'SwimmingJump'

function SwimmingJump:__init()
    self.jumpheight = 7

    if not LocalPlayer:InVehicle() then
        self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
    end

    Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
end

function SwimmingJump:LocalPlayerEnterVehicle()
    if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
end

function SwimmingJump:LocalPlayerExitVehicle()
    if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
end

function SwimmingJump:LocalPlayerInput(args)
    local inputDown = Input:GetValue(Action.Jump) > 0

    if inputDown and not self.inputWasDown then
        local bs = LocalPlayer:GetBaseState()

        if bs == AnimationState.SSwimIdle or bs == AnimationState.SSwimNavigation then
            local ray = Physics:Raycast(LocalPlayer:GetPosition(), LocalPlayer:GetAngle() * Vector3.Forward, 0, 3)

            if ray.distance < 3 then
                LocalPlayer:SetBaseState(7)
                LocalPlayer:SetLinearVelocity(Vector3(0, self.jumpheight, 0))
            end
        end
    end

    self.inputWasDown = inputDown
end

local swimmingjump = SwimmingJump()