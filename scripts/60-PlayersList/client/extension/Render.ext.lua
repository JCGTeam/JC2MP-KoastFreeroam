function Render:DrawBorderedText(pos, text, colour, size, scale)
    Render:DrawShadowedText( pos, text, colour, Color( 0, 0, 0, colour.a * 0.9 ), size, scale );
end

function Render:GetScreenSize()
	return { width = Render.Size.x, height = Render.Size.y };
end