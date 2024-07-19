class 'Stats'

function Stats:__init()
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function Stats:PlayerChat( args )
	local cmd_args = args.text:split( " " )

	if (cmd_args[1] == "/stats") then
		local text_clr = Color.White
		local text2_clr = Color.Yellow
		local pColor = args.player:GetColor()
		local pLang = args.player:GetValue( "Lang" )

		Chat:Send( args.player, "==============", text_clr )
		Chat:Send( args.player, "Steam-ID: ", text_clr, tostring( args.player:GetSteamId() ), text2_clr )
		Chat:Send( args.player, "ID: ", text_clr, tostring( args.player:GetId() ), text2_clr )
		Chat:Send( args.player, pLang == "EN" and "Character ID: " or "ID персонажа: ", text_clr, tostring( args.player:GetModelId() ), text2_clr )
		Chat:Send( args.player, pLang == "EN" and "Nickname color: " or "Цвет ника: ", text_clr, tostring( pColor ), pColor )
		Chat:Send( args.player, pLang == "EN" and "Balance: " or "Деньги: ", text_clr, "$" .. tostring( args.player:GetMoney() ), text2_clr )
		Chat:Send( args.player, pLang == "EN" and "Vehicle: " or "Транспорт: ", text_clr, tostring( args.player:GetVehicle() ), text2_clr )
		Chat:Send( args.player, "==============", text_clr )
        return false
    end
	return false
end

stats = Stats()