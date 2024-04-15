class "ChatBubbles"

function ChatBubbles:__init()
	self.canSeeOwn = false
	self.timeout = 5
	self.distance = 30
	self.backgroundColor = Color( 0, 0, 0, 150 )
	self.textColor = Color( 255, 255, 255 )
	self.height = 0.5

	self.bubbles = {}
	self.fontSize = TextSize.Default
	self.textScale = 1

	Events:Subscribe( "PlayerQuit", self, self.onPlayerQuit )
	Events:Subscribe( "Render", self, self.onBubblesRender )
	Network:Subscribe( "chatBubbles.receiveMessage", self, self.addMessage )
end

function ChatBubbles:addMessage( args )
	if not (args.text:sub(1, 1) ~= '/') then
		return true
	end

	if args.player:GetValue( "ChatMode" ) ~= 1 then
		return
	end

	if ( args.player == LocalPlayer and not self.canSeeOwn ) then
		return
	end

	self:addBubble( args.player, args.text )
end

function ChatBubbles:onPlayerQuit( args )
	self.bubbles [ args.player:GetId() ] = nil
end

function ChatBubbles:onBubblesRender()
    if Game:GetState() ~= GUIState.Game then return end

	local myPos = Camera:GetPosition()
	local angle = Angle ( Camera:GetAngle().yaw, 0, math.pi ) * Angle ( math.pi, 0, 0 )

	for playerID, bubbles in pairs ( self.bubbles ) do
		local player = Player.GetById( playerID )
		if IsValid ( player ) then
			if ( type ( bubbles ) == "table" ) then
				local position = player:GetPosition()
				local headPos = player:GetBonePosition( "ragdoll_head" )
				local distance = position:Distance2D( myPos )

				if ( distance <= self.distance ) then
					local height = self.height
					for index = #bubbles, 1, -1 do
						local data = bubbles [ index ]
						if ( type ( data ) == "table" ) then
							if ( data.timer:GetSeconds() >= self.timeout )then
								self.bubbles [ playerID ] [ index ] = nil
							else
								local headPos = ( headPos + Vector3 ( 0, height, 0 ) )
								local text_size = Render:GetTextSize ( data.msg, self.fontSize, self.textScale )
								local width = Render:GetTextWidth ( data.msg, self.fontSize, self.textScale )
								local position = Render:WorldToScreen ( headPos )

								Render:FillArea( position - Vector2( width / 2, 0 ), Vector2( text_size.x + 1, text_size.y ), self.backgroundColor )
								Render:DrawText( position - Vector2( width / 2, 0 ), data.msg, self.textColor, self.fontSize, self.textScale )
							end
						end
					end
				end
			end
		end
	end
end

function ChatBubbles:addBubble( player, msg )
	if ( player and msg ) then
		local id = player:GetId()
		if ( not self.bubbles [ id ] ) then
			self.bubbles [ id ] = {}
		else
			if ( #self.bubbles [ id ] >= 1 ) then
				self.bubbles [ id ] [ 1 ] = nil
			end
		end

		table.insert (
			self.bubbles [ id ],
			{
				player = player,
				msg = msg,
				timer = Timer()
			}
		)

		return true
	else
		return false
	end
end

chatbubbles = ChatBubbles()