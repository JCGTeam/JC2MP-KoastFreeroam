class 'GameModesMenu'

function GameModesMenu:__init()
    Network:Subscribe("GoTron", self, self.GoTron)
    Network:Subscribe("GoKHill", self, self.GoKHill)
    Network:Subscribe("GoDerby", self, self.GoDerby)
    Network:Subscribe("GoPong", self, self.GoPong)
    Network:Subscribe("LeavePong", self, self.LeavePong)
end

function GameModesMenu:GoTron(args, sender)
    Events:Fire("PlayerChat", {player = sender, text = "/tron"})
end

function GameModesMenu:GoKHill(args, sender)
    Events:Fire("PlayerChat", {player = sender, text = "/khill"})
end

function GameModesMenu:GoDerby(args, sender)
    Events:Fire("PlayerChat", {player = sender, text = "/derby"})
end

function GameModesMenu:GoPong(args, sender)
    Events:Fire("PlayerChat", {player = sender, text = "/pong Medium"})
end

function GameModesMenu:LeavePong(args, sender)
    Events:Fire("PlayerChat", {player = sender, text = "/pong exit"})
end

local gamemodesmenu = GameModesMenu()