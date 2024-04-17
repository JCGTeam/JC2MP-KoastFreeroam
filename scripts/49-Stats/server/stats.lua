class 'Stats'

function Stats:__init()
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function Stats:PlayerChat( args )
	local msg = args.text

	if ( msg:sub(1, 1) ~= "/" ) then
		return true
	end

	local cmdargs = {}
	for word in string.gmatch( msg, "[^%s]+" ) do
		table.insert( cmdargs, word )
	end

	if (cmdargs[1] == "/stats") then
		local text_clr = Color.White
		local text2_clr = Color.Yellow

		Chat:Send( args.player, "==============", text_clr )
		Chat:Send( args.player, "Steam-ID: ", text_clr, tostring( args.player:GetSteamId() ), text2_clr )
		Chat:Send( args.player, "ID: ", text_clr, tostring( args.player:GetId() ), text2_clr )
		Chat:Send( args.player, args.player:GetValue( "Lang" ) == "EN" and "Character ID: " or "ID персонажа: ", text_clr, tostring( args.player:GetModelId() ), text2_clr )
		Chat:Send( args.player, args.player:GetValue( "Lang" ) == "EN" and "Nickname color: " or "Цвет ника: ", text_clr, tostring( args.player:GetColor() ), args.player:GetColor() )
		Chat:Send( args.player, args.player:GetValue( "Lang" ) == "EN" and "Balance: " or "Деньги: ", text_clr, "$" .. tostring( args.player:GetMoney() ), text2_clr )
		Chat:Send( args.player, args.player:GetValue( "Lang" ) == "EN" and "Vehicle: " or "Транспорт: ", text_clr, tostring( args.player:GetVehicle() ), text2_clr )
		Chat:Send( args.player, "==============", text_clr )
        return false
    end
	return false
end

stats = Stats()