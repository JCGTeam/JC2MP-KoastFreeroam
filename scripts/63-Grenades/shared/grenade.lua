class "Grenade"

Grenade.FlashTime = 3

Grenade.Types = {

	["Frag"] = {
		["effect_id"] = 377,
		["weight"] = 1,
		["drag"] = 0.15,
		["restitution"] = 0.2,
		["radius"] = 0,
		["sound"] = true,
		["frag"] = 1,
		["fusetime"] = 4
	},
	["Flashbang"] = {
		["effect_id"] = 19,
		["weight"] = 1,
		["drag"] = 0.15,
		["restitution"] = 0,
		["radius"] = 150,
		["sound"] = false,
		["fusetime"] = 3
	},
	["Smoke"] = {
		["effect_id"] = 79,
		["weight"] = 1,
		["drag"] = 0.15,
		["restitution"] = 0.3,
		["radius"] = 0,
		["sound"] = false,
		["fusetime"] = 4
	},
	["MichaelBay"] = {
		["effect_id"] = 129,
		["weight"] = 2,
		["drag"] = 0.15,
		["restitution"] = 0.2,
		["radius"] = 6,
		["sound"] = true,
		["fusetime"] = 3.5
	},
	["Atom"] = {
		["effect_id"] = 132,
		["weight"] = 3,
		["drag"] = 0.15,
		["restitution"] = 0.001,
		["radius"] = 36,
		["sound"] = true,
		["fusetime"] = 5
	}
}

function Grenade:__init(position, velocity, type)
	self.object = ClientStaticObject.Create({
		["position"] = position,
		["angle"] = Angle.FromVectors(velocity, Vector3.Forward),
		["model"] = "wea33-wea33.lod"
	})
	self.effect = ClientEffect.Create(AssetLocation.Game, {
		["position"] = self.object:GetPosition(),
		["angle"] = self.object:GetAngle(),
		["effect_id"] = 61
	})
	self.velocity = velocity
	self.type = type or Grenade.Types.Frag
	self.weight = self.type.weight
	self.drag = self.type.drag
	self.restitution = self.type.restitution
	self.radius = self.type.radius
	self.fusetime = self.type.fusetime
	self.effect_id = self.type.effect_id
	self.sound = self.type.sound
	self.frag = self.type.frag
	self.timer = Timer()
	self.lastTime = 0
	if self.sound then
		self.firesound = ClientEffect.Create(AssetLocation.Game, {
			effect_id = 64,
			position = self.object:GetPosition(),
			angle = self.object:GetAngle()
		})
	end
end

function Grenade:Update()
	local delta = (self.timer:GetSeconds() - self.lastTime) / 1

	if self.timer:GetSeconds() < self.fusetime then
		if not self.stopped then
			self.velocity = (self.velocity - (self.velocity * self.drag * delta)) + (Vector3.Down * self.weight * 9.81 * delta)

			local ray = Physics:Raycast(self.object:GetPosition(), self.velocity * delta, 0, 1, true)

			if ray.distance <= math.min(self.velocity:Length() * delta, 1) then
				local dotTimesTwo = 2 * self.velocity:Dot(ray.normal)

				self.velocity.x = self.velocity.x - dotTimesTwo * ray.normal.x
				self.velocity.y = self.velocity.y - dotTimesTwo * ray.normal.y
				self.velocity.z = self.velocity.z - dotTimesTwo * ray.normal.z
				self.velocity = self.velocity * self.restitution

				if (self.velocity * delta):Length() <= 0.01 then
					self.stopped = true
				end
			end

			if not self.stopped then
				self.object:SetPosition(self.object:GetPosition() + (self.velocity * delta))
				self.effect:SetPosition(self.object:GetPosition())
				self.object:SetAngle(Angle.FromVectors(self.velocity, Vector3.Right))
				if self.sound then
					self.firesound:SetPosition(self.object:GetPosition())
				end
				self.effect:SetAngle(self.object:GetAngle())
			else
				self.object:SetPosition(self.object:GetPosition() + (Vector3.Up * 0.05))
				self.effect:SetPosition(self.object:GetPosition())
			end
		end
	else
		self:Detonate()
	end

	self.lastTime = self.timer:GetSeconds()
end

function Grenade:Detonate()
	Network:Send("GrenadeExplode", {
		["position"] = self.object:GetPosition(),
		["angle"] = self.object:GetAngle(),
		["type"] = self.type
	})

	local effect = ClientEffect.Play(AssetLocation.Game, {
		["position"] = self.object:GetPosition(),
		["angle"] = Angle(),
		["effect_id"] = self.effect_id
	})

	if self.frag then
		local sound = ClientSound.Play(AssetLocation.Game, {
			position = self.object:GetPosition(),
			bank_id = 11,
			sound_id = 13,
			variable_id_timeline = 0,
			variable_id_distance = 1,
			variable_id_focus = 2
		})
		if self.object:GetPosition().y < 200 then
			local effect = ClientEffect.Play(AssetLocation.Game, {
				effect_id = 112,
				position = Vector3(self.object:GetPosition().x, 200, self.object:GetPosition().z),
				angle = Angle()
			})
		end
	end
	self:Remove()
end

function Grenade:Remove()
	self.object:Remove()
	self.effect:Remove()
	if self.sound then
		self.firesound:Remove()
	end
end