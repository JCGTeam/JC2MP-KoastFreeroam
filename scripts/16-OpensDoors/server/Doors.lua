class 'Doors'

function Doors:__init()
	self.places = {}

	self:LoadPlaces( "places.txt" )

	Events:Subscribe( "ClientModuleLoad", self, self.ClientModuleLoad )
	Network:Subscribe( "GetPlayers", self, self.GetPlayers )
end

function Doors:LoadPlaces( filename )
    print("Opening " .. filename)
    local file = io.open( filename, "r" )

    if file == nil then
        print( "No places.txt, aborting loading of places" )
        return
    end

    local timer = Timer()

    for line in file:lines() do
        self:ParsePlace( line )
    end

    print( string.format( "Loaded places, %.02f seconds", timer:GetSeconds() ) )

	timer = nil
    file:close()
end

function Doors:ParsePlace( line )
    line = line:gsub( " ", "" )

    local tokens = line:split( "," )
    local pos_str = { tokens[1], tokens[2], tokens[3] }
    local vector = Vector3( tonumber( pos_str[1] ), tonumber( pos_str[2] ), tonumber( pos_str[3] ) )

    self.places[ tokens[1] ] = vector

	table.insert( self.places, { line, vector } )
end

function Doors:ClientModuleLoad( args )
    Network:Send( args.player, "Places", self.places )
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