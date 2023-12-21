class 'Crosshair'

local blacklist = { 64, 24, 53, 20, 75, 30, 47, 83, 32, 90, 61, 89, 43, 74, 21, 11 }

function Crosshair:__init()
	LocalPlayer:SetValue( "CustomCrosshairVisible", 1 )

	self.cooltime = 0
	self.alpha = 0
	self.size = 3
	self.crosscolor = Color.White

	self.blacklist = {
		actions = { 
			[Action.LookUp] = false,
			[Action.LookDown] = false,
			[Action.LookLeft] = false,
			[Action.LookRight] = false
		},

		animations = { 
			[AnimationState.SDead] = true,
		},

		animations2 = { 
			[AnimationState.SReeledFireHook] = true,
			[AnimationState.SHangFireHook] = true,
			[AnimationState.SHitByGrapplinghook] = true,
			[AnimationState.SReeledWaitForHook] = true,
			[AnimationState.SSwimDiveNavigation] = true,
			[AnimationState.SSwimDiveIdle] = true,
			[AnimationState.SSwimDiveRotateCcw] = true,
			[AnimationState.SSwimDiveRotateCw] = true,
			[AnimationState.SAirborneRagdoll] = true,
			[AnimationState.SUncontrolledFlightProtect] = true,
			[AnimationState.SHitreactUncontrolledFlight] = true,
			[AnimationState.SHitreactUncontrolledFlightPosematching] = true,
			[AnimationState.SHitreactGetUpBlendin] = true,
			[AnimationState.SUncontrolledSkydive] = true,
		},

		animations3 = { 
			[AnimationState.SSkydive] = true,
			[AnimationState.SSkydiveDash] = true,
		},

		animations4 = { 
			[AnimationState.SRollLeft] = true,
			[AnimationState.SReelStart] = true,
			[AnimationState.SReelFlight] = true,
			[AnimationState.SIdleMg] = true,
			[AnimationState.SWalkMg] = true,
			[AnimationState.SAimMg] = true,
			[AnimationState.SIdleFixedMg] = true,
			[AnimationState.SExitMgWithMg] = true,
			[AnimationState.SIdleFmg] = true,
			[AnimationState.SExitFmg] = true,
			[AnimationState.SVictimHitreact3] = true,
			[AnimationState.SClingStuntpositionIdle] = true,
			[AnimationState.SClingRightToIdlePart1] = true,
			[AnimationState.SClingRightToIdlePart2] = true,
			[AnimationState.SClingMidToRightPart1] = true,
			[AnimationState.SClingMidToLeftPart1] = true,
			[AnimationState.SClingLeftToIdlePart1] = true,
			[AnimationState.SClingLeftToIdlePart2] = true,
			[AnimationState.SClingLeanLeft] = true,
			[AnimationState.SClingLeanRight] = true,
			[AnimationState.SClingLftToRoof] = true,
			[AnimationState.SClingRgtToRoof] = true,
			[AnimationState.SRoofToCling] = true,
			[AnimationState.SRoofToClingInterupt] = true,
			[AnimationState.SClingMidToRoof] = true,
			[AnimationState.SClingMidToRoofInterupt] = true,
			[AnimationState.SCartwheel] = true,
			[AnimationState.SCartwheelInterupt] = true,
		}
	}

	Events:Subscribe( "GetOption", self, self.GetOption )
end

function Crosshair:GetOption( args )
	if args.actCH then
		if not self.RenderEvent then
			self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
			self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
			self.EntityBulletHitEvent = Events:Subscribe( "EntityBulletHit", self, self.EntityBulletHit )
		end
	else
		if self.RenderEvent then
			Game:FireEvent( "gui.aim.show" )
			Events:Unsubscribe( self.RenderEvent )
			self.RenderEvent = nil
			Events:Unsubscribe( self.LocalPlayerInputEvent )
			self.LocalPlayerInputEvent = nil
			Events:Unsubscribe( self.EntityBulletHitEvent )
			self.EntityBulletHitEvent = nil
		end

		if self.popalTimer then
			self.popalTimer = nil
		end
	end
end

function Crosshair:EntityBulletHit()
	if self.popalTimer then
		self.popalTimer:Restart()
	else
		self.popalTimer = Timer()
	end

	self.crosscolor = Color.Red
end

function Crosshair:CheckList( tableList, modelID )
	for k,v in pairs(tableList) do
		if v == modelID then return true end
	end
	return false
end

function Crosshair:GetRotation()
	local frac = math.sin( Client:GetElapsedSeconds() *5 ) * 0.5 + 0.5
	self.alpha = math.lerp( 50, 255, frac )
end

function Crosshair:Render()
	if self.popalTimer and self.popalTimer:GetSeconds() >= 0.1 then
		self.popalTimer = nil
	end

	if Game:GetState() ~= GUIState.Game then return end
	Game:FireEvent( "gui.aim.hide" )

	if not LocalPlayer:GetValue( "CustomCrosshairVisible" ) then return end
	if LocalPlayer:GetValue( "SpectatorMode" ) then return end

	if not self.popalTimer and LocalPlayer:GetAimTarget() then
		local aimTarget = LocalPlayer:GetAimTarget()
		if aimTarget.player or aimTarget.vehicle or (aimTarget.entity and aimTarget.entity.__type == 'ClientActor') then
			self.crosscolor = Color.LawnGreen
		else
			self.crosscolor = Color.White
		end
	end	

	local bs = LocalPlayer:GetBaseState()
	local las = LocalPlayer:GetLeftArmState()

	if self.blacklist.animations[bs] then return end
	--self.size = Render.Height / 400
	local pos_2d = Vector2( Render.Size.x / 2, Render.Size.y / 2 )
	--[[if not LocalPlayer:InVehicle() and not self.blacklist.animations2[bs] and LocalPlayer:GetEquippedSlot() <= 3 and not self.blacklist.animations3[bs] and not LocalPlayer:GetValue( "Passive" ) then
		--Тут хуйня для рисовки перекрестья
	end]]--

	local Transform = Transform2()
	Transform:Translate( pos_2d )
	Render:SetTransform( Transform )

	local velocity = -LocalPlayer:GetAngle() * LocalPlayer:GetLinearVelocity()
	self.velocity = -velocity.z
	local ray = Physics:Raycast( Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, 1000 )

	if ray.distance < 83 and ray.distance > 1 then
		self:GetRotation()
		self.distance = ray.distance
		self.position = ray.position
		self.normal = ray.normal
	else
		self.distance = 0
	end

	if LocalPlayer:GetVehicle() and LocalPlayer:InVehicle() then
		local vehicle = LocalPlayer:GetVehicle()
		local LocalVehicleModel	= vehicle:GetModelId()

		if LocalPlayer:GetSeat() ~= 6 and LocalPlayer:GetSeat() ~= 7 and not self:CheckList( blacklist, LocalVehicleModel ) then
			if vehicle:GetModelId() == 88 then
				if vehicle:GetTemplate() == "Default" then return end
			elseif vehicle:GetModelId() == 36 or vehicle:GetModelId() == 77 or vehicle:GetModelId() == 56 or vehicle:GetModelId() == 18 then
				if vehicle:GetTemplate() == "Gimp" then return end
			elseif vehicle:GetModelId() == 7 or vehicle:GetModelId() == 77 or vehicle:GetModelId() == 56 or vehicle:GetModelId() == 18 then
				if vehicle:GetTemplate() ~= "Armed" and vehicle:GetTemplate() ~= "FullyUpgraded" and vehicle:GetTemplate() ~= "" and vehicle:GetTemplate() ~= "Cannon" then return end
			else
				if vehicle:GetTemplate() ~= "Armed" and vehicle:GetTemplate() ~= "FullyUpgraded" and vehicle:GetTemplate() ~= "Dome" and vehicle:GetTemplate() ~= "Cutscene" and vehicle:GetTemplate() ~= "Mission" then return end
			end
		end
	end

	if self.distance > 1 and (self.distance > 1 or (self.velocity > 20)) and not LocalPlayer:InVehicle() and not self.blacklist.animations2[bs] and not self.blacklist.animations2[las] and not self.blacklist.animations4[bs] then
		if LocalPlayer:GetValue( "GameMode" ) ~= "Охота" then
			Render:DrawLine( Vector2( 4, 4 ), Vector2( 3, 3 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( -4, -4 ), Vector2( -3, -3 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( -4, 4 ), Vector2( -3, 3 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( 4, -4 ), Vector2( 3, -3 ), Color( 0, 0, 0, self.alpha ) )

			Render:DrawLine( Vector2( 14, 14 ), Vector2( 15, 15 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( -14, -14 ), Vector2( -15, -15 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( -14, 14 ), Vector2( -15, 15 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( 14, -14 ), Vector2( 15, -15 ), Color( 0, 0, 0, self.alpha ) )

			Render:DrawLine( Vector2( 3, 4 ), Vector2( 13, 14 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( -3, -4 ), Vector2( -13, -14 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( -3, 4 ), Vector2( -13, 14 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( 3, -4 ), Vector2( 13, -14 ), Color( 0, 0, 0, self.alpha ) )

			Render:DrawLine( Vector2( 4, 3 ), Vector2( 14, 13 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( -4, -3 ), Vector2( -14, -13 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( -4, 3 ), Vector2( -14, 13 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( 4, -3 ), Vector2( 14, -13 ), Color( 0, 0, 0, self.alpha ) )

			Render:DrawLine( Vector2( 4, 5 ), Vector2( 14, 15 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( -4, -5 ), Vector2( -14, -15 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( -4, 5 ), Vector2( -14, 15 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( 4, -5 ), Vector2( 14, -15 ), Color( 0, 0, 0, self.alpha ) )

			Render:DrawLine( Vector2( 5, 4 ), Vector2( 15, 14 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( -5, -4 ), Vector2( -15, -14 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( -5, 4 ), Vector2( -15, 14 ), Color( 0, 0, 0, self.alpha ) )
			Render:DrawLine( Vector2( 5, -4 ), Vector2( 15, -14 ), Color( 0, 0, 0, self.alpha ) )

			Render:DrawLine( Vector2( 4, 4 ), Vector2( 14, 14 ), Color( 255, 255, 255, self.alpha ) )
			Render:DrawLine( Vector2( -4, -4 ), Vector2( -14, -14 ), Color( 255, 255, 255, self.alpha ) )
			Render:DrawLine( Vector2( -4, 4 ), Vector2( -14, 14 ), Color( 255, 255, 255, self.alpha ) )
			Render:DrawLine( Vector2( 4, -4 ), Vector2( 14, -14 ), Color( 255, 255, 255, self.alpha ) )
		end
	end

	if not self.blacklist.animations2[bs] then
		Render:FillCircle( Vector2.Zero, self.size / 2, self.crosscolor )
		Render:DrawCircle( Vector2.Zero, self.size / 2, Color.Black )
	end
end

function Crosshair:LocalPlayerInput( args )
	if args.input == Action.ShoulderCam then
		local time = Client:GetElapsedSeconds()

		if time < self.cooltime then
			return
		else
			if LocalPlayer:GetEquippedWeapon() == Weapon( Weapon.Sniper ) then
				if LocalPlayer:GetUpperBodyState() == 347 then
					LocalPlayer:SetValue( "CustomCrosshairVisible", 1 )
				else
					LocalPlayer:SetValue( "CustomCrosshairVisible", tonumber( not LocalPlayer:GetValue( "CustomCrosshairVisible" ) ) )
				end
			end
		end
		self.cooltime = time + 0.3
	else
		if LocalPlayer:GetValue( "GameMode" ) == "FREEROAM" then
			if LocalPlayer:GetEquippedWeapon() ~= Weapon( Weapon.Sniper ) then
				LocalPlayer:SetValue( "CustomCrosshairVisible", 1 )
			end
		end
	end
end

crosshair = Crosshair()