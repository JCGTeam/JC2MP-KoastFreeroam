class 'Doors'

function Doors:__init()
	Network:Subscribe( "GetPlayers", self, self.GetPlayers )
end

function Doors:GetPlayers( args, sender )
	for p in Server:GetPlayers() do
		jDist = sender:GetPosition():Distance( p:GetPosition() )
		if jDist < 50 then
			Network:Send( p, "OpenDoors" )
			if p:GetValue( "Lang" ) == "EN" then
				Chat:Send( p, "[Doors] ", Color.White, sender:GetName() .. " opened the doors.", Color.DarkGray )
			else
				Chat:Send( p, "[Ворота] ", Color.White, sender:GetName() .. " открыл ворота.", Color.DarkGray )
			end
		end
	end
end

doors = Doors()