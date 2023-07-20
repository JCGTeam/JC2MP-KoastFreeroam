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

	for p in Server:GetPlayers() do
		Network:Send( p, "PlayerJoin", { player = args.player } )
	end

	Events:Fire( "ToDiscordConsole", { text = ">" .. args.player:GetName() .. " joined to the server. |" .. " SteamID: " .. tostring( args.player:GetSteamId() ) .. " IP: " .. tostring( args.player:GetIP() ) } )

	local pcountry = args.player:GetValue( "Country" )

	if self.languageslist[pcountry] then
		Chat:Send( args.player, "Добро пожаловать на Koast Freeroam! Приятной игры :3", Color( 200, 120, 255 ) )

		Chat:Send( args.player, "==============", Color( 255, 255, 255 ) )
		Chat:Send( args.player, "> Меню сервера: ", Color.White, "B", Color.Yellow )
		Chat:Send( args.player, "> Меню действий: ", Color.White, "V", Color.Yellow )
		Chat:Send( args.player, "> Серверная карта: ", Color.White, "M", Color.Yellow, " / ", Color.White, "F2", Color.Yellow )
		Chat:Send( args.player, "> Список игроков: ", Color.White, "F5", Color.Yellow )
		Chat:Send( args.player, "==============", Color( 255, 255, 255 ) )
	else
		Chat:Send( args.player, "Welcome to Koast Freeroam! Have a good game :3", Color( 200, 120, 255 ) )
		Chat:Send( args.player, "==============", Color( 255, 255, 255 ) )
		Chat:Send( args.player, "> Server Menu: ", Color.White, "B", Color.Yellow )
		Chat:Send( args.player, "> Actions Menu: ", Color.White, "V", Color.Yellow )
		Chat:Send( args.player, "> Server Map: ", Color.White, "M", Color.Yellow, " / ", Color.White, "F2", Color.Yellow )
		Chat:Send( args.player, "> Players List: ", Color.White, "F5", Color.Yellow )
		Chat:Send( args.player, "==============", Color( 255, 255, 255 ) )
	end
end

function JoinLeave:PlayerQuit( args )
	for p in Server:GetPlayers() do
		Network:Send( p, "PlayerQuit", { player = args.player } )
	end

	Events:Fire( "ToDiscordConsole", { text = ">" .. args.player:GetName() .. " left the server." } )
end

joinLeave = JoinLeave()