heli = {} -- reference table
heli[3] = true
heli[14] = true
heli[37] = true
heli[57] = true
heli[62] = true
heli[64] = true
heli[65] = true
heli[67] = true
bike = {} -- reference table
bike[21] = true
bike[32] = true
bike[43] = true
bike[47] = true
bike[61] = true
bike[74] = true
bike[83] = true
bike[89] = true
bike[90] = true

function Mount( args, player )
	local veh2 = args.veh
	if IsValid(veh2) then
		local id = veh2:GetModelId()
		if heli[id] then
			player:EnterVehicle(veh2, 10)
		elseif bike[id] then
			if veh2:GetOccupants() ~= nil then RemoveOccupants(veh2) end
			player:EnterVehicle(veh2, 0)
		else
			player:EnterVehicle(veh2, 8)
		end
	end
end
Network:Subscribe( "MountVehicle", Mount )

function RemoveOccupants( vehicle)
	local occupants = vehicle:GetOccupants()
	for index, ply in ipairs(occupants) do
		local plypos = ply:GetPosition()
		plypos.y = plypos.y + 10
		ply:SetPosition(plypos)
	end
end