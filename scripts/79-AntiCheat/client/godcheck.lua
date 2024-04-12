class 'GodCheck'

function GodCheck:__init()
	self.active = true

	Events:Subscribe( "AntiCheat", self, self.AntiCheat )
	Events:Subscribe( "LocalPlayerBulletHit", self, self.LocalPlayerBulletHit )

	Network:Subscribe( "Checking", self, self.Checking )
	self.phealth = 1
end

function GodCheck:AntiCheat( args )
	self.active = args.acActive
end

function GodCheck:LocalPlayerBulletHit( args )
	if self.active then
		self.phealth = LocalPlayer:GetHealth()
		if args.attacker:GetEquippedWeapon() ~= Weapon( Weapon.Minigun ) then
			if not args.attacker:GetVehicle() then
				if not LocalPlayer:GetVehicle() then
					if LocalPlayer:GetHealth() >= self.phealth then
						if LocalPlayer:GetHealth() > 0 then
							Network:Send( "CheckThisPlayer" )
						end
					end
				end
			end
		end
	end
end

function GodCheck:Checking()
	if LocalPlayer:GetHealth() >= self.phealth then
    	if LocalPlayer:GetHealth() > 0 then
    		Network:Send( "ItsCheater" )
    	end
	end
end

godcheck = GodCheck()