class 'Woet'

function Woet:__init()
	self.cooldown = 2
	self.cooltime = 0

	if LocalPlayer:InVehicle() then
        self.KeyUpEvent = Events:Subscribe( "KeyUp", self, self.KeyUp )
    end

	Events:Subscribe( "LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
end

function Woet:LocalPlayerEnterVehicle()
	if not self.KeyUpEvent then self.KeyUpEvent = Events:Subscribe( "KeyUp", self, self.KeyUp ) end
end

function Woet:LocalPlayerExitVehicle()
	if self.KeyUpEvent then Events:Unsubscribe( self.KeyUpEvent ) self.KeyUpEvent = nil end
end

function Woet:KeyUp( args )
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if LocalPlayer:GetState() ~= PlayerState.InVehicle then return end
	if LocalPlayer:GetValue( "Freeze" ) then return end

	if LocalPlayer:GetValue( "EnhancedWoet" ) and args.key == string.byte( "Y" ) then
		if not LocalPlayer:GetValue("Passive") then
			local vehicle = LocalPlayer:GetVehicle()

			if not IsValid( vehicle ) then return end

			if LocalPlayer:GetValue( "EnhancedWoet" ) == "Roll" then
				local dir2 = vehicle:GetAngle() * Vector3( 0, 0, -30 )
				vehicle:SetAngularVelocity( dir2 )
			elseif LocalPlayer:GetValue( "EnhancedWoet" ) == "Spin" then
				local dir2 = vehicle:GetAngle() * Vector3( 0, -30, 0 )
				vehicle:SetAngularVelocity( dir2 )
			elseif LocalPlayer:GetValue( "EnhancedWoet" ) == "Flip" then
				local dir1 = vehicle:GetLinearVelocity() + Vector3( 0, 35, 0 )
				vehicle:SetLinearVelocity( dir1 )
				local dir2 = vehicle:GetAngle() * Vector3( -30, 0, 0 )
				vehicle:SetAngularVelocity( dir2 )
			end
		end
	end

	if args.key == VirtualKey.Tab then
		if LocalPlayer:GetValue( "VehicleJump" ) then
			local time = Client:GetElapsedSeconds()
			local vehicle = LocalPlayer:GetVehicle()

			if not IsValid( vehicle ) then return end

			if time > self.cooltime then
				local dir1 = vehicle:GetLinearVelocity() + Vector3( 0, 6.5, 0 )
				vehicle:SetLinearVelocity( dir1 )

				self.cooltime = time + self.cooldown
			end
		end
	end
end

woet = Woet()