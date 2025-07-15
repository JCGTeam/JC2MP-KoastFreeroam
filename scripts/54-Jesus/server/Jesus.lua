class 'Jesus'

function Jesus:__init()
    Network:Subscribe("SetSystemValue", self, self.SetSystemValue)
end

function Jesus:SetSystemValue(args)
    args.player:SetNetworkValue(args.name, args.value)
end

local jesus = Jesus()