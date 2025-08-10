class 'Menu'

function Menu:__init()
    SQL:Execute("CREATE TABLE IF NOT EXISTS players_color (steamid VARCHAR UNIQUE, r INTEGER, g INTEGER, b INTEGER)")
    SQL:Execute("CREATE TABLE IF NOT EXISTS players_registered (steamid VARCHAR UNIQUE, registered INTEGER)")

    self.languageslist = {
        ["RU"] = true,
        ["UK"] = true,
        ["BY"] = true,
        ["KZ"] = true,
        ["MD"] = true,
        ["N/A"] = true
    }

    -- self.worlds = {}

    Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
    -- Events:Subscribe("ClientModuleLoad", self, self.ClientModuleLoad)

    Network:Subscribe("SetPlayerColor", self, self.SetPlayerColor)
    Network:Subscribe("SetFreeroam", self, self.SetFreeroam)
    Network:Subscribe("SetLang", self, self.SetLang)
    Network:Subscribe("Exit", self, self.Exit)
    Network:Subscribe("GoMenu", self, self.GoMenu)
end

function Menu:PlayerJoin(args)
    local qry = SQL:Query("select registered from players_registered where steamid = (?)")
    qry:Bind(1, args.player:GetSteamId().id)
    local result = qry:Execute()

    if #result > 0 then
        args.player:SetNetworkValue("Registered", tonumber(result[1].registered))
    end
end

function Menu:ClientModuleLoad(args)
    local pId = args.player:GetId()
    self.worlds[pId] = World.Create()
    self.worlds[pId]:SetTime(18)
    self.worlds[pId]:SetTimeStep(0)
    self.worlds[pId]:SetWeatherSeverity(0.6)

    args.player:SetWorld(self.worlds[pId])
    args.player:SetNetworkValue("GameMode", "Приветствие")
end

function Menu:SetPlayerColor(args, sender)
    local color = args.color
    local steamId = sender:GetSteamId().id

    local qry = SQL:Query('INSERT OR REPLACE INTO players_color (steamid, r, g, b) VALUES(?, ?, ?, ?)')
    qry:Bind(1, steamId)
    qry:Bind(2, color.r)
    qry:Bind(3, color.g)
    qry:Bind(4, color.b)
    qry:Execute()

    sender:SetColor(args.color)
end

function Menu:SetFreeroam(args, sender)
    --[[local pId = sender:GetId()
	if self.worlds[pId] then
		self.worlds[pId]:Remove()
		self.worlds[pId] = nil
	end]] --

    sender:SetNetworkValue("GameMode", "FREEROAM")
    sender:SetNetworkValue("Joined", true)

    if sender:GetValue("Registered") then return end

    sender:SetNetworkValue("Registered", 1)

    local cmd = SQL:Command("INSERT OR REPLACE INTO players_registered (steamid, registered) values (?, ?)")
    cmd:Bind(1, sender:GetSteamId().id)
    cmd:Bind(2, sender:GetValue("Registered"))
    cmd:Execute()
end

function Menu:SetLang(args, sender)
    if args.lang then
        sender:SetNetworkValue("Lang", args.lang)

        if args.lang == "RU" then
            if sender:GetValue("Country") and sender:GetValue("Country") == "N/A" then
                sender:SetNetworkValue("Country", "RU")
            end
        end
    end
end

function Menu:Exit(args, sender)
    sender:Kick()
end

function Menu:GoMenu(args, sender)
    Network:Send(sender, "BackMe")
end

local menu = Menu()