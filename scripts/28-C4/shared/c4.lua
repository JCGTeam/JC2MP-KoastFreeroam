class "C4"

C4.__type = "C4"
C4.FlashDelay = 1

function C4:__init(WNO)
	self.WNO = WNO
	self.events = {}

	-- table.insert(self.events, Events:Subscribe("PreTick", self, self.PreTick))
	table.insert(self.events, Events:Subscribe("PostTick", function()
		self:PostTick()
	end))

	if Client then
		self.entities = {}
		self.timer = Timer()
		self.lastFlash = -C4.FlashDelay

		-- table.insert(self.events, Events:Subscribe("Render", self, self.Render))
		table.insert(self.events, Events:Subscribe("Render", function()
			self:Render()
		end))

		table.insert(self.entities, ClientStaticObject.Create({
			model = "wea35-tte.lod",
			position = self:GetPosition(),
			angle = self:GetAngle()
		}))
	end
end

function C4:GetOwner()
	local owner = self.WNO:GetValue("owner")

	if owner then
		return owner
	end

	return false
end

function C4:GetParent()
	local parent = self.WNO:GetValue("parent")

	if parent and IsValid(parent) then
		return parent
	end

	return false
end

function C4:GetParentBone()
	local parent = self.WNO:GetValue("parent_bone")

	if parent then
		return parent
	end

	return false
end

function C4:GetPositionOffset()
	if self.WNO:GetValue("position_offset") then
		return self.WNO:GetValue("position_offset")
	end

	return Vector3.Zero
end

function C4:GetAngleOffset()
	if self.WNO:GetValue("angle_offset") then
		return self.WNO:GetValue("angle_offset")
	end

	return Angle()
end

function C4:GetId()
	return self.WNO:GetId()
end

function C4:GetCellId()
	return self.WNO:GetCellId()
end

function C4:GetPosition()
	if self:GetParent() then
		if not self:GetParentBone() or Server then
			return self:GetParent():GetPosition() + (self:GetParent():GetAngle() * self:GetPositionOffset())
		else
			return self:GetParent():GetBonePosition(self:GetParentBone()) + (self:GetParent():GetBoneAngle(self:GetParentBone()) * self:GetPositionOffset())
		end
	end

	return self.WNO:GetPosition()
end

function C4:GetAngle()
	if self:GetParent() then
		if not self:GetParentBone() or Server then
			return self:GetParent():GetAngle() * self:GetAngleOffset()
		else
			return self:GetParent():GetBoneAngle(self:GetParentBone()) * self:GetAngleOffset()
		end
	end

	return self.WNO:GetAngle()
end

function C4:IsDetonated()
	return self.WNO:GetValue("detonated")
end

function C4:PostTick( args )
	if Server then
		if self:GetParent() and self:GetParent():GetCellId() ~= self:GetCellId() then
			self.WNO:SetPosition(self:GetPosition())
		end

		if self:IsDetonated() then
			self.WNO:Remove()
		end
	elseif self.timer:GetSeconds() - self.lastFlash > C4.FlashDelay then
		local effect = ClientEffect.Play(AssetLocation.Game, {
			effect_id = 280,
			position = self:GetPosition(),
			angle = self:GetAngle()
		})

		local sound = ClientSound.Play(AssetLocation.Game, {
			position = self:GetPosition(),
			bank_id = 11,
			sound_id = 2,
			variable_id_focus = 0
		})

		self.lastFlash = self.timer:GetSeconds()
	end
end

function C4:Render()
	for k, entity in ipairs(self.entities) do
		entity:SetPosition(self:GetPosition())
		entity:SetAngle(self:GetAngle())
	end
end

function C4:Detonate()
	if Server then
		self.WNO:SetNetworkValue("detonated", true)
	else
		local effect = ClientEffect.Play(AssetLocation.Game, {
			effect_id = 377,
			position = self:GetPosition(),
			angle = self:GetAngle()
		})

		local sound = ClientSound.Play(AssetLocation.Game, {
			position = self:GetPosition(),
			bank_id = 11,
			sound_id = 13,
			variable_id_timeline = 0,
			variable_id_distance = 1,
			variable_id_focus = 2
		})

		if self:GetPosition().y < 200 then
			local effect = ClientEffect.Play(AssetLocation.Game, {
				effect_id = 112,
				position = Vector3(self:GetPosition().x, 200, self:GetPosition().z),
				angle = Angle()
			})
		end
	end
end

function C4:Remove()
	if self.removed then return else self.removed = true end

	if self:IsDetonated() and Client then
		self:Detonate()
	end

	if Server and C4Manager:Contains(self.WNO) then
		self.WNO:Remove()
	end

	for k, event in ipairs(self.events) do
		Events:Unsubscribe(event)
	end

	if Client then
		for k, entity in ipairs(self.entities) do
			entity:Remove()
		end
	end
end