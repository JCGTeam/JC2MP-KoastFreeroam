class 'Eject'

function Eject:__init()
	Network:Subscribe( "EjectPassenger", self, self.EjectFunction )
end

function Eject:EjectFunction( args, sender )
	if args.vehicle then
		sender:EnterVehicle( args.vehicle, VehicleSeat.RooftopStunt )
	end
end

eject = Eject()