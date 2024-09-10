class 'AntiCrash'

function AntiCrash:__init()
    self.map_limit = 16000

    local vehicle = LocalPlayer:GetVehicle()

    if LocalPlayer:InVehicle() and vehicle:GetClass() == VehicleClass.Land then
        self.InputPollEvent = Events:Subscribe( "InputPoll", self, self.InputPoll )
    end

    Events:Subscribe( "LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
end

function AntiCrash:InputPoll()
    local coordString = LocalPlayer:GetPosition()

    if coordString.z < -self.map_limit or coordString.z > self.map_limit then
        local vehicle = LocalPlayer:GetVehicle()

        if LocalPlayer:InVehicle() and vehicle:GetClass() == VehicleClass.Land then
            Input:SetValue( Action.UseItem, 1 )
        end
    end
end

function AntiCrash:LocalPlayerEnterVehicle( args )
    if not ( args.vehicle:GetClass() == VehicleClass.Land ) then return end

	if not self.InputPollEvent then self.InputPollEvent = Events:Subscribe( "InputPoll", self, self.InputPoll ) end
end

function AntiCrash:LocalPlayerExitVehicle( args )
    if not ( args.vehicle:GetClass() == VehicleClass.Land ) then return end

	if self.InputPollEvent then Events:Unsubscribe( self.InputPollEvent ) self.InputPollEvent = nil end
end

anticrash = AntiCrash()