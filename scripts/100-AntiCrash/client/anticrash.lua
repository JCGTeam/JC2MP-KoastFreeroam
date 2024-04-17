class 'AntiCrash'

function AntiCrash:__init()
    self.map_limit = 16000

    self.allowed_vehicles = {
        [5] = true, [6] = true, [16] = true, [19] = true,
        [25] = true, [27] = true, [28] = true, [38] = true,
        [45] = true, [50] = true, [53] = true, [69] = true,
        [80] = true, [88] = true,
        [3] = true, [14] = true, [37] = true, [57] = true,
        [62] = true, [64] = true, [65] = true, [67] = true,
        [24] = true, [30] = true, [34] = true, [39] = true,
        [51] = true, [59] = true, [81] = true, [85] = true
	}

    local vehicle = LocalPlayer:GetVehicle()
    local id = vehicle and vehicle:GetModelId()

    if LocalPlayer:InVehicle() and not self.allowed_vehicles[id] then
        self.InputPollEvent = Events:Subscribe( "InputPoll", self, self.InputPoll )
    end

    Events:Subscribe( "LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
end

function AntiCrash:InputPoll()
    local coordString = LocalPlayer:GetPosition()

    if coordString.z < -self.map_limit or coordString.z > self.map_limit then
        local vehicle = LocalPlayer:GetVehicle()
        local id = vehicle and vehicle:GetModelId()

        if LocalPlayer:InVehicle() and not self.allowed_vehicles[id] then
            Input:SetValue( Action.UseItem, 1 )
        end
    end
end

function AntiCrash:LocalPlayerEnterVehicle()
    local vehicle = LocalPlayer:GetVehicle()
    local id = vehicle and vehicle:GetModelId()

    if self.allowed_vehicles[id] then return end

	if not self.InputPollEvent then self.InputPollEvent = Events:Subscribe( "InputPoll", self, self.InputPoll ) end
end

function AntiCrash:LocalPlayerExitVehicle()
    local vehicle = LocalPlayer:GetVehicle()
    local id = vehicle and vehicle:GetModelId()

    if self.allowed_vehicles[id] then return end

	if self.InputPollEvent then Events:Unsubscribe( self.InputPollEvent ) self.InputPollEvent = nil end
end

anticrash = AntiCrash()