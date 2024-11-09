class 'QuickTP'

function QuickTP:__init()
	self.fontColor       = Color( 255, 255, 255 )
	self.fontShadow      = Color( 25, 25, 25 )
	self.fontUpper       = true
	self.showGroupCount  = true

	self.menuColor       = Color( 185, 215, 255, 170 )
	self.backgroundColor = Color( 10, 10, 10, 200 )
	self.highlightColor  = Color( 185, 215, 255, 120 )
	self.innerRadius     = 50
	self.fontSize = 42

	self.menuOpen = false

	Network:Subscribe( "WarpDoPoof", self, self.WarpDoPoof )

	self.subRecTP = Network:Subscribe( "TPList", self, self.ReceiveTPList )

	Network:Send( "RequestTPList" )
end

function QuickTP:WarpDoPoof( position )
    local effect = ClientEffect.Play( AssetLocation.Game, {effect_id = 250, position = position, angle = Angle()} )
end

function QuickTP:ReceiveTPList( args )
	self.collection = args

	if not self.subKey then self.subKey = Events:Subscribe( "KeyDown", self, self.KeyDown ) end

	if self.subRecTP then Network:Unsubscribe( self.subRecTP ) self.subRecTP = nil end
end

function QuickTP:KeyDown( args )
	if args.key == 74 and Game:GetState() == GUIState.Game then
		if self.subKey then Events:Unsubscribe( self.subKey ) self.subKey = nil end

		if not self.subKey then self.subKey = Events:Subscribe( "KeyUp", self, self.KeyUp ) end

		self:OpenMenu()
	end
end

function QuickTP:KeyUp( args )
	if args.key == 74 then
		if self.subKey then Events:Unsubscribe( self.subKey ) self.subKey = nil end

		if self.timerF then
			self.timerF = nil
		end

		if not self.subKey then self.subKey = Events:Subscribe( "KeyDown", self, self.KeyDown ) end

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

	if not self.subRender then self.subRender = Events:Subscribe( "PostRender", self, self.PostRender ) end
	if not self.subMouse then self.subMouse = Events:Subscribe( "MouseDown", self, self.MouseDown ) end

	Animation:Play( 0, 1, 0.15, easeIOnut, function( value ) self.animationValue = value end )

	Mouse:SetPosition( Vector2( Render.Width / 2, Render.Height / 2 ) )
	Mouse:SetVisible( true )
	Input:SetEnabled( false )

	self.menu = self.collection
	self.menuOpen = true
end

function QuickTP:CloseMenu()
	if self.subRender then Events:Unsubscribe( self.subRender ) self.subRender = nil end
	if self.subMouse then Events:Unsubscribe( self.subMouse ) self.subMouse = nil end

	Mouse:SetVisible( false )
	Input:SetEnabled( true )

	if self.sound then self.sound = nil end

	self.menuOpen = false
end

function QuickTP:PostRender()
	if Game:GetState() ~= GUIState.Game then return end

	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end

	local count = #self.menu - 1
	local size = self.fontSize - count * 1.4
	if size < 12 then size = 12 end

	local radius = ( Render.Height / 2 ) - self.fontSize
	local angle = math.pi / count
	local center = Vector2( Render.Width / 2, Render.Height / 2 )
	local drawRad = 2200

	local current = count % 2 == 1 and math.pi / 2 or 0

	local mouseP = Mouse:GetPosition()
	local mouseA = math.atan2( mouseP.y - center.y, mouseP.x - center.x )
	self.selection = math.floor( ( ( mouseA + angle - current ) / ( math.pi * 2 ) ) * count )

	if self.selection < 0 then self.selection = self.selection + count end

	local fontAlpha = math.lerp( 0, self.fontColor.a, self.animationValue )
	local backgroundColor = Color( self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b, math.lerp( 0, self.backgroundColor.a, self.animationValue ) )
	local highlightColor = Color( self.highlightColor.r, self.highlightColor.g, self.highlightColor.b, math.lerp( 0, self.highlightColor.a, self.animationValue ) )
	local menuColor = Color( self.menuColor.r, self.menuColor.g, self.menuColor.b, math.lerp( 0, self.menuColor.a, self.animationValue ) )

	if self.sound then
		self.sound:SetPosition( Camera:GetPosition() )
	end

	Render:FillArea( Vector2.Zero, Render.Size, backgroundColor )

	if count < 3 then
		Render:FillArea( Vector2( ( self.selection == 0 and count == 2 ) and center.x or 0, 0 ), Vector2( count == 1 and Render.Width or center.x, Render.Height ), highlightColor )
	else
		Render:FillTriangle( center, Vector2( math.cos( self.selection * ( angle * 2 ) - angle + current ) * drawRad, math.sin( self.selection * ( angle * 2 ) - angle + current ) * drawRad ) + center, Vector2( math.cos( self.selection * ( angle * 2 ) + angle + current ) * drawRad, math.sin( self.selection * ( angle * 2 ) + angle + current ) * drawRad ) + center, highlightColor )
	end

	for i=2, #self.menu, 1 do
		local t = self.menu[i]
		if type(t) == "table" then t = t[1] .. ( self.showGroupCount and " (" .. tostring( #t - 1 ) .. ")" or "" ) end
		if self.fontUpper then t = string.upper( t ) end

		local textSize = Render:GetTextSize( t, size ) 
		local coord = Vector2( math.cos( current ) * radius + center.x - textSize.x / 2, math.sin( current ) * radius + center.y - textSize.y / 2 )
		current  = current + angle

		Render:DrawShadowedText( coord, t, Color( self.fontColor.r, self.fontColor.g, self.fontColor.b, fontAlpha ), Color( self.fontShadow.r, self.fontShadow.g, self.fontShadow.b, fontAlpha ), size )
		Render:DrawLine( Vector2( math.cos( current ) * self.innerRadius, math.sin( current ) * self.innerRadius ) + center, Vector2( math.cos( current ) * drawRad, math.sin( current ) * drawRad ) + center, menuColor )

		current = current + angle
	end

	Render:FillCircle( center, self.innerRadius, backgroundColor )
	Render:DrawCircle( center, self.innerRadius, menuColor )
end

quicktp = QuickTP()