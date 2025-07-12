-- Normalized coords to pixels. From -1 to 1.
NormVector2 = function(arg1, arg2)
    local x, y
    if arg2 then
        x = arg1
        y = arg2
    else
        x = arg1.x
        y = arg1.y
    end

    return Vector2((x * 0.5 + 0.5) * Render.Width, (y * 0.5 + 0.5) * Render.Height)
end

-- Draws shadowed, aligned text.
DrawText = function(pos, text, color, size, alignment, scale)
    if not text then
        print("Warning: trying to draw nil text! This should never happen!")
        print("pos = ", pos, ", color = ", color, ", size = ", size)
        text = "***ERROR***"
    end

    if not alignment then alignment = "left" end

    if alignment == "center" then
        pos = pos + Vector2(Render:GetTextWidth(text, size) * -0.5, Render:GetTextHeight(text, size) * -0.5)
    elseif alignment == "right" then
        pos = pos + Vector2(Render:GetTextWidth(text, size) * -1, Render:GetTextHeight(text, size) * -0.5)
    else -- "left"
        pos = pos + Vector2(0, Render:GetTextHeight(text, size) * -0.5)
    end

    local shadowColor = Copy(settings.shadowColor)
    shadowColor.a = color.a

    Render:DrawShadowedText(pos, text, color, shadowColor, size, scale or 1)
end