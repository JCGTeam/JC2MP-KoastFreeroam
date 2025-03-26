
ShadedRectangle = {}

ShadedRectangle.Create = function(...)
	local baseRect = BaseWindow.Create(...)

	local darkRect = Rectangle.Create(baseRect)
	darkRect:SetSizeAutoRel(Vector2.One)

	baseRect:SetDataObject("darkRect" , darkRect)
	
	function baseRect:SetColor(color)
		local colorLight = math.lerp(color , Color.White , 0.1)
		colorLight.a = color.a

		local darkRect = self:GetDataObject("darkRect")
		darkRect:SetColor(color)
	end

	baseRect:SetColor(Color.Gray)

	return baseRect
end
