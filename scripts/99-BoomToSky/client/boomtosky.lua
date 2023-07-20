class 'BoomToSky'

function BoomToSky:__init()
	self.pvpblock = "Вы не можете использовать это во время боя!"

	Events:Subscribe( "Lang", self, self.Lang )
	Network:Subscribe( "StartBoomToSky", self, self.StartBoomToSky )
	Network:Subscribe( "BoomToSkyEffect", self, self.BoomToSkyEffect )
end

function BoomToSky:Lang()
	self.pvpblock = "You cannot use this during combat!"
end

function BoomToSky:Render()
    if self.flyTimer:GetSeconds() >= 1 then
        Events:Unsubscribe( self.RenderEvent )
        self.RenderEvent = nil
        self.flyTimer = nil
    else
        if LocalPlayer:GetVehicle() then
            LocalPlayer:GetVehicle():SetLinearVelocity( Vector3( LocalPlayer:GetLinearVelocity().x, self.boomvelocity, LocalPlayer:GetLinearVelocity().z ) / 2 or Vector3() )
        else
            LocalPlayer:SetLinearVelocity( Vector3( LocalPlayer:GetLinearVelocity().x, self.boomvelocity, LocalPlayer:GetLinearVelocity().z ) or Vector3() )
        end
    end
end

function BoomToSky:StartBoomToSky( args )
	if LocalPlayer:GetValue( "PVPMode" ) then
		Events:Fire( "CastCenterText", { text = self.pvpblock, time = 6, color = Color.Red } )
	else
		if LocalPlayer:GetBaseState() ~= 212 and LocalPlayer:GetBaseState() ~= 110 then
			if not self.flyTimer then
				local bs = LocalPlayer:GetBaseState()

				if bs == AnimationState.SSkydive or bs == AnimationState.SSkydiveDash then
					Events:Fire( "AbortWingsuit" )
				end

				self.flyTimer = Timer()
				self.RenderEvent = Events:Subscribe( "Render", self, self.Render )

				if args.boomvelocity then
					self.boomvelocity = args.boomvelocity
				end

				Network:Send( "EffectPlay" )

				ClientEffect.Play(AssetLocation.Game, {
					effect_id = 20,
					position = LocalPlayer:GetPosition(),
					angle = Angle()
				})
			end
		else
			Chat:Print( "[Сервер] ", Color.White, "Не удалось выполнить действие :(", Color.DarkGray )
		end
	end
end

function BoomToSky:BoomToSkyEffect( args )
	ClientEffect.Play(AssetLocation.Game, {
		effect_id = 20,
		position = args.targerp:GetPosition(),
		angle = Angle()
	})
end

boomtosky = BoomToSky()