function Render:DrawShadowedText( pos, string, color, shadowColor, size, scale )
	Render:DrawText( pos + Vector2.One, string, shadowColor, ( size or 16 ), ( scale or 1 ) )
	Render:DrawText( pos, string, color, ( size or 16 ), ( scale or 1 ) )
end