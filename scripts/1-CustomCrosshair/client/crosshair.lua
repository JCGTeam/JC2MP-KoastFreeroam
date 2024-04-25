class 'Crosshair'

local blacklist = { 64, 24, 53, 20, 75, 30, 47, 83, 32, 90, 61, 89, 43, 74, 21, 11 }

function Crosshair:__init()
	if not LocalPlayer:GetValue( "CustomCrosshairVisible" ) then
		LocalPlayer:SetValue( "CustomCrosshairVisible", 1 )
	end

	self.cooltime = 0
	self.alpha = 0
	self.size = 3

	self.blacklist = {
		actions = { 
			[Action.LookUp] = false,
			[Action.LookDown] = false,
			[Action.LookLeft] = false,
			[Action.LookRight] = false
		},

		animations = { 
			[AnimationState.SDead] = true
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
			[AnimationState.SUncontrolledSkydive] = true
			--[AnimationState.SDash] = true
		},

		animations3 = { 
			[AnimationState.SSkydive] = true,
			[AnimationState.SSkydiveDash] = true
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
			[AnimationState.SCartwheelInterupt] = true
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
			Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil
			Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil
			Events:Unsubscribe( self.EntityBulletHitEvent ) self.EntityBulletHitEvent = nil
		end

		if self.popalTimer then self.popalTimer = nil end
	end
end

function Crosshair:EntityBulletHit()
	if self.popalTimer then self.popalTimer:Restart() else self.popalTimer = Timer() end

	self.pointColor = Color.Red
end

function Crosshair:CheckList( tableList, modelID )
	for k,v in ipairs(tableList) do
		if v == modelID then return true end
	end
	return false
end

function Crosshair:GetRotation()
	local frac = math.sin( Client:GetElapsedSeconds() * 5 ) * 0.5 + 0.5
	self.alpha = math.lerp( 50, 255, frac )
end

function Crosshair:Render()
	if self.popalTimer and self.popalTimer:GetSeconds() >= 0.1 then self.popalTimer = nil end
	if self.resetTimer and self.resetTimer:GetSeconds() >= 1.25 then self:ShowCrosshair() end

	if Game:GetState() ~= GUIState.Game then return end
	Game:FireEvent( "gui.aim.hide" )

	if not LocalPlayer:GetValue( "CustomCrosshairVisible" ) then return end
	if LocalPlayer:GetValue( "SpectatorMode" ) then return end

	local aimTarget = LocalPlayer:GetAimTarget()
	if not self.popalTimer and aimTarget then
		self.pointColor = ( aimTarget.player or aimTarget.vehicle or ( aimTarget.entity and aimTarget.entity.__type == "ClientActor" ) ) and Color.LawnGreen or Color.White
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

	local ray = Physics:Raycast( Camera:GetPosition(), Camera:GetAngle() * Vector3.Forward, 0, 1000 )

	if ray.position.y > 198 and ray.distance < 83 and ray.distance > 1 then
		self:GetRotation()
		self.distance = ray.distance
		self.position = ray.position
		self.normal = ray.normal
	else
		self.distance = 0
	end

	if LocalPlayer:GetVehicle() and LocalPlayer:InVehicle() then
		local vehicle = LocalPlayer:GetVehicle()
		local vehicleModel = vehicle:GetModelId()
		local seat = LocalPlayer:GetSeat()

		if seat ~= 6 and seat ~= 7 and not self:CheckList( blacklist, vehicleModel ) then
			local vehicleTemplate = vehicle:GetTemplate()
			if vehicleModel == 88 then
				if vehicleTemplate == "Default" then return end
			elseif vehicleModel == 36 or vehicleModel == 77 or vehicleModel == 56 or vehicleModel == 18 then
				if vehicleTemplate == "Gimp" then return end
			elseif vehicleModel == 7 or vehicleModel == 77 or vehicleModel == 56 or vehicleModel == 18 then
				if vehicleTemplate ~= "Armed" and vehicleTemplate ~= "FullyUpgraded" and vehicleTemplate ~= "" and vehicleTemplate ~= "Cannon" then return end
			else
				if vehicleTemplate ~= "Armed" and vehicleTemplate ~= "FullyUpgraded" and vvehicleTemplate ~= "Dome" and vehicleTemplate ~= "Cutscene" and vehicleTemplate ~= "Mission" then return end
			end
		end
	end

	if self.distance > 1 and not LocalPlayer:InVehicle() and not self.blacklist.animations2[bs] and not self.blacklist.animations2[las] and not self.blacklist.animations4[bs] then
		if LocalPlayer:GetValue( "GameMode" ) ~= "Охота" then
			local crossColor = Color( 255, 255, 255, self.alpha )
			local crossColorShadow = Color( 0, 0, 0, self.alpha )

			Render:DrawLine( Vector2( 4, 4 ), Vector2( 3, 3 ), crossColorShadow )
			Render:DrawLine( Vector2( -4, -4 ), Vector2( -3, -3 ), crossColorShadow )
			Render:DrawLine( Vector2( -4, 4 ), Vector2( -3, 3 ), crossColorShadow )
			Render:DrawLine( Vector2( 4, -4 ), Vector2( 3, -3 ), crossColorShadow )

			Render:DrawLine( Vector2( 14, 14 ), Vector2( 15, 15 ), crossColorShadow )
			Render:DrawLine( Vector2( -14, -14 ), Vector2( -15, -15 ), crossColorShadow )
			Render:DrawLine( Vector2( -14, 14 ), Vector2( -15, 15 ), crossColorShadow )
			Render:DrawLine( Vector2( 14, -14 ), Vector2( 15, -15 ), crossColorShadow )

			Render:DrawLine( Vector2( 3, 4 ), Vector2( 13, 14 ), crossColorShadow )
			Render:DrawLine( Vector2( -3, -4 ), Vector2( -13, -14 ), crossColorShadow )
			Render:DrawLine( Vector2( -3, 4 ), Vector2( -13, 14 ), crossColorShadow )
			Render:DrawLine( Vector2( 3, -4 ), Vector2( 13, -14 ), crossColorShadow )

			Render:DrawLine( Vector2( 4, 3 ), Vector2( 14, 13 ), crossColorShadow )
			Render:DrawLine( Vector2( -4, -3 ), Vector2( -14, -13 ), crossColorShadow )
			Render:DrawLine( Vector2( -4, 3 ), Vector2( -14, 13 ), crossColorShadow )
			Render:DrawLine( Vector2( 4, -3 ), Vector2( 14, -13 ), crossColorShadow )

			Render:DrawLine( Vector2( 4, 5 ), Vector2( 14, 15 ), crossColorShadow )
			Render:DrawLine( Vector2( -4, -5 ), Vector2( -14, -15 ), crossColorShadow )
			Render:DrawLine( Vector2( -4, 5 ), Vector2( -14, 15 ), crossColorShadow )
			Render:DrawLine( Vector2( 4, -5 ), Vector2( 14, -15 ), crossColorShadow )

			Render:DrawLine( Vector2( 5, 4 ), Vector2( 15, 14 ), crossColorShadow )
			Render:DrawLine( Vector2( -5, -4 ), Vector2( -15, -14 ), crossColorShadow )
			Render:DrawLine( Vector2( -5, 4 ), Vector2( -15, 14 ), crossColorShadow )
			Render:DrawLine( Vector2( 5, -4 ), Vector2( 15, -14 ), crossColorShadow )

			Render:DrawLine( Vector2( 4, 4 ), Vector2( 14, 14 ), crossColor )
			Render:DrawLine( Vector2( -4, -4 ), Vector2( -14, -14 ), crossColor )
			Render:DrawLine( Vector2( -4, 4 ), Vector2( -14, 14 ), crossColor )
			Render:DrawLine( Vector2( 4, -4 ), Vector2( 14, -14 ), crossColor )
		end
	end

	if not self.blacklist.animations2[bs] then
		Render:FillCircle( Vector2.Zero, self.size / 2, self.pointColor )
		Render:DrawCircle( Vector2.Zero, self.size / 2, Color.Black )
	end
end

function Crosshair:LocalPlayerInput( args )
	if args.input == Action.ShoulderCam then
		local ubs = LocalPlayer:GetUpperBodyState()

		if LocalPlayer:GetEquippedWeapon() == Weapon( Weapon.Sniper ) and ( ubs == 347 or ubs == 353 or ubs == 371 ) then
			if LocalPlayer:GetValue( "CustomCrosshairVisible" ) then
				LocalPlayer:SetValue( "CustomCrosshairVisible", nil )
			end

			if not self.resetTimer then self.resetTimer = Timer() else self.resetTimer:Restart() end
		end
	end
end

function Crosshair:ShowCrosshair()
	local ubs = LocalPlayer:GetUpperBodyState()

	if not ( ubs == 347 or ubs == 353 or ubs == 371 ) then
		if not LocalPlayer:GetValue( "CustomCrosshairVisible" ) then
			LocalPlayer:SetValue( "CustomCrosshairVisible", 1 )

			if self.resetTimer then self.resetTimer = nil end
		end
	end
end

crosshair = Crosshair()