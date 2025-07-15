class "Point"

function Point:__init(position, angle)
    self.position = position
    self.angle = angle
end

function Point:GetPosition()
    return self.position
end

function Point:GetPosition2D()
    return Vector2(self.position.x, self.position.z)
end

function Point:GetAngle()
    return self.angle
end