class 'SuperGrapple'

function SuperGrapple:__init()
	self.timer = Timer()
	self.distance = 80
	self.destroyTimer = Timer()
	self.disttext = "%i м"

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
end

function SuperGrapple:Lang()
	self.disttext = "%i m"
end

function SuperGrapple:Render()
	if LocalPlayer:GetValue( "LongerGrappleEnabled" ) and LocalPlayer:GetValue( "LongerGrapple" ) then
		if LocalPlayer:InVehicle() or Game:GetState() ~= GUIState.Game or LocalPlayer:GetWorld() ~= DefaultWorld then return end
		local velocity = -LocalPlayer:GetAngle() * LocalPlayer:GetLinearVelocity()
		self.velocity = -velocity.z
		if not self.object then
			local ray = Physics:Raycast(Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, LocalPlayer:GetValue( "LongerGrapple" ) )
			if ray.distance < LocalPlayer:GetValue( "LongerGrapple" ) and ray.distance > 1 then
				self.distance = ray.distance
				self.position = ray.position
				self.normal = ray.normal
			else
				self.distance = 0
			end
		end

		local bs = LocalPlayer:GetBaseState()
		if self.distance > 1 and (self.distance > 80 or (self.velocity > 20 and bs ~= AnimationState.SSkydive)) then
			if LocalPlayer:GetValue( "LongerGrappleVisible" ) and not LocalPlayer:GetValue( "HiddenHUD" ) then
				if bs ~= 45 and bs ~= 43 and bs ~= 41 and bs ~= 208 and bs ~= 38 and bs ~= 47 and bs ~= 42 and bs ~= 191 and bs ~= 56 and bs ~= 143 and bs ~= 142 then
					Render:SetFont( AssetLocation.Disk, "Archivo.ttf" )
					local str = "> " .. string.format( self.disttext, tostring(self.distance) ) .. " <"
					local size = Render.Size.x / 100
					local pos = Vector2( Render.Size.x / 2 - Render:GetTextWidth(str, size) / 2, 30 )
					local sett_alpha = Game:GetSetting(4) * 2.25
					local color = Color( 0, 0, 0, sett_alpha )

					Render:DrawShadowedText( pos, str, Color( 255, 255, 255, sett_alpha ), color, size )
				end
			end
		end
		if self.fire and not self.object and self.distance > 80 then
			local args = {
				collision = "km02.towercomplex.flz/key013_01_lod1-g_col.pfx",
				model = "",
				position = Camera:GetPosition() + (Camera:GetAngle() * (Vector3.Forward * 30)),
				angle = Camera:GetAngle()
			}
			self.object = ClientStaticObject.Create(args)
			self.endposition = self.position + Camera:GetAngle() * Vector3.Forward * 1.5
			self.startposition = args.position
			self.fire = nil
		elseif self.object and self.endposition then
			local dist = Vector3.Distance(LocalPlayer:GetPosition(), self.object:GetPosition())
			if dist < 15 then
				local angle = Angle.FromVectors(Vector3.Up, self.normal) * Angle(0,math.pi/2,0)
				self.object:SetPosition(self.endposition - (angle * (Vector3.Forward * 2)))
				self.object:SetAngle(angle)
				self.endposition = nil
				self.object:Remove()
				self.object = nil
				self.destroyTimer:Restart()
			end
		end
	end
end

function SuperGrapple:ModuleUnload()
	if self.object then self.object:Remove() end
	if self.fx then self.fx:Remove() end
end

function SuperGrapple:LocalPlayerInput( args )
	if LocalPlayer:GetValue( "LongerGrappleEnabled" ) then
		if Game:GetSetting(GameSetting.GamepadInUse) == 0 then
			if args.input == Action.FireGrapple and self.timer:GetSeconds() > 3 then
				self.destroyTimer:Restart()
				if self.object then self.object:Remove() self.object = nil end
				self.fire = true
				self.timer:Restart()
			elseif self.destroyTimer:GetSeconds() > 3 then
				if self.object then self.object:Remove() self.object = nil end
			elseif args.input == Action.GrapplingAction then
				self.grappling = true
			else
				self.fire = false
				self.grappling = false
			end
		end

		if Game:GetSetting(GameSetting.GamepadInUse) == 1 then
			if Input:GetValue(Action.FireGrapple) > 0 then
				self.destroyTimer:Restart()
				if self.object then self.object:Remove() self.object = nil end
				self.fire = true
				self.timer:Restart()
			elseif self.destroyTimer:GetSeconds() > 3 then
				if self.object then self.object:Remove() self.object = nil end
			elseif args.input == Action.GrapplingAction then
				self.grappling = true
			else
				self.fire = false
				self.grappling = false
			end
		end
	end
end

SuperGrapple = SuperGrapple()