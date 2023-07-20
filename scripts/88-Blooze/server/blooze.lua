class 'BloozeMod'

function BloozeMod:__init()
    Network:Subscribe( "MinusHP", self, self.MinusHP )
end

function BloozeMod:MinusHP( args, sender )
    sender:SetHealth( sender:GetHealth() - 0.1 )
    if sender:GetValue( "Bloozing" ) then
		sender:SetNetworkValue( "Bloozing", 1 )
	end
end

bloozemod = BloozeMod()