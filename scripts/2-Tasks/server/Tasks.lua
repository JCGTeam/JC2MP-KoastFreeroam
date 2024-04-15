class 'Tasks'

function string.starts( String,Start )
	return string.sub(String,1,string.len(Start))==Start
end

function string.upto( String,End )
	return string.sub(String, 1, string.find(String,End) - 1)
end

function Tasks:__init()
	math.randomseed(os.time())

	self.jobp_ru = "[Задания] "
	self.jobp_en = "[Tasks] "

	self.groundVehicles = {66, 12, 54, 23, 33, 68, 78, 8, 35, 44, 2, 7, 29, 70, 55, 15, 91, 21, 83, 32, 79, 22, 9, 4, 41, 49, 71, 42, 76, 31}
	self.offroadVehicles = {11, 36, 72, 73, 26, 63, 86, 77, 48, 84, 46, 10, 52, 13, 60, 87, 74, 43, 89, 90, 61, 47, 18, 56, 40}
	self.waterVehicles = {80, 38, 88, 45, 6, 19, 5, 27, 28, 25, 69, 16, 50}
	self.heliVehicles = {64, 65, 14, 67, 3, 37, 57, 62}
	self.jetVehicles = {39, 85, 34}
	self.planeVehicles = {51, 59, 81, 30}
	--vehicle "difficulty" tables
	self.easyVehicles = {81, 64, 14, 67, 3, 37, 57, 62, 80, 88, 27, 54, 72, 73, 23, 33, 63, 26, 68, 78, 86, 35, 77, 2, 84, 46, 7, 10, 52, 29, 70, 55, 15, 13, 91, 60, 87, 74, 21, 43, 89, 90, 61, 18, 56, 76, 31}
	self.mediumVehicles = {51, 34, 30, 65, 45, 6, 19, 28, 69, 16, 11, 36, 44, 48, 83, 32, 47, 79, 22, 9, 4, 41, 49, 71, 42}
	self.hardVehicles = {59, 38, 5, 25, 66, 12, 8, 1, 40}
	self.harderVehicles = {39, 75, 85, 50}

	self.easy = 0.20
	self.medium = 0.21
	self.hard = 0.21
	self.harder = 0.21
	self.shortJobBias = 2

	self.rewardMultiplier = 0.2

	self.jobCooldownTime = 1

	self.locations = {}

	self.gLocs = {}
	self.oLocs = {}
	self.wLocs = {}
	self.hLocs = {}
	self.jLocs = {}
	self.pLocs = {}
	self.xLocs = {}
	self.dLocs = {}

	self.availableJobs = {}

	self.playerJobs = {}

	self.playerJobTimers = {}

	self.jobCancelTimer = Timer()
	self.jobsToCancel = {}

	self:LoadLocations( "locations.txt" )

	self:GenerateJobs()

	Events:Subscribe( "ClientModuleLoad", self, self.ClientModuleLoad )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "PlayerExitVehicle", self, self.OnPlayerExitV )
	Events:Subscribe( "PlayerDeath", self, self.OnPlayerDeath )
	Events:Subscribe( "PreTick", self, self.PreTick )
	Network:Subscribe( "TakeJob", self, self.PlayerTakeJob )
	Network:Subscribe( "CompleteJob", self, self.PlayerCompleteJob )
end

function Tasks:LoadLocations( filename )
	print( "now opening " .. filename )
	local file = io.open( filename, "r" )
	if file == nil then
		print( filename .. " is missing, can't load spawns" )
		return
	end

	for line in file:lines() do 
		if line:sub(1,1) == "L" then
			self:ParseVehicleLocation(line:sub(3))
		end
	end
	file:close()

	for key,location in pairs(self.locations) do
		if location.type == "G" then
			table.insert(self.gLocs, key)
		elseif location.type == "O" then
			table.insert(self.oLocs, key)
		elseif location.type == "W" then
			table.insert(self.wLocs, key)
		elseif location.type == "H" then
			table.insert(self.hLocs, key)
		elseif location.type == "J" then
			table.insert(self.jLocs, key)
		elseif location.type == "P" then
			table.insert(self.pLocs, key)
		elseif location.type == "X" then
			table.insert(self.xLocs, key)
		elseif location.type == "D" then
			table.insert(self.dLocs, key)			
		end
	end
end

function Tasks:ParseVehicleLocation( line )
	local vehicleType = string.sub(line, 1, 1)

	local tokens = line:split(",")

	local locName = tokens[1]

	local locPos = { tokens[2]:gsub(" ",""), tokens[3]:gsub(" ",""), tokens[4]:gsub(" ","")}
	local locAngle = {tokens[5]:gsub(" ",""), tokens[6]:gsub(" ",""), tokens[7]:gsub(" ","")}

	local locArgs = {}
	locArgs.name = locName
	locArgs.type = vehicleType
	locArgs.position = Vector3(tonumber(locPos[1]),tonumber(locPos[2]),tonumber(locPos[3]))
	locArgs.angle = Angle(tonumber(locAngle[1]),tonumber(locAngle[2]),tonumber(locAngle[3]))

	table.insert(self.locations, locArgs)
end

function Tasks:GenerateJobs()
	print( "generating jobs" )
	for key,location in pairs(self.locations) do
		local job = self:MakeJob(key)
		--search for shorter jobs
		for i = 1,self.shortJobBias do
			job2 = self:MakeJob(key)
			if job2.distance < job.distance and job2.distance > 100 then
				job = job2
			end
		end
		self.availableJobs[key] = job
	end
end

function Tasks:MakeJob( key )
	local location = self.locations[key]
	local job = {}
	job.start = key
	--set a destination (and make sure it's not the same as the start)
	--watch out, this will go forever if there's not at least 2 of each type of destination.
	local destKey = self:GetRandomDestination(location.type, key)
	job.destination = destKey
	--set a vehicle
	local dest = self.locations[job.destination]
	if dest.type == "O" or location.type == "O" then
		job.vehicle = self:GetRandomVehicleOfType("O")
	else
		job.vehicle = self:GetRandomVehicleOfType(dest.type)
	end
	--set the direction between the start and destination
	local startPoint = location.position
	local destPoint = dest.position
	local direction = startPoint - destPoint
	direction = direction:Normalized()
	job.direction = direction
	--calculate a reward
	local distance = startPoint:Distance(destPoint)
	job.distance = distance
	local multiplier = self:GetVehicleRewardMultiplier(job.vehicle)
	job.reward = math.floor(multiplier * distance * self.rewardMultiplier)
	job.description = dest.name
	return job
end

function Tasks:GetVehicleRewardMultiplier( vehicleType )
	for k,v in pairs(self.easyVehicles) do
		if v == vehicleType then
			return self.easy
		end
	end
	for k,v in pairs(self.mediumVehicles) do
		if v == vehicleType then
			return self.medium
		end
	end
	for k,v in pairs(self.hardVehicles) do
		if v == vehicleType then
			return self.hard
		end
	end
	for k,v in pairs(self.harderVehicles) do
		if v == vehicleType then
			return self.harder
		end
	end
	return self.easy
end

function Tasks:GetRandomVehicleOfType( vehicleType )
	math.random()
	math.random()
	math.random()
	if (vehicleType == "G") then
		return self.groundVehicles[math.random(#self.groundVehicles)]
	elseif (vehicleType == "O") then
		return self.offroadVehicles[math.random(#self.offroadVehicles)]	
	elseif (vehicleType == "W") then
		return self.waterVehicles[math.random(#self.waterVehicles)]
	elseif (vehicleType == "H") then
		return self.heliVehicles[math.random(#self.heliVehicles)]
	elseif (vehicleType == "J") then
		return self.jetVehicles[math.random(#self.jetVehicles)]
	elseif (vehicleType == "P") then
		return self.planeVehicles[math.random(#self.planeVehicles)]
	elseif (vehicleType == "X") then
		return self.offroadVehicles[math.random(#self.offroadVehicles)]
	elseif (vehicleType == "D") then
		return self.offroadVehicles[math.random(#self.offroadVehicles)]		
	else 
		print( "tried to spawn invalid vehicle type. Made tractor instead" )
		return 1
	end
end

function Tasks:GetRandomDestination( startType, key )
	math.random()
	math.random()
	math.random()
	local i = 1
	local r = 1
	if (startType == "G") or (startType == "O") then
		if math.random(2) == 1 then
			i = math.random(#self.oLocs)
			r = self.oLocs[i]
			if r == key then
				if i < #self.oLocs then
					i = i + 1
					r = self.oLocs[i]
				elseif i > #self.oLocs then
					i = i - 1
					r = self.oLocs[i]
				end
			end
		else
			i = math.random(#self.gLocs)
			r = self.gLocs[i]
			if r == key then
				if i < #self.gLocs then
					i = i + 1
					r = self.gLocs[i]
				elseif i > #self.gLocs then
					i = i - 1
					r = self.gLocs[i]
				end
			end
		end
	elseif (startType == "W") then
		i = math.random(#self.wLocs)
			r = self.wLocs[i]
			if r == key then
				if i < #self.wLocs then
					i = i + 1
					r = self.wLocs[i]
				elseif i > #self.wLocs then
					i = i - 1
					r = self.wLocs[i]
				end
			end
	elseif (startType == "H") then
		i = math.random(#self.hLocs)
			r = self.hLocs[i]
			if r == key then
				if i < #self.hLocs then
					i = i + 1
					r = self.hLocs[i]
				elseif i > #self.hLocs then
					i = i - 1
					r = self.hLocs[i]
				end
			end
	elseif (startType == "J") then
		i = math.random(#self.jLocs)
			r = self.jLocs[i]
			if r == key then
				if i < #self.jLocs then
					i = i + 1
					r = self.jLocs[i]
				elseif i > #self.jLocs then
					i = i - 1
					r = self.jLocs[i]
				end
			end
	elseif (startType == "P") then
		i = math.random(#self.pLocs)
			r = self.pLocs[i]
			if r == key then
				if i < #self.pLocs then
					i = i + 1
					r = self.pLocs[i]
				elseif i > #self.pLocs then
					i = i - 1
					r = self.pLocs[i]
				end
			end
	elseif (startType == "X") then
		i = math.random(#self.xLocs)
			r = self.xLocs[i]
			if r == key then
				if i < #self.xLocs then
					i = i + 1
					r = self.xLocs[i]
				elseif i > #self.xLocs then
					i = i - 1
					r = self.xLocs[i]
				end
			end
	elseif (startType == "D") then
		i = math.random(#self.dLocs)
			r = self.dLocs[i]
			if r == key then
				if i < #self.dLocs then
					i = i + 1
					r = self.dLocs[i]
				elseif i > #self.dLocs then
					i = i - 1
					r = self.dLocs[i]
				end
			end			
	else
		print( "tried to create job with invalid type" )
		return locations[1]
	end
	return r
end

function string.Split( str )
	tab = {}
	for s in str:gmatch("%S+") do 
		table.insert(tab,s)
	end
	return tab
end

function Tasks:PreTick( args )
	if self.jobCancelTimer:GetSeconds() > 2 then
		self.jobCancelTimer:Restart()
		--cancel jobs in queue
		for player in Server:GetPlayers() do
			pId = player:GetId()

			if self.jobsToCancel[pId] == true then
				if IsValid( self.playerJobTimers[pId] ) then
					self.playerJobTimers[pId]:Restart()
				end
				if self.playerJobs[pId] and self.playerJobs[pId] ~= nil then
					if IsValid( self.playerJobs[pId].vehiclePointer ) then
						self.playerJobs[pId].vehiclePointer:Remove()
					end
					self.playerJobs[pId] = nil
				end
				Network:Send( player, "JobFailed", true )
				self.jobsToCancel[pId] = false
			end
		end
	end
end

function Tasks:OnPlayerExitV( args )
	self.jobsToCancel[args.player:GetId()] = true
end

function Tasks:OnPlayerDeath( args )
	self.jobsToCancel[args.player:GetId()] = true
end

function Tasks:PlayerTakeJob( args, player )
	--check if they're in a vehicle
	if player:GetState() == PlayerState.InVehiclePassenger or player:GetVehicle() ~= nil then
        return false
    end
	--cooldown timer
	if self.playerJobTimers[player:GetId()]:GetSeconds() < self.jobCooldownTime then
		player:SendChatMessage( player:GetValue( "Lang" ) == "EN" and self.jobp_en or self.jobp_ru, Color.White, player:GetValue( "Lang" ) == "EN" and "Wait a bit before starting a new task!" or "Подождите немного прежде, чем начинать новое задание!", Color.DarkGray )
		return false
	end
	--make sure the job is valid
	local thatJob = self.availableJobs[args.job]
	if thatJob == nil then
		return false
	end

	local jobDist = self.locations[thatJob.start].position:Distance(player:GetPosition())
	if jobDist < 5 then
		--restart timer
		self.playerJobTimers[player:GetId()]:Restart()
		--spawn vehicle
		local vArgs = {}
		vArgs.model_id = thatJob.vehicle
		--if it's the H-62 Quapaw, spawn it a bit higher up or else it'll sometimes randomly explode
		if vArgs.model_id == 65 then
			vArgs.position = self.locations[thatJob.start].position + Vector3(0, 2.5, 0)
		else
			vArgs.position = self.locations[thatJob.start].position
		end
		vArgs.angle = self.locations[thatJob.start].angle
		vArgs.enabled = true
		vArgs.world = player:GetWorld()
		vArgs.tone1 = Color( 255, 225, 0 )
		vArgs.tone2 = Color( 255, 238, 0 )
		local veh = Vehicle.Create( vArgs )
		veh:SetUnoccupiedRemove(true)
		veh:SetDeathRemove(true)
		veh:SetUnoccupiedRespawnTime(nil)
		veh:SetDeathRespawnTime(nil)
		player:EnterVehicle( veh, VehicleSeat.Driver )
		thatJob.vehiclePointer = veh
		--tell the player that they got the job!
		Network:Send( player, "JobStart", thatJob)
		--put job in table
		self.playerJobs[player:GetId()] = thatJob
		--generate a new job for that location, and tell the clients about it
		self.availableJobs[args.job] = self:MakeJob( args.job )
		jUpdate = {args.job, self.availableJobs[args.job]}
		Network:Broadcast("JobsUpdate", jUpdate)
	end
end

function Tasks:PlayerCompleteJob( args, player )
	local thatJob = self.playerJobs[player:GetId()]
	if thatJob == nil then
		print("player tried to complete a nil job, something went horribly wrong")
		return
	end
	local destDist = self.locations[thatJob.destination].position:Distance(player:GetPosition())
	local pVehicle = player:GetVehicle()
	if pVehicle == nil then
		return
	end
	local vVel = pVehicle:GetLinearVelocity():Length()
	local stopped = false
	if vVel < 1 then
		stopped = true
	end

	local playerId = player:GetId()

	--if player isn't in a company
	if destDist < 20 and stopped then
		if IsValid( thatJob.vehiclePointer ) and pVehicle == thatJob.vehiclePointer then
			player:GetVehicle():Remove()
			local reward = thatJob.reward
			player:SetMoney(player:GetMoney() + reward)
			self.playerJobs[playerId] = nil
			Network:Send( player, "JobFinish", reward)
			player:SendChatMessage( player:GetValue( "Lang" ) == "EN" and self.jobp_en or self.jobp_ru, Color.White, ( player:GetValue( "Lang" ) == "EN" and "Task completed! Reward: $" or "Задание выполнено! Награда: $" ) .. reward, Color( 0, 255, 0 ) )
			self.playerJobTimers[playerId]:Restart()
		else
			Network:Send( player, "JobFailed", true )
			self.playerJobs[playerId] = nil
			self.playerJobTimers[playerId]:Restart()
		end
	end
end

function Tasks:ClientModuleLoad( args )
    Network:Send( args.player, "Locations", self.locations )
	Network:Send( args.player, "Jobs", self.availableJobs)
	self.playerJobTimers[args.player:GetId()] = Timer()
end

function Tasks:PlayerQuit( args )
	pId = args.player:GetId()
	self.playerJobs[pId] = nil
end

function Tasks:ModuleUnload()
	for p in Server:GetPlayers() do
		if not self.playerJobs[p:GetId()] then return end

		local pVehicle = p:GetVehicle()

		if not pVehicle then return end

		if IsValid( self.playerJobs[p:GetId()].vehiclePointer ) and pVehicle == self.playerJobs[p:GetId()].vehiclePointer then
			pVehicle:Remove()
		end
	end
end

tasks = Tasks()