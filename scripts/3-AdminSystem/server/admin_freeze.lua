local frozen = {}

function setPlayerFrozen( player, state )
	if IsValid ( player, false ) then
		frozen [ tostring ( player:GetSteamId() ) ] = state
		Network:Send( player, "freeze.setStatus", state )
	else
		return false
	end
end

function isPlayerFrozen( player )
	if IsValid ( player, false ) then
		local steamID = tostring ( player:GetSteamId() )
		return ( frozen [ steamID ] == nil and false or frozen [ steamID ] )
	else
		return false
	end
end

Events:Subscribe( "PlayerQuit",
	function ( args )
		frozen [ tostring ( args.player:GetSteamId() ) ] = nil
	end
)