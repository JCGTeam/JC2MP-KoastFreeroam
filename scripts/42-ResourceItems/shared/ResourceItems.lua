class "shCash"

function shCash:__init()
	Events:Subscribe( "EntitySpawn", self, self.EntitySpawn )
end

function shCash:EntitySpawn( args )
	if args.entity:GetValue( "Cash" ) then
		print("spawn")
	end
end