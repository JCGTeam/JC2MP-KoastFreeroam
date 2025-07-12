class 'Pong'

function Pong:__init()
    self.tag = "[Понг] "

    self.tag_clr = Color.White

    Events:Subscribe("PlayerChat", self, self.PlayerChat)

    Network:Subscribe("Win", self, self.Win)
end

function Pong:PlayerChat(args)
    local player = args.player
    local msg = args.text

    if string.sub(msg, 1, 1) ~= "/" then
        return true
    end

    local params = {}
    for param in string.gmatch(msg, "[^%s]+") do
        table.insert(params, param)
    end

    if params[1] == "/pong" then
        if params[2] and params[2] == "exit" or params[2] and params[2] == "leave" then
            Network:Send(player, "StartUp", {value = 1})
            return false
        end

        if not params[2] then
            Chat:Send(player, self.tag, self.tag_clr, "Используйте /pong <сложность>", Color(185, 215, 255))
            Chat:Send(player, self.tag, self.tag_clr, "Сложности: Noob, Easy, Medium, Hard, Extreme", Color(165, 165, 165))
            return false
        end

        params[2] = params[2]:lower()
        Network:Send(player, "StartUp", {value = 2, cparams = params})
    end
end

function Pong:Win(args, sender)
    sender:SetNetworkValue("PongWinsCount", (sender:GetValue("PongWinsCount") or 0) + 1)

    sender:SetMoney(sender:GetMoney() + 5)
end

local pong = Pong()