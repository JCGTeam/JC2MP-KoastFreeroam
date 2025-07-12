class 'HijackBlocker'

function HijackBlocker:__init()
    Network:Subscribe("EnterPassenger", self, self.PassengerFunction)
end

function HijackBlocker:PassengerFunction(args, sender)
	local vehicle = args.vehicle

	if vehicle and vehicle:GetOccupants() ~= nil then
		local players = vehicle:GetOccupants()

		if #players == 1 then
			sender:EnterVehicle(vehicle, VehicleSeat.Passenger)
		end
	end
end

local hijackblocker = HijackBlocker()