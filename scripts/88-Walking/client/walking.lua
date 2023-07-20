class 'Walking'

function Walking:__init()
    if not LocalPlayer:InVehicle() then
        self.InputPollEvent = Events:Subscribe( "InputPoll", self, self.InputPoll )
    end

    Events:Subscribe( "LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
end

function Walking:LocalPlayerEnterVehicle()
	if self.InputPollEvent then
		Events:Unsubscribe( self.InputPollEvent )
		self.InputPollEvent = nil
	end
end

function Walking:LocalPlayerExitVehicle()
	if not self.InputPollEvent then
		self.InputPollEvent = Events:Subscribe( "InputPoll", self, self.InputPoll )
	end
end

function Walking:InputPoll()
    if Game:GetSetting( GameSetting.GamepadInUse ) == 0 then
        Input:SetValue( Action.Walk, Input:GetValue( Action.StuntJump ) )
    end
end

walking = Walking()