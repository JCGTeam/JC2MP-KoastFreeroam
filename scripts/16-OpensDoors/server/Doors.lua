class 'Doors'

function Doors:__init()
	Network:Subscribe( "GetPlayers", self, self.GetPlayers )
end

function Doors:GetPlayers( args, sender )
	for p in Server:GetPlayers() do
		jDist = sender:GetPosition():Distance( p:GetPosition() )

		if jDist < 50 then
			Network:Send( p, "OpenDoors" )
			Chat:Send( p, p:GetValue( "Lang" ) == "EN" and "[Doors] " or "[Ворота] ", Color.White, sender:GetName() .. ( p:GetValue( "Lang" ) == "EN" and " opened the doors." or " открыл ворота." ), Color.DarkGray )
		end
	end
end

doors = Doors()