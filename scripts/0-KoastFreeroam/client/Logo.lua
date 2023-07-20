class 'Logo'

function Logo:__init()
	Events:Subscribe( "Render", self, self.Render )
	if LocalPlayer:GetValue( "KoastBuild" ) then
		print( "KMod ( Version: " .. LocalPlayer:GetValue( "KoastBuild" ) .. " ) loaded." )
	else
		print( "KMod loaded." )
	end
end

function Logo:Render()
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	Render:DrawText( Vector2( 20, (Render.Height - 30) ), "Koast Freeroam!", Color( 255, 255, 255, 30 ), TextSize.Default )
end

logo = Logo()