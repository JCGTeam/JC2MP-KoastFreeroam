class 'VTOL'

function VTOL:__init()
	self.namept = "Нажмите R чтобы включить автопилот."
	self.ReverseThrustActive	=	true	--	Whether or not Reverse Thrust is active by default.	Default: true
	self.ReverseKey			=	88		--	The key to activate Reverse Thrust, this is X by default.						Default: 88
	self.PlaneVehicles		=	{24, 30, 34, 39, 51, 59, 81, 85}	--	A list of all vehicle IDs of planes.

	self.MaxThrust				=	0.3		--	The maximum thrust speed.						Default: 10
	self.MinThrust				=	0.1		--	The minimum thrust speed.						Default: 0.1
	self.CurrentThrust			=	0		--	The starting thrust speed.						Default: 0
	self.MaxReverseThrust		=	1.5		--	The maximum speed a plane can go in reverse.	Default: 1.5
	self.ThrustIncreaseFactor	=	1.05	--	How quickly thrust is increased.				Default: 1.05

	if LocalPlayer:InVehicle() then
		self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
		self.PreTickEvent = Events:Subscribe( "PreTick", self, self.Thrust )
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
end

function VTOL:Lang()
	self.namept = "Press R to enable autopilot panel."
end

function VTOL:LocalPlayerEnterVehicle()
	local vehicle = LocalPlayer:GetVehicle()
	if LocalPlayer:GetState() == PlayerState.InVehicle and IsValid(vehicle) and vehicle:GetDriver() == LocalPlayer then
		vehicleModel = vehicle:GetModelId()
		if self:CheckList(self.PlaneVehicles, vehicleModel) then
			if not self.RenderEvent then
				self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
			end

			if not self.PreTickEvent then
				self.PreTickEvent = Events:Subscribe( "PreTick", self, self.Thrust )
			end

			if not self.hinttimer then
				self.hinttimer = Timer()
			else
				self.hinttimer:Restart()
			end

			self.CurrentThrust = 0
		end
	end
end

function VTOL:LocalPlayerExitVehicle()
	if self.RenderEvent then
		Events:Unsubscribe( self.RenderEvent )
		self.RenderEvent = nil
	end

	if self.PreTickEvent then
		Events:Unsubscribe( self.PreTickEvent )
		self.PreTickEvent = nil
	end

	if self.KeyUpEvent then
		Events:Unsubscribe( self.KeyUpEvent )
		self.KeyUpEvent = nil
	end
end

function VTOL:Render()
	local alpha = 255

	if self.hinttimer and self.hinttimer:GetSeconds() > 10 then
		alpha = math.clamp( 255 - ( ( self.hinttimer:GetSeconds() - 10 ) * 500 ), 0, 255 )

		if self.hinttimer:GetSeconds() > 12 then
			self.hinttimer = nil
		end
	end

	if Game:GetState() ~= GUIState.Game or LocalPlayer:GetValue( "HiddenHUD" ) then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if not LocalPlayer:GetVehicle() then return end
	if not self.hinttimer then return end

	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end

	local vehicle = LocalPlayer:GetVehicle()

	if LocalPlayer:GetState() == PlayerState.InVehicle and IsValid(vehicle) and vehicle:GetDriver() == LocalPlayer then
		local vehicleModel = vehicle:GetModelId()

		if self:CheckList(self.PlaneVehicles, vehicleModel) then
			local size = Render:GetTextSize( self.namept, 14 )
			local pos = Vector2( ( Render.Width - size.x ) / 2, Render.Height - size.y - 30 )
			if LocalPlayer:GetValue( "Boost" ) then
				pos = Vector2( ( Render.Width - size.x ) / 2, Render.Height - size.y - 30 )
			else
				pos = Vector2( ( Render.Width - size.x ) / 2, Render.Height - size.y - 10 )
			end

			Render:DrawShadowedText( pos, self.namept, Color( 255, 255, 255, alpha ), Color( 0, 0, 0, alpha ), 14 )
		end
	end
end

function VTOL:CheckThrust()
	self.CurrentThrust	=	self.CurrentThrust * self.ThrustIncreaseFactor
	if self.CurrentThrust < self.MinThrust then
		self.CurrentThrust	=	self.MinThrust
	elseif self.CurrentThrust > self.MaxThrust then
		self.CurrentThrust	=	self.MaxThrust
	end
	self.ReverseThrust	=	self.CurrentThrust
	if self.ReverseThrust > self.MaxReverseThrust then
		self.ReverseThrust = self.MaxReverseThrust
	end
end

function VTOL:Thrust( args )
	if Game:GetState() ~= GUIState.Game then return end
	local vehicle = LocalPlayer:GetVehicle()

	if LocalPlayer:GetState() == PlayerState.InVehicle and IsValid(vehicle) and vehicle:GetDriver() == LocalPlayer then
		local vehicleModel = vehicle:GetModelId()

		if self:CheckList(self.PlaneVehicles, vehicleModel) then
			local VehicleVelocity = vehicle:GetLinearVelocity()
			if IsValid(vehicle) then
				if Key:IsDown(self.ReverseKey) and self.ReverseThrustActive and not LocalPlayer:GetValue( "Freeze" ) then
					self:CheckThrust()
					local VehicleAngle = vehicle:GetAngle()
					local SetThrust	= VehicleVelocity + VehicleAngle * Vector3( 0, 0, self.ReverseThrust )
					local SendInfo = {}
						SendInfo.Player		=	LocalPlayer
						SendInfo.Vehicle	=	vehicle
						SendInfo.Thrust		=	SetThrust
					Network:Send( "ActivateThrust", SendInfo )
				end
			end
		end
	end
end

function VTOL:CheckList( tableList, modelID )
	for k,v in pairs(tableList) do
		if v == modelID then return true end
	end
	return false
end

vtol = VTOL()