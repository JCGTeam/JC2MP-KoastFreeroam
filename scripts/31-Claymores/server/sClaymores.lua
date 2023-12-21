class "sClaymores"

function sClaymores:__init()
	self:initVars()
	Events:Subscribe( "ModuleUnload", self, self.onModuleUnload )
	Network:Subscribe( "01", self, self.addClaymore )
	Network:Subscribe( "02", self, self.removeClaymore )
end

function sClaymores:initVars()
	self.objects = {}
	self.stream = 300 -- Distance in meters for claymore to be visible
	self.range = 2 -- Distance in meters for claymore to trigger
	self.reduction = 0.05 -- Claymore position height reduction
	self.rotation = math.pi / 2 -- Claymore angle yaw rotation
end

-- Events
function sClaymores:onModuleUnload()
	for triggerId, objectId in pairs(self.objects) do
		local object = WorldNetworkObject.GetById(objectId)
		local trigger = WorldNetworkObject.GetById(triggerId)
		if object then object:Remove() end
		if trigger then trigger:Remove() end
	end
end

-- Network
function sClaymores:addClaymore( _, player )
	local position = player:GetPosition()
	position.y = position.y - self.reduction
	local angle = player:GetAngle()
	angle.yaw = angle.yaw + self.rotation
	local object = WorldNetworkObject.Create(position, {["C"] = Class.ClaymoreObject})
	object:SetAngle(angle)
	object:SetStreamDistance(self.stream)
	local trigger = WorldNetworkObject.Create(position, {["C"] = Class.ClaymoreTrigger})
	trigger:SetAngle(angle)
	trigger:SetStreamDistance(self.range)
	self.objects[trigger:GetId()] = object:GetId()
end

function sClaymores:removeClaymore( args, player )
	if player:GetValue("Passive") then return end
	local objectId = self.objects[args.id]
	if not objectId then return end
	local object = WorldNetworkObject.GetById(objectId)
	local trigger = WorldNetworkObject.GetById(args.id)
	if object then object:Remove() end
	if trigger then trigger:Remove() end
	Network:Broadcast("EffectClay", {position = args.position, angle = args.angle})
end

sclaymores = sClaymores()