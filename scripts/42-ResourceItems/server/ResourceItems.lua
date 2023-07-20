class "ResourceItems"

function ResourceItems:__init()
	self.resptime = 30

	self.timer = Timer()

	Events:Subscribe( "PlayerEnterCheckpoint", self, self.PlayerEnterCheckpoint )
	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )

	Network:Subscribe( "SyncReq", self, self.SyncPlayerData )

	self:CreateCrates()
end

function ResourceItems:CreateCrates()
	self.ents = {}
	self.poss = {}

	local count = 0
	local file = io.open( "lootspawns.txt", "r" )

	if file then
		local args = {}
		args.world = DefaultWorld

		for line in file:lines() do
			line = line:trim()

			if string.len(line) > 0 then
				line = line:gsub( "LootSpawn%(", "" )
				line = line:gsub( "%)", "" )
				line = line:gsub( " ", "" )

				local tokens = line:split( "," )
				local mdl_str = tokens[1]
				local model = tostring( mdl_str )

				if model == "pickup.boost.cash.eez/pu05-a.lod" then
					local pos_str = { tokens[3], tokens[4], tokens[5] }
					local pos = Vector3( tonumber( pos_str[1] ), tonumber( pos_str[2] ), tonumber( pos_str[3] ) )
					local ang_str = { tokens[6], tokens[7], tokens[8] }
					local col_str = tokens[2]

					if pos:Distance2D( Vector3 ( -6568, 208, -3442 ) ) > 650 and pos:Distance2D( Vector3( 13199, 1094, -4928 ) ) > 250 and pos:Distance2D( Vector3( 2150, 711, 1397 ) ) > 300 and pos:Distance2D( Vector3( -1573, 358, 990 ) ) > 750 and pos:Distance2D( Vector3( 13753, 270, -2373 ) ) > 900 and pos:Distance2D( Vector3( -13603, 422, -13746 ) ) > 900 then
						args.position = Vector3( tonumber( pos_str[1] ), tonumber( pos_str[2] ), tonumber( pos_str[3] ) )
						args.angle = Angle( tonumber( ang_str[1] ), tonumber( ang_str[2] ), tonumber( ang_str[3] ) )
						args.model = model
						args.collision = col_str
						args.world = DefaultWorld

						local ent = StaticObject.Create( args )
						ent:SetStreamDistance( 200 )
						ent:SetNetworkValue( "Cash", true )

						local checkpoint = Checkpoint.Create( ent:GetPosition() )
						checkpoint:SetWorld( DefaultWorld )
						checkpoint:SetCreateIndicator( false )
						checkpoint:SetCreateCheckpoint( false )
						checkpoint:SetType( 12 )
						checkpoint:SetCreateTrigger( true )
						checkpoint:SetDespawnOnEnter( false )
						checkpoint:SetStreamDistance( 25 )
						checkpoint:SetActivationBox( Vector3.One )

						local objid = ent:GetId()
						local mult = math.random( 0, 4 )
						local cash = 5
						if mult == 0 then cash = 25
						elseif mult == 1 then cash = 25
						elseif mult == 2 then cash = 25
						elseif mult == 3 then cash = 25
						elseif mult == 4 then cash = 50 end

						table.insert( self.ents, { ent = ent, cash = cash, checkpoint = checkpoint } )
						table.insert( self.poss, { pos = pos, id = ent:GetId() } )

						count = count + 1
					end
				end
			end
		end

		file:close()
		print( "Loaded " .. count .. " crates." )
	else
		print( "Error: Could not load loot from file" )
	end
end

function ResourceItems:PlayerEnterCheckpoint( args )
	if args.player:GetWorld() ~= DefaultWorld then return end
	for _, ent2 in pairs( self.ents ) do
		if ent2 and ent2.checkpoint then
			if IsValid( ent2.checkpoint ) then
				if ent2.checkpoint:GetId() == args.checkpoint:GetId() then
					args.player:SetMoney( args.player:GetMoney() + 10 )

					for p in Server:GetPlayers() do
						Network:Send( p, "SyncTriggersRemove", { id = ent2.ent:GetId() } )
					end

					local count = 0
					Network:Send( args.player, "CrateTaken", count )

					ent2.ent:Remove()
					ent2.checkpoint:Remove()
					ent2 = nil
					break
				end
			end
		end
	end
end

function ResourceItems:PostTick()
	if self.timer:GetHours() >= self.resptime then
		local count = 0
		for _, ent2 in pairs( self.ents ) do
			if not IsValid( ent2.ent ) then
				count = count + 1
				if count >= 1 then
					print( "All crates has been respawned." )
					self:ModuleUnload()
					self:CreateCrates()
					break
				end
			end
		end
		self.timer:Restart()
	end
end

function ResourceItems:onSyncRequest( source )
	self:SyncPlayerData( source )
end

function ResourceItems:SyncPlayerData( player )
	self.poss = {}

	for _,ent2 in pairs( self.ents ) do
		if IsValid( ent2.ent ) then
			table.insert( self.poss, { pos = ent2.ent:GetPosition(), id = ent2.ent:GetId() } )
		end
	end

	if player then
		Network:Send( player, "SyncTriggers", self.poss )
	end
end

function ResourceItems:ModuleUnload()
	for _, ent2 in pairs( self.ents ) do
		if IsValid( ent2.ent ) then
			ent2.ent:Remove()
		end

		if IsValid( ent2.checkpoint ) then
			ent2.checkpoint:Remove()
		end
	end

	if self.ents then
		self.ents = nil
	end

	if self.poss then
		self.poss = nil
	end
end

resourceitems = ResourceItems()