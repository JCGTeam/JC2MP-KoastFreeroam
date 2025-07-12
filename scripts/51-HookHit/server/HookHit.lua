class 'HookHit'

function HookHit:__init()
    Network:Subscribe("HitPlayers", self, self.HitPlayers)
end

function HookHit:HitPlayers(args, sender)
    local sPos = sender:GetPosition()

    for p in Server:GetPlayers() do
        local jDist = sPos:Distance(p:GetPosition())

        if jDist < 2 then
            if p ~= sender then
                if not p:GetValue("Passive") then
                    p:Damage(0.1)
                end
            end
        end
    end
end

local hookhit = HookHit()