class 'Killfeed'

function Killfeed:__init()
    Events:Subscribe("PlayerDeath", self, self.PlayerDeath)
end

function Killfeed:PlayerDeath(args)
    t = {
        ["player"] = args.player,
        ["reason"] = args.reason
    }

    if args.killer and args.killer:GetSteamId() ~= args.player:GetSteamId() then
        t.killer = args.killer
    end

    t.id = math.random(1, 3)

    Network:Broadcast("PlayerDeath", t)
end

local killfeed = Killfeed()