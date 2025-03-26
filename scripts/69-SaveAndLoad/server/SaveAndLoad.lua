class 'SaveAndLoad'

function SaveAndLoad:__init()
	self.playerTimes = {}

	for p in Server:GetPlayers() do
		self.playerTimes[p:GetId()] = {
			joinTime = os.time(),
			totalTime = p:GetValue( "TotalTime" ) or 0
		}
	end

	self.timer = Timer()
	self.saveTimer = Timer()

	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "PostTick", self, self.PostTick )

    self.one_handed = { Weapon.Handgun, Weapon.Revolver, Weapon.SMG, Weapon.SawnOffShotgun }
    self.two_handed = { Weapon.Assault, Weapon.Shotgun, Weapon.MachineGun }

	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_models (steamid VARCHAR UNIQUE, model_id INTEGER)" )
    SQL:Execute( "CREATE TABLE IF NOT EXISTS players_weapons (steamid VARCHAR UNIQUE, two INTEGER, ammo_two_c INTEGER, ammo_two_r INTEGER, left INTEGER, ammo_left_c INTEGER, ammo_left_r INTEGER, right INTEGER, ammo_right_c INTEGER, ammo_right_r INTEGER)" )
	SQL:Execute( [[
		CREATE TABLE IF NOT EXISTS players_stats (
			steamid VARCHAR UNIQUE,
			joindate INTEGER,
			totaltime INTEGER,
			chatmessagescount INTEGER,
			killscount INTEGER,
			collectedresourceitemscount INTEGER,
			completedtaskscount INTEGER,
			completeddailytaskscount INTEGER,
			maxrecordinbestdrift INTEGER,
			maxrecordinbesttetris INTEGER,
			maxrecordinbestflight INTEGER,
			racewinscount INTEGER,
			tronwinscount INTEGER,
			kinghillwinscount INTEGER,
			derbywinscount INTEGER,
			pongwinscount INTEGER,
			victorinscorrectanswers INTEGER
		)
	]] )
end

function SaveAndLoad:PlayerJoin( args )
	self:LoadModel( args )
    self:LoadWeapons( args )
	self:LoadStats( args )
end

function SaveAndLoad:LoadModel( args )
	local steamId = args.player:GetSteamId().id

    local qry = SQL:Query( "select model_id from players_models where steamid = (?)" )
    qry:Bind( 1, steamId )
    local result = qry:Execute()

	if #result > 0 then
        args.player:SetModelId( tonumber(result[1].model_id) )
    end
end

function SaveAndLoad:LoadWeapons( args )
	local qry = SQL:Query( "SELECT two, ammo_two_c, ammo_two_r, left, ammo_left_c, ammo_left_r, right, ammo_right_c, ammo_right_r FROM players_weapons WHERE steamid = ?" )
    qry:Bind( 1, args.player:GetSteamId().id )
    local weaponResult = qry:Execute()

    if #weaponResult == 1 then
		local row = weaponResult[1]
		args.player:ClearInventory()
		if tonumber( row.two ) ~= 0 then
		    args.player:GiveWeapon( WeaponSlot.Primary, Weapon( tonumber( row.two ), tonumber( row.ammo_two_c ), tonumber( row.ammo_two_r ) ) )
		end
		if tonumber( row.left ) ~= 0 then
		    args.player:GiveWeapon( WeaponSlot.Left, Weapon( tonumber( row.left ), tonumber( row.ammo_left_c ), tonumber( row.ammo_left_r ) ) )
		end
		if tonumber( row.right ) ~= 0 then
		    args.player:GiveWeapon( WeaponSlot.Right, Weapon( tonumber( row.right ), tonumber( row.ammo_right_c ), tonumber( row.ammo_right_r ) ) )
		end
    else
		args.player:ClearInventory()

		local one_id = table.randomvalue( self.one_handed )
		local two_id = table.randomvalue( self.two_handed )

		args.player:GiveWeapon( WeaponSlot.Right, Weapon( one_id, 666, 666 ) )
		args.player:GiveWeapon( WeaponSlot.Primary, Weapon( two_id, 666, 666 ) )
	end
end

function SaveAndLoad:LoadStats( args )
	local steamId = args.player:GetSteamId().id

	local qry = SQL:Query( [[
		SELECT 
			joindate, 
			totaltime, 
			chatmessagescount, 
			killscount, 
			collectedresourceitemscount, 
			completedtaskscount, 
			completeddailytaskscount, 
			maxrecordinbestdrift, 
			maxrecordinbesttetris, 
			maxrecordinbestflight, 
			racewinscount, 
			tronwinscount, 
			kinghillwinscount, 
			derbywinscount, 
			pongwinscount, 
			victorinscorrectanswers 
		FROM players_stats 
		WHERE steamid = (?)
	]] )

    qry:Bind( 1, steamId )
    local result = qry:Execute()

	if #result > 0 then
        args.player:SetNetworkValue( "JoinDate", result[1].joindate )

		self.playerTimes[args.player:GetId()] = {
			joinTime = os.time(),
			totalTime = tonumber( result[1].totaltime )
		}

		args.player:SetNetworkValue( "ChatMessagesCount", result[1].chatmessagescount )
		args.player:SetNetworkValue( "KillsCount", result[1].killscount )
		args.player:SetNetworkValue( "CollectedResourceItemsCount", result[1].collectedresourceitemscount )
		args.player:SetNetworkValue( "CompletedTasksCount", result[1].completedtaskscount )
		args.player:SetNetworkValue( "CompletedDailyTasksCount", result[1].completeddailytaskscount )
		args.player:SetNetworkValue( "MaxRecordInBestDrift", result[1].maxrecordinbestdrift )
		args.player:SetNetworkValue( "MaxRecordInBestTetris", result[1].maxrecordinbesttetris )
		args.player:SetNetworkValue( "MaxRecordInBestFlight", result[1].maxrecordinbestflight )
		args.player:SetNetworkValue( "RaceWinsCount", result[1].racewinscount )
		args.player:SetNetworkValue( "TronWinsCount", result[1].tronwinscount )
		args.player:SetNetworkValue( "KingHillWinsCount", result[1].kinghillwinscount )
		args.player:SetNetworkValue( "DerbyWinsCount", result[1].derbywinscount )
		args.player:SetNetworkValue( "PongWinsCount", result[1].pongwinscount )
		args.player:SetNetworkValue( "VictorinsCorrectAnswers", result[1].victorinscorrectanswers )
	else
		local date = os.date( "%d/%m/%y %X" )

        local cmd = SQL:Command( "INSERT OR REPLACE INTO players_stats (steamid, joindate) values (?, ?)" )
        cmd:Bind( 1, steamId )
        cmd:Bind( 2, date )
        cmd:Execute()

		args.player:SetNetworkValue( "JoinDate", date )

		self.playerTimes[args.player:GetId()] = {
			joinTime = os.time(),
			totalTime = 0
		}
    end
end

function SaveAndLoad:PlayerQuit( args )
	self:SaveModel( args )
    self:SaveWeapons( args )
	self:SaveStats( args )
end

function SaveAndLoad:SaveModel( args )
	local steamId = args.player:GetSteamId().id

    if args.player:GetModelId() ~= 51 then
        local cmd = SQL:Command( "INSERT OR REPLACE INTO players_models (steamid, model_id) values (?, ?)" )
        cmd:Bind( 1, steamId )
        cmd:Bind( 2, args.player:GetModelId() )
        cmd:Execute()
    else
        local cmd = SQL:Command( "DELETE FROM players_models WHERE steamid = (?)" )
        cmd:Bind( 1, steamId )
        cmd:Execute()
    end
end

function SaveAndLoad:SaveWeapons( args )
	if args.player:GetWorld() ~= DefaultWorld then return end
	local inventory = args.player:GetInventory()

	local two = 0
	local left = 0
	local right = 0

	local ammo_two_c = 0
	local ammo_two_r = 0
	local ammo_left_c = 0
	local ammo_left_r = 0
	local ammo_right_c = 0
	local ammo_right_r = 0

	for slot, weapon in pairs( inventory ) do
		if slot == 2 then
			two = weapon.id
			ammo_two_c = weapon.ammo_clip
			ammo_two_r = weapon.ammo_reserve
		elseif slot == 0 then
			left = weapon.id
			ammo_left_c = weapon.ammo_clip
			ammo_left_r = weapon.ammo_reserve
		elseif slot == 1 then
			right = weapon.id
			ammo_right_c = weapon.ammo_clip
			ammo_right_r = weapon.ammo_reserve
		end
	end

	local cmd = SQL:Command( "INSERT OR REPLACE INTO players_weapons (steamid, two, ammo_two_c, ammo_two_r, left, ammo_left_c, ammo_left_r, right, ammo_right_c, ammo_right_r) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" )
    cmd:Bind( 1, args.player:GetSteamId().id )
    cmd:Bind( 2, two )
    cmd:Bind( 3, ammo_two_c )
    cmd:Bind( 4, ammo_two_r )
    cmd:Bind( 5, left )
    cmd:Bind( 6, ammo_left_c )
    cmd:Bind( 7, ammo_left_r )
    cmd:Bind( 8, right )
    cmd:Bind( 9, ammo_right_c )
    cmd:Bind( 10, ammo_right_r )
    cmd:Execute()
end

function SaveAndLoad:SaveStats( args )
	local steamId = args.player:GetSteamId().id

	local cmd = SQL:Command( [[
		UPDATE players_stats 
		SET 
			totaltime = ?, 
			chatmessagescount = ?, 
			killscount = ?, 
			collectedresourceitemscount = ?, 
			completedtaskscount = ?, 
			completeddailytaskscount = ?, 
			maxrecordinbestdrift = ?, 
			maxrecordinbesttetris = ?, 
			maxrecordinbestflight = ?, 
			racewinscount = ?, 
			tronwinscount = ?, 
			kinghillwinscount = ?, 
			derbywinscount = ?, 
			pongwinscount = ?, 
			victorinscorrectanswers = ?
		WHERE steamid = ?
	]] )

	local defaultValue = 0

	cmd:Bind( 1, args.player:GetValue( "TotalTime" ) or defaultValue )
	cmd:Bind( 2, args.player:GetValue( "ChatMessagesCount" ) or defaultValue )
	cmd:Bind( 3, args.player:GetValue( "KillsCount" ) or defaultValue )
	cmd:Bind( 4, args.player:GetValue( "CollectedResourceItemsCount" ) or defaultValue )
	cmd:Bind( 5, args.player:GetValue( "CompletedTasksCount" ) or defaultValue )
	cmd:Bind( 6, args.player:GetValue( "CompletedDailyTasksCount" ) or defaultValue )
	cmd:Bind( 7, args.player:GetValue( "MaxRecordInBestDrift" ) or defaultValue )
	cmd:Bind( 8, args.player:GetValue( "MaxRecordInBestTetris" ) or defaultValue )
	cmd:Bind( 9, args.player:GetValue( "MaxRecordInBestFlight" ) or defaultValue )
	cmd:Bind( 10, args.player:GetValue( "RaceWinsCount" ) or defaultValue )
	cmd:Bind( 11, args.player:GetValue( "TronWinsCount" ) or defaultValue )
	cmd:Bind( 12, args.player:GetValue( "KingHillWinsCount" ) or defaultValue )
	cmd:Bind( 13, args.player:GetValue( "DerbyWinsCount" ) or defaultValue )
	cmd:Bind( 14, args.player:GetValue( "PongWinsCount" ) or defaultValue )
	cmd:Bind( 15, args.player:GetValue( "VictorinsCorrectAnswers" ) or defaultValue )
	cmd:Bind( 16, steamId )
	cmd:Execute()

	local pId = args.player:GetId()

	if self.playerTimes[pId] then
        self.playerTimes[pId] = nil
    end
end

function SaveAndLoad:PostTick()
	if self.saveTimer:GetMinutes() >= 1 then
        self:CommitChanges()
        self.saveTimer:Restart()
    end

	if self.timer:GetSeconds() <= 1 then return end
	local currentTime = os.time()

    for playerId, data in pairs( self.playerTimes ) do
		local player = Player.GetById( playerId )

		if player then
			local sessionTime = currentTime - data.joinTime
			local totalTime = data.totalTime + sessionTime

			player:SetNetworkValue( "TotalTime", totalTime )
			player:SetNetworkValue( "SessionTime", sessionTime )
		end
    end

	self.timer:Restart()
end

function SaveAndLoad:CommitChanges()
    for playerId, data in pairs( self.playerTimes ) do
        local player = Player.GetById( playerId )

        if player then
            local cmd = SQL:Command( [[
                UPDATE players_stats
                SET 
                    totaltime = ?,
                    chatmessagescount = ?,
                    killscount = ?,
                    collectedresourceitemscount = ?,
                    completedtaskscount = ?,
                    completeddailytaskscount = ?,
                    maxrecordinbestdrift = ?,
                    maxrecordinbesttetris = ?,
                    maxrecordinbestflight = ?,
                    racewinscount = ?,
                    tronwinscount = ?,
                    kinghillwinscount = ?,
                    derbywinscount = ?,
                    pongwinscount = ?,
                    victorinscorrectanswers = ?
                WHERE steamid = ?
            ]] )

			local defaultValue = 0
			local totalTime = player:GetValue( "TotalTime" ) or defaultValue

            cmd:Bind( 1, totalTime )
            cmd:Bind( 2, player:GetValue( "ChatMessagesCount" ) or defaultValue )
            cmd:Bind( 3, player:GetValue( "KillsCount" ) or defaultValue )
            cmd:Bind( 4, player:GetValue( "CollectedResourceItemsCount" ) or defaultValue )
            cmd:Bind( 5, player:GetValue( "CompletedTasksCount" ) or defaultValue )
            cmd:Bind( 6, player:GetValue( "CompletedDailyTasksCount" ) or defaultValue )
            cmd:Bind( 7, player:GetValue( "MaxRecordInBestDrift" ) or defaultValue )
            cmd:Bind( 8, player:GetValue( "MaxRecordInBestTetris" ) or defaultValue )
            cmd:Bind( 9, player:GetValue( "MaxRecordInBestFlight" ) or defaultValue )
            cmd:Bind( 10, player:GetValue( "RaceWinsCount" ) or defaultValue )
            cmd:Bind( 11, player:GetValue( "TronWinsCount" ) or defaultValue )
            cmd:Bind( 12, player:GetValue( "KingHillWinsCount" ) or defaultValue )
            cmd:Bind( 13, player:GetValue( "DerbyWinsCount" ) or defaultValue )
            cmd:Bind( 14, player:GetValue( "PongWinsCount" ) or defaultValue )
            cmd:Bind( 15, player:GetValue( "VictorinsCorrectAnswers" ) or defaultValue )
            cmd:Bind( 16, player:GetSteamId().id )
            cmd:Execute()

			if totalTime >= 7200 then
				Events:Fire( "InvitationPromocodeActivated", player )
			end
        end
    end
end

saveandload = SaveAndLoad()