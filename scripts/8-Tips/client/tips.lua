class 'Tips'

function Tips:__init()
	self.active = true

	if LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.text = "Чат: T  I Меню сервера: B I Меню действий: V"
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "Render", self, self.Render )
end

function Tips:Lang()
	self.text = "Chat: T  I Server Menu: B I Actions Menu: V"
end

function Tips:Render()
	if self.active and Game:GetState() == GUIState.PDA then
		Chat:SetEnabled( false )
		self.activeTw = true
	end

	if self.activeTw and Game:GetState() ~= GUIState.PDA then
		Chat:SetEnabled( true )
		self.active = true
		self.activeTw = false
	end

	if Chat:GetEnabled() and Chat:GetUserEnabled() and not Chat:GetActive() then
		local text_width = Render:GetTextWidth( self.text )
		local chatPos = Chat:GetPosition()

		if LocalPlayer:GetValue( "ChatBackgroundVisible" ) then
			Render:FillArea( chatPos + Vector2( -4, 0 ), Vector2( 508, - Render:GetTextHeight( self.text ) * 13.5 ), Color( 0, 0, 0, 80 ) )
		end

		if LocalPlayer:GetValue( "ChatTipsVisible" ) then
			local color = Color( 215, 215, 215 )
			local linepoint1 = chatPos + Vector2( 0, 3 )
			local linepoint2 = chatPos +  Vector2( 500, 3 )

			Render:DrawLine( linepoint1 + Vector2.One, linepoint2 + Vector2.One, Color( 25, 25, 25, 100 ) )
			Render:DrawLine( linepoint1, linepoint2, color )

			if LocalPlayer:GetValue( "SystemFonts" ) then
				Render:SetFont( AssetLocation.SystemFont, "Impact" )
			end

			local textpos = chatPos + Vector2( 1, 11 )
			Render:DrawShadowedText( textpos, self.text, color, Color( 25, 25, 25, 150 ), 14 )
		end
	end
end

tips = Tips()