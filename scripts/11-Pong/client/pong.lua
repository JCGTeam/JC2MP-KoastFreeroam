class 'Pong'

function Pong:__init()
	self.text_clr = Color.White
	self.board_clr = Color( 10, 10, 10, 100 )
	self.plaftorm_clr = Color( 185, 215, 255 )
	self.shadow = Color( 25, 25, 25, 150 )

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.locStrings = {
			tip = "ⓘ Используйте мышь для перемещения платформы",
			you = "Вы: ",
			enemy = "Соперник: ",
			limit = "Лимит попаданий: ",
			win = "Вы победили!",
			lose = "Вы проиграли :("
		}
	end

	Events:Subscribe( "Lang", self, self.Lang )

	Network:Subscribe( "StartUp", self, self.StartUp )
end

function Pong:Lang()
	self.locStrings = {
		tip = "ⓘ Move the mouse to move the platform",
		you = "You: ",
		enemy = "Enemy: ",
		limit = "Hit limit: ",
		win = "Well done!",
		lose = "You suck!"
	}
end

function Pong:LocalPlayerInput( args )
	if active and args.state ~= 0 then
		if args.input == Action.LookUp or args.input == Action.LookDown or args.input == Action.LookLeft or args.input == Action.LookRight then
			return false
		end
	end
end

function Pong:ClientTick( args )
	if active and not paused then
		self:HandleBallData(args)
		self:HandleCPU(args)
	end
end

function Pong:MouseMove( args )
	if active then
		if args.position.y >= mouse_last.y and (ping_pos + ping_height) < pong_table_height then
			ping_pos = ping_pos + (args.position.y - mouse_last.y)

			if (ping_pos + ping_height) + (args.position.y - mouse_last.y) > pong_table_height then ping_pos = (pong_table_height - ping_height) end
		elseif args.position.y <= mouse_last.y and ping_pos > 0 then
			ping_pos = ping_pos - (mouse_last.y - args.position.y)

			if ping_pos - (mouse_last.y - args.position.y) < 0 then ping_pos = 0 end
		end
		mouse_last.y = args.position.y
	end
end

function Pong:Render()
	if active then
		if LocalPlayer:GetValue( "SystemFonts" ) then Render:SetFont( AssetLocation.SystemFont, "Impact" ) end

		Render:FillArea( pong_draw_start, Vector2( pong_table_width, pong_table_height ), self.board_clr )	
		Render:FillArea( pong_draw_start + Vector2( 10, ping_pos ), Vector2( ping_width, ping_height ), self.plaftorm_clr )
		Render:FillArea( pong_draw_start + Vector2( pong_table_width - ping_width - 10, ping_pos_opp ), Vector2( ping_width, ping_height ), self.plaftorm_clr )
		Render:FillArea( pong_draw_start + ball_pos, Vector2( ball_width, ball_height ), self.text_clr )

		local textSize = 15
		Render:DrawShadowedText( pong_draw_start + Vector2( 0, pong_table_height + 5 ), self.locStrings["you"] .. scores[1], self.text_clr, self.shadow, textSize )
		Render:DrawShadowedText( pong_draw_start + Vector2( pong_table_width - 65, pong_table_height + 5 ), self.locStrings["enemy"] .. scores[2], self.text_clr, self.shadow, textSize )
		Render:DrawShadowedText( pong_draw_start + Vector2( pong_table_width / 2 - Render:GetTextWidth( self.locStrings["limit"], textSize ) / 2, pong_table_height + 5 ), self.locStrings["limit"] .. score_limit, self.text_clr, self.shadow, textSize )

		Render:DrawShadowedText( pong_draw_start + Vector2( pong_table_width / 2 - Render:GetTextWidth( self.locStrings["tip"], textSize ) / 2, pong_table_height + 50 ), self.locStrings["tip"], self.text_clr, self.shadow, textSize )

		if paused then
			Render:DrawText( pong_draw_start + pong_table_center + Vector2( Render:GetTextWidth( status_text, TextSize.Huge ) * -0.5, Render:GetTextHeight( status_text, TextSize.Huge) * -0.5 ), status_text, status_colour, TextSize.Huge )
		end
	end
end

function Pong:StartUp( args )
	if args.value == 1 then
		active = false
		Mouse:SetVisible( active )
		LocalPlayer:SetValue( "InPong", active )

		if self.MouseMoveEvent then Events:Unsubscribe( self.MouseMoveEvent ) self.MouseMoveEvent = nil end
		if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
		if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
		if self.PreTickEvent then Events:Unsubscribe( self.PreTickEvent ) self.PreTickEvent = nil end
	elseif args.value == 2 then
		if not difficulty_level[args.cparams[2]] then Chat:Print( "Неверная сложность!", Color( 255, 0, 0 ) ) return false end

		cpu_difficulty = difficulty_level[args.cparams[2]][1]
		angle_modifier = difficulty_level[args.cparams[2]][3]
		ball_speed_limit.upper = difficulty_level[args.cparams[2]][2]
		ball_speed_limit.lower = -ball_speed_limit.upper

		if not self.MouseMoveEvent then self.MouseMoveEvent = Events:Subscribe( "MouseMove", self, self.MouseMove ) end
		if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end
		if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
		if not self.PreTickEvent then self.PreTickEvent = Events:Subscribe( "PreTick", self, self.ClientTick ) end

		active = true
		Mouse:SetVisible( active )
		LocalPlayer:SetValue( "InPong", active )
		paused = false
		scores = {0, 0}
		ball_pos = Vector2( pong_table_center.x - ( ball_width / 2 ), pong_table_center.y - ( ball_height / 2 ) ) -- Put the ball back in the middle of the game
		ball_speed.x = 2
		ball_speed.y = 0
	end
end

function Pong:HandleBallData()
	if (ball_pos.x) >= (pong_table_width - ping_width - 20) and (ball_pos.y + ball_height) >= ping_pos_opp and ball_pos.y <= (ping_pos_opp + ping_height) then
		ball_speed.x = -ball_speed.x

		if ball_speed.x > ball_speed_limit.lower then ball_speed.x = ball_speed.x - 1 end

		if ball_speed.x < ball_speed_limit.lower then ball_speed.x = ball_speed_limit.lower end

		ball_speed.y = CalculateBallAngle(ball_pos.y, ping_pos_opp)

		if (ball_pos.x) > (pong_table_width - ping_width - 20) then 
			ball_pos.x = pong_table_width - ping_width - 20
		end
	elseif ball_pos.x <= ping_width + 10 and (ball_pos.y + ball_height) >= ping_pos and ball_pos.y <= (ping_pos + ping_height) then
		ball_speed.x = -ball_speed.x

		if ball_speed.x < ball_speed_limit.upper then ball_speed.x = ball_speed.x + 1 end

		if ball_speed.x > ball_speed_limit.upper then ball_speed.x = ball_speed_limit.upper end

		ball_speed.y = CalculateBallAngle(ball_pos.y, ping_pos)

		if ball_pos.x < ping_width + 10 then ball_pos.x = ping_width + 10 end
	end

	if (ball_pos.y + ball_height + ball_speed.y) > pong_table_height or ball_pos.y < 0 then ball_speed.y = -ball_speed.y end

	ball_pos.x = ball_pos.x + ball_speed.x
	ball_pos.y = ball_pos.y + ball_speed.y

	if ball_pos.x <= 0 then
		ball_speed.x = 2
		ball_speed.y = 0
		scores[2] = scores[2] + 1

		ball_pos = Vector2(pong_table_center.x - (ball_width / 2), pong_table_center.y - (ball_height / 2))

		if scores[2] == score_limit then 
			Events:Fire( "CastCenterText", { text = self.locStrings["lose"], time = 2, color = Color.Red } )
			active = false
			Mouse:SetVisible( active )
			LocalPlayer:SetValue( "InPong", active )

			if self.MouseMoveEvent then Events:Unsubscribe( self.MouseMoveEvent ) self.MouseMoveEvent = nil end
			if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
			if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
			if self.PreTickEvent then Events:Unsubscribe( self.PreTickEvent ) self.PreTickEvent = nil end
		end
	elseif ball_pos.x + ball_width >= pong_table_width then
		ball_speed.x = -2
		ball_speed.y = 0
		scores[1] = scores[1] + 1

		ball_pos = Vector2(pong_table_center.x - (ball_width / 2), pong_table_center.y - (ball_height / 2))

		if scores[1] == score_limit then 
			Events:Fire( "CastCenterText", { text = self.locStrings["win"], time = 2, color = Color( 0, 222, 0 ) } )
			Network:Send( "Win" )
			active = false
			Mouse:SetVisible( active )
			LocalPlayer:SetValue( "InPong", active )

			if self.MouseMoveEvent then Events:Unsubscribe( self.MouseMoveEvent ) self.MouseMoveEvent = nil end
			if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
			if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
			if self.PreTickEvent then Events:Unsubscribe( self.PreTickEvent ) self.PreTickEvent = nil end
		end
	end
end

function Pong:HandleCPU()
	if ball_pos.y > ping_pos_opp + (ping_height / 2) and (ping_pos_opp + ping_height) < pong_table_height then 
		ping_pos_opp = ping_pos_opp + cpu_difficulty
	elseif ball_pos.y < ping_pos_opp + (ping_height / 2) and ping_pos_opp > 0 then
		ping_pos_opp = ping_pos_opp - cpu_difficulty 
	end
end

pong = Pong()

function DrawStatus( text, colour )
	status_text = text
	status_colour = colour
end

function CalculateBallAngle( ball_y, ping_y )
	return (((ball_y + (ball_height / 2)) - (ping_y + (ping_height / 2))) / 40) * angle_modifier
end