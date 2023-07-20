class 'Notifications'

function Notifications:__init()
	Events:Subscribe( "SendNotification", self, self.GetNotification )
	Events:Subscribe( "PostRender", self, self.PostRender )

	Upgrade		= 	Image.Create( AssetLocation.Resource, "Upgrade" )
	Information	= 	Image.Create( AssetLocation.Resource, "Information" )
	Warning		= 	Image.Create( AssetLocation.Resource, "Warning" )

	NotificationQueue = {}

	MainTxt 	= 	nil
	SubTxt 		= 	nil
	ImageType 	= 	nil

	ProcessTimer = Timer()
end

function Notifications:GetNotification( args )
	local MainTxt	= args.txt
	local ImageType = args.image
	local SubTxt 	= args.subtxt
	local QueueArgs = {maintxt = args.txt, imagetype = args.image, subtxt = args.subtxt}

	table.insert(NotificationQueue, QueueArgs)
end

function Notifications:ProcessQueue()
	if table.count(NotificationQueue) > 0 then
		for k, args in ipairs(NotificationQueue) do 
			MainTxt 	= 	args.maintxt
			ImageType 	= 	args.imagetype
			SubTxt 		= 	args.subtxt
			FadeInTimer =	Timer()
			table.remove(NotificationQueue, k)
		end
	end
end

function Notifications:PostRender()
	if FadeInTimer ~= nil or DelayTimer ~= nil or FadeOutTimer ~= nil then

	if MainTxt == nil then
		FadeInTimer = nil
		return
	end

	if Render:GetTextWidth(MainTxt, 15) > 200 then
		FadeInTimer = nil
		return
	end

	if SubTxt ~= nil then
		if Render:GetTextWidth(SubTxt, 15) > 230 then
			FadeInTimer = nil
			return
		end
	end

	if FadeInTimer ~= nil then
		TxtAlpha 		= 	math.clamp( 0 + (FadeInTimer:GetSeconds() * 400), 0, 200 )
		RenderAlpha1	= 	math.clamp( 0 + (FadeInTimer:GetSeconds() * 360), 0, 180 )
		RenderAlpha2	= 	math.clamp( 0 + (FadeInTimer:GetSeconds() * 340), 0, 170 )
		ImageAlpha 		= 	math.clamp( 0 + (FadeInTimer:GetSeconds() * 2), 0, 1 )
		if TxtAlpha >= 200 or  RenderAlpha1 >= 180 or RenderAlpha2 >= 170 or ImageAlpha >= 1 then
			TxtAlpha 	 = 200
			RenderAlpha1 = 180
			RenderAlpha2 = 170
			ImageAlpha 	 = 1
			DelayTimer 	= Timer()
			FadeInTimer = nil
		end
	end

	if DelayTimer ~= nil then
		if DelayTimer:GetSeconds() >= 1 then
			DelayTimer = nil
			FadeOutTimer = Timer()
		end
	end

	if FadeOutTimer ~= nil then
		TxtAlpha 		= 	math.clamp( 200 - (FadeOutTimer:GetSeconds() * 66.66666666666667), 0, 200 )
		RenderAlpha1	= 	math.clamp( 180 - (FadeOutTimer:GetSeconds() * 60), 0, 180 )
		RenderAlpha2	= 	math.clamp( 170 - (FadeOutTimer:GetSeconds() * 56.66666666666667), 0, 170 )
		ImageAlpha		= 	math.clamp( 1 - (FadeOutTimer:GetSeconds() / 3), 0, 1 )
		if TxtAlpha <= 0 or  RenderAlpha1 <= 0 or RenderAlpha2 <= 0 or ImageAlpha <= 0 then
			FadeOutTimer = nil
			self.ProcessQueue()
		end
	end

	local MainTxt 	= 	MainTxt
	local SubTxt	=	SubTxt
	local ImageType	=	tostring(ImageType)

	Render:FillArea( Vector2( (Render.Width - 255), 50 ), Vector2( 250, 40 ), Color( 0, 0, 0, RenderAlpha1 ) )
	Render:FillArea( Vector2( (Render.Width - 255), 50 ), Vector2( 1, 40 ), Color( 70, 200, 255, RenderAlpha2 ) )
	Render:FillArea( Vector2( (Render.Width - 210), 50 ), Vector2( 1, 40 ), Color( 30, 160, 215, RenderAlpha2 ) )
	Render:FillArea( Vector2( (Render.Width - 5), 50 ), Vector2( 1, 40 ), Color( 70, 200, 255, RenderAlpha2 ) )
	Render:FillArea( Vector2( (Render.Width - 255), 50 ), Vector2( 250, 1 ), Color( 70, 200, 255, RenderAlpha2 ) )
	Render:FillArea( Vector2( (Render.Width - 255), 90 ), Vector2( 250, 1 ), Color( 70, 200, 255, RenderAlpha2 ) )

	if ImageType == "Upgrade" or ImageType == "3" then
		Upgrade:SetAlpha(ImageAlpha)
		Upgrade:Draw( Vector2( (Render.Width - 249), 52.5 ), Vector2( 35, 35 ), Vector2.Zero,Vector2.One )
	elseif ImageType == "Information" or ImageType == "1" then
		Information:SetAlpha(ImageAlpha)
		Information:Draw( Vector2( (Render.Width - 249), 52.5 ), Vector2( 35, 35 ), Vector2.Zero,Vector2.One )
	elseif ImageType == "Warning" or ImageType == "2" then
		Warning:SetAlpha(ImageAlpha)
		Warning:Draw( Vector2( (Render.Width - 249), 52.5 ), Vector2( 35, 35 ), Vector2.Zero,Vector2.One )
	else
		Information:SetAlpha(ImageAlpha)
		Information:Draw( Vector2( (Render.Width - 249), 52.5 ), Vector2( 35, 35 ), Vector2.Zero,Vector2.One )
	end

	if SubTxt ~= nil then
		Render:DrawText( Vector2( (Render.Width - 107.5 ) - (Render:GetTextWidth(MainTxt, 15) / 2), 56 ), MainTxt, Color( 210, 210, 210, TxtAlpha ), 15 )
		Render:DrawText( Vector2( (Render.Width - 107.5 ) - (Render:GetTextWidth(SubTxt, 12) / 2), 73 ), SubTxt, Color( 140, 140, 140, TxtAlpha ), 12 )
	else
		Render:DrawText( Vector2( (Render.Width - 107.5 ) - (Render:GetTextWidth(MainTxt, 15) / 2), 64 ), MainTxt, Color( 210, 210, 210, TxtAlpha ), 15 )
	end

	else
		if ProcessTimer then
			if ProcessTimer:GetSeconds() >= 1 then
				self.ProcessQueue()
				ProcessTimer:Restart()
			end
		end
	end
end

Notifications = Notifications()