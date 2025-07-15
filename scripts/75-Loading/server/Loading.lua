class 'Load'

function Load:__init()
    Network:Subscribe("KickPlayer", self, self.KickPlayer)
end

function Load:KickPlayer(args, sender)
    sender:Kick()
end

local load = Load()