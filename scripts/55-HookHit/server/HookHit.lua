class 'HookHit'

function HookHit:__init()
	Network:Subscribe( "HitPlayers", self, self.HitPlayers )
end

function HookHit:HitPlayers( args, sender )
	for p in Server:GetPlayers() do
		jDist = sender:GetPosition():Distance( p:GetPosition() )
		if jDist < 2 then
			if p ~= sender then
				if not p:GetValue( "Passive" ) then
					p:Damage( 0.1 )
				end
			end
		end
	end
end

hookhit = HookHit()