class 'Clock'

function Clock:__init()
	Events:Subscribe( "Render", self, self.Render )
end

function Clock:Render()
	if Game:GetState() ~= GUIState.Game or Game:GetSetting(4) <= 1 then return end
	if not LocalPlayer:GetValue( "ClockVisible" ) or LocalPlayer:GetValue( "HiddenHUD" ) then return end

	local format = LocalPlayer:GetValue( "ClockPendosFormat" ) and "%I:%M:%S %p" or "%X"

	local position = Vector2( 20, Render.Height * 0.31 )
	local textTime = os.date( format )
	local textDate = os.date( "%d/%m/%Y" )

	Render:SetFont( AssetLocation.Disk, "Archivo.ttf" )
	Render:DrawShadowedText( position, textTime, Color( 255, 255, 255, Game:GetSetting(4) * 2.25 ), Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 24 )

	local height = Render:GetTextHeight("A") * 1.5
	position.y = position.y + height
	Render:DrawShadowedText( position, textDate, Color( 255, 165, 0, Game:GetSetting(4) * 2.25 ), Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 16 )
end

clock = Clock()