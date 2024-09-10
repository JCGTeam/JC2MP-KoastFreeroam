class 'VTOL'

function VTOL:__init()
	self.ReverseThrustActive = true
	self.PlaneVehicles = { 24, 30, 34, 39, 51, 59, 81, 85 }

	self.MaxThrust				=	0.3		--	The maximum thrust speed.						Default: 10
	self.MinThrust				=	0.1		--	The minimum thrust speed.						Default: 0.1
	self.CurrentThrust			=	0		--	The starting thrust speed.						Default: 0
	self.MaxReverseThrust		=	1.5		--	The maximum speed a plane can go in reverse.	Default: 1.5
	self.ThrustIncreaseFactor	=	1.05	--	How quickly thrust is increased.				Default: 1.05

	if LocalPlayer:InVehicle() then
		local vehicle = LocalPlayer:GetVehicle()

		if vehicle:GetClass() == VehicleClass.Air then
			self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
		end
	end

	Events:Subscribe( "LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
end

function VTOL:LocalPlayerEnterVehicle( args )
	if args.is_driver then
		if args.vehicle:GetClass() == VehicleClass.Air then
			if self:CheckList( self.PlaneVehicles, args.vehicle:GetModelId() ) then
				if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end

				self.CurrentThrust = 0
			end
		end
	end
end

function VTOL:LocalPlayerExitVehicle()
	if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
end

function VTOL:CheckThrust()
	self.CurrentThrust = self.CurrentThrust * self.ThrustIncreaseFactor
	if self.CurrentThrust < self.MinThrust then
		self.CurrentThrust = self.MinThrust
	elseif self.CurrentThrust > self.MaxThrust then
		self.CurrentThrust = self.MaxThrust
	end
	self.ReverseThrust = self.CurrentThrust
	if self.ReverseThrust > self.MaxReverseThrust then
		self.ReverseThrust = self.MaxReverseThrust
	end
end

function VTOL:LocalPlayerInput( args )
	if Game:GetState() ~= GUIState.Game then return end
	local vehicle = LocalPlayer:GetVehicle()

	if LocalPlayer:InVehicle() and IsValid( vehicle ) and vehicle:GetDriver() == LocalPlayer then
		if self:CheckList( self.PlaneVehicles, vehicle:GetModelId() ) then
			local vehicleVelocity = vehicle:GetLinearVelocity()

			if args.input == Action.Handbrake and self.ReverseThrustActive and not LocalPlayer:GetValue( "Freeze" ) then
				self:CheckThrust()
				local vehicleAngle = vehicle:GetAngle()
				local SetThrust	= vehicleVelocity + vehicleAngle * Vector3( 0, 0, self.ReverseThrust )
				local SendInfo = {}
				SendInfo.Player		=	LocalPlayer
				SendInfo.Vehicle	=	vehicle
				SendInfo.Thrust		=	SetThrust
				Network:Send( "ActivateThrust", SendInfo )
			end
		end
	end
end

function VTOL:CheckList( tableList, modelID )
	for k,v in ipairs(tableList) do
		if v == modelID then return true end
	end
	return false
end

vtol = VTOL()