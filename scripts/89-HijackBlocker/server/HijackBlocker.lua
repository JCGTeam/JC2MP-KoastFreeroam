class 'HijackBlocker'

function HijackBlocker:__init()
	Network:Subscribe( "EnterPassenger", self, self.PassengerFunction )
end

function HijackBlocker:PassengerFunction( args, sender )
	if args.vehicle then
		if args.vehicle:GetOccupants() ~= nil then
			local players = args.vehicle:GetOccupants()

			if (#players == 1) then
				sender:EnterVehicle( args.vehicle, VehicleSeat.Passenger )
			end
		end
	end
end

hijackblocker = HijackBlocker()