function Render:DrawShadowedText( pos, string, color, ShadowColor, size, scale )
	Render:DrawText( pos + Vector2.One, string, ShadowColor, ( size or 16 ), ( scale or 1 ) )
	Render:DrawText( pos, string, color, ( size or 16 ), ( scale or 1 ) )
end