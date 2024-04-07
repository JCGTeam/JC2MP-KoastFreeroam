class 'Notifications'

function Notifications:__init()
	Events:Subscribe( "SendNotification", self, self.GetNotification )
	Events:Subscribe( "PostRender", self, self.PostRender )

	self.upgrade = Image.Create( AssetLocation.Resource, "Upgrade" )
	self.information = Image.Create( AssetLocation.Resource, "Information" )
	self.warning = Image.Create( AssetLocation.Resource, "Warning" )

	self.notificationQueue = {}

	self.processTimer = Timer()
end

function Notifications:GetNotification( args )
	self.mainTxt = args.txt
	self.imageType = args.image
	self.subTxt = args.subtxt

	local QueueArgs = { maintxt = args.txt, imagetype = args.image, subtxt = args.subtxt }

	table.insert( self.notificationQueue, QueueArgs )
end

function Notifications:ProcessQueue()
	if table.count( self.notificationQueue ) > 0 then
		for k, args in ipairs( self.notificationQueue ) do 
			self.mainTxt = args.maintxt
			self.imageType = args.imagetype
			self.subTxt = args.subtxt
			self.fadeInTimer = Timer()
			table.remove( self.notificationQueue, k )
		end
	end
end

function Notifications:PostRender()
	if self.fadeInTimer ~= nil or self.delayTimer ~= nil or self.fadeOutTimer ~= nil then
		if self.mainTxt == nil then
			self.fadeInTimer = nil
			return
		end

		if Render:GetTextWidth( self.mainTxt, 15 ) > 200 then
			self.fadeInTimer = nil
			return
		end

		if self.subTxt ~= nil then
			if Render:GetTextWidth( self.subTxt, 15 ) > 230 then
				self.fadeInTimer = nil
				return
			end
		end

		if self.fadeInTimer ~= nil then
			self.txtAlpha = math.clamp( 0 + ( self.fadeInTimer:GetSeconds() * 400 ), 0, 200 )
			self.renderAlpha1 = math.clamp( 0 + ( self.fadeInTimer:GetSeconds() * 360 ), 0, 180 )
			self.renderAlpha2 = math.clamp( 0 + ( self.fadeInTimer:GetSeconds() * 340 ), 0, 170 )
			self.imageAlpha = math.clamp( 0 + ( self.fadeInTimer:GetSeconds() * 2 ), 0, 1 )

			if self.txtAlpha >= 200 or  self.renderAlpha1 >= 180 or self.renderAlpha2 >= 170 or self.imageAlpha >= 1 then
				self.txtAlpha = 200
				self.renderAlpha1 = 180
				self.renderAlpha2 = 170
				self.imageAlpha = 1
				self.delayTimer = Timer()
				self.fadeInTimer = nil
			end
		end

		if self.delayTimer ~= nil then
			if self.delayTimer:GetSeconds() >= 1 then
				self.delayTimer = nil
				self.fadeOutTimer = Timer()
			end
		end

		if self.fadeOutTimer ~= nil then
			self.txtAlpha = math.clamp( 200 - ( self.fadeOutTimer:GetSeconds() * 66.66666666666667 ), 0, 200 )
			self.renderAlpha1 = math.clamp( 180 - ( self.fadeOutTimer:GetSeconds() * 60 ), 0, 180 )
			self.renderAlpha2 = math.clamp( 170 - ( self.fadeOutTimer:GetSeconds() * 56.66666666666667 ), 0, 170 )
			self.imageAlpha = math.clamp( 1 - ( self.fadeOutTimer:GetSeconds() / 3 ), 0, 1 )

			if self.txtAlpha <= 0 or  self.renderAlpha1 <= 0 or self.renderAlpha2 <= 0 or self.imageAlpha <= 0 then
				self.fadeOutTimer = nil
				self:ProcessQueue()
			end
		end

		local backgroundColor = Color( 0, 0, 0, self.renderAlpha1 )
		local outlinesColor = Color( 70, 200, 255, self.renderAlpha2 )

		Render:FillArea( Vector2( ( Render.Width - 255 ), 50 ), Vector2( 250, 40 ), Color( 0, 0, 0, self.renderAlpha1 ) )
		Render:FillArea( Vector2( ( Render.Width - 255 ), 50 ), Vector2( 1, 40 ), outlinesColor )
		Render:FillArea( Vector2( ( Render.Width - 210 ), 50 ), Vector2( 1, 40 ), outlinesColor )
		Render:FillArea( Vector2( ( Render.Width - 5 ), 50 ), Vector2( 1, 40 ), outlinesColor )
		Render:FillArea( Vector2( ( Render.Width - 255 ), 50 ), Vector2( 250, 1 ), outlinesColor )
		Render:FillArea( Vector2( ( Render.Width - 255 ), 90 ), Vector2( 250, 1 ), outlinesColor )

		if self.imageType == "Upgrade" or self.imageType == "3" then
			self.upgrade:SetAlpha( self.imageAlpha )
			self.upgrade:Draw( Vector2( ( Render.Width - 249 ), 52.5 ), Vector2( 35, 35 ), Vector2.Zero, Vector2.One )
		elseif self.imageType == "Information" or self.imageType == "1" then
			self.information:SetAlpha( self.imageAlpha )
			self.information:Draw( Vector2( ( Render.Width - 249 ), 52.5 ), Vector2( 35, 35 ), Vector2.Zero, Vector2.One )
		elseif self.imageType == "Warning" or self.imageType == "2" then
			self.warning:SetAlpha( self.imageAlpha )
			self.warning:Draw( Vector2( ( Render.Width - 249 ), 52.5 ), Vector2( 35, 35 ), Vector2.Zero, Vector2.One )
		else
			self.information:SetAlpha( self.imageAlpha )
			self.information:Draw( Vector2( ( Render.Width - 249 ), 52.5 ), Vector2( 35, 35 ), Vector2.Zero, Vector2.One )
		end

		if self.subTxt ~= nil then
			Render:DrawText( Vector2( ( Render.Width - 107.5 ) - ( Render:GetTextWidth( self.mainTxt, 15 ) / 2 ), 56 ), self.mainTxt, Color( 210, 210, 210, self.txtAlpha ), 15 )
			Render:DrawText( Vector2( ( Render.Width - 107.5 ) - ( Render:GetTextWidth( self.subTxt, 12 ) / 2 ), 73 ), self.subTxt, Color( 140, 140, 140, self.txtAlpha ), 12 )
		else
			Render:DrawText( Vector2( ( Render.Width - 107.5 ) - ( Render:GetTextWidth( self.mainTxt, 15 ) / 2 ), 64 ), self.mainTxt, Color( 210, 210, 210, self.txtAlpha ), 15 )
		end
	else
		if self.processTimer then
			if self.processTimer:GetSeconds() >= 1 then
				self:ProcessQueue()
				self.processTimer:Restart()
			end
		end
	end
end

notifications = Notifications()