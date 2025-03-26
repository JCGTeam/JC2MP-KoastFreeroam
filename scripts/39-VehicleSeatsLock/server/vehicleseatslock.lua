class 'VehicleSeatsLock'

function VehicleSeatsLock:__init()
    Network:Subscribe( "SetSeatLock", self, self.SetSeatLock )

    Events:Subscribe( "EntityDespawn", self, self.EntityDespawn )
end

function VehicleSeatsLock:SetSeatLock( args, sender )
    if args and args.vehicle then
        args.vehicle:SetNetworkValue( "SeatLocked", { seat = args.seat, locked = args.locked } )

        Network:SendNearby( sender, "SyncSeatLock", { vehicle = args.vehicle, seat = args.seat, locked = args.locked } )
    end
end

function VehicleSeatsLock:EntityDespawn( args, sender )
	local entity = args.entity

	if entity.__type == "Vehicle" then
		if entity:GetValue( "SeatLocked" )  then
			entity:SetNetworkValue( "SeatLocked", nil )
		end
    end
end

vehicleseatslock = VehicleSeatsLock()