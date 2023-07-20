CASINO_CONFIGURATION = 
{
    COINFLIPLIMIT = 10000,
    CHANCE = 30
}

function formatNumber( amount )
	local formatted = tostring( amount );
	while true do  
		formatted, k = string.gsub( formatted, "^(-?%d+)(%d%d%d)", '%1.%2' );
		if (k==0) then
			break
		end
	end
	return formatted;
end