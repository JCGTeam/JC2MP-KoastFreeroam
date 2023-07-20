class 'SeaTrafficNPC'

function SeaTrafficNPC:__init( args )
	self.vehicle = Vehicle.Create( args )

	SeaTrafficManager.npcs[self.vehicle:GetId()] = self
	SeaTrafficManager.count = SeaTrafficManager.count + 1

	local path = SeaTrafficManager.map:GetRandomPath(args.node, args.angle * Vector3.Forward)

	local path_positions = {}
	for _, node in ipairs(path) do
		table.insert(path_positions, node[1])
	end

	self.t = 0

	self.vehicle:SetNetworkValue("STT", self.t)
	self.vehicle:SetNetworkValue("STPath", path_positions)

	self.distance = path[1][1]:Distance(path[3][1])
	self.distance = self.distance == 0 and 2 * SeaTrafficManager.map.h or self.distance	
	self.speed = settings.speeds[self.vehicle:GetModelId()] * settings.speed_gain
	self.path = path

	self.timers = {tick = Timer()}
end

function SeaTrafficNPC:Tick()
	local path = self.path 
	local vehicle = self.vehicle

	self.t = self.t + self.speed * self.timers.tick:GetSeconds() / self.distance

	local path_update

	while self.t >= 1 do
		self.t = self.t - 1

		path[1] = path[3]
		path[2] = path[4]
		path[3] = path[5]
		path[4] = path[6]
		path[5] = SeaTrafficManager.map:GetNextNode(path[4], path[4][1] - path[3][1])
		path[6] = SeaTrafficManager.map:GetNextNode(path[5], path[5][1] - path[4][1])
		self.distance = path[1][1]:Distance(path[3][1])
		self.distance = self.distance == 0 and 2 * SeaTrafficManager.map.h or self.distance

		path_update = true
	end

	local position, angle = math.bezier(path[1][1], path[2][1], path[4][1] - 2 * (path[4][1] - path[3][1]), path[3][1], self.t)

	vehicle:SetStreamPosition(position)
	vehicle:SetStreamAngle(angle)

	if path_update then
		local path_positions = {}
		for _, node in ipairs(self.path) do
			table.insert(path_positions, node[1])
		end
		vehicle:SetNetworkValue("STPath", path_positions)
	end

	vehicle:SetNetworkValue("STT", self.t)
	self.timers.tick:Restart()
end

function SeaTrafficNPC:IsStreamed()
	for player in self.vehicle:GetStreamedPlayers() do
		return true
	end
	return false
end

function SeaTrafficNPC:Remove()
	SeaTrafficManager.npcs[self.vehicle:GetId()] = nil
	SeaTrafficManager.count = SeaTrafficManager.count - 1
	if IsValid(self.vehicle) then self.vehicle:Remove() end
end