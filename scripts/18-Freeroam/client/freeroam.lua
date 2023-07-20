class 'Freeroam'

function Freeroam:__init()
	self.hotspots = {}

	Events:Subscribe( "GameLoad", self, self.GameLoad )
	Network:Subscribe( "EnableAutoPassive", self, self.EnableAutoPassive )
	Network:Subscribe( "Hotspots", self, self.Hotspots )
	Network:Subscribe( "KillerStats", self, self.KillerStats )
end

function Freeroam:GameLoad()
	Events:Fire( "RestoreParachute" )
end

function Freeroam:EnableAutoPassive()
	if not LocalPlayer:GetValue( "Passive" ) then
		if not self.PostTickEvent then
			Network:Send( "TogglePassiveAfterSpawn", { enabled = true } )
			self.passiveTimer = Timer()
			self.PostTickEvent = Events:Subscribe( "PostTick", self, self.PostTick )
		end
	end
end

function Freeroam:PostTick()
	if self.passiveTimer:GetSeconds() >= 10 then
		self.passiveTimer = nil
		Network:Send( "TogglePassiveAfterSpawn", { enabled = false } )
		if self.PostTickEvent then
			Events:Unsubscribe( self.PostTickEvent )
			self.PostTickEvent = nil
		end
	end
end

function Freeroam:KillerStats( args )
	Events:Fire( "CastCenterText", { text = args.text, time = 4, color = Color.White } )
end

function Freeroam:Hotspots( args )
	self.hotspots = args
end

function Freeroam:DrawHotspot( v, dist )
	local text = "/tp " .. v[1]
	local text_size = Render:GetTextSize( text, TextSize.VeryLarge )
end

freeroam = Freeroam()