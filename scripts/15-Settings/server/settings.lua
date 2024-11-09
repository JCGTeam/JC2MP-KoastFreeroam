class 'Settings'

function Settings:__init()
	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_color (steamid VARCHAR UNIQUE, r INTEGER, g INTEGER, b INTEGER)" )
	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_settings (steamid VARCHAR UNIQUE, clockvisible INTEGER, clockpendosformat INTEGER, bestrecordsvisible INTEGER, passivemodevisible INTEGER, jesusmodevisible INTEGER, killfeedvisible INTEGER, chattipsvisible INTEGER, chatbackgroundvisible INTEGER, playersmarkersvisible INTEGER, jobsmarkersvisible INTEGER, customcrosshair INTEGER, jethud INTEGER, longergrapplevisible INTEGER, jobsvisible INTEGER, longergrappleenabled INTEGER, vehicleejectblocker INTEGER, wingsuitenabled INTEGER, hydraulicsenabled INTEGER, driftphysics INTEGER, opendoorstipsvisible INTEGER, vehiclejump INTEGER, aircontrol INTEGER)" )
	--SQL:Execute( "CREATE TABLE IF NOT EXISTS players_binds (steamid VARCHAR UNIQUE, servermenu INTEGER, actionsmenu INTEGER, quicktp INTEGER, togglegrenades INTEGER, freecam INTEGER, opendoors INTEGER, playerslist INTEGER, firstperson INTEGER, toggleserverui INTEGER, boost INTEGER, airboost INTEGER, vehcamera INTEGER, nexttrack INTEGER, tuning INTEGER)" )

	--for p in Server:GetPlayers() do
	--	self:GetDBSettings( p )
	--end

	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )

	Network:Subscribe( "UpdateParameters", self, self.UpdateParameters )
	Network:Subscribe( "SetPlyColor", self, self.SetPlyColor )
	Network:Subscribe( "SPOff", self, self.SPOff )
	Network:Subscribe( "SetWeather", self, self.SetWeather )
	Network:Subscribe( "RequestStats", self, self.RequestStats )
	Network:Subscribe( "RequestPromocodes", self, self.RequestPromocodes )
	Network:Subscribe( "GeneratePromocode", self, self.GeneratePromocode )
	Network:Subscribe( "GetInvitationPromocodesReward", self, self.GetInvitationPromocodesReward )
	Network:Subscribe( "ActivateInvitationPromocode", self, self.ActivateInvitationPromocode )
	Network:Subscribe( "RunConsoleCommand", self, self.RunConsoleCommand )
end

function Settings:UpdateParameters( args, sender )
	if args.parameter == 1 then
		sender:SetNetworkValue( "ClockVisible", args.boolean )
	elseif args.parameter == 2 then
		sender:SetNetworkValue( "ClockPendosFormat", args.boolean )
	elseif args.parameter == 3 then
		sender:SetNetworkValue( "BestRecordVisible", args.boolean )
	elseif args.parameter == 4 then
		sender:SetNetworkValue( "PassiveModeVisible", args.boolean )
	elseif args.parameter == 5 then
		sender:SetNetworkValue( "JesusModeVisible", args.boolean )
	elseif args.parameter == 6 then
		sender:SetNetworkValue( "KillFeedVisible", args.boolean )
	elseif args.parameter == 7 then
		sender:SetNetworkValue( "ChatTipsVisible", args.boolean )
	elseif args.parameter == 8 then
		sender:SetNetworkValue( "ChatBackgroundVisible", args.boolean )
	elseif args.parameter == 9 then
		sender:SetNetworkValue( "PlayersMarkersVisible", args.boolean )
	elseif args.parameter == 10 then
		sender:SetNetworkValue( "JobsMarkersVisible", args.boolean )
	elseif args.parameter == 11 then
		sender:SetNetworkValue( "CustomCrosshair", args.boolean )
	elseif args.parameter == 12 then
		sender:SetNetworkValue( "JetHUD", args.boolean )
	elseif args.parameter == 13 then
		sender:SetNetworkValue( "LongerGrappleVisible", args.boolean )
	elseif args.parameter == 14 then
		sender:SetNetworkValue( "JobsVisible", args.boolean )
	elseif args.parameter == 15 then
		sender:SetNetworkValue( "LongerGrappleEnabled", args.boolean )
	elseif args.parameter == 16 then
		sender:SetNetworkValue( "VehicleEjectBlocker", args.boolean )
	elseif args.parameter == 17 then
		sender:SetNetworkValue( "WingsuitEnabled", args.boolean )
	elseif args.parameter == 18 then
		sender:SetNetworkValue( "HydraulicsEnabled", args.boolean )
	elseif args.parameter == 19 then
		sender:SetNetworkValue( "DriftPhysics", args.boolean )
	elseif args.parameter == 20 then
		sender:SetNetworkValue( "OpenDoorsTipsVisible", args.boolean )
	elseif args.parameter == 21 then
		sender:SetNetworkValue( "VehicleJump", args.boolean )
	elseif args.parameter == 22 then
		sender:SetNetworkValue( "AirControl", args.boolean )
	end
end

function Settings:BooleanToNumber( value )
	return value == true and 1 or ( value == false or value == nil ) and 0
end

function Settings:NumberToBoolean( value )
	return value == 1 and true or value == 0 and false
end

function Settings:PlayerQuit( args )
	local steamId = args.player:GetSteamId().id

    local cmd = SQL:Command( "INSERT OR REPLACE INTO players_settings (steamid, clockvisible, clockpendosformat, bestrecordsvisible, passivemodevisible, jesusmodevisible, killfeedvisible, chattipsvisible, chatbackgroundvisible, playersmarkersvisible, jobsmarkersvisible, customcrosshair, jethud, longergrapplevisible, jobsvisible, longergrappleenabled, vehicleejectblocker, wingsuitenabled, hydraulicsenabled, driftphysics, opendoorstipsvisible, vehiclejump, aircontrol) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" )
    cmd:Bind( 1, tostring( steamId ) )
    cmd:Bind( 2, self:BooleanToNumber( args.player:GetValue( "ClockVisible" ) ) )
	cmd:Bind( 3, self:BooleanToNumber( args.player:GetValue( "ClockPendosFormat" ) ) )
	cmd:Bind( 4, self:BooleanToNumber( args.player:GetValue( "BestRecordVisible" ) ) )
	cmd:Bind( 5, self:BooleanToNumber( args.player:GetValue( "PassiveModeVisible" ) ) )
	cmd:Bind( 6, self:BooleanToNumber( args.player:GetValue( "JesusModeVisible" ) ) )
	cmd:Bind( 7, self:BooleanToNumber( args.player:GetValue( "KillFeedVisible" ) ) )
	cmd:Bind( 8, self:BooleanToNumber( args.player:GetValue( "ChatTipsVisible" ) ) )
	cmd:Bind( 9, self:BooleanToNumber( args.player:GetValue( "ChatBackgroundVisible" ) ) )
	cmd:Bind( 10, self:BooleanToNumber( args.player:GetValue( "PlayersMarkersVisible" ) ) )
	cmd:Bind( 11, self:BooleanToNumber( args.player:GetValue( "JobsMarkersVisible" ) ) )
	cmd:Bind( 12, self:BooleanToNumber( args.player:GetValue( "CustomCrosshair" ) ) )
	cmd:Bind( 13, self:BooleanToNumber( args.player:GetValue( "JetHUD" ) ) )
	cmd:Bind( 14, self:BooleanToNumber( args.player:GetValue( "LongerGrappleVisible" ) ) )
	cmd:Bind( 15, self:BooleanToNumber( args.player:GetValue( "JobsVisible" ) ) )
	cmd:Bind( 16, self:BooleanToNumber( args.player:GetValue( "LongerGrappleEnabled" ) ) )
	cmd:Bind( 17, self:BooleanToNumber( args.player:GetValue( "VehicleEjectBlocker" ) ) )
	cmd:Bind( 18, self:BooleanToNumber( args.player:GetValue( "WingsuitEnabled" ) ) )
	cmd:Bind( 19, self:BooleanToNumber( args.player:GetValue( "HydraulicsEnabled" ) ) )
	cmd:Bind( 20, self:BooleanToNumber( args.player:GetValue( "DriftPhysics" ) ) )
	cmd:Bind( 21, self:BooleanToNumber( args.player:GetValue( "OpenDoorsTipsVisible" ) ) )
	cmd:Bind( 22, self:BooleanToNumber( args.player:GetValue( "VehicleJump" ) ) )
	cmd:Bind( 23, self:BooleanToNumber( args.player:GetValue( "AirControl" ) ) )
	cmd:Execute()
end

function Settings:GetDBSettings( player )
	local qry = SQL:Query( "SELECT clockvisible, clockpendosformat, bestrecordsvisible, passivemodevisible, jesusmodevisible, killfeedvisible, chattipsvisible, chatbackgroundvisible, playersmarkersvisible, jobsmarkersvisible, customcrosshair, jethud, longergrapplevisible, jobsvisible, longergrappleenabled, vehicleejectblocker, wingsuitenabled, hydraulicsenabled, driftphysics, opendoorstipsvisible, vehiclejump, aircontrol FROM players_settings WHERE steamid = ?")
	qry:Bind( 1, player:GetSteamId().id )
	local result = qry:Execute()

	if #result > 0 then
		player:SetNetworkValue( "ClockVisible", self:NumberToBoolean( tonumber( result[1].clockvisible ) ) )
		player:SetNetworkValue( "ClockPendosFormat", self:NumberToBoolean( tonumber( result[1].clockpendosformat ) ) )
		player:SetNetworkValue( "BestRecordVisible", self:NumberToBoolean( tonumber( result[1].bestrecordsvisible ) ) )
		player:SetNetworkValue( "PassiveModeVisible", self:NumberToBoolean( tonumber( result[1].passivemodevisible ) ) )
		player:SetNetworkValue( "JesusModeVisible", self:NumberToBoolean( tonumber( result[1].jesusmodevisible ) ) )
		player:SetNetworkValue( "KillFeedVisible", self:NumberToBoolean( tonumber( result[1].killfeedvisible ) ) )
		player:SetNetworkValue( "ChatTipsVisible", self:NumberToBoolean( tonumber( result[1].chattipsvisible ) ) )
		player:SetNetworkValue( "ChatBackgroundVisible", self:NumberToBoolean( tonumber( result[1].chatbackgroundvisible ) ) )
		player:SetNetworkValue( "PlayersMarkersVisible", self:NumberToBoolean( tonumber( result[1].playersmarkersvisible ) ) )
		player:SetNetworkValue( "JobsMarkersVisible", self:NumberToBoolean( tonumber( result[1].jobsmarkersvisible ) ) )
		player:SetNetworkValue( "CustomCrosshair", self:NumberToBoolean( tonumber( result[1].customcrosshair ) ) )
		player:SetNetworkValue( "JetHUD", self:NumberToBoolean( tonumber( result[1].jethud ) ) )
		player:SetNetworkValue( "LongerGrappleVisible", self:NumberToBoolean( tonumber( result[1].longergrapplevisible ) ) )
		player:SetNetworkValue( "JobsVisible", self:NumberToBoolean( tonumber( result[1].jobsvisible ) ) )
		player:SetNetworkValue( "LongerGrappleEnabled", self:NumberToBoolean( tonumber( result[1].longergrappleenabled ) ) )
		player:SetNetworkValue( "VehicleEjectBlocker", self:NumberToBoolean( tonumber( result[1].vehicleejectblocker ) ) )
		player:SetNetworkValue( "WingsuitEnabled", self:NumberToBoolean( tonumber( result[1].wingsuitenabled ) ) )
		player:SetNetworkValue( "HydraulicsEnabled", self:NumberToBoolean( tonumber( result[1].hydraulicsenabled ) ) )
		player:SetNetworkValue( "DriftPhysics", self:NumberToBoolean( tonumber( result[1].driftphysics ) ) )
		player:SetNetworkValue( "OpenDoorsTipsVisible", self:NumberToBoolean( tonumber( result[1].opendoorstipsvisible ) ) )
		player:SetNetworkValue( "VehicleJump", self:NumberToBoolean( tonumber( result[1].vehiclejump ) ) )
		player:SetNetworkValue( "AirControl", self:NumberToBoolean( tonumber( result[1].aircontrol ) ) )
	else
		player:SetNetworkValue( "ClockVisible", true )
		player:SetNetworkValue( "ClockPendosFormat", false )
		player:SetNetworkValue( "BestRecordVisible", true )
		player:SetNetworkValue( "PassiveModeVisible", true )
		player:SetNetworkValue( "JesusModeVisible", true )
		player:SetNetworkValue( "KillFeedVisible", true )
		player:SetNetworkValue( "ChatTipsVisible", true )
		player:SetNetworkValue( "ChatBackgroundVisible", false )
		player:SetNetworkValue( "PlayersMarkersVisible", true )
		player:SetNetworkValue( "JobsMarkersVisible", true )
		player:SetNetworkValue( "CustomCrosshair", true )
		player:SetNetworkValue( "JetHUD", false )
		player:SetNetworkValue( "LongerGrappleVisible", true )
		player:SetNetworkValue( "JobsVisible", true )
		player:SetNetworkValue( "LongerGrappleEnabled", true )
		player:SetNetworkValue( "VehicleEjectBlocker", false )
		player:SetNetworkValue( "WingsuitEnabled", true )
		player:SetNetworkValue( "HydraulicsEnabled", true )
		player:SetNetworkValue( "DriftPhysics", false )
		player:SetNetworkValue( "OpenDoorsTipsVisible", true )
		player:SetNetworkValue( "VehicleJump", true )
		player:SetNetworkValue( "AirControl", true )
	end
end

function Settings:SetPlyColor( args, sender )
	local color = args.pcolor
	local steamId = sender:GetSteamId().id

	local qry = SQL:Query( 'INSERT OR REPLACE INTO players_color (steamid, r, g, b) VALUES(?, ?, ?, ?)' )
	qry:Bind( 1, steamId )
	qry:Bind( 2, color.r )
	qry:Bind( 3, color.g )
	qry:Bind( 4, color.b )
	qry:Execute()

	sender:SetColor( args.pcolor )
end

function Settings:PlayerJoin( args )
	local qry = SQL:Query("SELECT r, g, b FROM players_color WHERE steamid = ?")
	qry:Bind(1, args.player:GetSteamId().id)
    local result = qry:Execute()

	if #result > 0 then
		args.player:SetColor( Color( tonumber(result[1].r), tonumber(result[1].g), tonumber(result[1].b) ) )
	end
	self:GetDBSettings( args.player )
end

function Settings:SPOff( args, sender )
	if not sender:GetValue("SavePos") then
		Chat:Send( sender, "[Сервер] ", Color.White, "Позиция сброшена. Перезайдите в игру.", Color.Yellow )
		sender:SetNetworkValue( "SavePos", true )
		Network:Send( sender, "ResetDone" )
	end
end

function Settings:SetWeather( args, sender )
	if sender:GetWorld() ~= DefaultWorld then return end
	sender:SetWeatherSeverity( args.severity )
end

function Settings:RequestStats( args, sender )
	local stats = {}
	stats.modelId = tostring( sender:GetModelId() )

	Network:Send( sender, "UpdateStats", stats )
end

function Settings:RequestPromocodes( args, sender )
	Events:Fire( "UpdateInvitationPromocodesInfo", sender )

	Network:Send( sender, "UpdatePromocodes" )
end

function Settings:GetRandomChar()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local index = math.random( 1, #chars )

    return chars:sub( index, index )
end

function Settings:GeneratePromoCode( steamId )
    local promoCode = ""

    local steamIdSuffix = string.sub( steamId, -4 )

    for i = 1, 6 do
        promoCode = promoCode .. self:GetRandomChar()
    end

    return steamIdSuffix .. promoCode
end

function Settings:GeneratePromocode( args, sender )
	local steamId = sender:GetSteamId().id
	local name = self:GeneratePromoCode( steamId )

	Events:Fire( "AddInvitationPromocode", { text = steamId .. " " .. name .. " " .. InviteBonuses.Bonus1 .. " " .. InviteBonuses.Bonus2 } )

	Events:Fire( "UpdateInvitationPromocodesInfo", sender )

	Network:Send( sender, "UpdatePromocodes", { promocode = name } )
end

function Settings:GetInvitationPromocodesReward( args, sender )
	local promocodeRewards = sender:GetValue( "PromoCodeRewards" )

	if promocodeRewards and tonumber( promocodeRewards ) > 0 then
		sender:SetMoney( sender:GetMoney() + promocodeRewards * InviteBonuses.Bonus1 )
		Events:Fire( "GetInvitationPromocodesReward", sender )
	end
end

function Settings:ActivateInvitationPromocode( args, sender )
	local activePromocode = sender:GetValue( "ActivePromocode" )

	if activePromocode then
		sender:SetMoney( sender:GetMoney() + activePromocode )
		sender:SetNetworkValue( "ActivePromocode", nil )
	end
end

function Settings:RunConsoleCommand( cmd )
	Console:Run( cmd )
end

settings = Settings()