class 'Woet'

function Woet:__init()
	Network:Subscribe( "EnhancedWoet", self, self.EnhancedWoet )
end

function Woet:EnhancedWoet( action, sender )
	vehicle = sender:GetVehicle()

	if not IsValid(vehicle) then return end
	if sender:GetWorld() ~= DefaultWorld then return end
	if sender:GetState() ~= PlayerState.InVehicle then return end

	if action == "roll" then
		dir2 = vehicle:GetAngle() * Vector3( 0, 0, -30 )
		vehicle:SetAngularVelocity( dir2 )
	end

	if action == "spin" then
		dir2 = vehicle:GetAngle() * Vector3( 0, -30, 0 )
		vehicle:SetAngularVelocity( dir2 )
	end

	if action == "flip" then
		dir1 = vehicle:GetLinearVelocity() + Vector3( 0, 35, 0 )
		vehicle:SetLinearVelocity( dir1 )
		dir2 = vehicle:GetAngle() * Vector3( -30, 0, 0 )
		vehicle:SetAngularVelocity( dir2 )
	end

	return false
end

woet = Woet()