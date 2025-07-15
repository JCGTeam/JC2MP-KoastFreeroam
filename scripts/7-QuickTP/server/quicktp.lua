--
spawnFile = "spawns.txt"
seperator = "," -- Seperator sign(s), this string can only used for value seperation in the spawnFile
spawnHeight = 200
spawnRandomize = Vector3(100, 100, 100)

restrictedToMain = true
restrictedMessage = "Вы не можете использовать телепорт здесь!"

--

collection = nil
quickList = {}

QuickTP = function(args, player)
    if restrictedToMain and player:GetWorld() ~= DefaultWorld then
        player:SendChatMessage("[Телепорт] ", Color.White, restrictedMessage, Color(255, 0, 0))
        return
    end

    if args.target then
        Chat:Send(player, "[Телепорт] ", Color.White, "Вы телепортировались на " .. args.target, Color.DarkGray)
    end

    item = quickList[args.target]
    if item == nil then return end

    local vehicle = player:GetVehicle()
    local offset = Vector3((math.random() - 0.5) * item.randomize.x, (math.random() - 0.5) * item.randomize.y + item.height, (math.random() - 0.5) * item.randomize.z)

    Network:SendNearby(player, "WarpDoPoof", player:GetPosition())
    player:SetPosition(item.position + offset)

    if args.button == 2 and vehicle then
        vehicle:Teleport(player:GetPosition(), vehicle:GetAngle())
        player:EnterVehicle(vehicle, 0)
    end
end
Network:Subscribe("QuickTP", QuickTP)

SendTPList = function(args, player)
    if collection == nil then return end

    Network:Send(player, "TPList", collection.name)
end
Network:Subscribe("RequestTPList", SendTPList)

--

class 'TPItem'

function TPItem:__init(group, line)
    self.height = group.height
    self.randomize = group.randomize

    if line then
        self:Parse(line)
    end
end

function TPItem:Parse(line)
    local values = line:sub(3):split(seperator)

    self.name = values[1]
    self.position = Vector3(tonumber(values[2]), tonumber(values[3]), tonumber(values[4]))
end

--

class 'TPGroup'

function TPGroup:__init(parent, line)
    self.parent = parent
    self.entrys = {}

    if line then
        self:Parse(line)
    end
end

function TPGroup:Parse(line)
    local values = line:sub(3):split(seperator)

    self.name = values[1]
    self.height = #values < 2 and self.parent.height or values[2]
    self.randomize = #values < 5 and self.parent.randomize or Vector3(tonumber(values[3]), tonumber(values[4]), tonumber(values[5]))
end

function TPGroup:Close()
    self.name = {self.name}

    for i = 1, #self.entrys, 1 do
        table.insert(self.name, self.entrys[i].name)
    end
end

--

LoadTeleports = function(filename)
    local file = io.open(filename, "r")

    if file == nil then
        print(filename .. " not found!")
        return
    end

    collection = TPGroup()
    collection.name = "main"
    collection.height = spawnHeight
    collection.randomize = spawnRandomize

    for line in file:lines() do
        line = line:gsub("\t", ""):match '^%s*(.*)'
        if line:sub(1, 2) == "T " then
            item = TPItem(collection, line)
            quickList[item.name] = item
            table.insert(collection.entrys, item)
        elseif line:gsub(" ", ""):sub(1, 6) == "GCLOSE" then
            if collection.parent == nil then break end
            collection:Close()
            collection = collection.parent
        elseif line:sub(1, 2) == "G " then
            item = TPGroup(collection, line)
            table.insert(collection.entrys, item)
            collection = item
        end
    end

    while collection.parent do
        collection:Close()
        collection = collection.parent
    end

    collection:Close()
    file:close()
end

LoadTeleports(spawnFile)