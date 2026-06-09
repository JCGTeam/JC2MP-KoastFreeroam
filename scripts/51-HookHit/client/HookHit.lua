class 'HookHit'

function HookHit:__init()
    self.cooldown = 1
    self.cooltime = 0

    if not LocalPlayer:InVehicle() then
        self:LocalPlayerExitVehicle()
    end

    Events:Subscribe("LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle)
    Events:Subscribe("LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle)
end

function HookHit:LocalPlayerEnterVehicle()
    if not self.eventsLoaded then return end

    Events:Unsubscribe(self.NetworkObjectValueChangeEvent) self.NetworkObjectValueChangeEvent = nil
    Events:Unsubscribe(self.LocalPlayerInputEvent) self.LocalPlayerInputEvent = nil

    self.eventsLoaded = nil

    self.PassiveValue = nil
end

function HookHit:LocalPlayerExitVehicle()
    if self.eventsLoaded then return end

    self:NetworkObjectValueChange()

    self.NetworkObjectValueChangeEvent = Events:Subscribe("NetworkObjectValueChange", self, self.NetworkObjectValueChange)
    self.LocalPlayerInputEvent = Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)

    self.eventsLoaded = true
end

function HookHit:NetworkObjectValueChange(args)
    if args and args.object.__type ~= "LocalPlayer" then return end

    self.PassiveValue = LocalPlayer:GetValue("Passive")
end

function HookHit:LocalPlayerInput(args)
    if args.input == 124 and LocalPlayer:GetBaseState() == AnimationState.SGrappleSmashLeft then
        local time = Client:GetElapsedSeconds()

        if time > self.cooltime then
            if not self.PassiveValue then
                Network:Send("HitPlayers")
            end

            self.cooltime = time + self.cooldown
        end
    end
end

local hookhit = HookHit()