class "WidgetsManager"

function WidgetsManager:__init()
	self.textSize = 30

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "Render", self, self.Render )

	self:UpdateBestScoreWidget( 0 )

	Network:Subscribe( "UpdateBestScoreWidget", self, self.UpdateBestScoreWidget )

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.text1 = "Хорошечный"
	end
end

function WidgetsManager:Lang()
	self.text1 = "Fantastic"

	if not self.NetworkObjectValueChangeEvent then self.NetworkObjectValueChangeEvent = Events:Subscribe( "NetworkObjectValueChange", self, self.NetworkObjectValueChange ) end
end

function WidgetsManager:NetworkObjectValueChange( args )
    if args.key == "Lang" then
        self:UpdateBestScoreWidget( self.currentWidget )

		Events:Unsubscribe( self.NetworkObjectValueChangeEvent )
		self.NetworkObjectValueChangeEvent = nil
    end
end

function WidgetsManager:UpdateBestScoreWidget( widget )
	self.currentWidget = widget

	local lang = LocalPlayer:GetValue( "Lang" )

	if widget == 0 then
		self.object = NetworkObject.GetByName( "Drift" )

		if lang and lang == "EN" then
			self.text2 = "Drift:"
		else
			self.text2 = "Дрифтер:"
		end
	elseif widget == 1 then
		self.object = NetworkObject.GetByName( "Tetris" )

		if lang and lang == "EN" then
			self.text2 = "Tetris:"
		else
			self.text2 = "Тетрис:"
		end
	elseif widget == 2 then
		self.object = NetworkObject.GetByName( "Flying" )

		if lang and lang == "EN" then
			self.text2 = "Pigeon:"
		else
			self.text2 = "Голубь:"
		end
	end
end

function WidgetsManager:Render()
	if LocalPlayer:GetValue( "BestRecordVisible" ) and not LocalPlayer:GetValue( "HiddenHUD" ) and Game:GetState() == GUIState.Game then
		if Game:GetSetting(4) >= 1 then
			if LocalPlayer:GetValue( "SystemFonts" ) then Render:SetFont( AssetLocation.SystemFont, "Impact" ) end

			local sett_alpha = Game:GetSetting(4) * 2.25

			if self.object then
				local record = self.object:GetValue("S")
				local text = self.text1 .. " " .. self.text2
				local textSize = 16
				local color = Color( 255, 255, 255, sett_alpha )
				local colorShadow = Color( 25, 25, 25, sett_alpha )
				local position = Vector2( 20, Render.Height * 0.4 )

				Render:DrawShadowedText( position, text, color, colorShadow, textSize - 1 )
				Render:DrawText( position + Vector2( Render:GetTextWidth( self.text1 .. " ", textSize - 1 ), 0 ), self.text2, Color( 255, 165, 0, sett_alpha ), textSize - 1 )

				local bar_pos = position

				local height = Render:GetTextHeight("A") * 1.2
				position.y = position.y + height
				local record = self.object:GetValue("S")

				if record then
					text = tostring( record ) .. " - " .. self.object:GetValue("N")
					Render:DrawText( position + Vector2.One, text, colorShadow, textSize )
					text = tostring( record )
					Render:DrawText( position, text, Color( 0, 150, 255, sett_alpha ), textSize )
					text = tostring( record )
					Render:DrawText( position + Vector2( Render:GetTextWidth( text, textSize ), 0 ), " - ", color, textSize )
					text = tostring( record ) .. " - "
					if self.object:GetValue("C") then
						Render:DrawText( position + Vector2( Render:GetTextWidth( text, textSize ), 0 ), self.object:GetValue("N"), self.object:GetValue("C") + Color( 0, 0, 0, sett_alpha ), textSize )
					end
					text = ""
					for i = 1, self.object:GetValue("E") do text = text .. ">" end
					position.y = position.y + height * 0.95
					Render:SetFont( AssetLocation.Disk, "LeagueGothic.ttf" )
					Render:DrawShadowedText( position, text, color, colorShadow, textSize - 3 )
					Render:ResetFont()
					if LocalPlayer:GetValue( "SystemFonts" ) then Render:SetFont( AssetLocation.SystemFont, "Impact" ) end

					if self.attempt then
						local player = Player.GetById( self.attempt[2] - 1 )

						if player then
							position.y = position.y + height * 0.6
							local alpha = math.min(self.attempt[3], 1)
							text = tostring( self.attempt[1] ) .. " - " .. player:GetName()
							Render:DrawShadowedText( position, text, Color( 255, 255, 255, 255 * alpha ), Color( 25, 25, 25, 150 * alpha ), textSize )
							text = tostring( self.attempt[1] )
							Render:DrawShadowedText( position, text, Color( 240, 220, 70, 255 * alpha ), Color( 25, 25, 25, 150 * alpha ), textSize )

							self.attempt[3] = self.attempt[3] - 0.02
							if self.attempt[3] < 0.02 then self.attempt = nil end
						end
					end
				else
					text = "–"
					Render:DrawShadowedText( position, text, Color( 200, 200, 200, sett_alpha ), colorShadow, textSize )
				end
			end
		end
	end
end

widgetsmanager = WidgetsManager()