class "sTuner"

function sTuner:__init()
	Events:Subscribe( "EntityDespawn", self, self.EntityDespawn )

	Network:Subscribe( "UpdateNeonColor", self, self.UpdateNeonColor )
	Network:Subscribe( "ToggleSyncNeon", self, self.ToggleSyncNeon )
	Network:Subscribe( "SyncTune", self, self.syncTune )
	Network:Subscribe( "ColorChanged", self, self.ColorChanged )
end

function sTuner:EntityDespawn( args )
	local entity = args.entity

	if entity.__type == "Vehicle" then
		if entity:GetValue( "Neon" ) and entity:GetValue( "NeonColor" ) then
			entity:SetNetworkValue( "Neon", nil )
			entity:SetNetworkValue( "NeonColor", nil )
		end

		--[[entity:SetNetworkValue( "vehid", nil )
		entity:SetNetworkValue( "modelid", nil )

		entity:SetNetworkValue( "clutch_delay", nil )
		entity:SetNetworkValue( "reverse_ratio", nil )
		entity:SetNetworkValue( "primary_transmission_ratio", nil )

		entity:SetNetworkValue( "airdensity", nil )
		entity:SetNetworkValue( "frontalarea", nil )
		entity:SetNetworkValue( "dragcoeff", nil )
		entity:SetNetworkValue( "liftcoeff", nil )
		entity:SetNetworkValue( "gravity", nil )

		entity:SetNetworkValue( "gear_ratios1", nil )
		entity:SetNetworkValue( "gear_ratios2", nil )
		entity:SetNetworkValue( "gear_ratios3", nil )
		entity:SetNetworkValue( "gear_ratios4", nil )
		entity:SetNetworkValue( "gear_ratios5", nil )
		entity:SetNetworkValue( "gear_ratios6", nil )
		entity:SetNetworkValue( "gear_ratios7", nil )

		entity:SetNetworkValue( "wheel1_length", nil )
		entity:SetNetworkValue( "wheel1_strength", nil )
		entity:SetNetworkValue( "wheel1_direction", nil )
		entity:SetNetworkValue( "wheel1_position", nil )
		entity:SetNetworkValue( "wheel1_dampcompression", nil )
		entity:SetNetworkValue( "wheel1_damprelaxation", nil )

		entity:SetNetworkValue( "wheel2_length", nil )
		entity:SetNetworkValue( "wheel2_strength", nil )
		entity:SetNetworkValue( "wheel2_direction", nil )
		entity:SetNetworkValue( "wheel2_position", nil )
		entity:SetNetworkValue( "wheel2_dampcompression", nil )
		entity:SetNetworkValue( "wheel2_damprelaxation", nil )

		entity:SetNetworkValue( "wheel3_length", nil )
		entity:SetNetworkValue( "wheel3_strength", nil )
		entity:SetNetworkValue( "wheel3_direction", nil )
		entity:SetNetworkValue( "wheel3_position", nil )
		entity:SetNetworkValue( "wheel3_dampcompression", nil )
		entity:SetNetworkValue( "wheel3_damprelaxation", nil )

		entity:SetNetworkValue( "wheel4_length", nil )
		entity:SetNetworkValue( "wheel4_strength", nil )
		entity:SetNetworkValue( "wheel4_direction", nil )
		entity:SetNetworkValue( "wheel4_position", nil )
		entity:SetNetworkValue( "wheel4_dampcompression", nil )
		entity:SetNetworkValue( "wheel4_damprelaxation", nil )

		entity:SetNetworkValue( "wheel5_length", nil )
		entity:SetNetworkValue( "wheel5_strength", nil )
		entity:SetNetworkValue( "wheel5_direction", nil )
		entity:SetNetworkValue( "wheel5_position", nil )
		entity:SetNetworkValue( "wheel5_dampcompression", nil )
		entity:SetNetworkValue( "wheel5_damprelaxation", nil )

		entity:SetNetworkValue( "wheel6_length", nil )
		entity:SetNetworkValue( "wheel6_strength", nil )
		entity:SetNetworkValue( "wheel6_direction", nil )
		entity:SetNetworkValue( "wheel6_position", nil )
		entity:SetNetworkValue( "wheel6_dampcompression", nil )
		entity:SetNetworkValue( "wheel6_damprelaxation", nil )

		entity:SetNetworkValue( "wheel7_length", nil )
		entity:SetNetworkValue( "wheel7_strength", nil )
		entity:SetNetworkValue( "wheel7_direction", nil )
		entity:SetNetworkValue( "wheel7_position", nil )
		entity:SetNetworkValue( "wheel7_dampcompression", nil )
		entity:SetNetworkValue( "wheel7_damprelaxation", nil )

		entity:SetNetworkValue( "wheel8_length", nil )
		entity:SetNetworkValue( "wheel8_strength", nil )
		entity:SetNetworkValue( "wheel8_direction", nil )
		entity:SetNetworkValue( "wheel8_position", nil )
		entity:SetNetworkValue( "wheel8_dampcompression", nil )
		entity:SetNetworkValue( "wheel8_damprelaxation", nil )

		entity:SetNetworkValue( "wheel_ratios1", nil )
		entity:SetNetworkValue( "wheel_ratios2", nil )
		entity:SetNetworkValue( "wheel_ratios3", nil )
		entity:SetNetworkValue( "wheel_ratios4", nil )
		entity:SetNetworkValue( "wheel_ratios5", nil )
		entity:SetNetworkValue( "wheel_ratios6", nil )
		entity:SetNetworkValue( "wheel_ratios7", nil )
		entity:SetNetworkValue( "wheel_ratios8", nil )]]--
	end
end

function sTuner:UpdateNeonColor( args, sender )
	local vehicle = sender:GetVehicle()

	if vehicle then
		vehicle:SetNetworkValue( "NeonColor", args.neoncolor )
	end
end

function sTuner:ToggleSyncNeon( args, sender )
	local vehicle = sender:GetVehicle()

	Network:Broadcast( "ToggleNeonLight", { vehicle = vehicle, value = vehicle:GetValue( "Neon" ) } )

    if vehicle:GetValue( "Neon" ) then
		vehicle:SetNetworkValue( "Neon", nil )
	else
		vehicle:SetNetworkValue( "Neon", true )
	end
end

function sTuner:syncTune( args, sender )
	local v = Vehicle.GetById(args.vehid)
	if not IsValid(v) then return end

	v:SetNetworkValue( "vehid", args.vehid )
	v:SetNetworkValue( "modelid", args.modelid )

	v:SetNetworkValue( "clutch_delay", args.clutch_delay )
	v:SetNetworkValue( "reverse_ratio", args.reverse_ratio )
	v:SetNetworkValue( "primary_transmission_ratio", args.primary_transmission_ratio )

	v:SetNetworkValue( "airdensity", args.airdensity )
	v:SetNetworkValue( "frontalarea", args.frontalarea )
	v:SetNetworkValue( "dragcoeff", args.dragcoeff )
	v:SetNetworkValue( "liftcoeff", args.liftcoeff )
	v:SetNetworkValue( "gravity", args.gravity )

	if args.gear_ratios[1] then v:SetNetworkValue( "gear_ratios1", args.gear_ratios[1] ) end
	if args.gear_ratios[2] then v:SetNetworkValue( "gear_ratios2", args.gear_ratios[2] ) end
	if args.gear_ratios[3] then v:SetNetworkValue( "gear_ratios3", args.gear_ratios[3] ) end
	if args.gear_ratios[4] then v:SetNetworkValue( "gear_ratios4", args.gear_ratios[4] ) end
	if args.gear_ratios[5] then v:SetNetworkValue( "gear_ratios5", args.gear_ratios[5] ) end
	if args.gear_ratios[6] then v:SetNetworkValue( "gear_ratios6", args.gear_ratios[6] ) end
	if args.gear_ratios[7] then v:SetNetworkValue( "gear_ratios7", args.gear_ratios[7] ) end

	if args.wheels[1] then 
		v:SetNetworkValue( "wheel1_length", args.wheels[1].length )
		v:SetNetworkValue( "wheel1_strength", args.wheels[1].strength )
		v:SetNetworkValue( "wheel1_direction", args.wheels[1].direction )
		v:SetNetworkValue( "wheel1_position", args.wheels[1].position )
		v:SetNetworkValue( "wheel1_dampcompression", args.wheels[1].dampcompression )
		v:SetNetworkValue( "wheel1_damprelaxation", args.wheels[1].damprelaxation )
	end
	if args.wheels[2] then 
		v:SetNetworkValue( "wheel2_length", args.wheels[2].length )
		v:SetNetworkValue( "wheel2_strength", args.wheels[2].strength )
		v:SetNetworkValue( "wheel2_direction", args.wheels[2].direction )
		v:SetNetworkValue( "wheel2_position", args.wheels[2].position )
		v:SetNetworkValue( "wheel2_dampcompression", args.wheels[2].dampcompression )
		v:SetNetworkValue( "wheel2_damprelaxation", args.wheels[2].damprelaxation )
	end
	if args.wheels[3] then 
		v:SetNetworkValue( "wheel3_length", args.wheels[3].length )
		v:SetNetworkValue( "wheel3_strength", args.wheels[3].strength )
		v:SetNetworkValue( "wheel3_direction", args.wheels[3].direction )
		v:SetNetworkValue( "wheel3_position", args.wheels[3].position )
		v:SetNetworkValue( "wheel3_dampcompression", args.wheels[3].dampcompression )
		v:SetNetworkValue( "wheel3_damprelaxation", args.wheels[3].damprelaxation )
	end
	if args.wheels[4] then 
		v:SetNetworkValue( "wheel4_length", args.wheels[4].length )
		v:SetNetworkValue( "wheel4_strength", args.wheels[4].strength )
		v:SetNetworkValue( "wheel4_direction", args.wheels[4].direction )
		v:SetNetworkValue( "wheel4_position", args.wheels[4].position )
		v:SetNetworkValue( "wheel4_dampcompression", args.wheels[4].dampcompression )
		v:SetNetworkValue( "wheel4_damprelaxation", args.wheels[4].damprelaxation )
	end
	if args.wheels[5] then 
		v:SetNetworkValue( "wheel5_length", args.wheels[5].length )
		v:SetNetworkValue( "wheel5_strength", args.wheels[5].strength )
		v:SetNetworkValue( "wheel5_direction", args.wheels[5].direction )
		v:SetNetworkValue( "wheel5_position", args.wheels[5].position )
		v:SetNetworkValue( "wheel5_dampcompression", args.wheels[5].dampcompression )
		v:SetNetworkValue( "wheel5_damprelaxation", args.wheels[5].damprelaxation )
	end
	if args.wheels[6] then 
		v:SetNetworkValue( "wheel6_length", args.wheels[6].length )
		v:SetNetworkValue( "wheel6_strength", args.wheels[6].strength )
		v:SetNetworkValue( "wheel6_direction", args.wheels[6].direction )
		v:SetNetworkValue( "wheel6_position", args.wheels[6].position )
		v:SetNetworkValue( "wheel6_dampcompression", args.wheels[6].dampcompression )
		v:SetNetworkValue( "wheel6_damprelaxation", args.wheels[6].damprelaxation )
	end
	if args.wheels[7] then 
		v:SetNetworkValue( "wheel7_length", args.wheels[7].length )
		v:SetNetworkValue( "wheel7_strength", args.wheels[7].strength )
		v:SetNetworkValue( "wheel7_direction", args.wheels[7].direction )
		v:SetNetworkValue( "wheel7_position", args.wheels[7].position )
		v:SetNetworkValue( "wheel7_dampcompression", args.wheels[7].dampcompression )
		v:SetNetworkValue( "wheel7_damprelaxation", args.wheels[7].damprelaxation )
	end
	if args.wheels[8] then 
		v:SetNetworkValue( "wheel8_length", args.wheels[8].length )
		v:SetNetworkValue( "wheel8_strength", args.wheels[8].strength )
		v:SetNetworkValue( "wheel8_direction", args.wheels[8].direction )
		v:SetNetworkValue( "wheel8_position", args.wheels[8].position )
		v:SetNetworkValue( "wheel8_dampcompression", args.wheels[8].dampcompression )
		v:SetNetworkValue( "wheel8_damprelaxation", args.wheels[8].damprelaxation )
	end

	if args.wheel_ratios[1] then v:SetNetworkValue( "wheel_ratios1", args.wheel_ratios[1] ) end
	if args.wheel_ratios[2] then v:SetNetworkValue( "wheel_ratios2", args.wheel_ratios[2] ) end
	if args.wheel_ratios[3] then v:SetNetworkValue( "wheel_ratios3", args.wheel_ratios[3] ) end
	if args.wheel_ratios[4] then v:SetNetworkValue( "wheel_ratios4", args.wheel_ratios[4] ) end
	if args.wheel_ratios[5] then v:SetNetworkValue( "wheel_ratios5", args.wheel_ratios[5] ) end
	if args.wheel_ratios[6] then v:SetNetworkValue( "wheel_ratios6", args.wheel_ratios[6] ) end
	if args.wheel_ratios[7] then v:SetNetworkValue( "wheel_ratios7", args.wheel_ratios[7] ) end
	if args.wheel_ratios[8] then v:SetNetworkValue( "wheel_ratios8", args.wheel_ratios[8] ) end
end

function sTuner:ColorChanged( args, sender )
    local veh = sender:GetVehicle()

	if veh then
		veh:SetColors( args.tone1, args.tone2 )
	else
		sender:SendChatMessage( sender:GetValue( "Lang" ) == "EN" and "This isn't your vehicle!" or "Это не ваш транспорт!", Color( 255, 0, 0 ) )
	end
end

sTuner = sTuner()