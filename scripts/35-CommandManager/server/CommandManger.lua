class "CommandManager"

function CommandManager:__init()
    Events:Subscribe("PlayerChat", self, self.PlayerChat)
end

function CommandManager:PlayerChat(args)
    if args.text:sub(1, 1) ~= '/' then
        return true
    end

    -- print(args.player:GetName() .. " " .. args.text)
    return false
end

local commandmanager = CommandManager()