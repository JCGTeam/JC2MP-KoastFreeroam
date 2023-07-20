class "C4Manager"

C4Manager.__type = "C4Manager"

function C4Manager:__init()
	self.C4 = {}

	Events:Subscribe("WorldNetworkObjectCreate", self, self.WorldNetworkObjectCreate)
	Events:Subscribe("WorldNetworkObjectDestroy", self, self.WorldNetworkObjectDestroy)
end

function C4Manager.IsValidWNO(object)
	return type(object) == "userdata" and object.__type == "WorldNetworkObject" and object:GetValue("type") == C4.__type
end

function C4Manager:Contains(object)
	if C4Manager.IsValidWNO(object) then
		return self.C4[object:GetId()] ~= nil
	end

	return false
end

function C4Manager:Add(object)
	assert(C4Manager.IsValidWNO(object), "Must supply a valid WorldNetworkObject!")

	self.C4[object:GetId()] = C4(object)
end

function C4Manager:Remove(object)
	assert(self:Contains(object), "Must supply a managed WorldNetworkObject!")

	self.C4[object:GetId()]:Remove()
	self.C4[object:GetId()] = nil
end

function C4Manager:WorldNetworkObjectCreate(args)
	local WNO = args.object

	if WNO:GetValue("type") == C4.__type then
		self:Add(WNO)
	end
end

function C4Manager:WorldNetworkObjectDestroy(args)
	local WNO = args.object

	if self:Contains(WNO) then
		self:Remove(WNO)
	end
end

C4Manager = C4Manager()