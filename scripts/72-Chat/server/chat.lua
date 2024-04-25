class 'BetterChat'

local values_ru = { "Неудачно", "Удачно", "Неудачно" }
local values_en = { "Unsuccessful", "Successfully", "Unsuccessful" }

function BetterChat:__init()
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

    self.distance = 30
    self.toggle = 0
end

function BetterChat:SaveChatPos( args, sender )
	local cmd = SQL:Command( "insert or replace into settings_chatpos (steamid, positionX, positionY) values (?, ?, ?)" )
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
		sender:SetNetworkValue( "VisibleJoinMessages", ( args.joinmessagesmode == 0 ) and nil or args.joinmessagesmode )
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

			if chatsetting == 0 then
				for p in Server:GetPlayers() do
					p:SendChatMessage( p:GetValue( "Lang" ) == "EN" and "[Global] " or "[Общий] ", Color.LightSkyBlue, args.player:GetName(), args.player:GetColor(), ": "..args.text, Color.White )
				end
				Events:Fire( "ToDiscordConsole", { text = "[" .. tostring( args.player:GetValue( "Country" ) ) .. "] [Global] " .. args.player:GetName() .. ": "..args.text } )
				print( "(" .. args.player:GetId() .. ") " .. "[" .. tostring( args.player:GetValue( "Country" ) ) .. "] " .. "[Global] " .. args.player:GetName() .. ": " .. args.text )
				return false
			elseif chatsetting == 1 then
				for p in Server:GetPlayers() do
					local jDist = args.player:GetPosition():Distance( p:GetPosition() )

					if p and jDist < 50 then
						p:SendChatMessage( p:GetValue( "Lang" ) == "EN" and "[Local] " or "[Локальный] ", Color.DarkGray, args.player:GetName(), args.player:GetColor(), ": ".. args.text, Color.White )
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
		local cmd_args = string.split( args.text," ",true )
	end

    local msg = args.text
    if ( msg:sub ( 1, 1 ) ~= "/" ) then
        return true
    end

    local msg = msg:sub( 2 )
    local cmd_args = msg:split( " " )
    local cmd_name = cmd_args[ 1 ]:lower()

	if cmd_name == "me" then
		table.remove( cmd_args, 1 )
		for p in Server:GetPlayers() do
			local jDist = args.player:GetPosition():Distance( p:GetPosition() )

			if jDist < 50 then
				p:SendChatMessage( args.player:GetName() .. " " .. tostring( table.concat ( cmd_args, " " ) ), Color.Magenta )
			end
		end
	elseif cmd_name == "try" then
		table.remove( cmd_args, 1 )
		for p in Server:GetPlayers() do
			local jDist = args.player:GetPosition():Distance( p:GetPosition() )

			if jDist < 50 then
				p:SendChatMessage( args.player:GetName() .. " " .. tostring( table.concat ( cmd_args, " " ) ), Color.Magenta, " | ", Color.White, p:GetValue( "Lang" ) == "EN" and values_en[math.random(#values_en)] or values_ru[math.random(#values_ru)], Color.Magenta, " | ", Color.White )
			end
		end
	end
end

betterchat = BetterChat()