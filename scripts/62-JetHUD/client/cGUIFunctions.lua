GUIUtil = {}
local M = GUIUtil

-- Rotate a Vector2 about a central point.
M.Rot = function( vec , center , angle )
	-- Copy vector.
	vec = Vector2( vec.x , vec.y )

	vec3 = Vector3( vec.x - center.x , 0 , vec.y - center.y )
	vec3 = Angle( angle , 0 , 0 ) * vec3
	
	vec.x = vec3.x + center.x
	vec.y = vec3.z + center.y

	return vec
end

-- Draws line in 3D space. World position.
M.DrawLine3D = function( pos1 , pos2 , color  )
	Render:DrawLine( pos1 , pos2 , color )
end

M.DrawChar3D = function( char , color , pos , angle , scale )
	if not pos then pos = Vector3( 0, 0, 0 ) end
	if not scale then scale = 0.05 end

	local lines = characters3D[char]

	if lines then
		for n = 1 , #lines do
			-- Copy vectors, don't use them directly!
			local line1 = Vector2( lines[n][1].x , lines[n][1].y )
			local line2 = Vector2( lines[n][2].x , lines[n][2].y )
			-- Scale line.
			line1 = line1 * scale
			line2 = line2 * scale
			-- Transform into Vector3
			line1 = Vector3( line1.x , line1.y , 0 )
			line2 = Vector3( line2.x , line2.y , 0 )
			-- Rotate by angle.
			if angle then
				line1 = angle * line1
				line2 = angle * line2
			end
			-- Set position.
			line1 = line1 + pos
			line2 = line2 + pos
			-- Draw the line.
			Render:DrawLine( line1 , line2 , color )
		end
	else
		print( "Character not found: " , char or "nil" )
	end
end

M.DrawText3D = function( text , color , pos , angle , scale , align )
	if not align then align = "center" end

	-- Determine alignment.
	local start , ending
	if align == "left" then
		start = 1
		ending = text:len()
	elseif align == "right" then
		start = -text:len()
		ending = -0.0001
	elseif align == "center" then
		start = math.ceil(text:len() * -0.5)
		ending = math.floor(text:len() * 0.5)
		-- If text length is even, nudge the text forward.
		if text:len() % 2 == 0 then
			start = start + 0.5
			ending = ending + 0.4999
		end
	else
		return
	end

	local i = 0
	for n = start , ending do
		i = i + 1
		M.DrawChar3D(
			text:sub(i , i) ,
			color ,
			angle * Vector3(n*scale*1.1 , 0 , 0) + pos,
			angle ,
			scale
		)
	end
end

M.DrawAngleGizmo = function( angle )
	local pos
	local vehicle = LocalPlayer:GetVehicle()
	if vehicle then
		pos = vehicle:GetPosition()
	else
		pos = LocalPlayer:GetPosition()
	end

	GUIUtil.DrawLine3D( pos , pos + angle * Vector3 ( 1 , 0 , 0 ) * 3 , red * 0.8 )
	GUIUtil.DrawLine3D( pos , pos + angle * Vector3( 0 , 1 , 0 ) * 3 , green * 0.8 )
	GUIUtil.DrawLine3D( pos , pos + angle * Vector3( 0 , 0 , -1 ) * 3 , blue * 0.8 )
end

_print = print
function printC( color , ... )
	local x = 10
	local y = (0.25 + printCount * 0.02) * Render.Height
	local stringToPrint = "nil"

	local n = 0
	for k , v in pairs({...}) do
		n = n + 1
		x = x + Render:GetTextWidth(stringToPrint)
		stringToPrint = tostring(v)
		Render:DrawText(
			Vector2( x , y ) + Vector2.One ,
			stringToPrint ,
			black
		)
		Render:DrawText(
			Vector2( x , y ) ,
			stringToPrint ,
			color
		)
	end

	printCount = printCount + 1
end

function print( ... )
	printC( white , ... )
end