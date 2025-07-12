class 'FontCheck'

function FontCheck:__init()
    Network:Subscribe("ToggleSystemFonts", self, self.ToggleSystemFonts)
end

function FontCheck:ToggleSystemFonts(args, sender)
    sender:SetNetworkValue("SystemFonts", args.enabled)
end

local fontcheck = FontCheck()