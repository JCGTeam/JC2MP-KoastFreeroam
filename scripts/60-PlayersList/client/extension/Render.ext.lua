function Render:DrawBorderedText(pos, text, colour, size, scale)
    Render:DrawText( pos + Vector2( 1, 1 ), text, 
        Color( 0, 0, 0, colour.a * 0.9 ), size, scale );
    Render:DrawText( pos, text, colour, size, scale );
end

function Render:GetScreenSize()
	return { width = Render.Size.x, height = Render.Size.y };
end