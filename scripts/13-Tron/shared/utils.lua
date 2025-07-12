class "Utils"

-- Returns an array of arguments split by whitespace unless an argument was between "an argument" within double-quotes
function Utils.GetArgs(string)
    local args = {}
    local quote = ""

    for arg in string.gmatch(string, "[%S]+") do
        if arg:sub(1, 1) == "\"" or #quote > 0 then
            quote = quote .. (#quote > 0 and " " or "") .. arg

            if arg:sub(-1) == "\"" then
                table.insert(args, quote:sub(2, -2))
                quote = ""
            end
        else
            table.insert(args, arg)
        end
    end

    for k, v in pairs(quote:split(" ")) do
        if #v > 0 then
            table.insert(args, v)
        end
    end

    return args
end

-- Finds a by either a username snippet or by ID and then executes a callback function; if no player was found then the target player is notified (or if nil, the console will contain a notice)
function Utils.FindPlayer(needle, player, callback)
    local target = nil

    if tonumber(needle) then
        target = Player.GetById(tonumber(needle[2]))
    else
        for k, v in pairs(Player.Match(needle)) do
            target = v
            break
        end
    end

    if target then
        callback(target)
    elseif tonumber(needle) then
        if player then
            player:SendChatMessage("Could not find a player with the ID  " .. needle .. "!", Color.Red)
        else
            print("Could not find a player with the ID  " .. needle .. "!")
        end
    else
        if player then
            player:SendChatMessage("Could not find a player with the name \"" .. needle .. "\"!", Color.Red)
        else
            print("Could not find a player with the name \"" .. needle .. "\"!")
        end
    end
end