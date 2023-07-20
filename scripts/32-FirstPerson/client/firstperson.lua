class 'FirstPerson'

function FirstPerson:__init()
	self.enabled = false
	self.bikes = { [80] = true, [27] = true, [4] = true, [83] = true, [32] = true, [47] = true, [21] = true, 
				[43] = true, [22] = true, [9] = true, [61] = true, [74] = true, [89] = true, [90] = true, 
				[36] = true, [75] = true, [12] = true, [16] = true, [45] = true, [19] = true, 
				[5] = true, [38] = true, [25] = true, [50] = true, [46] = true, [72] = true, [48] = true, [76] = true }

	self.bering = { [85] = true }
	self.aero = { [39] = true }

	self.on = "Вид от 1-го лица включён"
	self.off = "Вид от 1-го лица отключён"

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
	Events:Subscribe( "KeyUp", self, self.KeyUp )
	Network:Subscribe( "FpActive", self, self.Active )
end

function FirstPerson:Lang()
	self.on = "First-person view enabled"
	self.off = "First-person view disabled"
end

function FirstPerson:LocalPlayerExitVehicle()
	if not self.enabled then return end
	Camera:SetFOV( 0.8 )
end

function FirstPerson:CalcView()
	if not self.enabled then return end
	if LocalPlayer:GetValue( "SpectatorMode" ) then return end

	local position = LocalPlayer:GetBonePosition( "ragdoll_Head" )
	local vehicle = LocalPlayer:GetVehicle()

	if LocalPlayer:InVehicle() then
		if IsValid(vehicle) and self.bering[vehicle:GetModelId()] then
			position = vehicle:GetPosition() + ( vehicle:GetAngle() * Vector3( 0, 6.0, -9 ) )
		end
		if IsValid(vehicle) and self.aero[vehicle:GetModelId()] then
			position = vehicle:GetPosition() + ( vehicle:GetAngle() * Vector3( 0, 4.4, -10.5 ) )
		end
		position = position + ( Camera:GetAngle() * Vector3( 0, 0, 0.3 ) )
		if IsValid(vehicle) and self.bikes[vehicle:GetModelId()] then
			Camera:SetFOV( 0.8 )
		else
			Camera:SetFOV( 0.5 )
		end
	else
		position = position + ( Camera:GetAngle() * Vector3( 0, 0.2, 0.1 ) )
	end

	Camera:SetPosition( position )
end

function FirstPerson:Active()
	if self.enabled then
		if self.EventCaclView then
			Events:Unsubscribe( self.EventCaclView )
			self.EventCaclView = nil
		end
		self.enabled = false
	else
		if not self.EventCaclView then
			self.EventCaclView = Events:Subscribe( "CalcView", self, self.CalcView )
		end
		self.enabled = true
		Events:Fire( "ZoomReset" )
	end

	Events:Fire( "CastCenterText", { text = ( self.enabled and self.on or self.off ), time = 2, color = Color( 0, 222, 0 ) } )
end

function FirstPerson:KeyUp( args )
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetValue( "SpectatorMode" ) then return end

	if args.key == VirtualKey.F6 then
		self:Active()
	end
end

firstperson = FirstPerson()