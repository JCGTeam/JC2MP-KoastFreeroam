class 'FirstPerson'

function FirstPerson:__init()
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function FirstPerson:PlayerChat( args )
	local msg = args.text

	if ( msg:sub(1, 1) ~= "/" ) then
		return true
	end

	local cmdargs = {}
	for word in string.gmatch(msg, "[^%s]+") do
		table.insert(cmdargs, word)
	end

	if (cmdargs[1] == "/fp") then
		Network:Send( args.player, "FpActive" )
        return false
    end
	return false
end

firstperson = FirstPerson()