class 'FreeCam'

function FreeCam:__init()
	self.pause = false
	self.tip = true
	self.speed = 1
	self.speedSetting = 0
	self.speedUp = 8
	self.speedDown = 4
	self.teleport = false
	self.activateKey = 'O'
	self.mouseSensitivity = 0.15
	self.gamepadSensitivity = 0.08
	self.permitted = true

	self.prefix = "[Свободная камера] "
	self.controltip = "[WASD] - Перемещение\n[Shift] - Ускорить движение\n[Ctrl] - Замедлить движение\n[<>] - Изменить угол камеры\n[{}] - Изменить поле зрения камеры\n[X] - Сбросить угол и поле зрения камеры\n[L] - Показать/скрыть черные полосы\n[Z] - Скрыть/показать подсказки"

	self.controltip_clr = Color.White
	self.controltip_shadow = Color.Black
	self.controltip_size = 15

	self.active = false
	self.translation = Vector3.Zero
	self.position = Vector3( 0, 500, 0 )
	self.angle = Angle( 0, 0, 0 )

	self.gamepadPressed = {false, false, false}

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "KeyUp", self, self.KeyUp )

	-- Change permission/force activate
	Network:Subscribe( "FreeCam", function( args )
		if args.perm ~= nil then
			-- Change permission
			self.permitted = args.perm
		end
		if args.active ~= nil then
			-- Set active
			if args.active then
				self:Activate()
			else
				self:Deactivate()
			end
			Network:Send( "FreeCamChange", {["active"] = self.active} ) -- Notice for server
			Events:Fire( "FreeCamChange", {["active"] = self.active} ) -- Notice for client
		end
	end )
end

function FreeCam:Lang()
	self.prefix = "[FREECAM] "
	self.controltip = "[WASD] - Move\n[Shift] - Speed ​​up movement\n[Ctrl] - Slow down movement\n[<>] - Change camera angle\n[{}] - Change camera FOV\n[X] - Reset camera angle and FOV\n[L] - Show/hide black bars\n[Z] - Hide/show tooltips"
end

function FreeCam:Render()
	if self.blackLines then
		local blacklinesize = Render.Size.x / 20
		local linescolor = Color.Black

		Render:FillArea( Vector2.Zero, Vector2( Render.Size.x, blacklinesize ), linescolor )
		Render:FillArea( Vector2( 0, Render.Size.y - blacklinesize ), Vector2( Render.Size.x, blacklinesize ), linescolor )
	end

	if Game:GetState() ~= 0 then
		if Game:GetState() ~= GUIState.Game then return end
	end

	Game:FireEvent( "gui.hud.hide" )

	if self.tip then
		Render:SetFont( AssetLocation.Disk, "Archivo.ttf" )
		Render:DrawShadowedText( Vector2( 50, 50 ), self.controltip, self.controltip_clr, self.controltip_shadow, self.controltip_size )
	end
end

function FreeCam:UpdateCamera()
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	if Game:GetState() ~= 0 then
		if Game:GetState() ~= GUIState.Game then return end
	end

	-- Set speed
	local speed = self.speed
	if self.speedSetting == 1 then
		if Input:GetValue( Action.PlaneIncTrust ) > 0 then
			self.speed = math.min( 1000, self.speed * 1.01 )
		elseif Input:GetValue(Action.PlaneDecTrust) > 0 then
			self.speed = math.max( 0.1, self.speed * 0.99 )
		end
		speed = self.speed
	else
		if Input:GetValue(Action.PlaneIncTrust) > 0 then
			speed = speed * self.speedUp
		elseif Input:GetValue(Action.PlaneDecTrust) > 0 then
			speed = speed / self.speedDown
		end
	end

	-- DEFAULT MODE
	if Key:IsDown(188) then
		self.angle = self.angle * Angle( 0, 0, (speed * 0.02) )
	end
	if Key:IsDown(190) then
		self.angle = self.angle * Angle( 0, 0, - (speed * 0.02) )
	end
	if Key:IsDown(219) then
		self.fov = math.clamp( self.fov + (speed * 0.01), -0.01, 2 )
	end
	if Key:IsDown(221) then
		self.fov = math.clamp( self.fov - (speed * 0.01), -0.01, 2 )
	end
	if Key:IsDown(88) then
		self.angle = Angle( Camera:GetAngle().yaw, 0, 0 )
		self.fov = self.defaultFOV
	end
	-- Set translation
	self.translation = Vector3.Zero
	if Input:GetValue(Action.MoveForward) >= 65535 then -- up
		self.translation = self.translation + Vector3( 0, 0, -1 )
	end
	if Input:GetValue(Action.MoveBackward) >= 65535 then -- down
		self.translation = self.translation + Vector3( 0, 0, 1 )
	end
	if Input:GetValue(Action.MoveLeft) >= 65535 then -- left
		self.translation = self.translation + Vector3( -1, 0, 0 )
	end
	if Input:GetValue(Action.MoveRight) >= 65535 then -- right
		self.translation = self.translation + Vector3( 1, 0, 0 )
	end
	-- Normalize translation
	if self.translation:Length() > 0 then
		self.translation = speed * ( self.translation/norm( self.translation ) )
	end
	-- Set position
	self.position = self.position + self.angle * self.translation
end

function FreeCam:CalcView()
	Camera:SetAngle( self.angle )
	Camera:SetPosition( self.position )
	Camera:SetFOV( self.fov )
	return false
end

function FreeCam:Activate()
	if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
	if not self.CalcViewEvent then self.CalcViewEvent = Events:Subscribe( "CalcView", self, self.CalcView ) end
	if not self.PostTickEvent then self.PostTickEvent = Events:Subscribe( "PostTick", self, self.UpdateCamera ) end
	if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.PlayerInput ) end
	if not self.InputPollEvent then self.InputPollEvent = Events:Subscribe( "InputPoll", self, self.ResetPressed ) end
	if not self.MouseDownEvent then self.MouseDownEvent = Events:Subscribe( "MouseDown", self, self.MouseDown ) end
	if not self.ModuleUnloadEvent then self.ModuleUnloadEvent = Events:Subscribe( "ModuleUnload", self, self.ModuleUnload ) end

	self.active = true
	self.position = LocalPlayer:GetBonePosition("ragdoll_Head")
	self.angle = LocalPlayer:GetAngle()
	self.angle.roll = 0
	self.fov = Camera:GetFOV()
	self.defaultFOV = Camera:GetFOV()

	Game:FireEvent( "gui.hud.hide" )

	Network:Send( "ToggleFreecam", { enabled = true } )
	LocalPlayer:SetValue( "SpectatorMode", 1 )
end

function FreeCam:Deactivate()
	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	if self.CalcViewEvent then Events:Unsubscribe( self.CalcViewEvent ) self.CalcViewEvent = nil end
	if self.PostTickEvent then Events:Unsubscribe( self.PostTickEvent ) self.PostTickEvent = nil end
	if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
	if self.InputPollEvent then Events:Unsubscribe( self.InputPollEvent ) self.InputPollEvent = nil end
	if self.MouseDownEvent then Events:Unsubscribe( self.MouseDownEvent ) self.MouseDownEvent = nil end
	if self.ModuleUnloadEvent then Events:Unsubscribe( self.ModuleUnloadEvent ) self.ModuleUnloadEvent = nil end

	self.active = false
	self.fov = nil
	Camera:SetFOV( self.defaultFOV )
	self.defaultFOV = nil

	if self.teleport then
		Network:Send( "FreeCamTP", {["pos"] = self.position, ["angle"] = self.angle} )
	end

	Game:FireEvent( "gui.hud.show" )

	Network:Send( "ToggleFreecam", { enabled = nil } )

	if IsValid( LocalPlayer ) then
		LocalPlayer:SetValue( "SpectatorMode", nil )
	end
end

function FreeCam:KeyUp( args )
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	if Game:GetState() ~= 0 then
		if Game:GetState() ~= GUIState.Game then return end
	end

	if args.key == string.byte( self.activateKey ) and self.permitted then
		if not self.active then
			self:Activate()
		else
			self:Deactivate()
		end
		Network:Send( "FreeCamChange", {["active"] = self.active} )
		Events:Fire( "FreeCamChange", {["active"] = self.active} )
	end

	if self.active then
		if args.key == 101 then
			self.pause = not self.pause
		elseif args.key == 90 then
			self.tip = not self.tip
		elseif args.key == 76 then
			self.blackLines = not self.blackLines
		end
	end
end

function FreeCam:MouseDown( args )
	if args.button == 2 then
		self.pause = not self.pause
	end
end

function FreeCam:PlayerInput( args )
	if Game:GetState() ~= 0 then
		if Game:GetState() ~= GUIState.Game then return end
	end

	local sensitivity = self.mouseSensitivity
	-- GamePad input
	if Game:GetSetting(GameSetting.GamepadInUse) == 1 then
		sensitivity = self.gamepadSensitivity
	end

	if args.input == Action.LookUp then
		self.angle.pitch = math.clamp( self.angle.pitch - args.state * sensitivity, -math.pi/2, math.pi/2 )
	elseif args.input == Action.LookDown then
		self.angle.pitch = math.clamp( self.angle.pitch + args.state * sensitivity, -math.pi/2, math.pi/2 )
	elseif args.input == Action.LookLeft then
		self.angle.yaw = SetAngleRange( self.angle.yaw + args.state * sensitivity )
	elseif args.input == Action.LookRight then
		self.angle.yaw = SetAngleRange( self.angle.yaw - args.state * sensitivity )
	end
end

function FreeCam:ResetPressed()
	if Input:GetValue(Action.SequenceButton1) == 0 then
		self.gamepadPressed[1] = false
	end
	if Input:GetValue(Action.SequenceButton4) == 0 then
		self.gamepadPressed[2] = false
	end
	if Input:GetValue(Action.SequenceButton3) == 0 then
		self.gamepadPressed[3] = false
	end
end

function FreeCam:ModuleUnload()
	self:Deactivate()
end

freeCam = FreeCam()

---------- SOME TOOLS ----------
function norm( v1, v2 )
	v2 = v2 or v1
	return math.sqrt( Vector3.Dot( v1, v2 ) )
end

function SetAngleRange( angle )
	if angle > math.pi then
		angle = angle - 2*math.pi
	elseif angle < -math.pi then
		angle = angle + 2*math.pi
	end
	return angle
end

-- Get angle difference using the closest distance
function AngleDiff( a1, a2 )
	local diff = Vector3()
	diff.x = AngleDiff2(a1, a2, "yaw")
	diff.y = AngleDiff2(a1, a2, "pitch")
	diff.z = AngleDiff2(a1, a2, "roll")
	return diff
end

function AngleDiff2( a1, a2, axis )	
	local diff = a1[axis] - a2[axis]
	if math.abs(diff) > math.pi then
		if a1[axis] > a2[axis] then
			diff = -(math.pi - math.abs(a1[axis]) + math.pi - math.abs(a2[axis]))
		else
			diff = math.pi - math.abs(a2[axis]) + math.pi - math.abs(a1[axis])
		end
	end
	return diff
end