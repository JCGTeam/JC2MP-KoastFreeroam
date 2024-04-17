class 'MHCMusicFix'

function MHCMusicFix:__init()
	self.mhc_pos = Vector3( 13199.357421875, 1083.1848144531, -4938.5234375 )
	self.mhc_dist = 700000

	Events:Subscribe( "GameLoad", self, self.GameLoad )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
end

function MHCMusicFix:GameLoad()
	local dist = LocalPlayer:GetPosition():DistanceSqr( self.mhc_pos )

	if not self.sound and dist <= self.mhc_dist then
		self.sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 25,
			sound_id = 148,
			position = self.mhc_pos,
			angle = Angle()
		})

		self.sound:SetParameter(0,0.75)
		self.sound:SetParameter(1,0)
	end

	if not self.PostTickEvent then
		self.timer = Timer()

		self.PostTickEvent = Events:Subscribe( "PostTick", self, self.PostTick )
	end
end

function MHCMusicFix:PostTick()
	if self.sound then self.sound:SetParameter( 0, Game:GetSetting( GameSetting.MusicVolume ) / 100 ) end

	if self.timer:GetSeconds() <= 1 then return end

	self.timer:Restart()

	local dist = LocalPlayer:GetPosition():DistanceSqr( self.mhc_pos )

	if dist >= self.mhc_dist then
		self:ModuleUnload()

		if self.PostTickEvent then Events:Unsubscribe( self.PostTickEvent ) self.PostTickEvent = nil self.timer = nil end
	end
end

function MHCMusicFix:ModuleUnload()
	if self.sound then self.sound:Remove() self.sound = nil end
end

mhcmusicfix = MHCMusicFix()