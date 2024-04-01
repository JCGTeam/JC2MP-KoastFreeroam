class 'QuickTP'

function QuickTP:__init()
	self.fontColor       = Color( 255, 255, 255 )
	self.fontUpper       = true
	self.showGroupCount  = true

	self.menuColor       = Color( 173, 216, 230, 170 )
	self.backgroundColor = Color( 10, 10, 10, 200 )
	self.highlightColor  = Color( 173, 216, 230, 130 )
	self.innerRadius     = 60

	self.menuOpen = false

	Network:Subscribe( "WarpDoPoof", self, self.WarpDoPoof )

	self.subRecTP = Network:Subscribe( "TPList", self, self.ReceiveTPList )

	Network:Send( "RequestTPList" )
end

function QuickTP:WarpDoPoof( position )
    ClientEffect.Play( AssetLocation.Game, {effect_id = 250, position = position, angle = Angle()} )
end

function QuickTP:ReceiveTPList( args )
	self.collection = args

	if not self.subKey then
		self.subKey = Events:Subscribe( "KeyDown", self, self.KeyDown )
	end

	if self.subRecTP then
		Network:Unsubscribe( self.subRecTP )
		self.subRecTP = nil
	end
end

function QuickTP:KeyDown( args )
	if args.key == 74 and Game:GetState() == GUIState.Game then
		if self.subKey then
			Events:Unsubscribe( self.subKey )
			self.subKey = nil
		end

		if not self.subKey then
			self.subKey = Events:Subscribe( "KeyUp", self, self.KeyUp )
		end

		self:OpenMenu()
	end
end

function QuickTP:KeyUp( args )
	if args.key == 74 then
		if self.subKey then
			Events:Unsubscribe( self.subKey )
			self.subKey = nil
		end

		if self.timerF then
			self.timerF = nil
		end

		if not self.subKey then
			self.subKey = Events:Subscribe( "KeyDown", self, self.KeyDown )
		end

		if self.menuOpen then
			self:CloseMenu()
		end
	end
end

function QuickTP:MouseDown( args )
	if type( self.menu[self.selection + 2] ) == "table" then
		self.menu = self.menu[self.selection + 2]
		self.sound = ClientSound.Create(AssetLocation.Game, {
					bank_id = 18,
					sound_id = 1,
					position = Camera:GetPosition(),
					angle = Angle()
		})

		self.sound:SetParameter(0,1)
		return
	end

	local sendArgs = {}
	sendArgs.target = self.menu[self.selection + 2]
	sendArgs.button = args.button

	Network:Send( "QuickTP", sendArgs )

	self:CloseMenu()
end

function QuickTP:OpenMenu()
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	if not self.subRender then
		self.subRender = Events:Subscribe( "PostRender", self, self.PostRender )
	end

	if not self.subMouse then
		self.subMouse = Events:Subscribe( "MouseDown", self, self.MouseDown )
	end

	Mouse:SetPosition( Vector2( Render.Width / 2, Render.Height / 2 ) )
	Mouse:SetVisible( true )
	Input:SetEnabled( false )

	if not self.timerF then
		self.timerF = Timer()
	end

	self.menu = self.collection
	self.menuOpen = true
end

function QuickTP:CloseMenu( args )
	if self.subRender then
		Events:Unsubscribe( self.subRender )
		self.subRender = nil
	end

	if self.subMouse then
		Events:Unsubscribe( self.subMouse )
		self.subMouse = nil
	end

	Mouse:SetVisible( false )
	Input:SetEnabled( true )

	self.border = false

	if self.timerF then
		self.timerF = nil
	end

	if self.sound then
		self.sound = nil
	end

	self.menuOpen = false
end

function QuickTP:PostRender( args )
	if Game:GetState() ~= GUIState.Game then return end

	if self.timerF then
		alpha = 0

		if self.timerF:GetSeconds() > 0 and self.timerF:GetSeconds() < 0.1 then
			alpha = math.clamp( self.timerF:GetSeconds() * 10, 0, 100 )
			self.border = false
			animplay = false
		elseif self.timerF:GetSeconds() > 0.1 then
			self.border = true
			animplay = true
			self.timerF = nil
		end
	end

	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	local count    = #self.menu - 1
	local size     = 42 - count * 1.4
	if size < 12 then size = 12 end

	local radius   = ( Render.Height / 2 ) - 42
	local angle    = math.pi / count
	local center   = Vector2( Render.Width / 2, Render.Height / 2 )
	local drawRad  = 2200

	local current  = count % 2 == 1 and math.pi / 2 or 0
	local textSize = nil
	local coord    = Vector2()

	local mouseP   = Mouse:GetPosition()
	local mouseA   = math.atan2(mouseP.y - center.y, mouseP.x - center.x)
	self.selection = math.floor(((mouseA + angle - current) / (math.pi * 2)) * count)

	if self.selection < 0 then self.selection = self.selection + count end

	if self.border then
		Render:FillArea( Vector2( 0, 0 ), Render.Size, self.backgroundColor )
	end

	if self.sound then
		self.sound:SetPosition( Camera:GetPosition() )
	end

	Render:FillArea( Vector2( 0, 0 ), Render.Size, Color( 10, 10, 10, 200 * alpha ) )

	if animplay then
		if count < 3 then
			Render:FillArea( Vector2( ( self.selection == 0 and count == 2 ) and center.x or 0, 0 ), Vector2( count == 1 and Render.Width or center.x, Render.Height ), self.highlightColor )
		else
			Render:FillTriangle( center, Vector2( math.cos(self.selection * (angle*2) - angle + current) * drawRad, math.sin(self.selection * (angle*2) - angle + current) * drawRad) + center, Vector2( math.cos(self.selection * (angle*2) + angle + current) * drawRad, math.sin(self.selection * (angle*2) + angle + current) * drawRad) + center, self.highlightColor )
		end
	else
		if count < 3 then
			Render:FillArea( Vector2( ( self.selection == 0 and count == 2 ) and center.x or 0, 0 ), Vector2( count == 1 and Render.Width or center.x, Render.Height ), Color( 173, 216, 230, 130 * alpha ) )
		else
			Render:FillTriangle( center, Vector2( math.cos(self.selection * (angle*2) - angle + current) * drawRad, math.sin(self.selection * (angle*2) - angle + current) * drawRad) + center, Vector2( math.cos(self.selection * (angle*2) + angle + current) * drawRad, math.sin(self.selection * (angle*2) + angle + current) * drawRad) + center, Color( 173, 216, 230, 130 * alpha ) )
		end
	end

	for i=2, #self.menu, 1 do
		local t = self.menu[i]
		if type(t) == "table" then t = t[1] .. (self.showGroupCount and " [" .. tostring(#t - 1) .. "]" or "") end
		if self.fontUpper then t = string.upper(t) end

		textSize = Render:GetTextSize(t, size) 
		coord.x  = math.cos(current) * radius + center.x - textSize.x / 2
		coord.y  = math.sin(current) * radius + center.y - textSize.y / 2
		current  = current + angle

		if animplay then
			Render:DrawShadowedText( coord, t, self.fontColor, Color( 25, 25, 25, 150 ), size )

			Render:DrawLine( Vector2( math.cos(current) * self.innerRadius, math.sin(current) * self.innerRadius) + center, Vector2( math.cos(current) * drawRad, math.sin(current) * drawRad) + center, self.menuColor )
		else
			Render:DrawShadowedText( coord, t, Color( 255, 255, 255, 255 * alpha ), Color( 25, 25, 25, 150 * alpha ), size )
			Render:DrawLine( Vector2( math.cos(current) * self.innerRadius, math.sin(current) * self.innerRadius) + center, Vector2( math.cos(current) * drawRad, math.sin(current) * drawRad) + center, Color( 173, 216, 230, 170 * alpha ) )
		end

		current = current + angle
	end

	if animplay then
		Render:FillCircle( center, self.innerRadius, self.backgroundColor )
		Render:DrawCircle( center, self.innerRadius, self.menuColor )
	else
		Render:FillCircle( center, self.innerRadius, Color( 10, 10, 10, 200 * alpha ) )
		Render:DrawCircle( center, self.innerRadius, Color( 173, 216, 230, 170 * alpha ) )
	end
end

quicktp = QuickTP()