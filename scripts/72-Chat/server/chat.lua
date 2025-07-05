class 'BetterChat'

function BetterChat:__init()
	self.values_ru = { "Неудачно", "Удачно" }
	self.values_en = { "Unsuccessful", "Successfully" }

	SQL:Execute( "CREATE TABLE IF NOT EXISTS settings_chatpos (steamid VARCHAR UNIQUE, positionX INTEGER, positionY INTEGER)")
	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_chatsettings (steamid VARCHAR UNIQUE, visiblejoinmessages INTEGER)")

	Network:Subscribe( "SaveChatPos", self, self.SaveChatPos )
	Network:Subscribe( "ResetChatPos", self, self.ResetChatPos )
	Network:Subscribe( "ChangeChatSettings", self, self.ChangeChatSettings )
	Network:Subscribe( "Toggle", self, self.Mode )

	Events:Subscribe( "ClientModuleLoad", self, self.LoadChatPos )
    Events:Subscribe( "PlayerJoin", self, self.Join )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "PlayerChat", self, self.Chat )

	self.msgColor = Color.White
	self.msgActionColor = Color.DarkGray

    self.distance = 30
    self.toggle = 0
end

function BetterChat:SaveChatPos( args, sender )
	local cmd = SQL:Command( "INSERT OR REPLACE INTO settings_chatpos (steamid, positionX, positionY) values (?, ?, ?)" )
    cmd:Bind( 1, sender:GetSteamId().id )
	cmd:Bind( 2, args.chatpos.x )
	cmd:Bind( 3, args.chatpos.y )
    cmd:Execute()
end

function BetterChat:ResetChatPos( args, sender )
	local cmd = SQL:Command( "DELETE FROM settings_chatpos WHERE steamid = (?)" )
	cmd:Bind( 1, sender:GetSteamId().id )
    cmd:Execute()
end

function BetterChat:ChangeChatSettings( args, sender )
	if args.joinmessagesmode then
		if args.joinmessagesmode == 0 then
			sender:SetNetworkValue( "VisibleJoinMessages", nil )
		else
			sender:SetNetworkValue( "VisibleJoinMessages", args.joinmessagesmode )
		end
	end
end

function BetterChat:LoadChatPos( args )
    local qry = SQL:Query( "select positionX, positionY from settings_chatpos where steamid = (?)" )
    qry:Bind( 1, args.player:GetSteamId().id )
    local result = qry:Execute()

	if #result > 0 then
        Network:Send( args.player, "ApplyChatPos", { sqlchatposX = tonumber(result[1].positionX), sqlchatposY = tonumber(result[1].positionY) } )
    end
end

function BetterChat:Join( args )
	args.player:SetNetworkValue( "ChatMode", 0 )
	local qry = SQL:Query("SELECT visiblejoinmessages FROM players_chatsettings WHERE steamid = ?")
	qry:Bind( 1, args.player:GetSteamId().id )
	local result = qry:Execute()

	if #result > 0 then
		args.player:SetNetworkValue( "VisibleJoinMessages", tonumber( result[1].visiblejoinmessages ) )
	end
end

function BetterChat:PlayerQuit( args )
	local steamId = args.player:GetSteamId().id
	local visibleJoinMessages = args.player:GetValue( "VisibleJoinMessages" )

	if visibleJoinMessages then
		local cmd = SQL:Command( "INSERT OR REPLACE INTO players_chatsettings (steamid, visiblejoinmessages) values (?, ?)" )
		cmd:Bind( 1, steamId )
		cmd:Bind( 2, visibleJoinMessages )
		cmd:Execute()
	else
        local cmd = SQL:Command( "DELETE FROM players_chatsettings WHERE steamid = (?)" )
        cmd:Bind( 1, steamId )
		cmd:Execute()
	end
end

function BetterChat:Mode( toggler, player )
    player:SetNetworkValue( "ChatMode", toggler )
end

function BetterChat:Chat( args )
	if args.text:sub(1,1) ~= "/" then
		if not args.player:GetValue( "Mute" ) then
			local chatsetting = args.player:GetValue( "ChatMode" )

			args.player:SetNetworkValue( "ChatMessagesCount", ( args.player:GetValue( "ChatMessagesCount" ) or 0 ) + 1 )

			if chatsetting == 0 then
				local tagColor = Color( 185, 215, 255 )
				local pName = args.player:GetName()
				local pColor = args.player:GetColor()

				for p in Server:GetPlayers() do
					p:SendChatMessage( p:GetValue( "Lang" ) == "EN" and "[Global] " or "[Общий] ", tagColor, pName, pColor, ": " .. args.text, self.msgColor )
				end
				Events:Fire( "ToDiscordConsole", { text = "[" .. tostring( args.player:GetValue( "Country" ) ) .. "] [Global] " .. pName .. ": "..args.text } )
				print( "(" .. args.player:GetId() .. ") " .. "[" .. tostring( args.player:GetValue( "Country" ) ) .. "] " .. "[Global] " .. pName .. ": " .. args.text )
				return false
			elseif chatsetting == 1 then
				local tagColor = Color.DarkGray
				local pName = args.player:GetName()
				local pColor = args.player:GetColor()
				local pPos = args.player:GetPosition()

				for p in Server:GetPlayers() do
					local jDist = pPos:Distance( p:GetPosition() )

					if p and jDist < 50 then
						p:SendChatMessage( p:GetValue( "Lang" ) == "EN" and "[Local] " or "[Локальный] ", tagColor, pName, pColor, ": ".. args.text, self.msgColor )
           			end
           		end
				return false
			elseif chatsetting == 2 then
				return false
			elseif chatsetting == 3 then
				return false
			end
		end
	else
		local cmd_args = string.split( args.text, " ", true )
	end

    local msg = args.text
    if ( msg:sub ( 1, 1 ) ~= "/" ) then
        return true
    end

    local msg = msg:sub( 2 )
    local cmd_args = msg:split( " " )
    local cmd_name = cmd_args[ 1 ]:lower()

	if cmd_name == "me" then
		local tagColor = Color.White
		local pName = args.player:GetName()
		local pPos = args.player:GetPosition()

		table.remove( cmd_args, 1 )
		for p in Server:GetPlayers() do
			local jDist = pPos:Distance( p:GetPosition() )

			if jDist < 50 then
				p:SendChatMessage( p:GetValue( "Lang" ) == "EN" and "[Action] " or "[Действие] ", tagColor, pName .. " " .. tostring( table.concat ( cmd_args, " " ) ), self.msgActionColor )
			end
		end
	elseif cmd_name == "try" then
		local tagColor = Color.White
		local pName = args.player:GetName()
		local pPos = args.player:GetPosition()

		table.remove( cmd_args, 1 )
		for p in Server:GetPlayers() do
			local jDist = pPos:Distance( p:GetPosition() )

			if jDist < 50 then
				p:SendChatMessage( p:GetValue( "Lang" ) == "EN" and "[Action] " or "[Действие] ", tagColor, pName .. " " .. tostring( table.concat ( cmd_args, " " ) ), self.msgActionColor, " | ", self.msgColor, p:GetValue( "Lang" ) == "EN" and table.randomvalue( self.values_en ) or table.randomvalue( self.values_ru ), self.msgActionColor, " | ", self.msgColor )
			end
		end
	end
end

betterchat = BetterChat()