class 'JoinLeave'

function JoinLeave:__init()
	self.geoip = require( "GeoIP" )

	self.languageslist = { 
        ["RU"] = true,
		["UK"] = true,
		["BY"] = true,
		["KZ"] = true,
		["MD"] = true,
        ["N/A"] = true
    }

	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
  	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
end

function JoinLeave:PlayerJoin( args )
	args.player:SetNetworkValue( "GameMode", "FREEROAM" )
	if self.geoip.Query( args.player:GetIP() )["status"] ~= "fail" then
		args.player:SetNetworkValue( "Country", self.geoip.Query( args.player:GetIP() )["countryCode"] )
	else
		args.player:SetNetworkValue( "Country", "N/A" )
	end

	Network:Broadcast( "PlayerJoin", { player = args.player } )

	Events:Fire( "ToDiscordConsole", { text = ">" .. args.player:GetName() .. " joined to the server. |" .. " SteamID: " .. tostring( args.player:GetSteamId() ) .. " IP: " .. tostring( args.player:GetIP() ) } )

	local pcountry = args.player:GetValue( "Country" )

	local text_clr = Color.White
	local text2_clr = Color.Yellow

	if self.languageslist[pcountry] then
		Chat:Send( args.player, "Добро пожаловать на Koast Freeroam! Приятной игры :3", Color( 200, 120, 255 ) )

		Chat:Send( args.player, "==============", Color( 255, 255, 255 ) )
		Chat:Send( args.player, "> Меню сервера: ", text_clr, "B", text2_clr )
		Chat:Send( args.player, "> Меню действий: ", text_clr, "V", text2_clr )
		Chat:Send( args.player, "> Серверная карта: ", text_clr, "M", text2_clr, " / ", text_clr, "F2", text2_clr )
		Chat:Send( args.player, "> Список игроков: ", text_clr, "F5", text2_clr )
		Chat:Send( args.player, "==============", Color( 255, 255, 255 ) )
	else
		Chat:Send( args.player, "Welcome to Koast Freeroam! Have a good game :3", Color( 200, 120, 255 ) )
		Chat:Send( args.player, "==============", Color( 255, 255, 255 ) )
		Chat:Send( args.player, "> Server Menu: ", text_clr, "B", text2_clr )
		Chat:Send( args.player, "> Actions Menu: ", text_clr, "V", text2_clr )
		Chat:Send( args.player, "> Server Map: ", text_clr, "M", text2_clr, " / ", text_clr, "F2", text2_clr )
		Chat:Send( args.player, "> Players List: ", text_clr, "F5", text2_clr )
		Chat:Send( args.player, "==============", Color( 255, 255, 255 ) )
	end
end

function JoinLeave:PlayerQuit( args )
	Network:Broadcast( "PlayerQuit", { player = args.player } )

	Events:Fire( "ToDiscordConsole", { text = ">" .. args.player:GetName() .. " left the server." } )
end

joinLeave = JoinLeave()