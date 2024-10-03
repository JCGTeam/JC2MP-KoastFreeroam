class 'JoinLeave'

function JoinLeave:__init()
	self.geoIP = require( "GeoIP" )

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
	Events:Subscribe( "SetJoinNotice", self, self.SetJoinNotice )
end

function JoinLeave:PlayerJoin( args )
	local pIP = args.player:GetIP()

	args.player:SetNetworkValue( "GameMode", "FREEROAM" )

	local geoIPResult = self.geoIP.Query( pIP )
	if geoIPResult["status"] ~= "fail" then
		args.player:SetNetworkValue( "Country", geoIPResult["countryCode"] )
	else
		args.player:SetNetworkValue( "Country", "N/A" )
	end

	Network:Broadcast( "PlayerJoin", { player = args.player } )

	Events:Fire( "ToDiscordConsole", { text = ">" .. args.player:GetName() .. " joined to the server. |" .. " SteamID: " .. tostring( args.player:GetSteamId() ) .. " IP: " .. tostring( pIP ) } )

	local pcountry = args.player:GetValue( "Country" )

	local text_clr = Color.White
	local text2_clr = Color.Yellow

	if self.languageslist[pcountry] then
		Chat:Send( args.player, "Добро пожаловать на Koast Freeroam! Приятной игры :3", Color( 200, 120, 255 ) )

		Chat:Send( args.player, "==============", text_clr )
		Chat:Send( args.player, "> Меню сервера: ", text_clr, "B", text2_clr )
		Chat:Send( args.player, "> Меню действий: ", text_clr, "V", text2_clr )
		Chat:Send( args.player, "> Серверная карта: ", text_clr, "M", text2_clr, " / ", text_clr, "F2", text2_clr )
		Chat:Send( args.player, "> Список игроков: ", text_clr, "F5", text2_clr )
		Chat:Send( args.player, "==============", text_clr )
	else
		Chat:Send( args.player, "Welcome to Koast Freeroam! Have a good game :3", Color( 200, 120, 255 ) )
		Chat:Send( args.player, "==============", text_clr )
		Chat:Send( args.player, "> Server Menu: ", text_clr, "B", text2_clr )
		Chat:Send( args.player, "> Actions Menu: ", text_clr, "V", text2_clr )
		Chat:Send( args.player, "> Server Map: ", text_clr, "M", text2_clr, " / ", text_clr, "F2", text2_clr )
		Chat:Send( args.player, "> Players List: ", text_clr, "F5", text2_clr )
		Chat:Send( args.player, "==============", text_clr )
	end

	if self.joinNotice then
		Chat:Send( args.player, self.languageslist[pcountry] and "[Объявление] " or "[Notice] ", Color( 255, 210, 0 ), self.joinNotice, Color.White )
	end
end

function JoinLeave:PlayerQuit( args )
	Network:Broadcast( "PlayerQuit", { player = args.player } )

	Events:Fire( "ToDiscordConsole", { text = ">" .. args.player:GetName() .. " left the server." } )
end

function JoinLeave:SetJoinNotice( text )
	self.joinNotice = text
end

joinLeave = JoinLeave()