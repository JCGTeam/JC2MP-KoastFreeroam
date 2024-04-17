function HUD:__init()
	self.vehicle = nil
	self.colorHUD = settings.colorHUD

	Events:Subscribe( "JHudActive" , self , self.Active )

	if LocalPlayer:GetValue( "JetHUD" ) then
		self:Active()
	end

	self.runways = LoadRunways()
	self.drawColor = Color( 0, 255, 0, 128 )
end

function HUD:Render()
	self.vehicle = LocalPlayer:GetVehicle()

	globals.printCount = 0

	-- Only draw if we're in a proper vehicle and not paused.
	if self:GetIsInAppropriateVehicle() and Game:GetState() == GUIState.Game then
		-- Check all runways
		for index, data in pairs(self.runways) do
			local center = data.center
			local radius = data.radius

			-- Player is close enough
			if Vector3.Distance(LocalPlayer:GetPosition(), center) <= radius then
				local runwayLines = data.runwayLines

				-- Draw all lines
				for index, line in pairs(runwayLines) do
					Render:DrawLine( line.lineStart, line.lineEnd, self.drawColor )
				end
			end
		end
		self:DrawHUD()
		-- self:GUpdate()
	end
end

function HUD:Active()
	if not self.EventRender then
		self.EventRender = Events:Subscribe( "Render" , self , self.Render )
	else
		Events:Unsubscribe( self.EventRender ) self.EventRender = nil
	end
end

function HUD:GetIsInAppropriateVehicle()
	-- If we're not in a vehicle, we don't care.
	if not self.vehicle then
		return
	end

	local modelId = self.vehicle:GetModelId()

	return settings.supportedVehicles[modelId] ~= nil
end

function HUD:GetRoll()
	local angle = self.vehicle:GetAngle()

	return angle.roll
end

function HUD:GetPitch()
	local angle = self.vehicle:GetAngle()

	local pitch = angle.pitch
	if pitch > settings.clampPitch then pitch = settings.clampPitch end
	if pitch < -settings.clampPitch then pitch = -settings.clampPitch end

	return pitch
end

function HUD:GetYaw()
	return self.vehicle:GetAngle().yaw
end