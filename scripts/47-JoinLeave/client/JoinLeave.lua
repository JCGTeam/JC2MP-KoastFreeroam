class 'JoinLeave'

function JoinLeave:__init()
	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "EN" then
		self:Lang()
	else
		self.tag = "[Сервер] "
		self.join_txt = " присоединился(лась) к серверу!"
		self.left_txt = " покинул(а) нас("
	end

	Events:Subscribe( "Lang", self, self.Lang )

	Network:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Network:Subscribe( "PlayerQuit", self, self.PlayerQuit )
end

function JoinLeave:Lang()
	self.tag = "[Server] "
	self.join_txt = " joined to the server!"
	self.left_txt = " left the server :("
end

function JoinLeave:PlayerJoin( args )
	--if not LocalPlayer:GetValue( "VisibleJoinMessages" ) then return end
	if LocalPlayer:GetName() == args.player:GetName() then return end

	if LocalPlayer:GetValue( "VisibleJoinMessages" ) and LocalPlayer:GetValue( "VisibleJoinMessages" ) == 1 then
		if LocalPlayer:IsFriend( args.player ) then
			Chat:Print( self.tag, Color.White, args.player:GetName(), args.player:GetColor(), self.join_txt, Color( 255, 215, 0 ) )
		end
	elseif not LocalPlayer:GetValue( "VisibleJoinMessages" ) then
		Chat:Print( self.tag, Color.White, args.player:GetName(), args.player:GetColor(), self.join_txt, Color( 255, 215, 0 ) )
	end
end

function JoinLeave:PlayerQuit( args )
	--if not LocalPlayer:GetValue( "VisibleJoinMessages" ) then return end
	if LocalPlayer:GetName() == args.player:GetName() then return end

	if LocalPlayer:GetValue( "VisibleJoinMessages" ) and LocalPlayer:GetValue( "VisibleJoinMessages" ) == 1 then
		if LocalPlayer:IsFriend( args.player ) then
			Chat:Print( self.tag, Color.White, args.player:GetName() .. self.left_txt, Color.DarkGray )
		end
	elseif not LocalPlayer:GetValue( "VisibleJoinMessages" ) then
		Chat:Print( self.tag, Color.White, args.player:GetName() .. self.left_txt, Color.DarkGray )
	end
end

joinLeave = JoinLeave()