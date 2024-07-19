class "Grenades"

function Grenades:__init()
	Network:Subscribe( "GrenadeTossed", self, self.GrenadeTossed )
	Network:Subscribe( "GrenadeExplode", self, self.GrenadeExplode )
end

function Grenades:GrenadeTossed( args, sender )
	Network:SendNearby(sender, "GrenadeTossed", args)
	if sender:GetValue( "FireworksTossed" ) then
		sender:SetNetworkValue( "FireworksTossed", sender:GetValue( "FireworksTossed" ) + 1 )
	end
end

function Grenades:GrenadeExplode( args, sender )
	local distance = sender:GetPosition():Distance( args.position )

	if distance < args.type.radius then
		local falloff = (args.type.radius - distance) / (args.type.radius * 0.6)

		if not sender:GetValue("Passive") then
			sender:Damage(falloff)

			if sender:InVehicle() then
				local vehicle = sender:GetVehicle()

				vehicle:SetHealth(vehicle:GetHealth() - falloff)
				vehicle:SetLinearVelocity(vehicle:GetLinearVelocity() + ((vehicle:GetPosition() - args.position):Normalized() * args.type.radius * 2 * falloff))
			end
		end
	end
end

grenades = Grenades()