fontColor       = Color( 255, 255, 255 )
fontUpper       = true
showGroupCount  = true

menuColor       = Color( 173, 216, 230, 170 )
backgroundColor = Color( 10, 10, 10, 200 )
highlightColor  = Color( 173, 216, 230, 130 )
innerRadius     = 60

collection  = nil
selection   = nil

subRender   = nil
subMouse    = nil
subKey      = nil

menuOpen    = false

WarpDoPoof = function( position )
    ClientEffect.Play( AssetLocation.Game, {effect_id = 250, position = position, angle = Angle()} )
end

Network:Subscribe( "WarpDoPoof", WarpDoPoof )

ReceiveTPList = function( args )
	collection = args
	if not subKey then
		subKey = Events:Subscribe( "KeyDown", OnKeyDown )
	end

	if subRecTP then
		Network:Unsubscribe( subRecTP )
		subRecTP = nil
	end
end

subRecTP = Network:Subscribe( "TPList", ReceiveTPList ) 
Network:Send( "RequestTPList" )

OnKeyDown = function( args )
	if args.key == 74 and Game:GetState() == GUIState.Game then
		if subKey then
			Events:Unsubscribe( subKey )
			subKey = nil
		end

		if not subKey then
			subKey = Events:Subscribe( "KeyUp", OnKeyUp )
		end
		OpenMenu()
	end
end

OnKeyUp = function( args )
	if args.key == 74 then
		if subKey then
			Events:Unsubscribe( subKey )
			subKey = nil
		end

		if timerF then
			timerF = nil
		end

		if not subKey then
			subKey = Events:Subscribe( "KeyDown", OnKeyDown )
		end
		if menuOpen then CloseMenu() end
	end
end

OnMouseClick = function( args )
	if type(menu[selection + 2]) == "table" then
		menu = menu[selection + 2]
		sound = ClientSound.Create(AssetLocation.Game, {
					bank_id = 18,
					sound_id = 1,
					position = Camera:GetPosition(),
					angle = Angle()
		})

		sound:SetParameter(0,1)
		return
	end

	sendArgs = {}
	sendArgs.target = menu[selection + 2]
	sendArgs.button = args.button
	Network:Send( "QuickTP", sendArgs )
	CloseMenu()
end

--

OpenMenu = function()
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if not subRender then
		subRender = Events:Subscribe( "PostRender", RenderMenu )
	end

	if not subMouse then
		subMouse = Events:Subscribe( "MouseDown", OnMouseClick )
	end

	Mouse:SetPosition( Vector2( Render.Width / 2, Render.Height / 2 ) )
	Mouse:SetVisible( true )
	Input:SetEnabled( false )

	if not timerF then
		timerF = Timer()
	end

	menu     = collection
	menuOpen = true
end

CloseMenu = function( args )
	if subRender then
		Events:Unsubscribe( subRender )
		subRender = nil
	end

	if subMouse then
		Events:Unsubscribe( subMouse )
		subMouse = nil
	end

	Mouse:SetVisible( false )
	Input:SetEnabled( true )

	border = false

	if timerF then
		timerF = nil
	end

	if sound then
		sound =nil
	end

	menuOpen = false
end

RenderMenu = function( args )
	if Game:GetState() ~= GUIState.Game then return end

	if timerF then
		alpha = 0

		if timerF:GetSeconds() > 0 and timerF:GetSeconds() < 0.1 then
			alpha = math.clamp( 0 + (timerF:GetSeconds() * 10), 0, 100 )
			border = false
			animplay = false
		elseif timerF:GetSeconds() > 0.1 then
			border = true
			animplay = true
			timerF = nil
		end
	end

	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	local count    = #menu - 1
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
	selection      = math.floor(((mouseA + angle - current) / (math.pi * 2)) * count)

	if selection < 0 then selection = selection + count end

	if border then
		Render:FillArea( Vector2( 0, 0 ), Render.Size, backgroundColor )
	end

	if sound then
		sound:SetPosition( Camera:GetPosition() )
	end

	Render:FillArea( Vector2( 0, 0 ), Render.Size, Color( 10, 10, 10, 200 * alpha ) )

	if animplay then
		if count < 3 then Render:FillArea(
			Vector2( ( selection == 0 and count == 2 ) and center.x or 0, 0 ),
			Vector2( count == 1 and Render.Width or center.x, Render.Height ),
			highlightColor
		) else Render:FillTriangle(
			center,
			Vector2( math.cos(selection * (angle*2) - angle + current) * drawRad, math.sin(selection * (angle*2) - angle + current) * drawRad) + center,
			Vector2( math.cos(selection * (angle*2) + angle + current) * drawRad, math.sin(selection * (angle*2) + angle + current) * drawRad) + center,
			highlightColor
		) end
	else
		if count < 3 then Render:FillArea(
			Vector2( ( selection == 0 and count == 2 ) and center.x or 0, 0 ),
			Vector2( count == 1 and Render.Width or center.x, Render.Height ),
			Color( 173, 216, 230, 130 * alpha )
		) else Render:FillTriangle(
			center,
			Vector2( math.cos(selection * (angle*2) - angle + current) * drawRad, math.sin(selection * (angle*2) - angle + current) * drawRad) + center,
			Vector2( math.cos(selection * (angle*2) + angle + current) * drawRad, math.sin(selection * (angle*2) + angle + current) * drawRad) + center,
			Color( 173, 216, 230, 130 * alpha )
		) end
	end

	for i=2, #menu, 1 do
		local t = menu[i]
		if type(t) == "table" then t = t[1] .. (showGroupCount and " [" .. tostring(#t - 1) .. "]" or "") end
		if fontUpper then t = string.upper(t) end

		textSize = Render:GetTextSize(t, size) 
		coord.x  = math.cos(current) * radius + center.x - textSize.x / 2
		coord.y  = math.sin(current) * radius + center.y - textSize.y / 2
		current  = current + angle

		if animplay then
			Render:DrawText( coord + Vector2.One, t, Color( 25, 25, 25, 150 ), size )
			Render:DrawText( coord, t, fontColor, size )

			Render:DrawLine(
				Vector2( math.cos(current) * innerRadius, math.sin(current) * innerRadius) + center, 
				Vector2( math.cos(current) * drawRad, math.sin(current) * drawRad) + center, 
				menuColor
			)
		else
			Render:DrawText( coord + Vector2.One, t, Color( 25, 25, 25, 150 * alpha ), size )
			Render:DrawText( coord, t, Color( 255, 255, 255, 255 * alpha ), size )
			Render:DrawLine(
				Vector2( math.cos(current) * innerRadius, math.sin(current) * innerRadius) + center, 
				Vector2( math.cos(current) * drawRad, math.sin(current) * drawRad) + center, 
				Color( 173, 216, 230, 170 * alpha )
			)
		end
		current = current + angle
	end

	if animplay then
		Render:FillCircle( center, innerRadius, backgroundColor )
		Render:DrawCircle( center, innerRadius, menuColor )
	else
		Render:FillCircle( center, innerRadius, Color( 10, 10, 10, 200 * alpha ) )
		Render:DrawCircle( center, innerRadius, Color( 173, 216, 230, 170 * alpha ) )
	end
end