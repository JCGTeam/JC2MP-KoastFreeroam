math.tau = math.pi * 2

-- Takes two Vector2s and draws them in front of the vehicle to simulate an actual HUD.
-- Is rotated by the vehicle's roll.
function HUD:DrawLineHUD(pos1, pos2, noRoll)
    local position = self.vehicle:GetPosition()
    local angle = self.vehicle:GetAngle()

    if noRoll then
        local roll = self:GetRoll()
        pos1 = GUIUtil.Rot(pos1, Vector2.Zero, roll)
        pos2 = GUIUtil.Rot(pos2, Vector2.Zero, roll)
    end

    -- Multiply them by distanceHUD, otherwise, they'll be tiny.
    pos1 = pos1 * settings.distanceHUD * settings.scaleHUD
    pos2 = pos2 * settings.distanceHUD * settings.scaleHUD

    -- Create the 3D vectors.
    local vec1 = Vector3(pos1.x, pos1.y, -settings.distanceHUD)
    vec1 = angle * vec1
    local vec2 = Vector3(pos2.x, pos2.y, -settings.distanceHUD)
    vec2 = angle * vec2

    vec1 = vec1 + position
    vec2 = vec2 + position

    GUIUtil.DrawLine3D(vec1, vec2, self.colorHUD)
end

function HUD:DrawCircleHUD(radius, center, numSegments)
    local posPrevious = Vector2(radius, 0) + center
    local pos

    for n = 1, numSegments do
        pos = Vector2(radius, 0)
        pos = GUIUtil.Rot(pos, Vector2.Zero, (n / numSegments) * math.tau)
        pos = pos + center
        self:DrawLineHUD(pos, posPrevious)
        posPrevious = pos
    end
end

-- pos is a Vector2.
function HUD:DrawTextHUD(text, pos, align, noRoll)
    local position = self.vehicle:GetPosition()
    local angle = self.vehicle:GetAngle()

    -- Rotate around center by vehicle roll.
    local roll = self:GetRoll()
    if noRoll then
        pos = GUIUtil.Rot(pos, Vector2.Zero, roll)
    end

    -- Multiply position by distanceHUD, otherwise it will be tiny.
    pos = pos * settings.distanceHUD * settings.scaleHUD

    -- Convert position to 3D vector.
    pos = Vector3(pos.x, pos.y, -settings.distanceHUD)
    pos = angle * pos
    pos = pos + position

    if noRoll then
        angle = Angle.AngleAxis(roll, angle * Vector3(0, 0, -1)) * angle
    end

    GUIUtil.DrawText3D(text, self.colorHUD, pos, angle, settings.distanceHUD * 0.035 * settings.scaleHUD, align)
end