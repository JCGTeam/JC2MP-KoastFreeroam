class 'OpenGates'

function OpenGates:__init()
    self.places = {}

    self:LoadPlaces("places.txt")

    self.tag_clr = Color.White
    self.text_clr = Color.DarkGray

    Events:Subscribe("ClientModuleLoad", self, self.ClientModuleLoad)
    Network:Subscribe("GetPlayers", self, self.GetPlayers)
end

function OpenGates:LoadPlaces(filename)
    print("Opening " .. filename)
    local file = io.open(filename, "r")

    if file == nil then
        print("No places.txt, aborting loading of places")
        return
    end

    local timer = Timer()

    for line in file:lines() do
        self:ParsePlace(line)
    end

    print(string.format("Loaded places, %.02f seconds", timer:GetSeconds()))

    timer = nil
    file:close()
end

function OpenGates:ParsePlace(line)
    line = line:gsub(" ", "")

    local tokens = line:split(",")
    local pos_str = {tokens[1], tokens[2], tokens[3]}
    local vector = Vector3(tonumber(pos_str[1]), tonumber(pos_str[2]), tonumber(pos_str[3]))

    self.places[tokens[1]] = vector

    table.insert(self.places, {line, vector})
end

function OpenGates:ClientModuleLoad(args)
    Network:Send(args.player, "Places", self.places)
end

function OpenGates:GetPlayers(args, sender)
    local sName = sender:GetName()
    local sPos = sender:GetPosition()
    local maxDist = 50
    local tag_clr = self.tag_clr

    for p in Server:GetPlayers() do
        local dist = sPos:Distance(p:GetPosition())

        if dist < maxDist then
            Network:Send(p, "OpenDoors")

            local pLang = p:GetValue("Lang")
            Chat:Send(p, pLang == "EN" and "[Gates] " or "[Ворота] ", tag_clr, sName .. (pLang == "EN" and " opened the gates" or " открыл ворота"), self.text_clr)
        end
    end
end

local opengates = OpenGates()