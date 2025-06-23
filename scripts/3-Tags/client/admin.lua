class 'Admin'

function Admin:__init()
	local lang = LocalPlayer:GetValue( "Lang" )
    if lang and lang == "EN" then
		self:Lang()
	else
		self.locStrings = {
			tag = "[Объявление] "
		}
	end

	self.textColor = Color( 255, 210, 0 )
	self.textColor2 = Color.White

	Events:Subscribe( "Lang", self, self.Lang )
	Network:Subscribe( "Notice", self, self.ClientFunction )
end

function Admin:Lang()
	self.locStrings = {
		tag = "[Notice] "
	}
end

function Admin:PostRender()
	if self.timer and self.message then
		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		end

		local size = 30
		local testpos = Vector2( Render.Size.x / 2 - Render:GetTextWidth( self.locStrings["tag"] .. self.message, size ) / 2, 80 )
		local shadowColor = Color( 0, 0, 0 )

		Render:DrawShadowedText( testpos, self.locStrings["tag"], self.textColor, shadowColor, size )

		testpos.x = testpos.x + Render:GetTextWidth( self.locStrings["tag"], size )

		Render:DrawShadowedText( testpos, self.message, self.textColor2, shadowColor, size )

		if self.timer:GetSeconds() > 10 then
			self.timer = nil
			self.message = nil

			if self.PostRenderEvent then Events:Unsubscribe( self.PostRenderEvent ) self.PostRenderEvent = nil end
		end
	end
end

function Admin:ClientFunction( args )
	self.timer = Timer()
	self.message = args.text

	Chat:Print( self.locStrings["tag"], self.textColor, self.message, self.textColor2 )

	if not self.PostRenderEvent then self.PostRenderEvent = Events:Subscribe( "PostRender", self, self.PostRender ) end
end

admin = Admin()