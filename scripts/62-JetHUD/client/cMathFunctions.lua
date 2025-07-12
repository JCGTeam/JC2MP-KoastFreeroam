-- Construct a Color with 0-1 floats.
ColorF = function(r, g, b)
    return Color(r * 255, g * 255, b * 255)
end

-- Construct an Angle in degrees.
AngleD = function(y, p, r)
    return Angle(math.rad(y), math.rad(p), math.rad(r))
end

math.round = function(x)
    return math.floor(x + 0.5)
end

-- Normalized coords to pixels.
ScreenVector2 = function(x, y)
    return Vector2((x * 0.5 + 0.5) * Render.Width, (y * 0.5 + 0.5) * Render.Height)
end

-- From pixels to normalized coords.
NormVector2 = function(x, y)
    return Vector2((x / Render.Width) * 2 - 1, (y / Render.Height) * 2 - 1)
end