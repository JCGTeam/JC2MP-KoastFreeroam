class 'Settings'

function Settings:__init()
	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_color (steamid VARCHAR UNIQUE, r INTEGER, g INTEGER, b INTEGER)" )
	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_settings (steamid VARCHAR UNIQUE, clockvisible INTEGER, clockpendosformat INTEGER, bestrecordsvisible INTEGER, passivemodevisible INTEGER, jesusmodevisible INTEGER, killfeedvisible INTEGER, chattipsvisible INTEGER, chatbackgroundvisible INTEGER, playersmarkersvisible INTEGER, jobsmarkersvisible INTEGER, customcrosshair INTEGER, jethud INTEGER, longergrapplevisible INTEGER, jobsvisible INTEGER, longergrappleenabled INTEGER, vehicleejectblocker INTEGER, wingsuitenabled INTEGER, hydraulicsenabled INTEGER)" )

	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )

	Network:Subscribe( "UpdateParameters", self, self.UpdateParameters )
	Network:Subscribe( "SetPlyColor", self, self.SetPlyColor )
	Network:Subscribe( "SPOff", self, self.SPOff )

	Network:Subscribe( "SetWeather", self, self.SetWeather )
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
	end
end

function Settings:BooleanToNumber( value )
	return value == true and 1 or value == false and 0
end

function Settings:NumberToBoolean( value )
	return value == 1 and true or value == 0 and false
end

function Settings:PlayerQuit( args )
	local steamID = args.player:GetSteamId().id

    local cmd = SQL:Command( "INSERT OR REPLACE INTO players_settings (steamid, clockvisible, clockpendosformat, bestrecordsvisible, passivemodevisible, jesusmodevisible, killfeedvisible, chattipsvisible, chatbackgroundvisible, playersmarkersvisible, jobsmarkersvisible, customcrosshair, jethud, longergrapplevisible, jobsvisible, longergrappleenabled, vehicleejectblocker, wingsuitenabled, hydraulicsenabled) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" )
    cmd:Bind( 1, tostring( steamID ) )
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
	cmd:Execute()
end

function Settings:GetDBSettings( args )
	local qry = SQL:Query( "SELECT clockvisible, clockpendosformat, bestrecordsvisible, passivemodevisible, jesusmodevisible, killfeedvisible, chattipsvisible, chatbackgroundvisible, playersmarkersvisible, jobsmarkersvisible, customcrosshair, jethud, longergrapplevisible, jobsvisible, longergrappleenabled, vehicleejectblocker, wingsuitenabled, hydraulicsenabled FROM players_settings WHERE steamid = ?")
	qry:Bind( 1, args.player:GetSteamId().id )
	local result = qry:Execute()

	if #result > 0 then
		args.player:SetNetworkValue( "ClockVisible", self:NumberToBoolean( tonumber( result[1].clockvisible ) ) )
		args.player:SetNetworkValue( "ClockPendosFormat", self:NumberToBoolean( tonumber( result[1].clockpendosformat ) ) )
		args.player:SetNetworkValue( "BestRecordVisible", self:NumberToBoolean( tonumber( result[1].bestrecordsvisible ) ) )
		args.player:SetNetworkValue( "PassiveModeVisible", self:NumberToBoolean( tonumber( result[1].passivemodevisible ) ) )
		args.player:SetNetworkValue( "JesusModeVisible", self:NumberToBoolean( tonumber( result[1].jesusmodevisible ) ) )
		args.player:SetNetworkValue( "KillFeedVisible", self:NumberToBoolean( tonumber( result[1].killfeedvisible ) ) )
		args.player:SetNetworkValue( "ChatTipsVisible", self:NumberToBoolean( tonumber( result[1].chattipsvisible ) ) )
		args.player:SetNetworkValue( "ChatBackgroundVisible", self:NumberToBoolean( tonumber( result[1].chatbackgroundvisible ) ) )
		args.player:SetNetworkValue( "PlayersMarkersVisible", self:NumberToBoolean( tonumber( result[1].playersmarkersvisible ) ) )
		args.player:SetNetworkValue( "JobsMarkersVisible", self:NumberToBoolean( tonumber( result[1].jobsmarkersvisible ) ) )
		args.player:SetNetworkValue( "CustomCrosshair", self:NumberToBoolean( tonumber( result[1].customcrosshair ) ) )
		args.player:SetNetworkValue( "JetHUD", self:NumberToBoolean( tonumber( result[1].jethud ) ) )
		args.player:SetNetworkValue( "LongerGrappleVisible", self:NumberToBoolean( tonumber( result[1].longergrapplevisible ) ) )
		args.player:SetNetworkValue( "JobsVisible", self:NumberToBoolean( tonumber( result[1].jobsvisible ) ) )
		args.player:SetNetworkValue( "LongerGrappleEnabled", self:NumberToBoolean( tonumber( result[1].longergrappleenabled ) ) )
		args.player:SetNetworkValue( "VehicleEjectBlocker", self:NumberToBoolean( tonumber( result[1].vehicleejectblocker ) ) )
		args.player:SetNetworkValue( "WingsuitEnabled", self:NumberToBoolean( tonumber( result[1].wingsuitenabled ) ) )
		args.player:SetNetworkValue( "HydraulicsEnabled", self:NumberToBoolean( tonumber( result[1].hydraulicsenabled ) ) )
	else
		args.player:SetNetworkValue( "ClockVisible", true )
		args.player:SetNetworkValue( "ClockPendosFormat", false )
		args.player:SetNetworkValue( "BestRecordVisible", true )
		args.player:SetNetworkValue( "PassiveModeVisible", true )
		args.player:SetNetworkValue( "JesusModeVisible", true )
		args.player:SetNetworkValue( "KillFeedVisible", true )
		args.player:SetNetworkValue( "ChatTipsVisible", true )
		args.player:SetNetworkValue( "ChatBackgroundVisible", false )
		args.player:SetNetworkValue( "PlayersMarkersVisible", true )
		args.player:SetNetworkValue( "JobsMarkersVisible", true )
		args.player:SetNetworkValue( "CustomCrosshair", true )
		args.player:SetNetworkValue( "JetHUD", false )
		args.player:SetNetworkValue( "LongerGrappleVisible", true )
		args.player:SetNetworkValue( "JobsVisible", true )
		args.player:SetNetworkValue( "LongerGrappleEnabled", true )
		args.player:SetNetworkValue( "VehicleEjectBlocker", false )
		args.player:SetNetworkValue( "WingsuitEnabled", true )
		args.player:SetNetworkValue( "HydraulicsEnabled", true )
	end
end

function Settings:SetPlyColor( args, sender )
	local colored = args.pcolor
	local steamID = tostring(sender:GetSteamId().id)

	local qry = SQL:Query('INSERT OR REPLACE INTO players_color (steamid, r, g, b) VALUES(?, ?, ?, ?)')
	qry:Bind(1, tostring(steamID))
	qry:Bind(2, colored.r)
	qry:Bind(3, colored.g)
	qry:Bind(4, colored.b)
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
	self:GetDBSettings( args )
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

settings = Settings()