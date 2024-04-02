class 'Stats'

function Stats:__init()
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function Stats:PlayerChat( args )
	local msg = args.text
	local player = args.player

	if ( msg:sub(1, 1) ~= "/" ) then
		return true
	end

	local cmdargs = {}
	for word in string.gmatch( msg, "[^%s]+" ) do
		table.insert( cmdargs, word )
	end

	if (cmdargs[1] == "/stats") then
		Chat:Send( args.player, "==============", Color.White )
		Chat:Send( args.player, "Steam-ID: ", Color.White, tostring( args.player:GetSteamId() ), Color.Yellow )
		Chat:Send( args.player, "ID: ", Color.White, tostring( args.player:GetId() ), Color.Yellow )
		Chat:Send( args.player, args.player:GetValue( "Lang" ) == "EN" and "Character ID: " or "ID персонажа: ", Color.White, tostring( args.player:GetModelId() ), Color.Yellow )
		Chat:Send( args.player, args.player:GetValue( "Lang" ) == "EN" and "Nickname color: " or "Цвет ника: ", Color.White, tostring( args.player:GetColor() ), args.player:GetColor() )
		Chat:Send( args.player, args.player:GetValue( "Lang" ) == "EN" and "Money: " or "Деньги: ", Color.White, "$" .. tostring( args.player:GetMoney() ), Color.Yellow )
		Chat:Send( args.player, args.player:GetValue( "Lang" ) == "EN" and "Vehicle: " or "Транспорт: ", Color.White, tostring( args.player:GetVehicle() ), Color.Yellow )
		Chat:Send( args.player, "==============", Color.White )
        return false
    end
	return false
end

stats = Stats()