class 'Eject'

function Eject:__init()
    self.invalidVehicles = {[3] = true, [14] = true, [67] = true}

    Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
end

function Eject:LocalPlayerInput(args)
    if Game:GetState() ~= GUIState.Game then return end

    if args.input == Action.StuntJump or args.input == Action.ParachuteOpenClose then
        local vehicle = LocalPlayer:GetVehicle()

        if vehicle and LocalPlayer:InVehicle() then
            if vehicle:GetDriver() and vehicle:GetDriver().__type ~= 'LocalPlayer' and not self.invalidVehicles[vehicle:GetModelId()] then
                local args = {}
                args.vehicle = vehicle
                Network:Send("EjectPassenger", args)
            end
        end
    end
end

local eject = Eject()