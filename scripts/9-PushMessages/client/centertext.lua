class 'CenterText'

function CenterText:__init()
    Events:Subscribe( "CastCenterText", self, self.CastCenterText )
    Network:Subscribe( "CastCenterText", self, self.CastCenterText )
end

function CenterText:CastCenterText( args )
    self.timerF = Timer()
    self.textF = args.text
	self.timeF = args.time or 1
    self.color = args.color or Color.White
    self.shadowColor = Color( 0, 0, 0, 80 )
    self.size = 30
    self.pos = Vector2( Render.Width / 2, Render.Height * 0.42 ) - Render:GetTextSize( self.textF, self.size ) / 2

    if self.fadeOutAnimation then Animation:Stop( self.fadeOutAnimation ) self.fadeOutAnimation = nil end

    Animation:Play( 0, 1, 0.15, easeIOnut, function( value ) self.animationValue = value end )

    if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
end

function CenterText:Render()
	if Game:GetState() ~= GUIState.Game then return end	

    if not self.textF then return end

	if self.timerF then
        local timerFSeconds = self.timerF:GetSeconds()

        if timerFSeconds > self.timeF then
            self.fadeOutAnimation = Animation:Play( self.animationValue, 0, 0.75, easeIOnut, function( value ) self.animationValue = value end, function()
                self.textF = nil
                self.timeF = nil
                self.color = nil
                self.shadowColor = nil
                self.size = nil
                self.pos = nil
                self.animationValue = nil
                self.fadeOutAnimation = nil

                if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
            end )

            self.timerF = nil
        end
    end

    if LocalPlayer:GetValue( "SystemFonts" ) then Render:SetFont( AssetLocation.SystemFont, "Impact" ) end

    local textColor = Color( self.color.r, self.color.g, self.color.b, math.lerp( 0, self.color.a, self.animationValue ) )
    local textShadow = Color( self.shadowColor.r, self.shadowColor.g, self.shadowColor.b, math.lerp( 0,  self.shadowColor.a, self.animationValue ) )

    Render:DrawShadowedText( self.pos, self.textF, textColor, textShadow, self.size )
end

centertext = CenterText()