class 'SeaTrafficManager'

function SeaTrafficManager:__init()
	self.npcs = {}

	Events:Subscribe( "Render", self, self.Tick )
	Events:Subscribe( "EntitySpawn", self, self.EntitySpawn )
	Events:Subscribe( "EntityDespawn", self, self.EntityDespawn )
	Events:Subscribe( "NetworkObjectValueChange", self, self.ValueChange )
	Network:Subscribe( "MapUpdate", self, self.MapUpdate )
end

function SeaTrafficManager:Tick( args )
	for _, npc in pairs(self.npcs) do
		npc:Tick(args.delta)
		if settings.debug then
			math.randomseed(npc:GetModelId())
			local color = Color(math.random(255), math.random(255), math.random(255))
			npc:DrawBezier(0.1, color)
			Render:DrawCircle(Render:WorldToScreen(npc:GetNetworkPosition()), 10, color)
			Render:DrawCircle(Render:WorldToScreen(npc:GetPosition()), 8, color)
		end
	end
end

function SeaTrafficManager:EntitySpawn( args )
	if args.entity.__type ~= "Vehicle" then return end
	if not args.entity:GetValue("STT") then return end

	SeaTrafficNPC(args)
end

function SeaTrafficManager:EntityDespawn( args )
	if args.entity.__type ~= "Vehicle" then return end
	local npc = self.npcs[args.entity:GetId()]
	if not npc then return end
	
	npc:Remove()
end

function SeaTrafficManager:ValueChange( args )
	if args.object.__type ~= "Vehicle" then return end
	local npc = self.npcs[args.object:GetId()]
	if not npc then return end
	
	if args.key == "STT" then
		if args.value then
			npc.network_t = args.value
			npc.predicted_t = args.value
		else
			npc:Remove()
		end
	elseif args.key == "STPath" then
		npc.path = args.value
		npc.distance = npc.path[1]:Distance(npc.path[3])
		npc.distance = npc.distance == 0 and 2 * self.map.h or npc.distance
	end
end

function SeaTrafficManager:MapUpdate( args )
	self.map = args
end

SeaTrafficManager = SeaTrafficManager()