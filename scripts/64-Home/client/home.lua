class 'Home'

function Home:__init()
	local lang = LocalPlayer:GetValue( "Lang" )
    if lang and lang == "EN" then
		self:Lang()
	else
		self.locStrings = {
			sethomepoint = "Точка дома установлена!"
		}
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "BuyHome", self, self.BuyHome )
	Events:Subscribe( "GoHome", self, self.GoHome )
	Events:Subscribe( "BuyHomeTw", self, self.BuyHomeTw )
	Events:Subscribe( "GoHomeTw", self, self.GoHomeTw )

	Network:Subscribe( "SetHome", self, self.SetHome )
	Network:Subscribe( "WarpDoPoof", self, self.WarpDoPoof )
end

function Home:Lang()
	self.locStrings = {
		sethomepoint = "Home point is set!"
	}
end

function Home:BuyHome()
	Network:Send( "SetHome" )
end

function Home:GoHome()
	Network:Send( "GoHome" )
end

function Home:BuyHomeTw()
	Network:Send( "SetHomeTw" )
end

function Home:GoHomeTw()
	Network:Send( "GoHomeTw" )
end

function Home:SetHome()
	Events:Fire( "CastCenterText", { text = self.locStrings["sethomepoint"], time = 6, color = Color.Yellow } )

	local sound = ClientSound.Create( AssetLocation.Game, {
			bank_id = 20,
			sound_id = 20,
			position = Camera:GetPosition(),
			angle = Angle()
	})

	sound:SetParameter(0,1)
end

function Home:WarpDoPoof( position )
    local effect = ClientEffect.Play( AssetLocation.Game, {effect_id = 250, position = position, angle = Angle()} )
end

home = Home()