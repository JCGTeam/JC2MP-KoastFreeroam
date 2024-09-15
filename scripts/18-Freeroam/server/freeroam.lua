class 'Freeroam'

function Freeroam:__init()
    self.weaponsBlackList = { [66] = true, [116] = true }

    SQL:Execute( "CREATE TABLE IF NOT EXISTS players_lastpos (steamid VARCHAR UNIQUE, pos VARCHAR, angle VARCHAR)" )
    SQL:Execute( "CREATE TABLE IF NOT EXISTS players_spawinhome (steamid VARCHAR UNIQUE, home INTEGER)" )
    SQL:Execute( "CREATE TABLE IF NOT EXISTS players_kills (steamid VARCHAR UNIQUE, kills INTEGER)")

    self.vehicles               = {}
    self.player_spawns          = {}
    self.teleports              = {}
    self.custom_teleports       = {}
    self.kills                  = {}

    self.one_handed = { Weapon.Handgun, Weapon.Revolver, Weapon.SMG, Weapon.SawnOffShotgun }
    self.two_handed = { Weapon.Assault, Weapon.Shotgun, Weapon.Sniper, Weapon.MachineGun }

    self:LoadSpawns( "spawns.txt" )

    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
    Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
    Events:Subscribe( "PlayerChat", self, self.PlayerChat )
    Events:Subscribe( "PlayerDeath", self, self.PlayerDeath )
	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "PlayerSpawn", self, self.PlayerSpawn )
    Events:Subscribe( "PlayerSpawnFromDB", self, self.PlayerSpawnFromDB )
    Events:Subscribe( "ToggleSpawnInHome", self, self.ToggleSpawnInHome )
    Events:Subscribe( "AddCustomTeleport", self, self.AddCustomTeleport )
    Events:Subscribe( "ClearCustomTeleports", self, self.ClearCustomTeleports )

	Network:Subscribe( "GiveMeWeapon", self, self.GiveMeWeapon )
    Network:Subscribe( "SetSpawnMode", self, self.SetSpawnMode )
    Network:Subscribe( "TogglePassiveAfterSpawn", self, self.TogglePassiveAfterSpawn )
end

function Freeroam:LoadSpawns( filename )
    print("Opening " .. filename)
    local file = io.open( filename, "r" )

    if file == nil then
        print( "No spawns.txt, aborting loading of spawns" )
        return
    end

    local timer = Timer()

    for line in file:lines() do
        if line:sub(1,1) == "V" then
            self:ParseVehicleSpawn( line )
        elseif line:sub(1,1) == "P" then
            self:ParsePlayerSpawn( line )
        elseif line:sub(1,1) == "T" then
            self:ParseTeleport( line )
        end
    end

    print( string.format( "Loaded spawns, %.02f seconds", timer:GetSeconds() ) )

    timer = nil
    file:close()
end

function Freeroam:ParseVehicleSpawn( line )
    line = line:gsub( "VehicleSpawn%(", "" )
    line = line:gsub( "%)", "" )
    line = line:gsub( " ", "" )

    local tokens = line:split( "," )   

    local model_id_str  = tokens[1]

    local pos_str = { tokens[2], tokens[3], tokens[4] }
    local ang_str = { tokens[5], tokens[6], tokens[7], tokens[8] }

    local args = {}

    args.model_id = tonumber( model_id_str )
    args.position = Vector3( tonumber( pos_str[1] ), tonumber( pos_str[2] ), tonumber( pos_str[3] ) )
    args.angle = Angle( tonumber( ang_str[1] ), tonumber( ang_str[2] ), tonumber( ang_str[3] ), tonumber( ang_str[4] ) )

    if #tokens > 8 then
        if tokens[9] ~= "NULL" then
            -- If there's a template, set it
            args.template = tokens[9]
        end

        if #tokens > 9 then
            if tokens[10] ~= "NULL" then
                -- If there's a decal, set it
                args.decal = tokens[10]
            end
        end
    end

    args.enabled = true
    local v = Vehicle.Create( args )

    self.vehicles[ v:GetId() ] = v
end

function Freeroam:ParsePlayerSpawn( line )
    line = line:gsub( "P", "" )
    line = line:gsub( " ", "" )

    -- Split into tokens
    local tokens        = line:split( "," )
    -- Create table containing appropriate strings
    local pos_str       = { tokens[1], tokens[2], tokens[3] }
    -- Create vector
    local vector        = Vector3( tonumber( pos_str[1] ), tonumber( pos_str[2] ), tonumber( pos_str[3] ) )

    table.insert( self.player_spawns, vector )
end

function Freeroam:ParseTeleport( line )
    -- Remove start, spaces
    line = line:sub( 3 )
    line = line:gsub( " ", "" )

    -- Split into tokens
    local tokens        = line:split( "," )
    -- Create table containing appropriate strings
    local pos_str       = { tokens[2], tokens[3], tokens[4] }
    -- Create vector
    local vector        = Vector3( tonumber( pos_str[1] ), tonumber( pos_str[2] ), tonumber( pos_str[3] ) )

    self.teleports[ tokens[1] ] = vector
end

function Freeroam:AddCustomTeleport( args )
    self.teleports[ args.name ] = Vector3( args.pos.x, args.pos.y, args.pos.z )
    table.insert( self.custom_teleports, args.name )

    print( "Added custom teleport. Name: " .. tostring( args.name ) .. ", Pos: " .. tostring( args.pos ) )
end

function Freeroam:ClearCustomTeleports()
    for _, name in ipairs( self.custom_teleports ) do
        self.teleports[name] = nil
    end

    self.custom_teleports = {}

    print( "Removed all custom teleports" )
end

function Freeroam:GiveNewWeapons( p )
    p:ClearInventory()

    local one_id = table.randomvalue( self.one_handed )
    local two_id = table.randomvalue( self.two_handed )

    p:GiveWeapon( WeaponSlot.Right, Weapon( one_id, 666, 666 ) )
    p:GiveWeapon( WeaponSlot.Primary, Weapon( two_id, 666, 666 ) )
end

function Freeroam:RandomizePosition( pos, magnitude, offset )
    if magnitude == nil then
        magnitude = 10
    end

    if offset == nil then
        offset = 250
    end

    return pos + Vector3( math.random( -magnitude, magnitude ), math.random( -magnitude, 0 ) + offset, math.random( -magnitude, magnitude ) )
end

ChatHandlers = {}

function ChatHandlers:teleport( args )
    local dest = args[1]

    -- Handle user help
    if dest == "" or dest == nil or dest == "help" then
        args.player:SendChatMessage( "Места для телепортации: ", Color( 0, 255, 0 ) )

        local i = 0
        local str = ""

        for k,v in pairs(self.teleports) do
            -- Send message every 4 teleports
            i = i + 1
            str = str .. k

            if i % 4 ~= 0 then
                -- If it's not the last teleport of the line, add a comma
                str = str .. ", "
            else
                args.player:SendChatMessage( "    " .. str, Color( 255, 255, 255 ) )
                str = ""
            end
        end
    elseif self.teleports[dest] ~= nil then
        if args.player:GetWorld() ~= DefaultWorld then
            args.player:SendChatMessage( "Вы не в главном мире! Выйдите из любых режимов и повторите попытку.", Color( 255, 0, 0 ) )
            return
        end

        -- If the teleport is valid, teleport them there
        args.player:SetPosition( self:RandomizePosition( self.teleports[dest] ) )
    else
        args.player:SendChatMessage( "Недопустимый пункт телепортации!", Color( 255, 0, 0 ) )
    end
end

ChatHandlers.tp = ChatHandlers.teleport

function Freeroam:ModuleUnload()
    for k,v in pairs(self.vehicles) do
        if IsValid(v) then
            v:Remove()
        end
    end
end

function Freeroam:ModulesLoad()
    for _, v in ipairs(self.player_spawns) do
        Events:Fire( "SpawnPoint", v )
    end

    for _, v in pairs(self.teleports) do
        Events:Fire( "TeleportPoint", v )
    end
end

function Freeroam:SetSpawnMode( args )
    sender:SetValue( "SpawnMode", args.type )
end

function Freeroam:ToggleSpawnInHome( args )
    local steamID = tostring( args.player:GetSteamId().id )

    if args.player:GetValue( "SpawnInHome" ) then
        args.player:SetNetworkValue( "SpawnInHome", nil )

        local cmd = SQL:Command( "DELETE FROM players_spawinhome WHERE steamid = (?)" )
        cmd:Bind( 1, steamID )
        cmd:Execute()
    else
        args.player:SetNetworkValue( "SpawnInHome", 1 )

        local cmd = SQL:Command( "INSERT OR REPLACE INTO players_spawinhome (steamid, home) values (?, ?)" )
        cmd:Bind( 1, steamID )
        cmd:Bind( 2, args.player:GetValue( "SpawnInHome" ) )
        cmd:Execute()
    end
end

function Freeroam:PlayerSpawn( args )
    local default_spawn = true

	if args.player:GetWorld() == DefaultWorld then
        local spawnMode = args.player:GetValue( "SpawnMode" )

        if spawnMode then
            if spawnMode == 0 then
                Network:Send( args.player, "EnableAutoPassive" )
            elseif spawnMode == 1 then
                if args.player:GetValue( "SpawnInHome" ) then
                    self:PlayerSpawnFromHomeDB( args )
                else
                    self:PlayerSpawnFromDB( args )
                end
            elseif spawnMode == 2 then
                self:PlayerRandomSpawn( args )
            end

            args.player:SetValue( "SpawnMode", 0 )
            default_spawn = false
        else
            default_spawn = true
        end
	end

    return default_spawn
end

function Freeroam:PlayerSpawnFromDB( args )
    if #self.player_spawns > 0 then
        local steamID = tostring( args.player:GetSteamId().id )
        local qry = SQL:Query( "SELECT * FROM players_lastpos WHERE steamid = ?" )
        qry:Bind( 1, steamID )
        local result = qry:Execute()

        if #result > 0 then
            local row = result[1]

            local pos = ( row.pos:split( "," ) or { 0, 0, 0 } )
            local angle = ( row.angle:split( "," ) or { 0, 0, 0 } )
    
            local pos_x, pos_y, pos_z = table.unpack( pos )
            local angle_x, angle_y, angle_z = table.unpack( angle )
    
            args.player:Teleport( Vector3( tonumber( pos_x ), tonumber( pos_y ) + 250, tonumber( pos_z ) ), Angle( tonumber( angle_x ), tonumber( angle_y ), tonumber( angle_z ) ) )
        else
            self:PlayerRandomSpawn( args )
        end
    end
end

function Freeroam:PlayerRandomSpawn( args )
    local position = table.randomvalue( self.player_spawns )
    args.player:SetPosition( self:RandomizePosition( position ) )
end

function Freeroam:PlayerSpawnFromHomeDB( args )
    Events:Fire( "SpawnInHome", { player = args.player } )
end

function Freeroam:TogglePassiveAfterSpawn( args, sender )
    sender:SetNetworkValue( "Passive", args.enabled )
    local vehicle = sender:GetVehicle()
    if IsValid(vehicle) and vehicle:GetDriver() == sender then
        vehicle:SetInvulnerable( false )
	end
end

function Freeroam:PlayerJoin( args )
    local steamID = tostring( args.player:GetSteamId().id )
    local qry = SQL:Query( "select home from players_spawinhome where steamid = (?)" )
    qry:Bind( 1, steamID )
    local result = qry:Execute()

    if #result > 0 then
        args.player:SetNetworkValue( "SpawnInHome", tonumber( result[1].home ) )
    end

    args.player:SetValue( "SpawnMode", 1 )

    self:PlayerSpawn( args )

    local qry = SQL:Query( "select kills from players_kills where steamid = (?)" )
    qry:Bind( 1, steamID )
    local result = qry:Execute()

	if #result > 0 then
        args.player:SetNetworkValue( "Kills", tonumber( result[1].kills ) )
    else
        args.player:SetNetworkValue( "Kills", 0 )
    end
end

function Freeroam:GiveMeWeapon( args, sender )
	self:GiveNewWeapons( sender )
end

function Freeroam:PlayerQuit( args )
    local steamID = tostring(args.player:GetSteamId().id)

    if not args.player:GetValue( "SavePos" ) then
        local qry = SQL:Query( "INSERT OR REPLACE INTO players_lastpos (steamid, pos, angle) VALUES(?, ?, ?)" )
        qry:Bind( 1, steamID )
        qry:Bind( 2, tostring( args.player:GetPosition() ) )
        qry:Bind( 3, tostring( args.player:GetAngle() ) )
        qry:Execute()
    else
        local qry = SQL:Command( "DELETE FROM players_lastpos WHERE steamid = (?)" )
        qry:Bind( 1, steamID )
        qry:Execute()
    end

    self.kills[ args.player:GetId() ] = nil

    if args.player:GetValue( "Kills" ) then
        local cmd = SQL:Command( "INSERT OR REPLACE INTO players_kills (steamid, kills) values (?, ?)" )
        cmd:Bind( 1, steamID )
        cmd:Bind( 2, args.player:GetValue( "Kills" ) )
        cmd:Execute()
    end
end

function Freeroam:PlayerChat( args )
    local msg = args.text

    if msg:sub(1, 1) ~= "/" then
        return true
    end

    msg = msg:sub(2)

    local cmd_args = msg:split(" ")
    local cmd_name = cmd_args[1]

    table.remove( cmd_args, 1 )
    cmd_args.player = args.player

    local func = ChatHandlers[string.lower(cmd_name)]
    if func ~= nil then
        -- If it's valid, call it
        func( self, cmd_args )
    end

    return false
end

function Freeroam:PlayerDeath( args )
    if args.player:GetWorld() ~= DefaultWorld then return end

    if args.killer and args.killer:GetSteamId() ~= args.player:GetSteamId() then
        if args.killer:GetValue( "Passive" ) then
			args.killer:SetHealth( 0 )
		else
            local player_kills = args.player:GetValue( "Kills" )
            local killer_kills = args.killer:GetValue( "Kills" )

            if killer_kills then
                if killer_kills < 1000 then
                    self.kills[ args.killer:GetId() ] = killer_kills + 1
                    args.killer:SetNetworkValue( "Kills", self.kills[ args.killer:GetId() ] )
                end

                local noreward_txt = "Без награды :c, используйте обычное оружие!"

                if player_kills == 0 then
                    if self.weaponsBlackList[args.killer:GetEquippedWeapon().id] == true and not args.killer:InVehicle() then
                        Network:Send( args.killer, "KillerStats", { text = noreward_txt } )
                    end
                elseif player_kills >= 0 then
                    if self.weaponsBlackList[args.killer:GetEquippedWeapon().id] == true and not args.killer:InVehicle() then
                        Network:Send( args.killer, "KillerStats", { text = noreward_txt } )
                    else
                        args.killer:SetMoney( args.killer:GetMoney() + player_kills * 10 )
                        args.player:SetValue( "Kills", 0 )
                    end
                end
            end
        end

        args.player:SetValue( "SpawnMode", 2 )
	else
        args.player:SetValue( "SpawnMode", 0 )
    end
end

freeroam = Freeroam()