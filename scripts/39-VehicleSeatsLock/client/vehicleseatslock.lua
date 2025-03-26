class 'VehicleSeatsLock'

function VehicleSeatsLock:__init()
    Events:Subscribe( "SetVehicleSeatLocked", self, self.SetVehicleSeatLocked )
    Events:Subscribe( "EntitySpawn", self, self.EntitySpawn )
	Events:Subscribe( "EntityDespawn", self, self.EntityDespawn )

    Network:Subscribe( "SyncSeatLock", self, self.SyncSeatLock )
end

function VehicleSeatsLock:SetVehicleSeatLocked( args )
    if args.vehicle then
        args.vehicle:SetSeatLocked( args.seat, args.locked )

        Network:Send( "SetSeatLock", { vehicle = args.vehicle, seat = args.seat, locked = args.locked } )
    end
end

function VehicleSeatsLock:SyncSeatLock( args )
    args.vehicle:SetSeatLocked( args.seat, args.locked )
end

function VehicleSeatsLock:EntitySpawn( args )
	local entity = args.entity

	if entity.__type == "Vehicle" then
        local seatLocked = entity:GetValue( "SeatLocked" )

		if seatLocked then
			entity:SetSeatLocked( seatLocked.seat, seatLocked.locked )
		end
	end
end

function VehicleSeatsLock:EntityDespawn( args )
	local entity = args.entity

	if entity.__type == "Vehicle" then
        local seatLocked = entity:GetValue( "SeatLocked" )

		if seatLocked then
			entity:SetSeatLocked( seatLocked.seat, false )
		end
	end
end

vehicleseatslock = VehicleSeatsLock()