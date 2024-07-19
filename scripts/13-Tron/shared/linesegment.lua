class "LineSegment"

function LineSegment:__init( startPoint, endPoint, height, color )
	self.startPoint = startPoint
	self.endPoint = endPoint
	self.height = height
	self.color = color
end

function LineSegment:Length()
	return (self.endPoint:GetPosition() - self.startPoint:GetPosition()):Length()
end

function LineSegment:Intersects2D( segment )
	local point1 = self.startPoint:GetPosition2D()
	local point2 = self.endPoint:GetPosition2D()
	local point3 = segment.startPoint:GetPosition2D()
	local point4 = segment.endPoint:GetPosition2D()
	local s1_x, s1_y, s2_x, s2_y
	local s, t

	s1_x = point2.x - point1.x
	s1_y = point2.y - point1.y
	s2_x = point4.x - point3.x
	s2_y = point4.y - point3.y

	s = (-s1_y * (point1.x - point3.x) + s1_x * (point1.y - point3.y)) / (-s2_x * s1_y + s1_x * s2_y)
	t = ( s2_x * (point1.y - point3.y) - s2_y * (point1.x - point3.x)) / (-s2_x * s1_y + s1_x * s2_y)

	if s >= 0 and s <= 1 and t >= 0 and t <= 1 then
		return true, Vector2(point1.x + (t * s1_x), point1.y + (t * s1_y))
	end

	return false
end

function LineSegment:GetFraction( intersection )
	return (intersection - self.startPoint:GetPosition2D()):Length() / (self.endPoint:GetPosition2D() - self.startPoint:GetPosition2D()):Length()
end

function LineSegment:Intersects(segment) -- This is pretty accurate, but it does /not/ take angles into account; that's a bit beyond the scope of this anyway.
	local intersects, intersection = self:Intersects2D(segment)

	if intersects then
		local collisionY = math.lerp(self.startPoint:GetPosition().y, self.endPoint:GetPosition().y, self:GetFraction(intersection))
		local segmentCollisionY = math.lerp(segment.startPoint:GetPosition().y, segment.endPoint:GetPosition().y, segment:GetFraction(intersection))

		if collisionY >= segmentCollisionY and collisionY <= segmentCollisionY + segment.height or collisionY + self.height >= segmentCollisionY and collisionY + self.height <= segmentCollisionY + segment.height then
			return true, Vector3(intersection.x, collisionY, intersection.y)
		end
	end

	return false
end

function LineSegment:Render()
	assert(Client, "Render can only be called from the Client!")

	local startPoint = self.startPoint
	local endPoint = self.endPoint
	local height = self.height
	local color = self.color

	local startPointPos = startPoint:GetPosition()
	local endPointPos = endPoint:GetPosition()

	Render:FillTriangle( startPointPos, endPointPos + endPoint:GetAngle() * Vector3.Up * height, endPointPos, color )
	Render:FillTriangle( startPointPos, endPointPos + endPoint:GetAngle() * Vector3.Up * height, startPointPos + startPoint:GetAngle() * Vector3.Up * height, color )
end