class 'Tips'

function Tips:__init()
	self.active = true

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.tipText = "Чат: T  I Меню сервера: B I Меню действий: V"
		self.adsTag = "[Реклама] "

		Network:Send( "GetAds", { file = "adsRU.txt" } )
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "Render", self, self.Render )

	Network:Subscribe( "LoadAds", self, self.AddAds )
	Network:Subscribe( "SendMessage", self, self.SendMessage )
end

function Tips:Lang()
	self.tipText = "Chat: T  I Server Menu: B I Actions Menu: V"
	self.adsTag = "[Advertising] "

	Network:Send( "GetAds", { file = "adsEN.txt" } )
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
		local text_width = Render:GetTextWidth( self.tipText )
		local chatPos = Chat:GetPosition()

		if LocalPlayer:GetValue( "ChatBackgroundVisible" ) then
			Render:FillArea( chatPos + Vector2( -4, 0 ), Vector2( 508, - Render:GetTextHeight( self.tipText ) * 13.5 ), Color( 0, 0, 0, 80 ) )
		end

		if LocalPlayer:GetValue( "ChatTipsVisible" ) then
			local color = Color( 215, 215, 215 )
			local lineSize = Vector2( 500, 1 )
			local linePos = chatPos + Vector2( 0, 3 )

			Render:FillArea( linePos + Vector2.One, lineSize, Color( 25, 25, 25, 100 ) )
			Render:FillArea( linePos, lineSize, color )

			if LocalPlayer:GetValue( "SystemFonts" ) then Render:SetFont( AssetLocation.SystemFont, "Impact" ) end

			local textpos = chatPos + Vector2( 1, 11 )
			Render:DrawShadowedText( textpos, self.tipText, color, Color( 25, 25, 25, 150 ), 14 )
		end
	end
end

function Tips:AddAds( lines )
	self.ads = {}
	self.adCount = 0

	for i, line in ipairs( lines ) do
		self.adCount = i
		self.ads[i] = line
	end
end

function Tips:SendMessage()
	Chat:Print( self.adsTag, Color.White, self.ads[ math.random( 1, self.adCount or 0 ) ], Color.DarkGray )
end

tips = Tips()