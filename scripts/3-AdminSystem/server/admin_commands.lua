class "Commands"

function Commands:__init()
	-- command name: { action it'll execute ( e.g: player.ban ), args: ( p = player, s = string, s- = string with spaces, i = integer )
	self.commands =
		{
			[ "cban" ] = { action = "player.ban", args = "p,i,s-" },
			[ "kick" ] = { action = "player.kick", args = "p,s-" },
			[ "warn" ] = { action = "player.warn", args = "p,s-" },
			[ "mute" ] = { action = "player.mute", args = "p,i,s-" },
			[ "freeze" ] = { action = "player.freeze", args = "p" },
			[ "kill" ] = { action = "player.kill", args = "p" },
			[ "sethealth" ] = { action = "player.sethealth", args = "p,i" },
			[ "setmodel" ] = { action = "player.setmodel", args = "p,i" },
			[ "setmoney" ] = { action = "player.setmoney", args = "p,i" },
			[ "givemoney" ] = { action = "player.givemoney", args = "p,i" },
			[ "awarp" ] = { action = "player.warp", args = "p" },
			[ "warpplayerto" ] = { action = "player.warpto", args = "p,p" },
			[ "giveveh" ] = { action = "player.givevehicle", args = "p,i,s" },
			[ "repairveh" ] = { action = "player.repairvehicle", args = "p" },
			[ "destroyveh" ] = { action = "player.destroyvehicle", args = "p" },
			[ "cgiveadmin" ] = { action = "player.giveadmin", args = "p" },
			[ "ctakeadmin" ] = { action = "player.takeadmin", args = "p" },
			[ "shout" ] = { action = "player.shout", args = "p,s-" },
			[ "settime" ] = { action = "general.settime", args = "i" },
			[ "ettimestep" ] = { action = "general.settimestep", args = "i" },
			[ "setweather" ] = { action = "general.setweather", args = "i" }
		}

	Events:Subscribe ( "PlayerChat", self, self.onPlayerChat )
end

function Commands:onPlayerChat( args )
    local msg = args.text
    if ( msg:sub ( 1, 1 ) ~= "/" ) then
        return true
    end

    local msg = msg:sub ( 2 )
    local cmdArgs = msg:split ( " " )
    local cmdName = cmdArgs [ 1 ]
    table.remove ( cmdArgs, 1 )

	local cmd = self.commands [ cmdName ]
	if ( cmd ) then
		local arguments = { }
		arguments [ 1 ] = cmd.action
		if ( cmd.subAction ) then
			arguments [ 2 ] = cmd.subAction
		end
		local commandArgs = cmd.args:split ( "," )
		if ( type ( commandArgs ) ~= "table" ) then
			commandArgs = { cmd.args }
		end
		for index, cmd in ipairs ( commandArgs ) do
			if ( cmdArgs [ index ] ) then
				if ( cmd == "p" ) then
					table.insert ( arguments, Player.Match ( cmdArgs [ index ] ) [ 1 ] )
				elseif ( cmd == "s" ) then
					table.insert ( arguments, cmdArgs [ index ] )
				elseif ( cmd == "i" ) then
					table.insert ( arguments, tonumber ( cmdArgs [ index ] ) )
				elseif ( cmd == "s-" ) then
					local str = ""
					for i = index, #cmdArgs do
						str = str .." ".. tostring ( cmdArgs [ i ] )
					end
					table.insert ( arguments, str )
				end
			end
		end
		if ( #arguments > 0 ) then
			Admin:executeAction ( arguments, args.player )
		end
    end

    return false
end

commands = Commands()