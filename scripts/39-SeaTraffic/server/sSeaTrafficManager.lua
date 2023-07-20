class 'SeaTrafficManager'

function SeaTrafficManager:__init()
	self.npcs = {}
	self.count = 0
	self.removals = {}

	self.timer = Timer()

	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
	Events:Subscribe( "EntityDespawn", self, self.EntityDespawn )
	Events:Subscribe( "PlayerEnterVehicle", self, self.PlayerEnterVehicle )
	Events:Subscribe( "PlayerExitVehicle", self, self.PlayerExitVehicle )
	Events:Subscribe( "ClientModuleLoad", self, self.ClientModuleLoad )
end

function SeaTrafficManager:ModuleLoad()
	local timer = Timer()

	self.map = SeaTrafficMap(data, 2048)

	for i = 1, settings.count do
		self:SpawnRandomNPC()
	end

	for _, node in ipairs(self.map.nodes) do
		node.occupied = nil
	end

	self.co = coroutine.create(function()
		while true do
			for _, npc in pairs(self.npcs) do
				npc:Tick()
				coroutine.yield()
			end
		end
	end)

	Events:Subscribe("PostTick", self, self.PostTick)
	
	data.positions = nil
	print(string.format("Sea traffic loaded in %i ms", timer:GetMilliseconds()))
end

function SeaTrafficManager:SpawnRandomNPC()
	local nodes = self.map.nodes
	if self.count == #nodes then return error("Node occupacy exceeded") end

	local node = table.randomvalue(nodes)
	while node.occupied do
		node = table.randomvalue(nodes)
	end
	node.occupied = true

	local direction = table.randomvalue(node[2])[1] - node[1]

	SeaTrafficNPC({
		model_id = table.randomvalue(settings.pool),
		position = node[1],
		angle = Angle(math.atan2(-direction.x, -direction.z), 0, 0),
		node = node
	})
end

function SeaTrafficManager:PostTick( args )
	local count = self.count
	local delay = settings.delay
	if count == 0 or delay == 0 then return end

	local n = math.min(args.delta * count / delay, count)

	if n > 1 then
		for i = 1, n do
			coroutine.resume(self.co)
		end

	elseif self.timer:GetSeconds() > delay / count then
		self.timer:Restart()
		coroutine.resume(self.co)
	end

	if #self.removals > 0 then
		table.remove(self.removals, 1):Remove()
		self:SpawnRandomNPC()
	end
end

function SeaTrafficManager:EntityDespawn( args )
	if self.unloading then return end
	if args.entity.__type ~= "Vehicle" then return end

	local id = args.entity:GetId()
	if not self.npcs[id] then return end

	self.npcs[id] = nil
	self.count = self.count - 1
end

function SeaTrafficManager:PlayerEnterVehicle( args )
	if not args.is_driver then return end
	local id = args.vehicle:GetId()
	if not self.npcs[id] then return end

	self.npcs[id] = nil
	self.count = self.count - 1

	args.vehicle:SetNetworkValue("STT", nil)
	args.vehicle:SetValue("STHijacked", true)

	self:SpawnRandomNPC()
end

function SeaTrafficManager:PlayerExitVehicle( args )
	if not args.vehicle:GetValue("STHijacked") then return end
	if #args.vehicle:GetOccupants() > 0 then return end
    args.vehicle:SetUnoccupiedRespawnTime( 60 )
end

function SeaTrafficManager:ClientModuleLoad( args )
	Network:Send(args.player, "MapUpdate", {h = data.h})
end

function SeaTrafficManager:ModuleUnload()
	for _, npc in pairs(self.npcs) do
		npc:Remove()
	end
end

SeaTrafficManager = SeaTrafficManager()