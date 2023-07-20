class 'ServerHealth'

function ServerHealth:__init()
    self:CheckServerHealth()
    Events:Subscribe( "ServerStart", self, self.ServerStart )
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

            if seconds_elapsed - last_time > 3 then
                local msg = string.format( "**[Status] Hitch warning: Server is running %.2f seconds behind!**", seconds_elapsed - last_time )
                Events:Fire( "ToDiscord", { text = msg })
                Events:Fire( "LogMessage", { text = msg })
                print( msg )

                local last_players = players_history[tostring(string.format("%.0f", last_time))]
            end

            -- Erase old players
            players_history[tostring(string.format("%.0f", last_time))] = nil

            last_time = seconds_elapsed

            -- Add new players
            players_history[tostring(string.format("%.0f", last_time))] = players
        end
    end )()
end

function ServerHealth:ServerStart()
    print( "Server is running." )
    Events:Fire( "ToDiscordConsole", { text = "**[Status] Server is running.**" } )
    Events:Fire( "ToDiscord", { text = "**[Status] Server is running.**" })
end

function ServerHealth:KickX( args )
    for p in Server:GetPlayers() do
        p:Kick( "\nServer disabled, join to the server later.\n\nСервер был отключен, перезайдите позже.\nВ случае перезапуска, максимальное время ожидания 2 минуты." )
    end

    local serverstopped_txt = "All players has been kicked\nSTOPPING..."

    print( serverstopped_txt )
    Events:Fire( "ToDiscordConsole", { text = serverstopped_txt } )

    Console:Run( "x" )
end

function ServerHealth:GetOnline( args )
    local players = {}
    local temp = ""

    Events:Fire( "ToDiscordConsole", { text = "Online: " .. Server:GetPlayerCount() })
    print( "Online: " .. Server:GetPlayerCount())

    if args.text == "full" then
        for p in Server:GetPlayers() do
            if IsValid(p) then
                players[p:GetId()] = p
                if args.text == "full" then
                    temp = temp .. "> " .. p:GetName() .. " (ID: " .. tostring( p:GetId() ) .. ") | SteamID: " .. tostring( p:GetSteamId() ) .. " IP: " .. tostring( p:GetIP() ) .. " (" .. tostring( p:GetValue( "Country" ) ) .. ")" .. "\n"
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

function ServerHealth:GetServerUpTime( args )
    Events:Fire( "ToDiscordConsole", { text = "Server uptime: " .. tostring( ServerHealth:SecondsToClock( Server:GetElapsedSeconds() ) ) } )
    print( "Server uptime: " .. tostring( ServerHealth:SecondsToClock( Server:GetElapsedSeconds() ) ) )
end

function ServerHealth:GetHelp( args )
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
        hours = string.format( "%02.f", math.floor( seconds / 3600) )
        mins = string.format( "%02.f", math.floor( seconds / 60 - ( hours * 60 ) ) )
        secs = string.format( "%02.f", math.floor( seconds - hours * 3600 - mins * 60 ) )
        return hours .. ":" .. mins .. ":" .. secs
    end
end

serverhealth = ServerHealth()