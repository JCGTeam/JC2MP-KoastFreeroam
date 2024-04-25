class 'Home'

function Home:__init()
	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_home (steamid VARCHAR UNIQUE, pos VARCHAR, angle VARCHAR)" )
	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_homeTw (steamid VARCHAR UNIQUE, pos INTEGER, angle VARCHAR)" )

	self.homePrice = 500
	self.homeTwPrice = 500

	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
	Events:Subscribe( "SpawnInHome", self, self.SpawnInHome )
	Network:Subscribe( "SetHome", self, self.SetHome )
	Network:Subscribe( "GoHome", self, self.GoHome )
	Network:Subscribe( "SetHomeTw", self, self.SetHomeTw )
	Network:Subscribe( "GoHomeTw", self, self.GoHomeTw )
end

function Home:PlayerChat( args )
	local cmd_args = args.text:split(" ")

	if cmd_args[1] == "/myhomes" then
		self:GetHome( args )
	end
end

function Home:SetHome( args, sender )
	local money = sender:GetMoney()

	if money >= self.homePrice then
		local steamID = tostring(sender:GetSteamId().id)

		local qry = SQL:Query( "INSERT OR REPLACE INTO players_home (steamid, pos, angle) VALUES(?, ?, ?)" )
		qry:Bind( 1, steamID )
		qry:Bind( 2, tostring( sender:GetPosition() ) )
		qry:Bind( 3, tostring( sender:GetAngle() ) )
		qry:Execute()

		Network:Send( sender, "SetHome" )
		print( sender:GetName() .. string.format( " set home. Coordinates: (%i, %i, %i)", sender:GetPosition().x, sender:GetPosition().y, sender:GetPosition().z ) )

		sender:SetMoney( money - self.homePrice )
	else
		Events:Fire( "CastCenterText", { target = sender, text = "Недостаточно средств. Требуется $" .. self.homePrice .. "!", time = 3, color = Color.Red } )
	end
end

function Home:GoHome( args, sender )
	if sender:GetWorld() ~= DefaultWorld then
        Events:Fire( "CastCenterText", { target = sender, text = sender:GetValue( "Lang" ) == "EN" and "Can't use it here!" or "Невозможно использовать это здесь!", time = 3, color = Color.Red } )
        return
    end

	local steamID = tostring( sender:GetSteamId().id )
	local qry = SQL:Query( "SELECT * FROM players_home WHERE steamid = ?" )
	qry:Bind( 1, steamID )
    local result = qry:Execute()

	if #result > 0 then
		local row = result[1]

		local pos = ( row.pos:split( "," ) or { 0, 0, 0 } )
		local angle = ( row.angle:split( "," ) or { 0, 0, 0 } )

		local pos_x, pos_y, pos_z = table.unpack( pos )
		local angle_x, angle_y, angle_z = table.unpack( angle )

		sender:Teleport( Vector3( tonumber( pos_x ), tonumber( pos_y ), tonumber( pos_z ) ), Angle( tonumber( angle_x ), tonumber( angle_y ), tonumber( angle_z ) ) )

		Network:SendNearby( sender, "WarpDoPoof", sender:GetPosition() )
		Network:Send( sender, "WarpDoPoof", sender:GetPosition() )

		Events:Fire( "CastCenterText", { target = sender, text = "Мам, я дома!", time = 6, color = Color.Yellow } )
	else
		Events:Fire( "CastCenterText", { target = sender, text = "У вас отсутствует дом!", time = 3, color = Color.Red } )
	end
end

function Home:SpawnInHome( args )
	local steamID = tostring( args.player:GetSteamId().id )
	local qry = SQL:Query( "SELECT * FROM players_home WHERE steamid = ?" )
	qry:Bind( 1, steamID )
    local result = qry:Execute()

	if #result > 0 then
		local row = result[1]

		local pos = ( row.pos:split( "," ) or { 0, 0, 0 } )
		local angle = ( row.angle:split( "," ) or { 0, 0, 0 } )

		local pos_x, pos_y, pos_z = table.unpack( pos )
		local angle_x, angle_y, angle_z = table.unpack( angle )

		args.player:Teleport( Vector3( tonumber( pos_x ), tonumber( pos_y ), tonumber( pos_z ) ), Angle( tonumber( angle_x ), tonumber( angle_y ), tonumber( angle_z ) ) )

		for p in Server:GetPlayers() do
			local jDist = args.player:GetPosition():Distance( p:GetPosition() )

			if jDist < 50 then
				Network:Send( p, "WarpDoPoof", Vector3( tonumber( pos_x ), tonumber( pos_y ), tonumber( pos_z ) ) )
			end
		end
	else
		Events:Fire( "PlayerSpawnFromDB", { player = args.player } )
	end
end

function Home:SetHomeTw( args, sender )
	local money = sender:GetMoney()

	if money >= self.homeTwPrice then
		local steamID = tostring(sender:GetSteamId().id)

		local qry = SQL:Query('INSERT OR REPLACE INTO players_homeTw (steamid, pos, angle) VALUES(?, ?, ?)')
		qry:Bind( 1, tostring( steamID ) )
		qry:Bind( 2, tostring( sender:GetPosition() ) )
		qry:Bind( 3, tostring( sender:GetAngle() ) )
		qry:Execute()

		Network:Send( sender, "SetHome" )
		print( sender:GetName() .. string.format( " set home 2. Coordinates: (%i, %i, %i)", sender:GetPosition().x, sender:GetPosition().y, sender:GetPosition().z ) )

		sender:SetMoney( money - self.homeTwPrice )
	else
		Events:Fire( "CastCenterText", { target = sender, text = "Недостаточно средств. Требуется $" .. self.homeTwPrice .. "!", time = 3, color = Color.Red } )
	end
end

function Home:GoHomeTw( args, sender )
	if sender:GetWorld() ~= DefaultWorld then
        Events:Fire( "CastCenterText", { target = sender, text = sender:GetValue( "Lang" ) == "EN" and "Can't use it here!" or "Невозможно использовать это здесь!", time = 3, color = Color.Red } )
        return
    end

	local steamID = tostring( sender:GetSteamId().id )
	local qry = SQL:Query( "SELECT * FROM players_homeTw WHERE steamid = ?" )
	qry:Bind( 1, steamID )
    local result = qry:Execute()

	if #result > 0 then
		local row = result[1]

		local pos = ( row.pos:split( "," ) or { 0, 0, 0 } )
		local angle = ( row.angle:split( "," ) or { 0, 0, 0 } )

		local pos_x, pos_y, pos_z = table.unpack( pos )
		local angle_x, angle_y, angle_z = table.unpack( angle )

		sender:Teleport( Vector3( tonumber( pos_x ), tonumber( pos_y ), tonumber( pos_z ) ), Angle( tonumber( angle_x ), tonumber( angle_y ), tonumber( angle_z ) ) )

		Network:SendNearby( sender, "WarpDoPoof", sender:GetPosition() )
		Network:Send( sender, "WarpDoPoof", sender:GetPosition() )

		Events:Fire( "CastCenterText", { target = sender, text = "Мам, я в дом 2!", time = 6, color = Color.Yellow } )
	else
		Events:Fire( "CastCenterText", { target = sender, text = "У вас отсутствует дом 2!", time = 3, color = Color.Red } )
	end
end

function Home:GetHome( args )
	local steamID = tostring(args.player:GetSteamId().id)
	local qry = SQL:Query("SELECT * FROM players_home WHERE steamid = ?")
	qry:Bind(1, steamID)
    local result = qry:Execute()

	if #result > 0 then
		local row = result[1]
		local pos = ( row.pos:split( "," ) or { 0, 0, 0 } )
		local x, y, z = table.unpack( pos )

		str = string.format( "%i, %i, %i", tonumber( x ), tonumber( y ), tonumber( z ) )
		args.player:SendChatMessage( "Координаты дома: ", Color.White, str, Color.DarkGray )
	end

	local qry = SQL:Query("SELECT * FROM players_homeTw WHERE steamid = ?")
	qry:Bind(1, steamID)
    local result = qry:Execute()

	if #result > 0 then
		local row = result[1]
		local pos = ( row.pos:split( "," ) or { 0, 0, 0 } )
		local x, y, z = table.unpack( pos )

		str = string.format( "%i, %i, %i", tonumber( x ), tonumber( y ), tonumber( z ) )
		args.player:SendChatMessage( "Координаты дома 2: ", Color.White, str, Color.DarkGray )
	end
end

home = Home()