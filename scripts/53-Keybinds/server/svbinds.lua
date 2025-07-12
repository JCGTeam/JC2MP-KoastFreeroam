SQL:Execute("CREATE TABLE IF NOT EXISTS keybinds (steamid VARCHAR, key INTEGER, command VARCHAR)")

function SimulateCommand(args, sender)
    Events:Fire("PlayerChat", {player = sender, text = args})
    -- if string.sub(args,1,1) ~= "/" then
    -- Chat:Broadcast(sender:GetName()..": "..args, Color(255, 255, 255)) -- This is dead code which used to allow spamming chat messages to other players by a mere keypress.
    -- end
end
Network:Subscribe("SimulateCommand", SimulateCommand)

function SQLSave(args, sender)
    local steamId = sender:GetSteamId().id

    local cmd1 = SQL:Command("DELETE FROM keybinds WHERE steamid=(?)")
    cmd1:Bind(1, steamId)
    cmd1:Execute()

    for k, v in pairs(args) do
        local cmd2 = SQL:Command("INSERT INTO keybinds (steamid, key, command) VALUES (?, ?, ?)")
        cmd2:Bind(1, steamId)
        cmd2:Bind(2, tonumber(k))
        cmd2:Bind(3, v)
        cmd2:Execute()
    end
end

Network:Subscribe("SQLSave", SQLSave)

function SQLLoad(args)
    local query = SQL:Query('SELECT * FROM keybinds WHERE steamID = ?')
    query:Bind(1, args.player:GetSteamId().id)
    local result = query:Execute()
    local binds = {}

    for k, v in pairs(result) do
        binds[tonumber(v.key)] = v.command
    end

    Network:Send(args.player, "SQLLoad", binds)
end

Events:Subscribe("ClientModuleLoad", SQLLoad)