local Colors = { 240, 125, 120, 135, 145, 130, 140, 0, 10, 50, 80 }
local SpVehicles = { 7, 77, 7, 77, 7, 77, 7, 77, 7, 77, 7, 77, 7, 77, 7, 77, 7, 77, 56, 7, 77, 7, 77 }
local VehSpawns = { Vector3( -13005, 205, -5260 ),
				Vector3( -13322, 205, -4950 ),
				Vector3( -12954, 205, -4441 ),
				Vector3( -12781, 205, -3792 ),
				Vector3( -12559, 205, -3929 ),
				Vector3( -12713, 205, -3885 ),
				Vector3( -12449, 205, -5243 ),
				Vector3( -12060, 205, -5299 ),
				Vector3( -11634, 205, -5275 ),
				Vector3( -12041, 205, -5166 ) }
local HealSpawns = { Vector3( -12888, 203, -4737 ),
				Vector3( -12938, 203, -4761 ),
				Vector3( -12793, 215, -4939 ),
				Vector3( -13175, 203, -5103 ),
				Vector3( -12805, 203, -5205 ),
				Vector3( -12446, 203, -5242 ),
				Vector3( -12253, 203, -5206 ),
				Vector3( -12314, 203, -5369 ),
				Vector3( -12026, 203, -5348 ),
				Vector3( -12045, 202, -5410 ),
				Vector3( -12196, 203, -4861 ),
				Vector3( -12317, 203, -4755 ),
				Vector3( -12380, 203, -4289 ),
				Vector3( -12336, 203, -4253 ),
				Vector3( -12336, 203, -4253 ),
				Vector3( -12781, 202, -3797 ),
				Vector3( -13288, 203, -4180 ),
				Vector3( -13268, 203, -4452 ),
				Vector3( -13248, 203, -4661 ),
				Vector3( -13506, 203, -4764 ), }
local Vehicles   = {}
local Island = Vector3( -13456.482421875, 202.9995880127, -4755.4057617188 )

class "CarBattlesPlayer"

function CarBattlesPlayer:__init( player, CarBattles )
	self.spVehicle = 77

	self.CarBattles = CarBattles
	self.player = player
	self.start_pos = player:GetPosition()
	self.start_world = player:GetWorld()
	self.inventory = player:GetInventory()
	self.oob = false
	self.pts = 0
	self.dead = false
	self.loaded = false
end

function CarBattlesPlayer:Enter()
	self.player:SetWorld( self.CarBattles.cbworld )
	self.player:SetNetworkValue( "GameMode", "Бои на тачках" )
	self:GiveVehicle()
	Network:Send( self.player, "Enter" )
end

function CarBattlesPlayer:GiveVehicle()
	local position = table.randomvalue( VehSpawns )
	self.spVehicle = SpVehicles[math.random(#SpVehicles)]

	local vehicle = self.player:GetVehicle()
	if vehicle then
		vehicle:Remove()
	end

	self.player:SetPosition( position )
	local vArgs = {}
	vArgs.position           = position
	vArgs.angle              = Angle( 0, 0, 0 )
	vArgs.linear_velocity    = self.player:GetLinearVelocity() * 1.1
	vArgs.enabled            = true
	vArgs.model_id = self.spVehicle
	vArgs.tone1 = Color( colors, colors, 0 )
	vArgs.tone2 = Color( colors, colors, 0 )
	local v = Vehicle.Create( vArgs )
	Vehicles[ self.player:GetId() ] = v

	v:SetWorld( self.CarBattles.cbworld )
	v:SetUnoccupiedRespawnTime( nil )
	v:SetDeathRemove( true )
	self.player:EnterVehicle( v, VehicleSeat.Driver )

	self.player:ClearInventory()
	self.player:SetHealth( 1 )
	self.player:DisableCollision( CollisionGroup.Vehicle )
	Network:Send( self.player, "RespawnTimer" )
end

function CarBattlesPlayer:Leave()
	self.player:SetWorld( self.start_world )
	self.player:SetNetworkValue( "GameMode", "FREEROAM" )
	self.player:Teleport( self.start_pos, Angle() )
	self.player:SetHealth( 1 )

	self.player:ClearInventory()
	for k,v in pairs(self.inventory) do
		self.player:GiveWeapon( k, v )
	end
	Network:Send( self.player, "Exit" )
end

class 'CarBattles'

function CarBattles:__init()
	self.players = {}
	self.timer = Timer()
	self.gay = 0
	--self.MapTimer = Timer()
	self.crash = true

	self.cbworld = World.Create()
	self.cbworld:SetTime( 10 )
	self.cbworld:SetWeatherSeverity( 0 )
	colors = Colors[math.random(#Colors)]

	self.checkpoint = Checkpoint.Create( Vector3 ( -12888, 203, -4737 ) )
	self.checkpoint:SetCreateIndicator( true )
	self.checkpoint:SetCreateCheckpoint( false )
	self.checkpoint:SetDespawnOnEnter( true )
	self.checkpoint:SetActivationBox( Vector3( 10, 10, 10 ) )
	self.checkpoint:SetType( 21 )
	self.checkpoint:SetWorld( self.cbworld )

	Network:Subscribe( "GoCB", self, self.ToggleCarBattles )
	Network:Subscribe( "EnableCollision", self, self.EnableCollision )

	Events:Subscribe( "PlayerEnterCheckpoint", self, self.PlayerEnterCheckpoint )
	Events:Subscribe( "PlayerSpawn", self, self.PlayerSpawn )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Network:Subscribe( "NoVehicle", self, self.NoVehicle )
	Network:Subscribe( "Respawn", self, self.Respawn )
	Network:Subscribe( "Health", self, self.Health )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "PlayerDeath", self, self.PlayerDeath )
end

function CarBattles:UpdateScores()
	scores = {}
	for k,v in pairs(self.players) do
		table.insert(scores, { name=v.player:GetName(), pts=v.pts, it=(self.it == v.player)})
	end
	table.sort(scores, function(a, b) return a.pts > b.pts end)
	for k,v in pairs(self.players) do
		Network:Send( v.player, "CarBattlesUpdateScores", scores )
	end
end

function CarBattles:EnableCollision( args, sender )
	sender:EnableCollision( CollisionGroup.Vehicle )
end

function CarBattles:PlayerEnterCheckpoint( args )
	if ( not self:IsInCarBattles(args.player) ) then
		return true
	end
	local position = table.randomvalue( HealSpawns )
	local pId = args.player:GetId()

	if args.player:GetVehicle() and Vehicles[ pId ] then
		Vehicles[ pId ]:SetHealth( Vehicles[ pId ]:GetHealth() + 0.2 )
		Network:Send( args.player, "HealSound" )
		self.checkpoint:SetPosition( position )
		self.checkpoint:Respawn()
	end
end

function CarBattles:IsInCarBattles( player )
	return self.players[player:GetId()] ~= nil
end

function CarBattles:NoVehicle( args, sender )
	local pId = sender:GetId()

	if IsValid( Vehicles[ pId ] ) then
		Vehicles[ pId ]:SetHealth( 0 )
	end
	sender:SetHealth( 0 )
end

function CarBattles:Respawn( args, sender )
	local vehicle = sender:GetVehicle()

	if vehicle then
		local getangle = vehicle:GetAngle()
		local ang = Angle( getangle.yaw, 0, 0 )
		vehicle:SetAngle( ang )
	end
end

function CarBattles:Health( args, sender )
	local vehicle = sender:GetVehicle()

	if vehicle then
		sender:SetHealth( vehicle:GetHealth() )
	end
end

function CarBattles:PlayerQuit( args )
	local pId = args.player:GetId()

	self.players[pId] = nil
	self:UpdateScores()

	if IsValid( Vehicles[ pId ] ) then
		Vehicles[ pId ]:Remove()
		Vehicles[ pId ] = nil
	end
end

function CarBattles:ModuleUnload()
	self.checkpoint:Respawn()
	for k,v in pairs(self.players) do
		v:Leave()
		self:MessagePlayer( v.player, "Вы были перенесены на FREEROAM." )
	end
	self.players = {}
	for k, v in pairs(Vehicles) do
		if IsValid( v ) then
			v:Remove()
		end
	end
end

function CarBattles:PostTick()
--	if self.MapTimer then
--		for p in self.cbworld:GetPlayers() do
--			secondsLeft = 120 - self.MapTimer:GetSeconds() - 1
--
--			local minutes = math.floor( secondsLeft / 60 )
--			local seconds = secondsLeft % 60
--
--			local timeDisplay = string.format( "%02d:%02d", minutes, seconds )
--
--			Network:Send( p, "GetTime", { MapTime = timeDisplay } )
--		end
--		if self.MapTimer:GetSeconds() >= 5 then
--			self.MapTimer = nil
--			for p in self.cbworld:GetPlayers() do
--				Network:Send( p, "MapFinished" )
--			end
--		end
--	end

	if self.timer:GetSeconds() <= 2 then return end

	self.timer:Restart()

	for p in self.cbworld:GetPlayers() do
		local lp_pos = p:GetPosition()
		local dist = lp_pos:DistanceSqr( Island )

		if dist > 3700000 then
			local vehicle = p:GetVehicle()
			if vehicle then
				vehicle:SetHealth( 0.1 )
				if self.crash then
					Network:Send( p, "Sound" )
					self.crash = false
				end
			end
		end
	end
end

function CarBattles:MessagePlayer( player, message )
	player:SendChatMessage( "[Бои на тачках] ", Color.White, message, Color( 228, 142, 56 ) )
end

function CarBattles:ToggleCarBattles( args, sender )
	if ( not self:IsInCarBattles(sender) ) then
		self:EnterCarBattles( args, sender )
	else
		self:LeaveCarBattles( args, sender )
	end
end

function CarBattles:EnterCarBattles( args, sender )
	if sender:GetWorld() ~= DefaultWorld then
		self:MessagePlayer( sender, "Перед присоединением вы должны выйти из всех других игровых режимов." )
		return
	end
	local p = CarBattlesPlayer(sender, self)
	p:Enter()
	self:MessagePlayer( sender, "Вы вошли в Бои на тачках. Приятной игры :)" ) 

	self.players[sender:GetId()] = p
	self:UpdateScores()
end

function CarBattles:LeaveCarBattles( args, sender )
	local pId = sender:GetId()
	local p = self.players[pId]

	if not p then return end
	p:Leave()

	self:MessagePlayer( sender, "Вы покинули Бои на тачках. Возвращайтесь ещё :)" )
	sender:EnableCollision( CollisionGroup.Vehicle )
	self.players[pId] = nil
	self:UpdateScores()
	if IsValid( Vehicles[ pId ] ) then
		Vehicles[ pId ]:Remove()
		Vehicles[ pId ] = nil
	end
end

function CarBattles:PlayerSpawn( args )
	if ( not self:IsInCarBattles(args.player) ) then
		return true
	end
	local pId = args.player:GetId()

	if IsValid( Vehicles[ pId ] ) then
		Vehicles[ pId ]:Remove()
		Vehicles[ pId ] = nil
	end
	local position = table.randomvalue( VehSpawns )

	self.players[pId]:GiveVehicle()
	return false
end

function CarBattles:PlayerDeath( args )
	if ( not self:IsInCarBattles(args.player) ) then
		return true
	end
	if args.killer and args.killer:GetSteamId() ~= args.player:GetSteamId() then
		args.killer:SetMoney( args.killer:GetMoney() + 30 )

		local vehicle = args.player:GetVehicle()

		if vehicle and vehicle:GetModelId() == 56 then
			self.players[args.killer:GetId()].pts = self.players[args.killer:GetId()].pts + 3
		else
			self.players[args.killer:GetId()].pts = self.players[args.killer:GetId()].pts + 1
		end
		Network:Send( args.killer, "CarBattlesUpdatePoints", self.players[args.killer:GetId()].pts )
		self:UpdateScores()
	end
end

carbattles = CarBattles()