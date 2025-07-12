class 'HookHit'

function HookHit:__init()
    self.cooldown = 1
    self.cooltime = 0

    if not LocalPlayer:InVehicle() then
        self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
    end

    Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
end

function HookHit:LocalPlayerEnterVehicle()
    if self.LocalPlayerInputEvent then Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil end
end

function HookHit:LocalPlayerExitVehicle()
    if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput) end
end

function HookHit:LocalPlayerInput(args)
    if args.input == 124 and LocalPlayer:GetBaseState() == AnimationState.SGrappleSmashLeft then
        local time = Client:GetElapsedSeconds()

        if time > self.cooltime then
            if not LocalPlayer:GetValue("Passive") then
                Network:Send("HitPlayers")
            end

            self.cooltime = time + self.cooldown
        end
    end
end

local hookhit = HookHit()