class 'HijackBlocker'

function HijackBlocker:__init()
	self.actions = { 37, 38, 45, 82, 121, 147, 148, 150 }
	self.always_drop_states = { 207, 208, 324, 221, 222, 270, 272, 273, 440, 50 }
	self.vehicleslist = { 1, 3, 5, 9, 14, 16, 18, 19, 22, 25, 28, 36, 38, 39, 45, 50, 56, 62, 64, 69, 85, 88 }

	self.invalidVehicles = {
		[1] = true,
		[3] = true,
		[5] = true,
		[9] = true,
		[11] = true,
		[14] = true,
		[16] = true,
		[19] = true,
		[21] = true,
		[22] = true,
		[25] = true,
		[28] = true,
		[32] = true,
		[36] = true,
		[38] = true,
		[39] = true,
		[43] = true,
		[45] = true,
		[47] = true,
		[50] = true,
		[56] = true,
		[57] = true,
		[61] = true,
		[62] = true,
		[64] = true,
		[67] = true,
		[69] = true,
		[74] = true,
		[80] = true,
		[83] = true,
		[85] = true,
		[88] = true,
		[89] = true,
		[90] = true,
	}

	self.cooldown = 2
	self.cooltime = 0

	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
end

function HijackBlocker:CheckList( tableList, modelID )
	for k,v in ipairs(tableList) do
		if v == modelID then return true end
	end
	return false
end

function HijackBlocker:LocalPlayerInput( args )
	if table.find( self.actions, args.input ) == nil then return true end

	local bs = LocalPlayer:GetBaseState()

	if table.find( self.always_drop_states, bs ) ~= nil then return false end

	local vehicle = LocalPlayer:GetVehicle()

	if not ( vehicle and vehicle:GetDriver() ) then return end

	local vehicleModel = vehicle:GetModelId()

	if self:CheckList( self.vehicleslist, vehicleModel ) then return end

	if LocalPlayer:GetState() == PlayerState.StuntPos or
		(bs >= 84 and bs <= 110) or
		(bs >= 318 and bs <= 327) or
		(bs == 88 or bs == 327) or
		(bs == 270 or bs == 273) or
		(bs == 207 or bs == 208) or
		(bs == 272 or bs == 222) or 
		(bs == 273 or bs == 221) then

		if not self.invalidVehicles[vehicleModel] and #vehicle:GetOccupants() == 1 then
			local time = Client:GetElapsedSeconds()

			if time > self.cooltime then
				local args = {}
				args.vehicle = vehicle
				Network:Send( "EnterPassenger", args )
			end

			self.cooltime = time + self.cooldown
		else
			return false
		end
	end
end

hijackblocker = HijackBlocker()