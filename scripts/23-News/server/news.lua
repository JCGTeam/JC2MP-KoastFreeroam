class 'LoadNews'

function LoadNews:__init()
    Network:Subscribe("GetNews", self, self.GetNews)
end

function LoadNews:GetNews(args, sender)
    local file = io.open(args.file, "r")

    if file then
        local s = file:read("*a")

        if s then
            Network:Send(sender, "LoadNews", {text = s})
        end

        file:close()
        file = nil
    else
        Network:Send(sender, "LoadNews", {text = "LOAD ERROR\nNews file not found. Path: " .. args.file})
    end
end

local loadnews = LoadNews()