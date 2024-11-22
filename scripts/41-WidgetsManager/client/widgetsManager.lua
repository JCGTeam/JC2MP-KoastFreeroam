class "WidgetsManager"

function WidgetsManager:__init()
	self.textSize = 15

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
    if args.key == "Lang" and args.object.__type == "LocalPlayer" then
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
			self.text2 = "Drift"
		else
			self.text2 = "Дрифтер"
		end
	elseif widget == 1 then
		self.object = NetworkObject.GetByName( "Tetris" )

		if lang and lang == "EN" then
			self.text2 = "Tetris"
		else
			self.text2 = "Тетрис"
		end
	elseif widget == 2 then
		self.object = NetworkObject.GetByName( "Flying" )

		if lang and lang == "EN" then
			self.text2 = "Flying"
		else
			self.text2 = "Полет"
		end
	end
end

function WidgetsManager:Render()
	if LocalPlayer:GetValue( "BestRecordVisible" ) and not LocalPlayer:GetValue( "HiddenHUD" ) and Game:GetState() == GUIState.Game then
		local gameAlpha = Game:GetSetting(4)

		if gameAlpha >= 1 then
			if LocalPlayer:GetValue( "SystemFonts" ) then Render:SetFont( AssetLocation.SystemFont, "Impact" ) end

			local sett_alpha = gameAlpha * 2.25

			if self.object then
				local record = self.object:GetValue( "S" )
				local text = self.text1 .. " " .. self.text2
				local color = Color( 255, 255, 255, sett_alpha )
				local color2 = Color( 185, 215, 255, sett_alpha )
				local colorShadow = Color( 25, 25, 25, sett_alpha )
				local position = Vector2( 20, Render.Height * 0.4 )

				Render:DrawShadowedText( position, self.text1, color, colorShadow, self.textSize )
				Render:DrawShadowedText( position + Vector2( Render:GetTextWidth( self.text1 .. " ", self.textSize ), 0 ), self.text2, color2, colorShadow, self.textSize )

				local height = Render:GetTextHeight( "A" ) * 1.2
				position.y = position.y + height
				local record = self.object:GetValue( "S" )

				if record then
					Render:DrawShadowedText( position, tostring( record ), color2, colorShadow, self.textSize )
					Render:DrawShadowedText( position + Vector2( Render:GetTextWidth( tostring( record ), self.textSize ), 0 ), " - ", color, colorShadow, self.textSize )
					if self.object:GetValue( "C" ) then
						Render:DrawShadowedText( position + Vector2( Render:GetTextWidth( tostring( record ) .. " - ", self.textSize ), 0 ), self.object:GetValue( "N" ), self.object:GetValue( "C" ) + Color( 0, 0, 0, sett_alpha ), colorShadow, self.textSize )
					end

					position.y = position.y + height * 1.05

					local bar_len = ( self.object:GetValue("E") or 0 ) * 3
					Render:FillArea( position + Vector2.One, Vector2( bar_len, 3 ), Color( 0, 0, 0, sett_alpha ) )
					Render:FillArea( position, Vector2( 30, 3 ), Color( 0, 0, 0, sett_alpha / 2 ) )
					Render:FillArea( position, Vector2( bar_len, 3 ), Color( 255, 255, 255, sett_alpha ) )

					if LocalPlayer:GetValue( "SystemFonts" ) then Render:SetFont( AssetLocation.SystemFont, "Impact" ) end

					if self.attempt then
						local player = Player.GetById( self.attempt[2] - 1 )

						if player then
							local alpha = math.min( self.attempt[3], 1 )

							position.y = position.y + height * 0.6
							text = tostring( self.attempt[1] ) .. " - " .. player:GetName()
							Render:DrawShadowedText( position, text, Color( 255, 255, 255, 255 * alpha ), Color( 25, 25, 25, 150 * alpha ), self.textSize )
							text = tostring( self.attempt[1] )
							Render:DrawShadowedText( position, text, Color( 240, 220, 70, 255 * alpha ), Color( 25, 25, 25, 150 * alpha ), self.textSize )

							self.attempt[3] = self.attempt[3] - 0.02
							if self.attempt[3] < 0.02 then self.attempt = nil end
						end
					end
				else
					text = "–"
					Render:DrawShadowedText( position, text, Color( 200, 200, 200, sett_alpha ), colorShadow, self.textSize )
				end
			end
		end
	end
end

widgetsmanager = WidgetsManager()