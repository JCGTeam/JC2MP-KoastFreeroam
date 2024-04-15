class 'HookHit'

function HookHit:__init()
	self.cooldown = 1
	self.cooltime = 0

	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
end

function HookHit:LocalPlayerInput( args )
	if args.input == 124 and LocalPlayer:GetBaseState() == AnimationState.SGrappleSmashLeft then
		local time = Client:GetElapsedSeconds()

		if time > self.cooltime then
			if not LocalPlayer:GetValue( "Passive" ) then
				Network:Send( "HitPlayers" )
			end

			self.cooltime = time + self.cooldown
		end
	end
end

hookhit = HookHit()