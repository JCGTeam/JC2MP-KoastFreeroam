class 'CenterText'

function CenterText:__init()
    Events:Subscribe( "CastCenterText", self, self.CastCenterText )
    Network:Subscribe( "CastCenterText", self, self.CastCenterText )
end

function CenterText:CastCenterText( args )
    self.timerF = Timer()
    self.textF = args.text
	self.timeF = args.time
    self.color = args.color
    self.size = 30
    if not self.RenderEvent then
        self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
    end
end

function CenterText:Render( args )
	if Game:GetState() ~= GUIState.Game then return end	
	if self.timerF and self.textF then
		local alpha = 4

        if self.timerF:GetSeconds() > self.timeF and self.timerF:GetSeconds() < self.timeF + 1 then
            alpha = self.timeF - (self.timerF:GetSeconds() - 1)
        elseif self.timerF:GetSeconds() >= self.timeF + 1 then
            self.timerF = nil
            self.textF = nil
            self.timeF = nil
            self.color= nil
            Events:Unsubscribe( self.RenderEvent )
            self.RenderEvent = nil
            return
        end

        if LocalPlayer:GetValue( "SystemFonts" ) then
            Render:SetFont( AssetLocation.SystemFont, "Impact" )
        end

        local pos = Vector2( Render.Width / 2, Render.Height * 0.42 ) - Render:GetTextSize( self.textF, self.size ) / 2
        col = Copy( self.color )
        col.a = col.a * alpha

        colS = Copy( Color( 0, 0, 0, 80 ) )
        colS.a = colS.a * alpha	

        Render:DrawShadowedText( pos, self.textF, col, colS, self.size )
	end
end

centertext = CenterText()