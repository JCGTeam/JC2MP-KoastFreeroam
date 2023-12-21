class 'FontCheck'

function FontCheck:__init()
	Network:Subscribe( "ToggleSystemFonts", self, self.ToggleSystemFonts )
end

function FontCheck:ToggleSystemFonts( args, sender )
	if not args.enabled then return end

	sender:SetNetworkValue( "SystemFonts", args.enabled )
end

fontcheck = FontCheck()