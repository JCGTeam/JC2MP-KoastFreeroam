class 'Admin'

function Admin:__init()
	self.message = ""

	Events:Subscribe( "Lang", self, self.Lang )
	Network:Subscribe( "Notice", self, self.ClientFunction )
end

function Admin:Lang()
	self.pvpblock = "You cannot use this during combat!"
end

function Admin:PostRender()
	if self.timer then
		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		end

		local size = Render.Size.x / 40
		local testpos = Vector2( (Render.Size.x / 1.9) - (Render:GetTextSize( self.message, size ).x / 2), 80 )
	
		Render:DrawShadowedText( testpos, self.message, Color( 255, 210, 0 ), Color( 0, 0, 0 ), size )

		if self.timer:GetSeconds() > 10 then
			self.timer = nil
			self.message = ""
			if self.PostRenderEvent then
				Events:Unsubscribe( self.PostRenderEvent )
				self.PostRenderEvent = nil
			end
		end
	end
end

function Admin:ClientFunction( args )
	self.timer = Timer()
	self.message = args.text
	if not self.PostRenderEvent then
		self.PostRenderEvent = Events:Subscribe( "PostRender", self, self.PostRender )
	end
end

admin = Admin()