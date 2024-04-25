class "ManhuntPlayer"

function ManhuntPlayer:__init( player, Manhunt )
	self.Manhunt = Manhunt
	self.player = player
	self.start_pos = player:GetPosition()
	self.start_world = player:GetWorld()
	self.inventory = player:GetInventory()
	self.color = player:GetColor()
	self.oob = false
	self.pts = 0
	self.dead = false
	self.loaded = false
end

function ManhuntPlayer:Enter()
	self.player:SetWorld( self.Manhunt.world )
	self.player:SetNetworkValue( "GameMode", "Охота" )
	self:Spawn()
	Network:Send( self.player, "ManhuntEnter" )
end

function ManhuntPlayer:Spawn()
	if self.player:GetHealth() <= 0.1 then return end

	local spawn = self.Manhunt.spawns[ math.random(1, #self.Manhunt.spawns) ]
	self.player:Teleport( spawn, Angle() )
	self.player:ClearInventory()
	if self.Manhunt.it == self.player then
		self.player:SetColor( Color( 255, 170, 0 ) )
		self.player:GiveWeapon( 0, Weapon(Weapon.Revolver) )
		self.player:GiveWeapon( 1, Weapon(Weapon.SMG) )
		self.player:GiveWeapon( 2, Weapon(Weapon.MachineGun) )
	else
		self.player:GiveWeapon( 0, Weapon(Weapon.Revolver) )
		self.player:GiveWeapon( 1, Weapon(Weapon.Sniper) )
		self.player:GiveWeapon( 2, Weapon(Weapon.MachineGun) )
		self.player:SetColor( Color.White )
	end
	self.player:SetHealth( 1 )
	self.dead = false
end

function ManhuntPlayer:Leave()
	self.player:SetWorld( self.start_world )
	self.player:Teleport( self.start_pos, Angle() )
	self.player:SetHealth( 1 )

	self.player:ClearInventory()
	self.player:SetNetworkValue( "GameMode", "FREEROAM" )
	for k,v in pairs(self.inventory) do
		self.player:GiveWeapon( k, v )
	end
	self.player:SetColor( self.color )
	Network:Send( self.player, "ManhuntExit" )
end

class "Manhunt"

function table.find(l, f)
	for _, v in ipairs(l) do
		if v == f then
			return _
		end
	end
	return nil
end

function Manhunt:CreateSpawns()
	local dist = self.maxDist - 128

	for j=0,8,1 do
		for i=0,360,1 do        
			local x = self.center.x + (math.sin( 2 * i * math.pi/360 ) * dist * math.random())
			local y = self.center.y 
			local z = self.center.z + (math.cos( 2 * i * math.pi/360 ) * dist * math.random())

			local radians = math.rad(360 - i)

			angle = Angle.AngleAxis(radians , Vector3(0 , -1 , 0))
			table.insert(self.spawns, Vector3( x, y, z ))
		end
	end
end

function Manhunt:UpdateScores()
	scores = {}
	for k,v in pairs(self.players) do
		table.insert(scores, { name=v.player:GetName(), pts=v.pts, it=(self.it == v.player)})
	end
	table.sort(scores, function(a, b) return a.pts > b.pts end)
	for k,v in pairs(self.players) do
		Network:Send( v.player, "ManhuntUpdateScores", scores )
	end
end

function Manhunt:SetIt( v )
	if self.it ~= nil then Network:Send( self.it, "ManhuntUpdateIt", false ) end
	self.it = v.player
	self.oldIt = v.player
	self:MessagePlayers( "За голову " .. self.it:GetName() .. " назначена награда!" )
	Network:Send( self.it, "ManhuntUpdateIt", true )
	v:Spawn()
	self:UpdateScores()
end

function Manhunt:__init( spawn, maxDist )
	self.world = World.Create()
	self.world:SetTimeStep( 2 )
	self.world:SetTime( 0 )

	self.spawns = {}
	self.center = spawn
	self.maxDist = maxDist

	self:CreateSpawns()

	self.players = {}
	self.last_wp = 0

	Network:Subscribe( "GoHunt", self, self.ToggleManhunt )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )

	Events:Subscribe( "PlayerJoin", self, self.PlayerJoined )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )

	Events:Subscribe( "PlayerDeath", self, self.PlayerDeath )
	Events:Subscribe( "PlayerSpawn", self, self.PlayerSpawn )
	Events:Subscribe( "PostTick", self, self.PostTick )

	Events:Subscribe( "JoinGamemode", self, self.JoinGamemode )
	local vArgs = {}
	vArgs.position = Vector3( -13814.696289063, 357.95449829102, -13214.424804688 )
	vArgs.angle = Angle( -2, -0, 0 )
	vArgs.enabled = true
	vArgs.model_id = 46
	vArgs.template = "CombiMG"
	local v = Vehicle.Create( vArgs )

	v:SetWorld( self.world )
	v:SetUnoccupiedRespawnTime( 300 )
	v:SetDeathRespawnTime( 30 )
end

function Manhunt:ModuleUnload()
	for k,v in pairs(self.players) do
		v:Leave()
		self:MessagePlayer( v.player, "Вы были перенесены на FREEROAM." )
	end
	self.players = {}
end

function Manhunt:PostTick()
	for k,v in pairs(self.players) do
		local randIt = math.random() < 1 / table.count(self.players)
		if self.it then
		elseif (randIt and self.oldIt and self.oldIt ~= player) or #self.players > 1 then
			self:SetIt( v )
		end
		local dist = Vector3.Distance(v.player:GetPosition(), self.center)
		if v.loaded then
			if v.oob and dist < self.maxDist - 32 then
				Network:Send( v.player, "ManhuntExitBorder" )
				v.oob = false
			end
			if not v.oob and dist > self.maxDist - 32 then
				Network:Send( v.player, "ManhuntEnterBorder" )
				v.oob = true
			end
			if not v.dead and dist > self.maxDist then
				v.player:SetHealth(0)
				v.dead = true
				v.loaded = false
				self:MessagePlayer ( v.player, "Вы покинули игровое поле!" )
			end
		else
			if Vector3.Distance(v.player:GetPosition(), self.center) < self.maxDist then v.loaded = true end
		end
	end
end

function Manhunt:IsInManhunt( player )
	return self.players[player:GetId()] ~= nil
end

function Manhunt:MessagePlayer( player, message )
	player:SendChatMessage( "[Охота] ", Color.White, message, Color( 228, 142, 56 ) )
end

function Manhunt:MessagePlayers( message )
	for k,v in pairs(self.players) do
		self:MessagePlayer(v.player, message)
	end
end

function Manhunt:ToggleManhunt( args, sender )
	if ( not self:IsInManhunt(sender) ) then
		self:EnterManhunt( args, sender )
	else
		self:LeaveManhunt( args, sender )
	end
end

function Manhunt:EnterManhunt( args, sender )
	if sender:GetWorld() ~= DefaultWorld then
		self:MessagePlayer( sender, "Перед присоединением вы должны выйти из всех других игровых режимов." )
		return
	end

	local args = {}
	args.name = "Manhunt"
	args.player = sender
	Events:Fire( "JoinGamemode", args )

	local p = ManhuntPlayer(sender, self)
	p:Enter()

	self:MessagePlayer( sender, "Вы вошли на Охоту. Приятной игры :)" ) 
	self:MessagePlayer( sender, "Ваша задача выживать и убивать остальных игроков." ) 

	if self.oldIt and self.it then
		self:MessagePlayer( sender, "За голову " .. self.it:GetName() .. " сейчас назначена награда!" ) 
	else
		self:SetIt( p )
	end

	self.players[sender:GetId()] = p
	Network:Send( sender, "ManhuntUpdateIt", self.it == sender )
	self:UpdateScores()
end

function Manhunt:LeaveManhunt( args, sender )
	local pId = sender:GetId()
	local p = self.players[pId]

	if p == nil then return end
	p:Leave()

	self:MessagePlayer( sender, "Вы покинули Охоту. Возвращайтесь ещё :)" )    
	self.players[pId] = nil
	if self.it == sender then self.it = nil end
	self:UpdateScores()
end

function Manhunt:PlayerJoined( args )
	self.players[args.player:GetId()] = nil
	if self.it == args.player then self.it = nil end
	self:UpdateScores()
end

function Manhunt:PlayerQuit( args )
	self.players[args.player:GetId()] = nil
	if self.it == args.player then self.it = nil end
	self:UpdateScores()
end

function Manhunt:PlayerDeath( args )
	if ( not self:IsInManhunt(args.player) ) then
		return true
	end

	if self.it == args.player then
		if args.killer then
			args.killer:SetColor( Color( 255, 170, 0 ) )
			self.it = args.killer
			self.oldIt = args.killer
			self.players[self.it:GetId()].pts = self.players[self.it:GetId()].pts + 3
			Network:Send( self.it, "ManhuntUpdatePoints", self.players[self.it:GetId()].pts )
			self:MessagePlayers( args.killer:GetName().." убил "..args.player:GetName().." и теперь за его голову назначена награда!" )
			args.killer:SetMoney( args.killer:GetMoney() + 60 )
		else
			self.it = nil
			if args.reason == DamageEntity.None then
				self:MessagePlayers( args.player:GetName().." погиб!" )
			elseif args.reason == DamageEntity.Physics then
				self:MessagePlayers( args.player:GetName().." был раздавлен!" )
			elseif args.reason == DamageEntity.Bullet then
				self:MessagePlayers( args.player:GetName().." помер!")
			elseif args.reason == DamageEntity.Explosion then
				self:MessagePlayers( args.player:GetName().." умер!" )
			elseif args.reason == DamageEntity.Vehicle then
				self:MessagePlayers( args.player:GetName().." был сбит!" )
			end
		end
		self:UpdateScores()
	elseif args.killer and args.killer:GetSteamId() ~= args.player:GetSteamId() then
		self.players[args.killer:GetId()].pts = self.players[args.killer:GetId()].pts + 1
		Network:Send( args.killer, "ManhuntUpdatePoints", self.players[args.killer:GetId()].pts )
		self:UpdateScores()
		args.player:SetColor( Color.White )
		args.killer:SetMoney( args.killer:GetMoney() + 30 )
	end

	if args.killer then
		if args.killer:GetValue( "HuntKills" ) then
			args.killer:SetNetworkValue( "HuntKills", args.killer:GetValue( "HuntKills" ) + 1 )
		end
	end
end

function Manhunt:PlayerSpawn( args )
	if ( not self:IsInManhunt(args.player) ) then
		return true
	end

	self.players[args.player:GetId()]:Spawn()
	return false
end

function Manhunt:JoinGamemode( args )
	if args.name ~= "Manhunt" then
		self:LeaveManhunt( args.player )
	end
end

Manhunt = Manhunt( Vector3(-13790, 1200, -13625), 2048 )