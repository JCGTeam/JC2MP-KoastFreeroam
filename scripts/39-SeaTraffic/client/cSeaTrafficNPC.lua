class 'SeaTrafficNPC'

function SeaTrafficNPC:__init( args )
	self.vehicle = args.entity

	local position = self:GetPosition()
	local angle = self:GetAngle()

	self.actor = ClientActor.Create(AssetLocation.Game, {
		model_id = 26,
		position = position,
		angle = angle
	})

	self.path = self.vehicle:GetValue("STPath")
	self.distance = self.path[1]:Distance(self.path[3])
	self.distance = self.distance == 0 and 2 * SeaTrafficManager.map.h or self.distance	

	self.local_t = self.vehicle:GetValue("STT")
	self.network_t = self.local_t
	self.predicted_t = self.local_t

	self.top_speed = settings.speeds[self.vehicle:GetModelId()]
	self.speed = self.top_speed * settings.speed_gain
	self.prev_position = position

	self.loader = Events:Subscribe( "PostTick", self, self.Load )
end

function SeaTrafficNPC:Load()
	if IsValid(self.vehicle) then
		if IsValid(self.actor) then
			self.actor:EnterVehicle(self.vehicle, 0)
			Events:Unsubscribe(self.loader)
			self.loader = nil
			SeaTrafficManager.npcs[self:GetId()] = self
		end
	else
		self.actor:Remove()
		Events:Unsubscribe(self.loader)
		self.loader = nil
	
	end
end

function SeaTrafficNPC:Tick( dt )
	local path = self.path
	local speed = self.speed
	local vehicle = self.vehicle
	local min = math.min

	local h = speed * dt / self.distance
	self.local_t = self.local_t + h + dt * (self.predicted_t - self.local_t)
	self.predicted_t = self.predicted_t + h

	while self.local_t >= 1 or self.predicted_t >= 1 do

		self.local_t = self.local_t - 1
		self.predicted_t = self.predicted_t - 1

		path[1] = path[3]
		path[2] = path[4]
		path[3] = path[5]
		path[4] = path[6]
		-- path 5 and 6 come from server
		self.distance = path[1]:Distance(path[3])
		self.distance = self.distance == 0 and 2 * SeaTrafficManager.map.h or self.distance

	end	

	local p1 = vehicle:GetPosition()
	local q1 = vehicle:GetAngle()
	local p2, q2 = math.bezier(path[1], path[2], path[4] - 2 * (path[4] - path[3]), path[3], self.local_t)

	local v1 = vehicle:GetLinearVelocity()
	local v2 = (p2 - self.prev_position) / dt
	local dv = v1:Distance(v2)
	self.prev_position = Copy(p2)

	p2.y = p1.y; q2.roll = q1.roll; q2.pitch = q1.pitch; v2.y = v1.y

	local dp = p1:Distance(p2)
	local dq = q1:Delta(q2)

	local v = (IsNaN(dv) or dv == 0) and v1 or math.lerp(v1, v2, min(2 * dt / dv, 1))
	local p = (IsNaN(dp) or dp == 0) and p1 or math.lerp(p1, p2, min((v:Length() + dp) * dt / dp, 1))
	local q = (IsNaN(dq) or dq == 0) and q1 or Angle.Slerp(q1, q2, min(2 * dt / dq, 1))

	vehicle:SetLinearVelocity(v)
	vehicle:SetPosition(p)
	vehicle:SetAngle(q)
	
	self.actor:SetInput(Action.Accelerate, min(v:Length() / self.top_speed, 1))
end

function SeaTrafficNPC:DrawBezier( h, color )
	local path = self.path

	for _, position in ipairs(path) do
		Render:DrawCircle(position, 1, color)
	end

	local positions = {}
	for i = 0, 1 / h do
		local p = math.bezier(path[1], path[2], path[4] - 2 * (path[4] - path[3]), path[3], i * h)
		table.insert(positions, p)
	end

	for i = 1, #positions - 1 do
		Render:DrawLine(positions[i], positions[i + 1], color)
	end
end

function SeaTrafficNPC:GetPosition()
	return self.vehicle:GetPosition()
end

function SeaTrafficNPC:GetNetworkPosition()
	local path = self.path
	local position = math.bezier(path[1], path[2], path[4] - 2 * (path[4] - path[3]), path[3], self.network_t)
	return position
end

function SeaTrafficNPC:GetAngle()
	return self.vehicle:GetAngle()
end

function SeaTrafficNPC:GetNetworkAngle()
	local path = self.path
	local _, angle = math.bezier(path[1], path[2], path[4] - 2 * (path[4] - path[3]), path[3], self.network_t)
	return angle
end

function SeaTrafficNPC:GetLinearVelocity()
	return self.vehicle:GetLinearVelocity()
end

function SeaTrafficNPC:GetModelId()
	return self.vehicle:GetModelId()
end

function SeaTrafficNPC:GetId()
	return self.vehicle:GetId()
end

function SeaTrafficNPC:IsValid()
	return IsValid(self.vehicle) and IsValid(self.actor)
end

function SeaTrafficNPC:Remove()
	SeaTrafficManager.npcs[self.vehicle:GetId()] = nil
	self.actor:Remove()
end