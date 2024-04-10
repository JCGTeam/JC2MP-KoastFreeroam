class 'HijackBlocker'

function HijackBlocker:__init()
	self.actions = { 37, 38, 45, 82, 121, 147, 148, 150 }
	self.always_drop_states = { 207, 208, 324, 221, 222, 270, 272, 273, 440, 50 }

	self.invalidVehicles = {
		[1] = true,
		[3] = true,
		[9] = true,
		[11] = true,
		[14] = true,
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

function CheckVehicle( target )
	return target == nil or not IsValid( target ) or not IsValid( target:GetDriver() )
end

function HijackBlocker:LocalPlayerInput( args )
	if table.find( self.actions, args.input ) == nil then return true end

	local base_state = LocalPlayer:GetBaseState()

	if table.find( self.always_drop_states, base_state ) ~= nil then return false end

	local state = LocalPlayer:GetState()

	local vehicle = LocalPlayer:GetVehicle()
	local target = LocalPlayer:GetAimTarget().vehicle

	if CheckVehicle( vehicle ) and CheckVehicle( target ) then return true end

	if LocalPlayer:GetState() == PlayerState.StuntPos or
		(base_state >= 84 and base_state <= 110) or
		(base_state >= 318 and base_state <= 327) or
		(base_state == 88 or base_state == 327) or
		(base_state == 270 or base_state == 273) or
		(base_state == 207 or base_state == 208) or
		(base_state == 272 or base_state == 222) or 
		(base_state == 273 or base_state == 221) then

		if vehicle and (not self.invalidVehicles[vehicle:GetModelId()] and #vehicle:GetOccupants() == 1) then
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