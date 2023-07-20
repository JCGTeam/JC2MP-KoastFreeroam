class 'ActionsMenu'

function ActionsMenu:__init()
    self.permissions = {
        ["Creator"] = true,
        ["GlAdmin"] = true,
        ["Admin"] = true,
        ["AdminD"] = true,
        ["ModerD"] = true,
        ["VIP"] = true
    }

	Network:Subscribe( "HealMe", self, self.HealMe )
	Network:Subscribe( "KillMe", self, self.KillMe )
	Network:Subscribe( "ClearInv", self, self.ClearInv )
	Network:Subscribe( "VehicleBoom", self, self.VehicleBoom )
	Network:Subscribe( "VehicleRepair", self, self.VehicleRepair )
	Network:Subscribe( "Sky", self, self.Sky )
	Network:Subscribe( "Down", self, self.Down )
end

function ActionsMenu:HealMe( args, sender )
	if sender:GetWorld() ~= DefaultWorld then return end
    sender:SetHealth( 1 )
end

function ActionsMenu:KillMe( args, sender )
	if sender:GetWorld() ~= DefaultWorld then return end
	if sender:GetHealth() ~= 0 then
		sender:SetHealth( 0 )
	end
end

function ActionsMenu:ClearInv( args, sender )
	if sender:GetWorld() ~= DefaultWorld then return end
    sender:ClearInventory()
end

function ActionsMenu:VehicleBoom( args, sender )
	if sender:GetWorld() ~= DefaultWorld then return end
	if not sender:GetVehicle() then return end

	if sender:GetVehicle():GetDriver() == sender then
		sender:GetVehicle():SetHealth( 0 )
	end
end

function ActionsMenu:VehicleRepair( args, sender )
	if sender:GetWorld() ~= DefaultWorld then return end
	if not sender:GetVehicle() then return end

	if sender:GetVehicle():GetDriver() == sender then
		sender:GetVehicle():SetHealth( 1 )
	end
end

function ActionsMenu:Sky( args, sender )
	local gettag = sender:GetValue( "Tag" )

	if self.permissions[gettag] then
		Events:Fire( "BoomToSky", { player = sender, type = 1 } )
	end
end

function ActionsMenu:Down( args, sender )
	local gettag = sender:GetValue( "Tag" )

	if self.permissions[gettag] then
		Events:Fire( "BoomToSky", { player = sender, type = 2 } )
	end
end

actionsmenu = ActionsMenu()