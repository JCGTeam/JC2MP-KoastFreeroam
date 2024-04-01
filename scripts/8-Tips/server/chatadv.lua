class 'ChatAdv'

function ChatAdv:__init()
	self.ads = {}
	self.adCount = 0
	self.currentAd = 0
	self.timer = Timer()

	self:loadAds( "ads.txt" )

	Events:Subscribe( "PostTick", self, self.PostTick )	
end

function ChatAdv:loadAds( filename )
	local file = io.open( filename, "r" )
	local i = 0

	if file == nil then
		print( "no ads.txt!" )
		return
	end

	for line in file:lines() do
		i = i + 1
		self.adCount = i
		self.ads[i] = line
	end

	if self.adCount > 0 then
		self.currentAd = 1
	end

	print( "Loaded " .. self.adCount .. " ads" )
	file:close()
end

function ChatAdv:PostTick( args )
	if self.adCount > 0 then
		if self.timer:GetMinutes() > 15 then
			if self.currentAd > self.adCount then
				self.currentAd = 1
			end
			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "RU" then
					p:SendChatMessage( "[Реклама] ", Color.White, self.ads[self.currentAd], Color.DarkGray )
				end
			end
			self.currentAd = self.currentAd + 1
			self.timer:Restart()
		end
	end
end

chatadv = ChatAdv()