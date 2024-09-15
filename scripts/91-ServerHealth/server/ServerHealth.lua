class 'ServerHealth'

function ServerHealth:__init()
    self:CheckServerHealth()

    Events:Subscribe( "ServerStart", self, self.ServerStart )

    if not Config:GetValue( "Server", "IKnowWhatImDoing" ) then
        self.iKnowWhatImDoingWarning = "IKnowWhatImDoing is not enabled in server configuration!"

        Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
    end

    Console:Subscribe( "kickx", self, self.KickX )
    Console:Subscribe( "online", self, self.GetOnline )
    Console:Subscribe( "getuptime", self, self.GetServerUpTime )
    Console:Subscribe( "help", self, self.GetHelp )
end

function ServerHealth:CheckServerHealth()
    local func = coroutine.wrap( function()
        local last_time = Server:GetElapsedSeconds()
        local players_history = {}

        while true do
            Timer.Sleep( 1000 )

            local players = {}

            for p in Server:GetPlayers() do
                if IsValid(p) then
                    players[p:GetId()] = p
                end
            end

            local seconds_elapsed = Server:GetElapsedSeconds()
            local last_players = players_history[tostring(string.format("%.0f", last_time))]

            if seconds_elapsed - last_time > 3 then
                local msg = string.format( "**[Status] Hitch warning: Server is running %.2f seconds behind!**", seconds_elapsed - last_time )

                Events:Fire( "ToDiscord", { text = msg })
                Events:Fire( "LogMessage", { text = msg })

                warn( msg )
            end

            -- Erase old players
            last_players = nil

            last_time = seconds_elapsed

            -- Add new players
            last_players = players
        end
    end )()
end

function ServerHealth:ServerStart()
    local msg = "Server is running."

    print( msg )

    Events:Fire( "ToDiscordConsole", { text = "**[Status] " .. msg .. "**" } )
    Events:Fire( "ToDiscord", { text = "**[Status] " .. msg .. "**" })

    if self.iKnowWhatImDoingWarning then
        warn( self.iKnowWhatImDoingWarning )

        Events:Fire( "ToDiscordConsole", { text = "**[Status] " .. self.iKnowWhatImDoingWarning .. "**" } )
    end
end

function ServerHealth:PlayerJoin( args )
    if self.iKnowWhatImDoingWarning then
        args.player:Kick( self.iKnowWhatImDoingWarning )
    end
end

function ServerHealth:KickX()
    for p in Server:GetPlayers() do
        p:Kick( "\nServer was shut down, please join later.\n\nСервер был отключен, перезайдите позже.\nВ случае перезапуска, максимальное время ожидания 2 минуты." )
    end

    local serverstopped_txt = "All players has been kicked\nSTOPPING..."

    print( serverstopped_txt )
    Events:Fire( "ToDiscordConsole", { text = serverstopped_txt } )

    Console:Run( "x" )
end

function ServerHealth:GetOnline( args )
    local players = {}
    local temp = ""

    local msg = "Online: " .. Server:GetPlayerCount()
    Events:Fire( "ToDiscordConsole", { text = msg } )
    print( msg )

    if args.text == "full" then
        for p in Server:GetPlayers() do
            if IsValid(p) then
                local pId = p:GetId()

                players[pId] = p
                if args.text == "full" then
                    temp = temp .. "> " .. p:GetName() .. " (ID: " .. tostring( pId ) .. ") | SteamID: " .. tostring( p:GetSteamId() ) .. " IP: " .. tostring( p:GetIP() ) .. " (" .. tostring( p:GetValue( "Country" ) ) .. ")" .. "\n"
                end
            end
        end

        local foundedplayers_txt = "Players not found."

        if temp ~= "" then
            foundedplayers_txt = "Players: \n" .. temp
        end

        print( foundedplayers_txt )
        Events:Fire( "ToDiscordConsole", { text = foundedplayers_txt } )
    end 
end

function ServerHealth:GetServerUpTime()
    local msg = "Server uptime: " .. tostring( ServerHealth:SecondsToClock( Server:GetElapsedSeconds() ) )

    Events:Fire( "ToDiscordConsole", { text = msg } )
    print( msg )
end

function ServerHealth:GetHelp()
    local docs_txt = "**Documentation:** \n" ..
    "Chat: \n" ..
    "> say <text> - write console message. \n" ..
    "Admin: \n" ..
    "> online - get online on the server. \n" ..
    "> online full - get full online on the server. \n" ..
    "> kick <player> - kick the player. \n" ..
    "> ban <player> - ban the player. (Unban only by the owner) \n" ..
    "> reloadbans - update bans list. \n" ..
    "> add<rolename> <steamID> - add SteamID to role. \n" ..
    "> getroles <rolename> - get all SteamId in role. \n" ..
    "> addmoney <player> <money> - add money for player. \n" ..
    "> setpromocode <name> - set promocode. \n" ..
    "Server: \n" ..
    "> getuptime - get server uptime. \n" ..
    "> reload <module> - reload module. \n" ..
    "> load <module> - load module. \n" ..
    "> unload <module> - unload module."

    print( docs_txt )
    Events:Fire( "ToDiscordConsole", { text = docs_txt } )
end

function ServerHealth:SecondsToClock( seconds )
    local seconds = tonumber( seconds )

    if seconds <= 0 then
        return "00:00:00"
    else
        local format = "%02.f"

        hours = string.format( format, math.floor( seconds / 3600) )
        mins = string.format( format, math.floor( seconds / 60 - ( hours * 60 ) ) )
        secs = string.format( format, math.floor( seconds - hours * 3600 - mins * 60 ) )

        return hours .. ":" .. mins .. ":" .. secs
    end
end

serverhealth = ServerHealth()