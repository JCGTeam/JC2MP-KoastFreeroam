class 'HookHit'

function HookHit:__init()
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )

	self.cooldown = 1
	self.cooltime = 0
end

function HookHit:LocalPlayerInput( args )
	if args.input == 124 and LocalPlayer:GetBaseState() == AnimationState.SGrappleSmashLeft then
		local time = Client:GetElapsedSeconds()
		if time < self.cooltime then
			return
		else
			if not LocalPlayer:GetValue( "Passive" ) then
				Network:Send( "HitPlayers" )
			end
		end
		self.cooltime = time + self.cooldown
		return false
	end
end

hookhit = HookHit()