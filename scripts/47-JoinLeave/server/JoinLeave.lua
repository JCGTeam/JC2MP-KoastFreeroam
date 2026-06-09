class 'JoinLeave'

function JoinLeave:__init()
    self.languageslist = {
        ["RU"] = true,
        ["UK"] = true,
        ["BY"] = true,
        ["KZ"] = true,
        ["MD"] = true,
        ["ZZ"] = true
    }

    self.db_ip = {}

    self:LoadDatabaseIP("server/dbip-country-lite.csv")

    Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
    Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
    Events:Subscribe("SetJoinNotice", self, self.SetJoinNotice)
end

function JoinLeave:IPToNumber(ip)
    local o1, o2, o3, o4 = ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")

    if o1 then
        return tonumber(o1) * 16777216 + tonumber(o2) * 65536 + tonumber(o3) * 256 + tonumber(o4)
    end

    return 0
end

function JoinLeave:LoadDatabaseIP(filename)
    local file = io.open(filename, "r")

    if not file then
        print("File " .. filename .. " not found")
        return
    end

    local timer = Timer()

    self.db_ip = {}

    for line in file:lines() do
        line = line:gsub('"', '')

        local o1, o2, o3, o4, o5, o6, o7, o8, country = line:match('^(%d+)%.(%d+)%.(%d+)%.(%d+),(%d+)%.(%d+)%.(%d+)%.(%d+),([^,%s]+)')

        if o1 and o5 and country then
            table.insert(self.db_ip, {
                start_num = tonumber(o1) * 16777216 + tonumber(o2) * 65536 + tonumber(o3) * 256 + tonumber(o4),
                end_num = tonumber(o5) * 16777216 + tonumber(o6) * 65536 + tonumber(o7) * 256 + tonumber(o8),
                country = country
            })
        end
    end

    file:close()
    print(string.format("Loaded %d IPv4 ranges in %.02f seconds", #self.db_ip, timer:GetSeconds()))
end

function JoinLeave:LookupCountry(ipNum)
    local low = 1
    local high = #self.db_ip

    while low <= high do
        local mid = math.floor((low + high) / 2)
        local range = self.db_ip[mid]

        if ipNum >= range.start_num and ipNum <= range.end_num then
            return range.country
        elseif ipNum < range.start_num then
            high = mid - 1
        else
            low = mid + 1
        end
    end

    return "ZZ"
end

function JoinLeave:PlayerJoin(args)
    local pIP = args.player:GetIP()

    args.player:SetNetworkValue("Country", self:LookupCountry(self:IPToNumber(pIP)))
    args.player:SetNetworkValue("GameMode", "FREEROAM")

    Network:Broadcast("PlayerJoin", {player = args.player})

    Events:Fire("ToDiscordConsole", {text = ">" .. args.player:GetName() .. " joined to the server. |" .. " SteamID: " .. tostring(args.player:GetSteamId()) .. " IP: " .. tostring(pIP)})

    local pcountry = args.player:GetValue("Country")

    local text_clr = Color.White
    local text2_clr = Color.DarkGray

    local languageslist = self.languageslist

    if languageslist[pcountry] then
        Chat:Send(args.player, "Добро пожаловать на Koast Freeroam! Приятной игры :3", Color(185, 215, 255))
    else
        Chat:Send(args.player, "Welcome to Koast Freeroam! Have a good game :3", Color(185, 215, 255))
    end

    if self.joinNotice then
        Chat:Send(args.player, languageslist[pcountry] and "[Объявление] " or "[Notice] ", Color(255, 210, 0), self.joinNotice, Color.White)
    end
end

function JoinLeave:PlayerQuit(args)
    Network:Broadcast("PlayerQuit", {player = args.player})

    Events:Fire("ToDiscordConsole", {text = ">" .. args.player:GetName() .. " left the server."})
end

function JoinLeave:SetJoinNotice(text)
    self.joinNotice = text
end

local joinLeave = JoinLeave()