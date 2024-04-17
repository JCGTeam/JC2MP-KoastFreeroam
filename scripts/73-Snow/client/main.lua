class 'Snow'

function Snow:__init()
	self.curTime = Client:GetElapsedSeconds()
	self.dt = 0.1

	self.current = {}

	self.pieces = {
		{
			Vector2( 2, 2 ), Vector2( 5, 2 ), Vector2( 5, -2 ),
			Vector2( 5, -2 ), Vector2( 2, -2 ), Vector2( 2, 2 ),

			Vector2( -2, -2 ), Vector2( -5, -2 ), Vector2( -5, 2 ),
			Vector2( -5, 2 ), Vector2( -2, 2 ), Vector2( -2, -2 ),

			Vector2( 2, 2 ), Vector2( 2, 5 ), Vector2( -2, 5 ),
			Vector2( -2, 5 ), Vector2( -2, 2 ), Vector2( 2, 2 ),

			Vector2( -2, -2 ), Vector2( -2, -5 ), Vector2( 2, -5 ),
			Vector2( 2, -5 ), Vector2( 2, -2 ), Vector2( -2, -2 ),

			Vector2( -2, 2 ), Vector2( 2, 2 ), Vector2( 2, -2 ),
			Vector2( 2, -2 ), Vector2( -2, -2 ), Vector2( -2, 2 )
		}
	}

	self.globalOpacity = 127

	self:PopulateGrid()

	Events:Subscribe( "SharedObjectValueChange", self, self.SharedObjectValueChange )

	if LocalPlayer:GetValue( "SnowVisible" ) then
        self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
	end
end

function Snow:SharedObjectValueChange( args )
	if args.key == "SnowVisible" and args.object.__type == "LocalPlayer" then
		if args.value then
			if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
		else
			if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
		end
	end
end

function Snow:Render()
	if Game:GetState() == GUIState.PDA then return end

	self.dt = Client:GetElapsedSeconds() - self.curTime
	self.curTime = Client:GetElapsedSeconds()

	self:RenderSnow()
end

function Snow:RenderSnow()
	for u,v in pairs(self.current) do
		v.offset.y = v.offset.y + self.dt * v.dropSpeed
		if v.offset.y > Render.Size.y then
			self:NewFlake(u)
		else
			local offset = v.offset
			for i = 1, (#v.pos)/3 do
				Render:FillTriangle( offset + v.pos[3 * i - 2], offset + v.pos[3 * i - 1], offset + v.pos[3 * i], Color( 255, 255, 255, self.globalOpacity ) )
			end
		end
	end
end

function Snow:PopulateGrid()
	for i = 1, 25 do
		self:NewFlake(i)
		self.current[i].offset.y = Render.Size.y * math.random()
	end
end

function Snow:NewFlake(i)
	local tData = {}
	tData.offset = Vector2( Render.Size.x * math.random(), 0 )
	tData.dropSpeed = math.random( 200, 500 )
	tData.pos = self.pieces[math.random(1,#self.pieces)]
	self.current[i] = tData
end

snow = Snow()