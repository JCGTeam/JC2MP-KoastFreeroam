function Render:DrawShadowedText( pos, string, color, shadowColor, size, scale )
	Render:DrawText( pos + Vector2.One, string, shadowColor, ( size or 16 ), ( scale or 1 ) )
	Render:DrawText( pos, string, color, ( size or 16 ), ( scale or 1 ) )
end

function playerNameContains( name, filter )
	return string.match( name:lower(), filter:lower() ) ~= nil
end

function easeInOut( t )
    return t < 0.5 and 4 * t * t * t or 1 - math.pow( -2 * t + 2, 3 ) / 2
end