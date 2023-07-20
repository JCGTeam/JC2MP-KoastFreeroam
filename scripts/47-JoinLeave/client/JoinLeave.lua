class 'JoinLeave'

function JoinLeave:__init()
	Network:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Network:Subscribe( "PlayerQuit", self, self.PlayerQuit )
end

function JoinLeave:PlayerJoin( args )
	if not LocalPlayer:GetValue( "VisibleJoinMessages" ) then return end

	if LocalPlayer:GetValue( "VisibleJoinMessages" ) == 1 then
		if LocalPlayer:IsFriend( args.player ) then
			if LocalPlayer:GetValue( "Lang" ) == "ENG" then
				Chat:Print( args.player:GetName(), args.player:GetColor(), " joined to the server!", Color( 255, 215, 0 ) )
			else
				Chat:Print( args.player:GetName(), args.player:GetColor(), " присоединился(лась) к серверу!", Color( 255, 215, 0 ) )
			end
		end
	elseif LocalPlayer:GetValue( "VisibleJoinMessages" ) == 2 then
		if LocalPlayer:GetValue( "Lang" ) == "ENG" then
			Chat:Print( args.player:GetName(), args.player:GetColor(), " joined to the server!", Color( 255, 215, 0 ) )
		else
			Chat:Print( args.player:GetName(), args.player:GetColor(), " присоединился(лась) к серверу!", Color( 255, 215, 0 ) )
		end
	end
end

function JoinLeave:PlayerQuit( args )
	if not LocalPlayer:GetValue( "VisibleJoinMessages" ) then return end

	if LocalPlayer:GetValue( "VisibleJoinMessages" ) == 1 then
		if LocalPlayer:IsFriend( args.player ) then
			if LocalPlayer:GetValue( "Lang" ) == "ENG" then
				Chat:Print( args.player:GetName() .. " left the server(", Color( 137, 137, 137 ) )
			else
				Chat:Print( args.player:GetName() .. " покинул(а) нас(", Color( 137, 137, 137 ) )
			end
		end
	elseif LocalPlayer:GetValue( "VisibleJoinMessages" ) == 2 then
		if LocalPlayer:GetValue( "Lang" ) == "ENG" then
			Chat:Print( args.player:GetName() .. " left the server(", Color( 137, 137, 137 ) )
		else
			Chat:Print( args.player:GetName() .. " покинул(а) нас(", Color( 137, 137, 137 ) )
		end
	end
end

joinLeave = JoinLeave()