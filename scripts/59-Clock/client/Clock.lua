class 'Clock'

function Clock:__init()
	Events:Subscribe( "Render", self, self.Render )
end

function Clock:Render()
	if Game:GetState() ~= GUIState.Game or Game:GetSetting(4) <= 1 then return end
	if not LocalPlayer:GetValue( "ClockVisible" ) or LocalPlayer:GetValue( "HiddenHUD" ) then return end

	local format = LocalPlayer:GetValue( "ClockPendosFormat" ) and "%I:%M:%S %p" or "%X"

	local time_txt = os.date( format )
	local date_txt = os.date( "%d/%m/%Y" )

	local sett_alpha = Game:GetSetting(4) * 2.25
	local shadow_clr = Color( 25, 25, 25, sett_alpha )
	local position = Vector2( 20, Render.Height * 0.31 )

	Render:SetFont( AssetLocation.Disk, "Archivo.ttf" )
	Render:DrawShadowedText( position, time_txt, Color( 255, 255, 255, sett_alpha ), shadow_clr, 24 )

	local height = Render:GetTextHeight("A") * 1.5
	position.y = position.y + height

	Render:DrawShadowedText( position, date_txt, Color( 255, 165, 0, sett_alpha ), shadow_clr, 16 )
end

clock = Clock()